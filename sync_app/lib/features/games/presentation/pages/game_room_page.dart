import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/game_room_service.dart';
import '../../../../core/services/locale_service.dart';
import '../../../../core/widgets/themed_background.dart';
import '../../../../data/models/game_model.dart';
import '../../../../data/models/game_room_model.dart';
import '../../../../data/repositories/auth_repository.dart';

class GameRoomPage extends StatefulWidget {
  const GameRoomPage({super.key, required this.gameType});

  final CoupleGameType gameType;

  @override
  State<GameRoomPage> createState() => _GameRoomPageState();
}

class _GameRoomPageState extends State<GameRoomPage>
    with SingleTickerProviderStateMixin {
  final _codeController = TextEditingController();
  final _roomService = getIt<GameRoomService>();
  final _focusNodes = List.generate(4, (_) => FocusNode());
  final _digitControllers = List.generate(4, (_) => TextEditingController());

  GameRoom? _createdRoom;
  bool _isCreating = false;
  bool _isJoining = false;
  String? _error;

  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _codeController.dispose();
    for (final c in _digitControllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _createRoom() async {
    setState(() {
      _isCreating = true;
      _error = null;
    });
    try {
      final user = await getIt<AuthRepository>().getCurrentUserProfile();
      final room = await _roomService.createRoom(
        gameType: widget.gameType,
        hostPlayerId:
            user?.uid ?? 'host_${DateTime.now().millisecondsSinceEpoch}',
      );
      setState(() {
        _createdRoom = room;
        _isCreating = false;
      });
    } catch (e) {
      setState(() {
        _error = l.tr('Failed to create room', 'Oda oluşturulamadı');
        _isCreating = false;
      });
    }
  }

  Future<void> _joinRoom() async {
    final code = _digitControllers.map((c) => c.text).join();
    if (code.length != 4) {
      setState(
          () => _error = l.tr('Enter 4-digit code', '4 haneli kodu girin'));
      return;
    }

    setState(() {
      _isJoining = true;
      _error = null;
    });

    try {
      final user = await getIt<AuthRepository>().getCurrentUserProfile();
      final room = await _roomService.joinRoom(
        roomCode: code,
        guestPlayerId:
            user?.uid ?? 'guest_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (room != null) {
        if (!mounted) return;
        _navigateToGame();
      } else {
        setState(() {
          _error = l.tr('Room not found or full', 'Oda bulunamadı veya dolu');
          _isJoining = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = l.tr('Failed to join room', 'Odaya katılınamadı');
        _isJoining = false;
      });
    }
  }

  void _navigateToGame() {
    final isArena = widget.gameType.category == GameCategory.arena;
    final route = isArena ? AppRoutes.arenaGame : AppRoutes.gamePlay;
    Get.offNamed(route, arguments: widget.gameType);
  }

  void _startGame() {
    _navigateToGame();
  }

  @override
  Widget build(BuildContext context) {
    final l = LocaleService.instance;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          l.tr('Game Room', 'Oyun Odası'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ThemedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _createdRoom != null
                ? _buildRoomCreated(l)
                : _buildRoomOptions(l),
          ),
        ),
      ),
    );
  }

  Widget _buildRoomOptions(LocaleService l) {
    return Column(
      children: [
        const SizedBox(height: 20),
        // Game title
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.gameType.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  widget.gameType.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Spacer(flex: 1),

        // Create Room
        _ActionCard(
          icon: Icons.add_circle_outline,
          title: l.tr('Create Room', 'Oda Oluştur'),
          subtitle: l.tr(
            'Get a 4-digit code to share',
            '4 haneli paylaşım kodu al',
          ),
          gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
          isLoading: _isCreating,
          onTap: _createRoom,
        ),

        const SizedBox(height: 20),

        // Divider
        Row(
          children: [
            Expanded(
                child: Divider(color: Colors.white.withValues(alpha: 0.2))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l.tr('OR', 'VEYA'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
                child: Divider(color: Colors.white.withValues(alpha: 0.2))),
          ],
        ),

        const SizedBox(height: 20),

        // Join Room
        _ActionCard(
          icon: Icons.login_rounded,
          title: l.tr('Join Room', 'Odaya Katıl'),
          subtitle: l.tr(
            'Enter the 4-digit room code',
            '4 haneli oda kodunu gir',
          ),
          gradient: const [Color(0xFFf093fb), Color(0xFFf5576c)],
          child: _buildCodeInput(),
          isLoading: _isJoining,
          onTap: _joinRoom,
        ),

        if (_error != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.redAccent, size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _error!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const Spacer(flex: 2),

        // Skip — play solo
        TextButton(
          onPressed: _navigateToGame,
          child: Text(
            l.tr('Play without room →', 'Odasız oyna →'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCodeInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (i) {
          return Container(
            width: 48,
            height: 56,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _digitControllers[i].text.isNotEmpty
                    ? Colors.white.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.15),
              ),
            ),
            child: TextField(
              controller: _digitControllers[i],
              focusNode: _focusNodes[i],
              textAlign: TextAlign.center,
              maxLength: 1,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
              ),
              onChanged: (val) {
                setState(() {});
                if (val.isNotEmpty && i < 3) {
                  _focusNodes[i + 1].requestFocus();
                }
                if (val.isEmpty && i > 0) {
                  _focusNodes[i - 1].requestFocus();
                }
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRoomCreated(LocaleService l) {
    final code = _createdRoom!.roomCode;
    return Column(
      children: [
        const SizedBox(height: 40),

        // Success icon
        AnimatedBuilder(
          animation: _pulseCtrl,
          builder: (context, child) {
            final scale = 1.0 + (_pulseCtrl.value * 0.08);
            return Transform.scale(scale: scale, child: child);
          },
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.greenAccent.withValues(alpha: 0.3),
                  Colors.cyanAccent.withValues(alpha: 0.2),
                ],
              ),
            ),
            child: const Icon(Icons.check_circle,
                color: Colors.greenAccent, size: 44),
          ),
        ),

        const SizedBox(height: 24),
        Text(
          l.tr('Room Created!', 'Oda Oluşturuldu!'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l.tr(
            'Share this code with your partner',
            'Bu kodu partnerinle paylaş',
          ),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 40),

        // Big code display
        GestureDetector(
          onTap: () {
            Clipboard.setData(ClipboardData(text: code));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l.tr('Code copied!', 'Kod kopyalandı!')),
                backgroundColor: Colors.green.withValues(alpha: 0.8),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: code.split('').map((digit) {
                    return Container(
                      width: 52,
                      height: 64,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.cyanAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        digit,
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.copy_rounded,
                      color: Colors.white.withValues(alpha: 0.4),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l.tr('Tap to copy', 'Kopyalamak için dokun'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const Spacer(),

        // Start game
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent.withValues(alpha: 0.2),
              foregroundColor: Colors.cyanAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.cyanAccent.withValues(alpha: 0.4),
                ),
              ),
              elevation: 0,
            ),
            child: Text(
              l.tr('Start Game', 'Oyunu Başlat'),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
    this.child,
    this.isLoading = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradient;
  final VoidCallback onTap;
  final Widget? child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient.map((c) => c.withValues(alpha: 0.15)).toList(),
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: gradient.first.withValues(alpha: 0.25),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: gradient.first, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white54,
                    ),
                  )
                else
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 16,
                  ),
              ],
            ),
            if (child != null) child!,
          ],
        ),
      ),
    );
  }
}
