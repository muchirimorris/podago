import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';
import '../services/simple_storage_service.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Singleton Pattern
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal() {
    _initLocalNotifications();
  }

  // Subscription management
  StreamSubscription<QuerySnapshot>? _subscription;
  String? _listeningUserId;

  // Initialize Local Notifications
  Future<void> _initLocalNotifications() async {
    print("🔔 NotificationService: Initializing...");
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidSettings);
      
      final bool? initialized = await _localNotifications.initialize(initSettings);
      print("🔔 NotificationService: Plugin initialized: $initialized");
      
      // Request Permission (Android 13+)
      if (await Permission.notification.isDenied) {
        print("🔔 NotificationService: Requesting notification permission...");
        final status = await Permission.notification.request();
        print("🔔 NotificationService: Permission status: $status");
      } else {
        print("🔔 NotificationService: Notification permission already granted.");
      }
      
    } catch (e) {
      print("🔔 NotificationService: CRITICAL INITIALIZATION FAILURE: $e");
    }
  }

  // Show "Pop" Notification
  Future<void> _showPopNotification(NotificationModel note) async {
    const androidDetails = AndroidNotificationDetails(
      'podago_channel_high', 'Podago Alerts', // KEEP NEW CHANNEL ID
      channelDescription: 'Important notifications for Podago',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
    const details = NotificationDetails(android: androidDetails);
    
    try {
      print("🔔 NotificationService: Attempting to show notification ID: ${note.id}, Title: ${note.title}");
      await _localNotifications.show(
        note.hashCode, // Unique ID
        note.title,
        note.body,
        details,
      );
      print("🔔 NotificationService: Display command sent successfully via LocalNotificationsPlugin");
    } catch (e) {
      print("🔔 NotificationService: FAILED to show notification: $e");
    }
  }

  // Keep track of notified IDs to avoid spamming
  final Set<String> _notifiedIds = {};

  // --- NEW: Global Listener ---
  void startListening(String userId) {
    if (userId.isEmpty) {
      print("🔔 NotificationService: Cannot listen - User ID is empty!");
      return;
    }

    if (_listeningUserId == userId && _subscription != null) {
      print("🔔 NotificationService: Already listening for $userId");
      return; 
    }

    // Cancel existing if user changed (unlikely but safe)
    stopListening();

    _listeningUserId = userId;
    
    print("🔔 NotificationService: STARTING STREAM for user $userId");

    try {
      _subscription = _db
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
        print("🔔 NotificationService: Stream received event. Docs count: ${snapshot.docs.length}");
        
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            try {
              final note = NotificationModel.fromFirestore(change.doc);
              print("🔔 NotificationService: New Notification Detected: ${note.id}, Title: ${note.title}, CreatedAt: ${note.createdAt}");
              
              if (!_notifiedIds.contains(note.id)) {
                // Check age to avoid popping old unreads on initial load
                // (Latency: allow 5 mins)
                final age = DateTime.now().difference(note.createdAt);
                print("🔔 NotificationService: Notification Age: ${age.inMinutes} minutes");

                if (age.inMinutes < 5) {
                  _showPopNotification(note);
                  _notifiedIds.add(note.id);
                } else {
                  print("🔔 NotificationService: Notification too old to pop (> 5 mins)");
                }
              } else {
                print("🔔 NotificationService: Already notified for ${note.id}, skipping.");
              }
            } catch (e) {
              print("🔔 NotificationService: Error parsing notification doc: $e");
            }
          }
        }
      }, onError: (error) {
        print("🔔 NotificationService: STREAM ERROR: $error");
        // Often happens if index is missing. Check log for URL!
      });
      
      print("🔔 NotificationService: Stream subscription established.");
      
    } catch (e) {
      print("🔔 NotificationService: Failed to setup stream: $e");
    }
  }

  void stopListening() {
    if (_subscription != null) {
      _subscription?.cancel();
      _subscription = null;
      _listeningUserId = null;
      print("🔕 NotificationService: Stopped listening");
    }
  }

  // --- Data Streams (Pure, No Side Effects) ---

  // Stream of notifications for the current user
  Stream<List<NotificationModel>> getUserNotifications() async* {
    final session = await SimpleStorageService.getUserSession();
    final userId = session?['userId'];

    if (userId == null) {
      yield [];
      return;
    }

    // Wrap in try-catch logic isn't direct for async*, but we can handle errors in the listen
    // However, for async* we usually rely on the stream consumer to handle generic errors.
    // But we can add print debugging here.
    print("🔔 NotificationService: getUserNotifications stream requested for $userId");

    yield* _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList();
          
          docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return docs;
        })
        .handleError((e) {
          print("🔔 NotificationService: getUserNotifications STREAM ERROR: $e");
          throw e; // Re-throw to UI
        });
  }

  // Count unread notifications
  Stream<int> getUnreadCount() async* {
    final session = await SimpleStorageService.getUserSession();
    final userId = session?['userId'];

    if (userId == null) {
      yield 0;
      return;
    }

    yield* _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length)
        .handleError((e) {
          print("🔔 NotificationService: getUnreadCount STREAM ERROR: $e");
          return 0;
        });
  }

  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
      print("🔔 NotificationService: Marked $notificationId as read");
    } catch (e) {
      print("Error marking notification as read: $e");
    }
  }

  // Mark ALL as read
  Future<void> markAllAsRead() async {
    final session = await SimpleStorageService.getUserSession();
    final userId = session?['userId'];

    if (userId == null) return;

    final batch = _db.batch();
    final unreadDocs = await _db
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in unreadDocs.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
    print("🔔 NotificationService: Marked ALL as read for $userId");
  }
}
