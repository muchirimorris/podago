import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:podago/providers/theme_provider.dart';

import 'firebase_options.dart';

import 'package:podago/screens/auth/login_screen.dart';
import 'package:podago/screens/auth/role_selection_screen.dart';
import 'package:podago/screens/farmer/dashboard_farmer.dart';
import 'package:podago/screens/collector/dashboard_collector.dart';
import 'package:podago/widgets/notification_manager.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:podago/services/simple_storage_service.dart';
import 'package:podago/utils/app_theme.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PodagoApp());
}




class PodagoApp extends StatelessWidget {
  const PodagoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Podago',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late Future<Map<String, dynamic>?> _sessionFuture;

  @override
  void initState() {
    super.initState();
    _sessionFuture = _checkLocalSession();
  }

  // Returns session data: { 'role': '...', 'userId': '...', 'authType': '...' } or null
  Future<Map<String, dynamic>?> _checkLocalSession() async {
    debugPrint('🕵️ Checking local session...');
    final localSession = await SimpleStorageService.getUserSession();

    if (localSession != null &&
        await SimpleStorageService.hasValidSession()) {
      return {
        'role': localSession['role'],
        'userId': localSession['userId'],
        'authType': localSession['authType'],
      };
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();

        if (doc.exists) {
          final role = doc.data()?['role'];
          
          // Re-save session for consistency
          await SimpleStorageService.saveFirebaseSession(
              userId: firebaseUser.uid,
              userEmail: firebaseUser.email ?? '',
              role: role ?? 'farmer',
            );

          return {
            'role': role,
            'userId': firebaseUser.uid,
            'authType': 'firebase',
          };
        }
      } catch (e) {
        debugPrint('❌ Firestore error: $e');
      }
    }

    return null; // No valid session
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _sessionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        final session = snapshot.data;
        
        if (session != null) {
          final role = session['role'];
          final userId = session['userId'];
          final authType = session['authType'];

          if (role == 'collector') {
            return NotificationManager(
              key: const ValueKey('collector_manager'), // Stable Key
              userId: userId, 
              child: const CollectorDashboard()
            );
          } else if (role == 'farmer') {
             return NotificationManager(
              key: const ValueKey('farmer_manager'), // Stable Key
              userId: userId, 
              child: FarmerDashboard(farmerId: userId)
            );
          }
        }
        
        return const RoleSelectionScreen();
      },
    );
  }
}
