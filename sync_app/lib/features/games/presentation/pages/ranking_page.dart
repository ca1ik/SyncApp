import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/locale_service.dart';
import '../../../../data/models/game_model.dart';
import '../../../../data/repositories/games_repository.dart';

/// TikTok-style 1-10 rating page.
/// Both partners rate items independently, then compare rankings.
class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  RankingCategory? _selectedCategory;
  List<String> _items = [];
  bool _started = false;
  bool _isP1Turn = true;
  int _currentIndex = 0;
  final Map<String, int> _p1Ratings = {};
  final Map<String, int> _p2Ratings = {};
  bool _showResults = false;
  final _customItemCtrl = TextEditingController();
  final List<String> _customItems = [];

  void _startRanking() {
    if (_selectedCategory == null) return;

    List<String> items;
    if (_selectedCategory == RankingCategory.custom) {
      if (_customItems.length < 5) return;
      items = List.from(_customItems);
    } else {
      items = GamesRepository.getRankingItems(_selectedCategory!);
    }

    setState(() {
      _items = items;
      _started = true;
      _isP1Turn = true;
      _currentIndex = 0;
      _p1Ratings.clear();
      _p2Ratings.clear();
      _showResults = false;
    });
  }

  void _rate(int rating) {
    HapticFeedback.lightImpact();
    final item = _items[_currentIndex];

    setState(() {
      if (_isP1Turn) {
        _p1Ratings[item] = rating;
      } else {
        _p2Ratings[item] = rating;
      }

      if (_currentIndex < _items.length - 1) {
        _currentIndex++;
      } else {
        // Finished current player
        if (_isP1Turn) {
          _isP1Turn = false;
          _currentIndex = 0;
        } else {
          _showResults = true;
          _saveScore();
        }
      }
    });
  }

  Future<void> _saveScore() async {
    // Calculate how similar the ratings are
    int matchScore = 0;
    for (final item in _items) {
      final diff = ((_p1Ratings[item] ?? 5) - (_p2Ratings[item] ?? 5)).abs();
      matchScore += (10 - diff);
    }
    await getIt<GamesRepository>().saveScore(GameScore(
      gameType: CoupleGameType.rateAndRank,
      player1Score: matchScore ~/ 2,
      player2Score: matchScore ~/ 2,
      playedAt: DateTime.now(),
      bonusPoints: matchScore > _items.length * 8 ? 20 : 0,
    ));
  }

  void _addCustomItem() {
    final text = _customItemCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _customItems.add(text);
      _customItemCtrl.clear();
    });
  }

  @override
  void dispose() {
    _customItemCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_showResults) return _buildResults();
    if (_started) return _buildRating();
    return _buildSetup();
  }

  Widget _buildSetup() {
    final theme = Theme.of(context);
    return Scaffold(
      appBar:
          AppBar(title: Text(l.tr('📊 Rate & Rank', '📊 Puanla ve Sirala'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('📊',
                  style: TextStyle(fontSize: 56), textAlign: TextAlign.center)
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const Gap(16),
          Text(
            l.tr('Rate items 1-10 together!', 'Birlikte 1-10 arasi puanlayin!'),
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          Text(
            l.tr('Both partners rate independently, then compare results!',
                'Her iki partner bagimsiz puanlar, sonra sonuclari karsilastirin!'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(24),
          Text(
            l.tr('Choose a Category', 'Kategori Sec'),
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const Gap(12),
          ...RankingCategory.values.map((cat) {
            final selected = _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                color: selected
                    ? theme.colorScheme.primary.withValues(alpha: 0.1)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: selected
                      ? BorderSide(color: theme.colorScheme.primary, width: 2)
                      : BorderSide.none,
                ),
                child: ListTile(
                  leading:
                      Text(cat.emoji, style: const TextStyle(fontSize: 28)),
                  title: Text(cat.title,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () => setState(() => _selectedCategory = cat),
                  trailing: selected
                      ? Icon(Icons.check_circle,
                          color: theme.colorScheme.primary)
                      : null,
                ),
              ),
            );
          }),

          // Custom items input
          if (_selectedCategory == RankingCategory.custom) ...[
            const Gap(8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customItemCtrl,
                    decoration: InputDecoration(
                      labelText: l.tr('Add item', 'Oge ekle'),
                      prefixIcon: const Icon(Icons.add_circle),
                    ),
                    onSubmitted: (_) => _addCustomItem(),
                  ),
                ),
                const Gap(8),
                IconButton.filled(
                  onPressed: _addCustomItem,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const Gap(8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: _customItems
                  .map((item) => Chip(
                        label: Text(item, style: const TextStyle(fontSize: 12)),
                        onDeleted: () =>
                            setState(() => _customItems.remove(item)),
                      ))
                  .toList(),
            ),
            Text('${_customItems.length}/10+ ${l.tr('items', 'oge')}',
                style: theme.textTheme.bodySmall),
          ],
          const Gap(24),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedCategory != null ? _startRanking : null,
              child: Text(
                l.tr('Start Rating! 🚀', 'Puanlamaya Basla! 🚀'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRating() {
    final theme = Theme.of(context);
    final item = _items[_currentIndex];
    final progress = (_currentIndex + 1) / _items.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${_selectedCategory?.emoji ?? ''} ${_currentIndex + 1}/${_items.length}'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Player indicator
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: (_isP1Turn ? Colors.pink : Colors.blue)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_isP1Turn ? '👩' : '👨',
                        style: const TextStyle(fontSize: 24)),
                    const Gap(8),
                    Text(
                      _isP1Turn
                          ? l.tr('Player 1 Rating', 'Oyuncu 1 Puanliyor')
                          : l.tr('Player 2 Rating', 'Oyuncu 2 Puanliyor'),
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),
              if (!_isP1Turn)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    l.tr('Don\'t look at partner\'s phone!',
                        'Partnerin telefonuna bakma!'),
                    style:
                        theme.textTheme.bodySmall?.copyWith(color: Colors.red),
                  ),
                ),
              const Spacer(),
              // Item card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        item,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
              const Gap(32),
              // 1-10 rating buttons
              Text(l.tr('Rate 1-10', 'Puanla 1-10'),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const Gap(12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: List.generate(10, (i) {
                  final rating = i + 1;
                  return SizedBox(
                    width: 56,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _rate(rating),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: _getRatingColor(rating),
                      ),
                      child: Text(
                        '$rating',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const Spacer(),
              // Progress bar
              LinearProgressIndicator(
                value: progress,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRatingColor(int rating) {
    if (rating <= 3) return Colors.red;
    if (rating <= 5) return Colors.orange;
    if (rating <= 7) return Colors.amber.shade700;
    if (rating <= 9) return Colors.green;
    return Colors.teal;
  }

  Widget _buildResults() {
    final theme = Theme.of(context);

    // Sort items by P1 rating (descending)
    final sortedItems = List<String>.from(_items);
    sortedItems
        .sort((a, b) => (_p1Ratings[b] ?? 0).compareTo(_p1Ratings[a] ?? 0));

    return Scaffold(
      appBar: AppBar(title: Text(l.tr('📊 Results', '📊 Sonuclar'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('📊',
                  style: TextStyle(fontSize: 56), textAlign: TextAlign.center)
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const Gap(8),
          Text(
            l.tr('Rating Comparison', 'Puanlama Karsilastirmasi'),
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms),
          const Gap(16),
          // Header row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                const SizedBox(width: 32),
                Expanded(
                    child: Text(l.tr('Item', 'Oge'),
                        style: const TextStyle(fontWeight: FontWeight.w700))),
                SizedBox(
                    width: 50,
                    child: Text('👩',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18))),
                SizedBox(
                    width: 50,
                    child: Text('👨',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18))),
                SizedBox(
                    width: 40,
                    child: Text('Δ',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800))),
              ],
            ),
          ),
          const Divider(),
          ...sortedItems.asMap().entries.map((e) {
            final item = e.value;
            final p1 = _p1Ratings[item] ?? 0;
            final p2 = _p2Ratings[item] ?? 0;
            final diff = (p1 - p2).abs();
            return Card(
              color: diff == 0
                  ? Colors.green.withValues(alpha: 0.08)
                  : diff >= 4
                      ? Colors.red.withValues(alpha: 0.08)
                      : null,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text('${e.key + 1}.',
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    const Gap(8),
                    Expanded(
                      child: Text(item,
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600)),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text('$p1',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.pink,
                            fontSize: 16,
                          )),
                    ),
                    SizedBox(
                      width: 50,
                      child: Text('$p2',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.blue,
                            fontSize: 16,
                          )),
                    ),
                    SizedBox(
                      width: 40,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: diff == 0
                              ? Colors.green.withValues(alpha: 0.2)
                              : diff >= 4
                                  ? Colors.red.withValues(alpha: 0.2)
                                  : Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          diff == 0 ? '✓' : '$diff',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: diff == 0
                                ? Colors.green
                                : diff >= 4
                                    ? Colors.red
                                    : Colors.orange,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate(delay: Duration(milliseconds: e.key * 50))
                .fadeIn()
                .slideX(begin: 0.1);
          }),
          const Gap(24),
          // Summary
          _buildMatchSummary(theme),
          const Gap(16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _started = false;
                    _showResults = false;
                    _selectedCategory = null;
                  }),
                  child: Text(l.tr('New Ranking', 'Yeni Siralama')),
                ),
              ),
              const Gap(12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l.tr('Back', 'Geri Don')),
                ),
              ),
            ],
          ),
          const Gap(32),
        ],
      ),
    );
  }

  Widget _buildMatchSummary(ThemeData theme) {
    int perfectMatches = 0;
    int totalDiff = 0;
    for (final item in _items) {
      final diff = ((_p1Ratings[item] ?? 0) - (_p2Ratings[item] ?? 0)).abs();
      totalDiff += diff;
      if (diff == 0) perfectMatches++;
    }
    final avgDiff = totalDiff / _items.length;
    final matchPct = ((1 - avgDiff / 10) * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '$matchPct%',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: matchPct > 70
                    ? Colors.green
                    : matchPct > 40
                        ? Colors.orange
                        : Colors.red,
              ),
            ),
            Text(l.tr('Taste Match', 'Zevk Uyumu'),
                style: theme.textTheme.titleMedium),
            const Gap(8),
            Text(
              l.tr(
                  '$perfectMatches perfect matches out of ${_items.length} items',
                  '${_items.length} ogeden $perfectMatches tam uyum'),
              style: theme.textTheme.bodyMedium,
            ),
            const Gap(4),
            Text(
              matchPct > 80
                  ? l.tr('Amazing! You think alike! 🎉',
                      'Muhtesem! Ayni dusunuyorsunuz! 🎉')
                  : matchPct > 50
                      ? l.tr('Pretty good compatibility! 👍', 'Guzel uyum! 👍')
                      : l.tr('Very different tastes — discuss! 💬',
                          'Cok farkli zevkler — tartisin! 💬'),
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2);
  }
}
