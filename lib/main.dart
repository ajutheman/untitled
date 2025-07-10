import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'HomeScreen.dart';
import 'LoginScreen.dart';
import 'OtpScreen.dart';
import 'firebase_options.dart';
import 'auth_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance?.resamplingEnabled = true; // optional workaround
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    BlocProvider(
      create: (_) => AuthBloc()..add(CheckAuthStatus()),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else if (state is Authenticated) {
            return HomeScreen();
          } else if (state is AuthCodeSent) {
            return OtpScreen(verificationId: state.verificationId);
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
