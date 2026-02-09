import 'package:flutter/material.dart';
import 'package:podago/screens/farmer/dashboard_farmer.dart';
import 'package:podago/screens/collector/dashboard_collector.dart';
import 'package:podago/screens/farmer/history_farmer.dart';
import 'package:podago/screens/collector/history_collector.dart';
import 'package:podago/screens/farmer/tips_farmer.dart';
import 'package:podago/screens/collector/tips_collector.dart';
import 'package:podago/screens/farmer/support_farmer.dart';
import 'package:podago/screens/collector/support_collector.dart';
import 'package:podago/screens/farmer/reports_farmer.dart';
import 'package:podago/services/chat_service.dart'; // NEW import

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final String role; // "farmer" or "collector"
  final String? farmerId; // Only needed if role == farmer
  final String? collectorId; // Only needed if role == collector

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.role,
    this.farmerId,
    this.collectorId,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return; // Already on this page

    Widget destination;

    if (role == "farmer") {
      switch (index) {
        case 0:
          destination = FarmerDashboard(farmerId: farmerId!);
          break;
        case 1:
          destination = FarmerHistoryScreen(farmerId: farmerId!);
          break;
        case 2:
          destination = FarmerTipsScreen(farmerId: farmerId!);
          break;
        case 3:
          destination = FarmerReportsScreen(farmerId: farmerId!);
          break;
        case 4:
          destination = FarmerSupportScreen(farmerId: farmerId!);
          break;
        default:
          return;
      }
    } else {
      // Collector Navigation
      switch (index) {
        case 0:
          destination = const CollectorDashboard();
          break;
        case 1:
          destination = CollectorHistoryScreen(collectorId: collectorId);
          break;
        case 2:
          destination = CollectorTipsScreen(collectorId: collectorId);
          break;
        case 3:
          destination = CollectorSupportScreen(collectorId: collectorId);
          break;
        default:
          return;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: (role == "farmer" && farmerId != null) 
          ? ChatService().getUserUnreadCount(farmerId!) 
          : (role == "collector" && collectorId != null)
              ? ChatService().getUserUnreadCount(collectorId!)
              : Stream.value(0),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;
        List<BottomNavigationBarItem> items;

        // Custom function to build BottomNavigationBarItem with potential badge
        BottomNavigationBarItem _buildItem(IconData icon, String label, bool isSupport) {
          if (isSupport && unreadCount > 0) {
            return BottomNavigationBarItem(
              icon: Stack(
                children: [
                  Icon(icon),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: Text(
                        '$unreadCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
              label: label,
            );
          }
          return BottomNavigationBarItem(icon: Icon(icon), label: label);
        }

        if (role == "farmer") {
          items = [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            const BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
            const BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: "Tips"),
            const BottomNavigationBarItem(icon: Icon(Icons.analytics), label: "Reports"),
            _buildItem(Icons.headset_mic, "Support", true),
          ];
        } else {
          items = [
            const BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            const BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
            const BottomNavigationBarItem(icon: Icon(Icons.lightbulb), label: "Tips"),
            _buildItem(Icons.headset_mic, "Support", true),
          ];
        }

        return BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(context, index),
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: items,
        );
      }
    );
  }
}
