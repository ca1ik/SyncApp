import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/locale_service.dart';
import '../../../../data/models/game_model.dart';
import '../../../../data/repositories/games_repository.dart';

/// Tournament bracket page — quizei.com style elimination
/// Supports 4/8/16/32/64 brackets with head-to-head picks.
/// Both players pick simultaneously (pass-the-phone style).
class TournamentPage extends StatefulWidget {
  const TournamentPage({super.key});

  @override
  State<TournamentPage> createState() => _TournamentPageState();
}

class _TournamentPageState extends State<TournamentPage> {
  TournamentCategory? _selectedCategory;
  BracketSize? _selectedSize;
  List<String> _items = [];
  List<String> _currentRound = [];
  List<String> _nextRound = [];
  int _matchIndex = 0;
  bool _tournamentStarted = false;
  String? _champion;
  bool _isPlayer1Turn = true;
  String? _p1Champion;
  final _customItemCtrl = TextEditingController();
  final List<String> _customItems = [];

  // Player results for comparison
  final List<String> _p1Picks = [];
  final List<String> _p2Picks = [];

  String get _roundName {
    final count = _currentRound.length;
    if (count == 2) return l.tr('🏆 FINAL', '🏆 FİNAL');
    if (count == 4) return l.tr('Semi-Final', 'Yari Final');
    if (count == 8) return l.tr('Quarter-Final', 'Ceyrek Final');
    return l.tr('Round of $count', '$count\'lu Tur');
  }

  void _startTournament() {
    if (_selectedCategory == null || _selectedSize == null) return;

    List<String> items;
    if (_selectedCategory == TournamentCategory.custom) {
      if (_customItems.length < _selectedSize!.count) return;
      items = List.from(_customItems);
    } else {
      items = GamesRepository.getTournamentItems(
          _selectedCategory!, _selectedSize!.count);
    }
    items.shuffle(Random());

    setState(() {
      _items = items;
      _currentRound = List.from(items);
      _nextRound = [];
      _matchIndex = 0;
      _tournamentStarted = true;
      _champion = null;
      _isPlayer1Turn = true;
      _p1Champion = null;
      _p1Picks.clear();
      _p2Picks.clear();
    });
  }

  void _pickWinner(String winner) {
    HapticFeedback.mediumImpact();

    if (_isPlayer1Turn) {
      _p1Picks.add(winner);
    } else {
      _p2Picks.add(winner);
    }

    _nextRound.add(winner);
    _matchIndex += 2;

    if (_matchIndex >= _currentRound.length) {
      // Round complete
      if (_nextRound.length == 1) {
        // Tournament over for current player
        if (_isPlayer1Turn) {
          setState(() {
            _p1Champion = _nextRound.first;
            _isPlayer1Turn = false;
            // Reset for player 2
            _currentRound = List.from(_items);
            _currentRound.shuffle(Random());
            _nextRound = [];
            _matchIndex = 0;
          });
        } else {
          setState(() {
            _champion = _nextRound.first;
          });
          _saveScore();
        }
      } else {
        setState(() {
          _currentRound = List.from(_nextRound);
          _nextRound = [];
          _matchIndex = 0;
        });
      }
    } else {
      setState(() {});
    }
  }

  Future<void> _saveScore() async {
    await getIt<GamesRepository>().saveScore(GameScore(
      gameType: CoupleGameType.bracketTournament,
      player1Score: 25,
      player2Score: 25,
      playedAt: DateTime.now(),
      bonusPoints: _p1Champion == _champion ? 20 : 0,
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
    if (_champion != null) return _buildChampionScreen();
    if (_tournamentStarted) return _buildMatchScreen();
    return _buildSetupScreen();
  }

  Widget _buildSetupScreen() {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.tr('🏅 Tournament', '🏅 Turnuva'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('🏅',
                  style: TextStyle(fontSize: 56), textAlign: TextAlign.center)
              .animate()
              .scale(duration: 600.ms, curve: Curves.elasticOut),
          const Gap(16),
          Text(
            l.tr('Choose a Category', 'Kategori Sec'),
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const Gap(16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: TournamentCategory.values.map((cat) {
              final selected = _selectedCategory == cat;
              return ChoiceChip(
                label: Text('${cat.emoji} ${cat.title}'),
                selected: selected,
                onSelected: (_) => setState(() => _selectedCategory = cat),
              );
            }).toList(),
          ),
          const Gap(24),

          // Custom items input
          if (_selectedCategory == TournamentCategory.custom) ...[
            Text(l.tr('Add Items', 'Ogeleri Ekle'),
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const Gap(8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customItemCtrl,
                    decoration: InputDecoration(
                      labelText: l.tr('Item name', 'Oge adi'),
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
            Text(
              '${_customItems.length} ${l.tr('items added', 'oge eklendi')}',
              style: theme.textTheme.bodySmall,
            ),
            const Gap(16),
          ],

          Text(
            l.tr('Bracket Size', 'Turnuva Boyutu'),
            style: theme.textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.w800),
            textAlign: TextAlign.center,
          ),
          const Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: BracketSize.values.map((size) {
              final selected = _selectedSize == size;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text('${size.count}'),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedSize = size),
                ),
              );
            }).toList(),
          ),
          const Gap(32),

          // Info cards
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    l.tr('How it works', 'Nasil calisir'),
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Gap(8),
                  Text(
                    l.tr(
                      '1. Items are placed in a bracket\n'
                          '2. You pick your favorite from each pair\n'
                          '3. Winners advance to the next round\n'
                          '4. Both partners play, then compare champions!\n'
                          '5. If you pick the same champion → bonus points! 🎉',
                      '1. Ogeler turnuva agacina yerlestirilir\n'
                          '2. Her cifttan favorini sec\n'
                          '3. Kazananlar sonraki tura ilerler\n'
                          '4. Her iki partner de oynar, sampiyonlari karsilastir!\n'
                          '5. Ayni sampiyonu secerseniz → bonus puan! 🎉',
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const Gap(24),

          SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: _selectedCategory != null && _selectedSize != null
                  ? _startTournament
                  : null,
              child: Text(
                l.tr('Start Tournament! 🚀', 'Turnuvayi Baslat! 🚀'),
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const Gap(32),
        ],
      ),
    );
  }

  Widget _buildMatchScreen() {
    final theme = Theme.of(context);
    if (_matchIndex + 1 >= _currentRound.length) return const SizedBox.shrink();

    final item1 = _currentRound[_matchIndex];
    final item2 = _currentRound[_matchIndex + 1];
    final totalMatches = _currentRound.length ~/ 2;
    final currentMatch = (_matchIndex ~/ 2) + 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('$_roundName — $currentMatch/$totalMatches'),
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
                  color: (_isPlayer1Turn ? Colors.pink : Colors.blue)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _isPlayer1Turn
                      ? l.tr('👩 Player 1\'s Turn', '👩 Oyuncu 1 Sirasi')
                      : l.tr('👨 Player 2\'s Turn', '👨 Oyuncu 2 Sirası'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _isPlayer1Turn ? Colors.pink : Colors.blue,
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),
              const Gap(8),
              Text(
                '${_selectedCategory?.emoji ?? ''} ${_selectedCategory?.title ?? ''}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const Spacer(),
              // VS Match
              GestureDetector(
                onTap: () => _pickWinner(item1),
                child: _MatchCard(item: item1, color: Colors.pink, index: 0),
              ),
              const Gap(16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                ),
                child: Text('VS',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    )),
              ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
              const Gap(16),
              GestureDetector(
                onTap: () => _pickWinner(item2),
                child: _MatchCard(item: item2, color: Colors.blue, index: 1),
              ),
              const Spacer(),
              // Progress
              LinearProgressIndicator(
                value: currentMatch / totalMatches,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
              const Gap(8),
              Text(
                l.tr('Remaining: ${_currentRound.length} items',
                    'Kalan: ${_currentRound.length} oge'),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChampionScreen() {
    final theme = Theme.of(context);
    final same = _p1Champion == _champion;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🏆', style: TextStyle(fontSize: 72))
                    .animate()
                    .scale(duration: 600.ms, curve: Curves.elasticOut),
                const Gap(16),
                Text(
                  l.tr('Champions!', 'Sampiyonlar!'),
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ).animate().fadeIn(delay: 200.ms),
                const Gap(24),
                _ChampionCard(
                  label: l.tr('👩 Player 1', '👩 Oyuncu 1'),
                  champion: _p1Champion ?? '?',
                  color: Colors.pink,
                ),
                const Gap(12),
                _ChampionCard(
                  label: l.tr('👨 Player 2', '👨 Oyuncu 2'),
                  champion: _champion ?? '?',
                  color: Colors.blue,
                ),
                const Gap(24),
                if (same)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🎉', style: TextStyle(fontSize: 24)),
                        const Gap(8),
                        Text(
                          l.tr('Same pick! +20 bonus!',
                              'Ayni secim! +20 bonus!'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ).animate().scale(
                      delay: 400.ms, duration: 400.ms, curve: Curves.elasticOut)
                else
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      l.tr('Different picks! Discuss why! 💬',
                          'Farkli secimler! Neden tartis! 💬'),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange,
                      ),
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                const Gap(32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() {
                          _tournamentStarted = false;
                          _champion = null;
                          _p1Champion = null;
                          _selectedCategory = null;
                          _selectedSize = null;
                        }),
                        child: Text(l.tr('New Tournament', 'Yeni Turnuva')),
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
                ).animate().fadeIn(delay: 600.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard({
    required this.item,
    required this.color,
    required this.index,
  });
  final String item;
  final Color color;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        children: [
          Text(
            item,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const Gap(8),
          Text(
            l.tr('Tap to pick', 'Secmek icin dokun'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: color.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: index * 200)).fadeIn().slideX(
          begin: index == 0 ? -0.3 : 0.3,
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }
}

class _ChampionCard extends StatelessWidget {
  const _ChampionCard({
    required this.label,
    required this.champion,
    required this.color,
  });
  final String label;
  final String champion;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const Gap(4),
          Text(
            '🏆 $champion',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2);
  }
}
