import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_bloc.dart';
import 'auth_event.dart';

class OtpScreen extends StatelessWidget {
  final String verificationId;
  final otpController = TextEditingController();

  OtpScreen({required this.verificationId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter OTP')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              decoration: const InputDecoration(hintText: 'Enter OTP'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(
                  OtpVerificationRequested(verificationId, otpController.text),
                );
              },
              child: const Text('Verify'),
            ),
          ],
        ),
      ),
    );
  }
}
