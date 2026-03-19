import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/locale_service.dart';
import '../../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegisterMode = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final bloc = context.read<AuthBloc>();
    if (_isRegisterMode) {
      bloc.add(
        AuthRegisterRequested(
          email: _emailController.text,
          password: _passwordController.text,
          displayName: _nameController.text,
        ),
      );
      return;
    }
    bloc.add(
      AuthSignInRequested(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.failure && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
        }
        if (state.status == AuthStatus.authenticated) {
          final isGuest = state.user?.uid == 'guest';
          final route = (isGuest || state.user?.partnerUid != null)
              ? AppRoutes.home
              : AppRoutes.partnerLink;
          Get.offAllNamed(route);
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sync',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Gap(8),
                          Text(
                            _isRegisterMode
                                ? l.tr(
                                    'Create a new account and link your partner.',
                                    'Yeni hesap olusturup partnerinizi baglayin.')
                                : l.tr(
                                    'Log in for mood sharing and micro advice.',
                                    'Mood paylasimi ve mikro tavsiyeler icin giris yapin.'),
                          ),
                          const Gap(24),
                          if (_isRegisterMode) ...[
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: l.tr('Display name', 'Gorunen ad'),
                              ),
                              validator: (value) {
                                if (!_isRegisterMode) {
                                  return null;
                                }
                                if (value == null || value.trim().isEmpty) {
                                  return l.tr('Name is required', 'Ad gerekli');
                                }
                                return null;
                              },
                            ),
                            const Gap(16),
                          ],
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                                labelText: l.tr('Email', 'E-posta')),
                            validator: (value) {
                              if (value == null || !value.contains('@')) {
                                return l.tr('Enter a valid email',
                                    'Gecerli bir e-posta girin');
                              }
                              return null;
                            },
                          ),
                          const Gap(16),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                                labelText: l.tr('Password', 'Sifre')),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return l.tr('At least 6 characters required',
                                    'En az 6 karakter gerekli');
                              }
                              return null;
                            },
                          ),
                          const Gap(24),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: state.status == AuthStatus.loading
                                      ? null
                                      : _submit,
                                  child: Text(
                                    state.status == AuthStatus.loading
                                        ? l.tr('Processing...', 'Isleniyor...')
                                        : (_isRegisterMode
                                            ? l.tr('Sign Up', 'Kayit ol')
                                            : l.tr('Log In', 'Giris yap')),
                                  ),
                                ),
                              );
                            },
                          ),
                          const Gap(12),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isRegisterMode = !_isRegisterMode;
                              });
                            },
                            child: Text(
                              _isRegisterMode
                                  ? l.tr('Already have an account? Log in',
                                      'Zaten hesabin var mi? Giris yap')
                                  : l.tr('Need a new account? Sign up',
                                      'Yeni hesap mi gerekiyor? Kayit ol'),
                            ),
                          ),
                          const Gap(8),
                          const Divider(),
                          const Gap(8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                context
                                    .read<AuthBloc>()
                                    .add(const AuthGuestLoginRequested());
                              },
                              icon: const Icon(Icons.person_outline),
                              label: Text(l.tr('Continue as Guest',
                                  'Misafir olarak devam et')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
