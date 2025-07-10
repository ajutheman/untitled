abstract class AuthEvent {}

class GoogleLoginRequested extends AuthEvent {}

class PhoneLoginRequested extends AuthEvent {
  final String phoneNumber;
  PhoneLoginRequested(this.phoneNumber);
}

class OtpVerificationRequested extends AuthEvent {
  final String verificationId;
  final String otp;
  OtpVerificationRequested(this.verificationId, this.otp);
}

class CheckAuthStatus extends AuthEvent {}

class LogoutRequested extends AuthEvent {}
