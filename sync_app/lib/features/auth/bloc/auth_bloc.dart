import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

part 'auth_bloc_events.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.message,
  });

  final AuthStatus status;
  final UserModel? user;
  final String? message;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? message,
    bool clearMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, user, message];
}

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignInRequested>(_onSignInRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthSignOutRequested>(_onSignOutRequested);
    on<AuthGuestLoginRequested>(_onGuestLoginRequested);
    on<AuthPartnerLinkRequested>(_onPartnerLinkRequested);
    on<_AuthSessionChanged>(_onSessionChanged);

    _authSubscription = _authRepository.authStateChanges.listen(
      (user) => add(_AuthSessionChanged(user)),
    );
  }

  final AuthRepository _authRepository;
  StreamSubscription<UserModel?>? _authSubscription;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final user = await _authRepository.getCurrentUserProfile();
    if (user == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
      return;
    }
    emit(state.copyWith(status: AuthStatus.authenticated, user: user));
  }

  Future<void> _onSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    try {
      final user = await _authRepository.signInWithEmail(
        email: event.email.trim(),
        password: event.password,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: error.message,
        ),
      );
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    try {
      final user = await _authRepository.registerWithEmail(
        email: event.email.trim(),
        password: event.password,
        displayName:
            event.displayName.trim().isEmpty ? null : event.displayName.trim(),
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: error.message,
        ),
      );
    }
  }

  Future<void> _onSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.signOut();
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }

  Future<void> _onGuestLoginRequested(
    AuthGuestLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    final user = await _authRepository.signInAsGuest();
    emit(state.copyWith(status: AuthStatus.authenticated, user: user));
  }

  Future<void> _onPartnerLinkRequested(
    AuthPartnerLinkRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearMessage: true));
    try {
      final user = await _authRepository.linkPartnerByEmail(event.partnerEmail);
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on AuthException catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: error.message,
          user: state.user,
        ),
      );
    }
  }

  void _onSessionChanged(_AuthSessionChanged event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        status: event.user == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated,
        user: event.user,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
