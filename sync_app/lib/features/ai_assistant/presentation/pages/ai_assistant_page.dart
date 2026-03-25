import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

import '../../../../data/services/ai_assistant_service.dart';
import '../../../../core/services/locale_service.dart';
import '../../../subscription/cubit/subscription_cubit.dart';

class AiAssistantPage extends StatefulWidget {
  const AiAssistantPage({super.key});

  @override
  State<AiAssistantPage> createState() => _AiAssistantPageState();
}

class _AiAssistantPageState extends State<AiAssistantPage>
    with TickerProviderStateMixin {
  AiAssistantType _activeType = AiAssistantType.relationshipCoach;
  final List<AiChatMessage> _messages = [];
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcome();
  }

  void _addWelcome() {
    _messages.add(AiChatMessage(
      text: _activeType == AiAssistantType.relationshipCoach
          ? l.tr(
              'Hello! 💕 I am your relationship coach. I can help you with your relationships, communication, trust, romance and more.\n\nHow can I help you?',
              'Merhaba! 💕 Ben iliski kocunuzum. Iliskileriniz, iletisim, guven, romantizm ve daha fazlasi hakkinda size yardimci olabilirim.\n\nNasil yardimci olabilirim?')
          : l.tr(
              'Hello! 🔮 I am your astrology assistant. I can guide you on zodiac signs, planetary transits, compatibility analysis and astrological interpretations.\n\nWhat is your sign?',
              'Merhaba! 🔮 Ben burc asistanınızım. Burclar, gezegen gecisleri, uyum analizi ve astrolojik yorumlar konusunda size yol gosterebilirim.\n\nBurcunuz ne?'),
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _switchAssistant(AiAssistantType type) {
    if (type == _activeType) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _activeType = type;
      _messages.clear();
      _addWelcome();
    });
  }

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty || _isTyping) return;

    // ── AI daily limit check for free users ──
    final subCubit = context.read<SubscriptionCubit>();
    final subState = subCubit.state;
    final isCoach = _activeType == AiAssistantType.relationshipCoach;

    if (isCoach && !subState.canUseCoachAi) {
      _showAiLimitReached();
      return;
    }
    if (!isCoach && !subState.canUseAstroAi) {
      _showAiLimitReached();
      return;
    }

    _inputCtrl.clear();
    HapticFeedback.lightImpact();

    setState(() {
      _messages.add(AiChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _scrollToBottom();

    // Simulate thinking delay for natural feel
    await Future.delayed(
        Duration(milliseconds: 800 + (text.length * 10).clamp(0, 1500)));

    final response = LocalAiEngine.generateResponse(_activeType, text);

    if (mounted) {
      // Increment usage counter for free users
      if (isCoach) {
        subCubit.incrementCoachAi();
      } else {
        subCubit.incrementAstroAi();
      }

      setState(() {
        _messages.add(AiChatMessage(
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isTyping = false;
      });
      _scrollToBottom();
    }
  }

  void _showAiLimitReached() {
    HapticFeedback.heavyImpact();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(20),
              const Text('🔒', style: TextStyle(fontSize: 48)),
              const Gap(12),
              Text(
                l.tr('Daily AI Limit Reached', 'Günlük AI Limiti Doldu'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Gap(8),
              Text(
                l.tr(
                  'Free users can use each AI assistant once per day. Upgrade to PRO for unlimited access!',
                  'Ücretsiz kullanıcılar her AI asistanını günde 1 kez kullanabilir. Sınırsız erişim için PRO\'ya yükseltin!',
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const Gap(20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/subscription');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    l.tr('Upgrade to PRO 👑', 'PRO\'ya Yükselt 👑'),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCoach = _activeType == AiAssistantType.relationshipCoach;
    final subState = context.watch<SubscriptionCubit>().state;
    final remaining = isCoach ? subState.remainingCoachAi : subState.remainingAstroAi;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isCoach ? '💕' : '🔮', style: const TextStyle(fontSize: 22)),
            const Gap(8),
            Text(_activeType.title),
          ],
        ),
        centerTitle: true,
        actions: [
          if (!subState.isPro)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                avatar: const Icon(Icons.auto_awesome, size: 16),
                label: Text(
                  '$remaining/${SubscriptionState.freeAiDailyLimit}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                backgroundColor: remaining > 0
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.errorContainer,
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                avatar: const Text('👑', style: TextStyle(fontSize: 14)),
                label: Text(
                  'PRO',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
                backgroundColor: theme.colorScheme.primaryContainer,
                side: BorderSide.none,
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Mode Selector ──
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _ModeTab(
                  emoji: '💕',
                  label: l.tr('Rel. Coach', 'Iliski Kocu'),
                  isActive: isCoach,
                  color: const Color(0xFFE06B8F),
                  onTap: () =>
                      _switchAssistant(AiAssistantType.relationshipCoach),
                ),
                const Gap(4),
                _ModeTab(
                  emoji: '🔮',
                  label: l.tr('Astro Assistant', 'Burc Asistani'),
                  isActive: !isCoach,
                  color: const Color(0xFF8B7EC8),
                  onTap: () =>
                      _switchAssistant(AiAssistantType.astrologyAssistant),
                ),
              ],
            ),
          ),

          // ── Chat Messages ──
          Expanded(
            child: _messages.isEmpty
                ? _EmptyState(type: _activeType)
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isTyping) {
                        return _TypingIndicator(isCoach: isCoach);
                      }
                      final msg = _messages[index];
                      return _ChatBubble(
                        message: msg,
                        isCoach: isCoach,
                      ).animate().fadeIn(duration: 300.ms).slideY(
                            begin: 0.1,
                            duration: 300.ms,
                            curve: Curves.easeOut,
                          );
                    },
                  ),
          ),

          // ── Quick Suggestions ──
          if (_messages.length <= 2)
            _QuickSuggestions(
              type: _activeType,
              onTap: (text) {
                _inputCtrl.text = text;
                _sendMessage();
              },
            ),

          // ── Input Bar ──
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              8,
              MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    maxLines: 3,
                    minLines: 1,
                    decoration: InputDecoration(
                      hintText: isCoach
                          ? l.tr('Ask about your relationship...',
                              'Iliskinizle ilgili sorun...')
                          : l.tr('Ask about your zodiac...',
                              'Burcunuzla ilgili sorun...'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isCoach
                          ? [const Color(0xFFE06B8F), const Color(0xFFF2A3B8)]
                          : [const Color(0xFF8B7EC8), const Color(0xFFB5A8E0)],
                    ),
                  ),
                  child: IconButton(
                    onPressed: _isTyping ? null : _sendMessage,
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mode Tab ──
class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.emoji,
    required this.label,
    required this.isActive,
    required this.color,
    required this.onTap,
  });
  final String emoji, label;
  final bool isActive;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:
                isActive ? color.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isActive ? Border.all(color: color, width: 1.5) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 18)),
              const Gap(6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                  color: isActive
                      ? color
                      : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Chat Bubble ──
class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message, required this.isCoach});
  final AiChatMessage message;
  final bool isCoach;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    final aiColor = isCoach ? const Color(0xFFE06B8F) : const Color(0xFF8B7EC8);

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : aiColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          border: Border.all(
            color: isUser
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : aiColor.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isCoach ? '💕' : '🔮',
                        style: const TextStyle(fontSize: 12)),
                    const Gap(4),
                    Text(
                      isCoach
                          ? l.tr('Rel. Coach', 'Iliski Kocu')
                          : l.tr('Astro Assistant', 'Burc Asistani'),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: aiColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              message.text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Typing Indicator ──
class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator({required this.isCoach});
  final bool isCoach;

  @override
  Widget build(BuildContext context) {
    final color = isCoach ? const Color(0xFFE06B8F) : const Color(0xFF8B7EC8);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.5),
              ),
            )
                .animate(
                  onPlay: (c) => c.repeat(reverse: true),
                )
                .scale(
                  delay: Duration(milliseconds: i * 200),
                  duration: 600.ms,
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                );
          }),
        ),
      ),
    );
  }
}

// ── Empty State ──
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.type});
  final AiAssistantType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(type.emoji, style: const TextStyle(fontSize: 56)),
          const Gap(16),
          Text(type.title,
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800)),
          const Gap(8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              type.description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Suggestions ──
class _QuickSuggestions extends StatelessWidget {
  const _QuickSuggestions({required this.type, required this.onTap});
  final AiAssistantType type;
  final void Function(String) onTap;

  @override
  Widget build(BuildContext context) {
    final suggestions = type == AiAssistantType.relationshipCoach
        ? [
            l.tr('We have communication issues with my partner',
                'Partnerimle iletisim sorunumuz var'),
            l.tr('How to manage jealousy?', 'Kiskanclik nasil yonetilir?'),
            l.tr('How to build trust in a relationship?',
                'Iliskide guven nasil insa edilir?'),
            l.tr('How to keep romance alive?',
                'Romantizmi nasil canli tutariz?'),
          ]
        : [
            l.tr('What is an Aries like?', 'Koc burcu nasil biri?'),
            l.tr('What does my sign say today?', 'Bugun burcum ne diyor?'),
            l.tr('Are Taurus and Scorpio compatible?',
                'Boga ve Akrep uyumlu mu?'),
            l.tr('What does Mercury retrograde affect?',
                'Merkur retrogradi ne etkiler?'),
          ];

    return Container(
      height: 42,
      margin: const EdgeInsets.only(bottom: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const Gap(8),
        itemBuilder: (context, i) {
          final color = type == AiAssistantType.relationshipCoach
              ? const Color(0xFFE06B8F)
              : const Color(0xFF8B7EC8);
          return ActionChip(
            label: Text(
              suggestions[i],
              style: TextStyle(fontSize: 12, color: color),
            ),
            backgroundColor: color.withValues(alpha: 0.08),
            side: BorderSide(color: color.withValues(alpha: 0.2)),
            onPressed: () => onTap(suggestions[i]),
          );
        },
      ),
    );
  }
}
