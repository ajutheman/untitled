import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_bloc.dart';
import 'auth_event.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _fcmToken;
  GoogleSignInAccount? _user;

  @override
  void initState() {
    super.initState();
    _fetchFCMToken();
    _fetchGoogleUser();
  }

  Future<void> _fetchFCMToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      setState(() {
        _fcmToken = token;
      });
      print('🔐 FCM Token: $token');
    } catch (e) {
      print('❌ Error fetching FCM token: $e');
    }
  }

  Future<void> _fetchGoogleUser() async {
    try {
      final googleUser = await GoogleSignIn().signInSilently(); // Silent reauth
      if (googleUser != null) {
        setState(() {
          _user = googleUser;
        });
        print('👤 Google User: ${googleUser.displayName}, ${googleUser.email}');
      }
    } catch (e) {
      print('❌ Error fetching Google user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text("You're logged in!", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              if (_user != null) ...[
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(_user!.photoUrl ?? ""),
                ),
                const SizedBox(height: 8),
                Text("Name: ${_user!.displayName ?? ''}"),
                Text("Email: ${_user!.email}"),
              ],
              const SizedBox(height: 20),
              if (_fcmToken != null)
                SelectableText(
                  "FCM Token:\n$_fcmToken",
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
