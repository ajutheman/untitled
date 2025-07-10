import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(); // ✅ Classic constructor

  AuthBloc() : super(AuthInitial()) {
    on<GoogleLoginRequested>(_googleLogin);
    on<PhoneLoginRequested>(_phoneLogin);
    on<OtpVerificationRequested>(_verifyOtp);
    on<CheckAuthStatus>(_checkStatus);
    on<LogoutRequested>(_logout);
  }

  Future<void> _googleLogin(GoogleLoginRequested event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        emit(AuthError("User cancelled Google sign-in"));
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      emit(Authenticated(userCredential.user!.uid));
    } catch (e) {
      emit(AuthError("Google Sign-In Failed: ${e.toString()}"));
    }
  }

  Future<void> _phoneLogin(PhoneLoginRequested event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());

      await _auth.verifyPhoneNumber(
        phoneNumber: event.phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          final userCredential = await _auth.signInWithCredential(credential);
          emit(Authenticated(userCredential.user!.uid));
        },
        verificationFailed: (FirebaseAuthException e) {
          emit(AuthError(e.message ?? "Phone verification failed"));
        },
        codeSent: (String verificationId, int? resendToken) {
          emit(AuthCodeSent(verificationId));
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      emit(AuthError("Phone Login Failed: ${e.toString()}"));
    }
  }

  Future<void> _verifyOtp(OtpVerificationRequested event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());

      final credential = PhoneAuthProvider.credential(
        verificationId: event.verificationId,
        smsCode: event.otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      emit(Authenticated(userCredential.user!.uid));
    } catch (e) {
      emit(AuthError("OTP Verification Failed: ${e.toString()}"));
    }
  }

  Future<void> _checkStatus(CheckAuthStatus event, Emitter<AuthState> emit) async {
    final user = _auth.currentUser;
    emit(user != null ? Authenticated(user.uid) : AuthInitial());
  }

  Future<void> _logout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _auth.signOut();
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    emit(AuthInitial());
  }
}
