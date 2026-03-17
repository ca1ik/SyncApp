part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthSignInRequested extends AuthEvent {
  const AuthSignInRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  final String email;
  final String password;
  final String displayName;

  @override
  List<Object?> get props => [email, password, displayName];
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthPartnerLinkRequested extends AuthEvent {
  const AuthPartnerLinkRequested(this.partnerEmail);

  final String partnerEmail;

  @override
  List<Object?> get props => [partnerEmail];
}

class _AuthSessionChanged extends AuthEvent {
  const _AuthSessionChanged(this.user);

  final UserModel? user;

  @override
  List<Object?> get props => [user];
}
