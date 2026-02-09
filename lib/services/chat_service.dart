import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of messages for a specific chat
  Stream<QuerySnapshot> getMessages(String userId) {
    return _firestore
        .collection('chats')
        .doc(userId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Stream of unread count for the user (listening to chat metadata)
  Stream<int> getUserUnreadCount(String userId) {
    return _firestore.collection('chats').doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) return 0;
      return (snapshot.data()?['userUnreadCount'] ?? 0) as int;
    });
  }

  // Send a message
  Future<void> sendMessage({
    required String senderId,
    required String receiverId, // 'admin' for user-to-admin
    required String message,
    required String senderName,
    required String senderRole,
  }) async {
    try {
      final timestamp = FieldValue.serverTimestamp();
      
      String chatDocId = senderRole == 'admin' ? receiverId : senderId;

      // 1. Add message to subcollection
      await _firestore
          .collection('chats')
          .doc(chatDocId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'text': message,
        'timestamp': timestamp,
        'isRead': false,
      });

      // 2. Update chat metadata
      // If Im user, I increase admin's unreadCount (which is just 'unreadCount')
      // If Im admin, I increase 'userUnreadCount'
      
      Map<String, dynamic> updateData = {
        'userId': chatDocId,
        'userName': senderName, 
        'userRole': senderRole == 'admin' ? 'user' : senderRole,
        'lastMessage': message,
        'lastMessageTime': timestamp,
      };
      
      if (senderRole == 'admin') {
         updateData['userUnreadCount'] = FieldValue.increment(1);
      } else {
         updateData['unreadCount'] = FieldValue.increment(1);
      }

      await _firestore.collection('chats').doc(chatDocId).set(updateData, SetOptions(merge: true));

    } catch (e) {
      if (kDebugMode) {
        print("Error sending message: $e");
      }
      rethrow;
    }
  }

  // Mark messages as read (User Side)
  Future<void> markMessagesAsRead(String userId) async {
    try {
      // User is opening the chat, so we reset 'userUnreadCount'
      await _firestore.collection('chats').doc(userId).update({
        'userUnreadCount': 0,
      });
    } catch (e) {
      print("Error marking as read: $e");
    }
  }
}
