import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_bloc.dart';
import 'auth_event.dart';

class LoginScreen extends StatelessWidget {
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(GoogleLoginRequested());
              },
              child: const Text('Sign in with Google'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(hintText: 'Enter phone number'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(PhoneLoginRequested(phoneController.text));
              },
              child: const Text('Send OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
