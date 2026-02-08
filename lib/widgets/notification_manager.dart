import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationManager extends StatefulWidget {
  final String userId;
  final Widget child;

  const NotificationManager({
    super.key,
    required this.userId,
    required this.child,
  });

  @override
  State<NotificationManager> createState() => _NotificationManagerState();
}

class _NotificationManagerState extends State<NotificationManager> {
  @override
  void initState() {
    super.initState();
    // Start listening for notifications globally
    print("🔔 NotificationManager: Init for user '${widget.userId}'");
    if (widget.userId.isNotEmpty) {
      NotificationService().startListening(widget.userId);
    } else {
      print("🔔 NotificationManager: WARNING - UserId is empty/null in initState!");
    }
  }

  @override
  void didUpdateWidget(covariant NotificationManager oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.userId != oldWidget.userId) {
      print("🔔 NotificationManager: User changed from '${oldWidget.userId}' to '${widget.userId}'");
      // User changed, restart listener
      if (widget.userId.isNotEmpty) {
        NotificationService().startListening(widget.userId);
      } else {
        NotificationService().stopListening();
      }
    }
  }

  @override
  void dispose() {
    // Keep listening even if this widget is disposed (navigation)
    // Listener will be stopped explicitly on Logout.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
