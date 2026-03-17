import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../../core/di/injection.dart';
import '../../../../data/models/game_model.dart';
import '../../../../data/repositories/games_repository.dart';

class QASystemPage extends StatefulWidget {
  const QASystemPage({super.key});

  @override
  State<QASystemPage> createState() => _QASystemPageState();
}

class _QASystemPageState extends State<QASystemPage>
    with SingleTickerProviderStateMixin {
  late final GamesRepository _repo;
  late final TabController _tabCtrl;
  final _questionCtrl = TextEditingController();
  List<CoupleQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    _repo = getIt<GamesRepository>();
    _tabCtrl = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final qs = await _repo.getQuestions();
    setState(() => _questions = qs);
  }

  @override
  void dispose() {
    _questionCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _askQuestion() async {
    final text = _questionCtrl.text.trim();
    if (text.isEmpty) return;

    final q = CoupleQuestion(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: text,
      category: 'genel',
      createdAt: DateTime.now(),
    );
    await _repo.saveQuestion(q);
    _questionCtrl.clear();
    HapticFeedback.mediumImpact();
    await _load();
  }

  Future<void> _answerQuestion(CoupleQuestion q, String answer) async {
    final updated = CoupleQuestion(
      id: q.id,
      question: q.question,
      category: q.category,
      askerAnswer: q.askerAnswer ?? answer,
      responderAnswer: answer,
      createdAt: q.createdAt,
    );
    await _repo.saveQuestion(updated);
    await _load();
  }

  Future<void> _rateAnswer(CoupleQuestion q, int rating) async {
    final updated = CoupleQuestion(
      id: q.id,
      question: q.question,
      category: q.category,
      askerAnswer: q.askerAnswer,
      responderAnswer: q.responderAnswer,
      rating: rating,
      createdAt: q.createdAt,
    );
    await _repo.saveQuestion(updated);
    await _repo.addPoints(rating * 2);
    HapticFeedback.lightImpact();
    await _load();
  }

  Future<void> _markCorrect(CoupleQuestion q, bool correct) async {
    final updated = CoupleQuestion(
      id: q.id,
      question: q.question,
      category: q.category,
      askerAnswer: q.askerAnswer,
      responderAnswer: q.responderAnswer,
      rating: q.rating,
      isCorrect: correct,
      createdAt: q.createdAt,
    );
    await _repo.saveQuestion(updated);
    await _repo.addPoints(correct ? 15 : 5);
    HapticFeedback.mediumImpact();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final unanswered =
        _questions.where((q) => q.responderAnswer == null).toList();
    final answered = _questions
        .where((q) => q.responderAnswer != null && q.rating == null)
        .toList();
    final completed = _questions.where((q) => q.rating != null).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Soru - Cevap 💬'),
        bottom: TabBar(
          controller: _tabCtrl,
          tabs: [
            Tab(text: 'Sor (${unanswered.length})'),
            Tab(text: 'Cevapla (${answered.length})'),
            Tab(text: 'Gecmis (${completed.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _AskTab(
            questionCtrl: _questionCtrl,
            onAsk: _askQuestion,
            unanswered: unanswered,
          ),
          _AnswerTab(
            questions: answered,
            onAnswer: _answerQuestion,
            onRate: _rateAnswer,
            onMarkCorrect: _markCorrect,
          ),
          _HistoryTab(questions: completed),
        ],
      ),
    );
  }
}

// ── ASK TAB ──
class _AskTab extends StatelessWidget {
  const _AskTab({
    required this.questionCtrl,
    required this.onAsk,
    required this.unanswered,
  });
  final TextEditingController questionCtrl;
  final VoidCallback onAsk;
  final List<CoupleQuestion> unanswered;

  static const _suggestions = [
    'En sevdigin anımız hangisi?',
    'Bende en cok neyi seviyorsun?',
    'Ilk bulusmamizda ne hissettin?',
    'Gelecekte birlikte ne yapmak istiyorsun?',
    'Beni en cok ne zaman ozledin?',
    'Hayalindeki tatil nerede?',
    'En komik animiz ne?',
    'Bana sorulamayan bir soru var mi?',
    'Evlilikte en onemli sey ne?',
    'Benim icin ne degisir?',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Partnerine Soru Sor',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const Gap(12),
                TextField(
                  controller: questionCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Soruyu buraya yaz...',
                    prefixIcon: Icon(Icons.help_outline),
                  ),
                ),
                const Gap(12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: onAsk,
                    icon: const Icon(Icons.send),
                    label: const Text('Soruyu Gonder'),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 300.ms),
        const Gap(16),
        Text('Ilham Al 💡',
            style: theme.textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w700)),
        const Gap(8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _suggestions
              .map((s) => ActionChip(
                    label: Text(s, style: const TextStyle(fontSize: 12)),
                    onPressed: () => questionCtrl.text = s,
                  ))
              .toList(),
        ),
        if (unanswered.isNotEmpty) ...[
          const Gap(20),
          Text('Bekleyen Sorular (${unanswered.length})',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w700)),
          const Gap(8),
          ...unanswered.map((q) => Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Text('❓')),
                  title: Text(q.question),
                  subtitle: Text(_timeAgo(q.createdAt ?? DateTime.now())),
                ),
              )),
        ],
      ],
    );
  }
}

// ── ANSWER TAB ──
class _AnswerTab extends StatelessWidget {
  const _AnswerTab({
    required this.questions,
    required this.onAnswer,
    required this.onRate,
    required this.onMarkCorrect,
  });
  final List<CoupleQuestion> questions;
  final Future<void> Function(CoupleQuestion, String) onAnswer;
  final Future<void> Function(CoupleQuestion, int) onRate;
  final Future<void> Function(CoupleQuestion, bool) onMarkCorrect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✅', style: TextStyle(fontSize: 48)),
            const Gap(12),
            Text('Tum sorular cevaplanmis!',
                style: theme.textTheme.titleMedium),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: questions.length,
      itemBuilder: (context, i) {
        final q = questions[i];
        return _AnswerCard(
          question: q,
          onAnswer: (ans) => onAnswer(q, ans),
          onRate: (r) => onRate(q, r),
          onMarkCorrect: (c) => onMarkCorrect(q, c),
        ).animate().fadeIn(delay: Duration(milliseconds: i * 100));
      },
    );
  }
}

class _AnswerCard extends StatefulWidget {
  const _AnswerCard({
    required this.question,
    required this.onAnswer,
    required this.onRate,
    required this.onMarkCorrect,
  });
  final CoupleQuestion question;
  final void Function(String) onAnswer;
  final void Function(int) onRate;
  final void Function(bool) onMarkCorrect;

  @override
  State<_AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<_AnswerCard> {
  final _ansCtrl = TextEditingController();

  @override
  void dispose() {
    _ansCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = widget.question;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('❓', style: TextStyle(fontSize: 20)),
                const Gap(8),
                Expanded(
                  child: Text(q.question,
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const Gap(12),
            if (q.responderAnswer == null) ...[
              TextField(
                controller: _ansCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: 'Cevabini yaz...',
                  prefixIcon: Icon(Icons.edit),
                ),
              ),
              const Gap(8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_ansCtrl.text.trim().isNotEmpty) {
                      widget.onAnswer(_ansCtrl.text.trim());
                    }
                  },
                  child: const Text('Cevapla'),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Text(q.responderAnswer!, style: theme.textTheme.bodyLarge),
              ),
              const Gap(12),
              if (q.rating == null) ...[
                Text('Cevabi puanla (1-10):',
                    style: theme.textTheme.labelLarge),
                const Gap(8),
                Wrap(
                  spacing: 6,
                  children: List.generate(10, (i) {
                    final r = i + 1;
                    return ChoiceChip(
                      label: Text('$r'),
                      selected: false,
                      onSelected: (_) => widget.onRate(r),
                    );
                  }),
                ),
                const Gap(12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => widget.onMarkCorrect(true),
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text('Dogru',
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green),
                      ),
                    ),
                    const Gap(8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => widget.onMarkCorrect(false),
                        icon: const Icon(Icons.close),
                        label: const Text('Yanlis'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ── HISTORY TAB ──
class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.questions});
  final List<CoupleQuestion> questions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (questions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📝', style: TextStyle(fontSize: 48)),
            const Gap(12),
            Text('Henuz gecmis yok', style: theme.textTheme.titleMedium),
            const Gap(4),
            Text('Soru sorup cevaplayin!',
                style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: questions.length,
      itemBuilder: (context, i) {
        final q = questions[questions.length - 1 - i];
        final color = (q.isCorrect ?? false) ? Colors.green : Colors.red;
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      (q.isCorrect ?? false)
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: color,
                      size: 20,
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(q.question,
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    if (q.rating != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              _ratingColor(q.rating!).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${q.rating}/10',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: _ratingColor(q.rating!))),
                      ),
                  ],
                ),
                if (q.responderAnswer != null) ...[
                  const Gap(8),
                  Text(q.responderAnswer!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7))),
                ],
                const Gap(4),
                Text(_timeAgo(q.createdAt ?? DateTime.now()),
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.4))),
              ],
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: i * 60));
      },
    );
  }

  Color _ratingColor(int r) {
    if (r >= 8) return Colors.green;
    if (r >= 5) return Colors.orange;
    return Colors.red;
  }
}

String _timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'Az once';
  if (diff.inMinutes < 60) return '${diff.inMinutes} dk once';
  if (diff.inHours < 24) return '${diff.inHours} saat once';
  return '${diff.inDays} gun once';
}
