import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/locale_service.dart';
import '../../bloc/auth_bloc.dart';

class PartnerLinkPage extends StatefulWidget {
  const PartnerLinkPage({super.key});

  @override
  State<PartnerLinkPage> createState() => _PartnerLinkPageState();
}

class _PartnerLinkPageState extends State<PartnerLinkPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.user != current.user || previous.status != current.status,
      listener: (context, state) {
        if (state.status == AuthStatus.failure && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!)),
          );
        }
        if (state.user?.partnerUid != null) {
          Get.offAllNamed(AppRoutes.home);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l.tr('Link Partner', 'Partner bagla'))),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.tr('Complete Matching', 'Eslesmeyi tamamla'),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Gap(12),
                      Text(
                        l.tr(
                            'Enter the email address your partner registered with. The system will link both accounts locally.',
                            'Partnerinizin daha once kayit oldugu e-posta adresini girin. Sistem iki hesabi yerel olarak baglayacak.'),
                        style: theme.textTheme.bodyLarge,
                      ),
                      const Gap(24),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: l.tr('Partner email', 'Partner e-posta'),
                        ),
                      ),
                      const Gap(20),
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: state.status == AuthStatus.loading
                                  ? null
                                  : () {
                                      context.read<AuthBloc>().add(
                                            AuthPartnerLinkRequested(
                                              _emailController.text.trim(),
                                            ),
                                          );
                                    },
                              child: Text(
                                state.status == AuthStatus.loading
                                    ? l.tr('Connecting...', 'Baglaniyor...')
                                    : l.tr('Link Partner', 'Partneri bagla'),
                              ),
                            ),
                          );
                        },
                      ),
                      const Gap(8),
                      TextButton(
                        onPressed: () => Get.offAllNamed(AppRoutes.home),
                        child: Text(l.tr('Skip for now', 'Simdilik gec')),
                      ),
                    ],
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
