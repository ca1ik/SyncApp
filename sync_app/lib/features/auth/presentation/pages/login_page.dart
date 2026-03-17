import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../core/router/app_router.dart';
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
          final route = state.user?.partnerUid == null
              ? AppRoutes.partnerLink
              : AppRoutes.home;
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
                                ? 'Yeni hesap olusturup partnerinizi baglayin.'
                                : 'Mood paylasimi ve mikro tavsiyeler icin giris yapin.',
                          ),
                          const Gap(24),
                          if (_isRegisterMode) ...[
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Gorunen ad',
                              ),
                              validator: (value) {
                                if (!_isRegisterMode) {
                                  return null;
                                }
                                if (value == null || value.trim().isEmpty) {
                                  return 'Ad gerekli';
                                }
                                return null;
                              },
                            ),
                            const Gap(16),
                          ],
                          TextFormField(
                            controller: _emailController,
                            decoration:
                                const InputDecoration(labelText: 'E-posta'),
                            validator: (value) {
                              if (value == null || !value.contains('@')) {
                                return 'Gecerli bir e-posta girin';
                              }
                              return null;
                            },
                          ),
                          const Gap(16),
                          TextFormField(
                            controller: _passwordController,
                            decoration:
                                const InputDecoration(labelText: 'Sifre'),
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'En az 6 karakter gerekli';
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
                                        ? 'Isleniyor...'
                                        : (_isRegisterMode
                                            ? 'Kayit ol'
                                            : 'Giris yap'),
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
                                  ? 'Zaten hesabin var mi? Giris yap'
                                  : 'Yeni hesap mi gerekiyor? Kayit ol',
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
