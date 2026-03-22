import 'dart:math';

import 'package:equatable/equatable.dart';

import 'game_model.dart';

/// Status of a game room
enum RoomStatus {
  waiting, // Room created, waiting for opponent
  ready, // Both players joined
  playing, // Game in progress
  finished, // Game over
}

/// A game room with a 4-digit join code.
/// Infrastructure is ready for online multiplayer — currently local-only.
class GameRoom extends Equatable {
  const GameRoom({
    required this.roomId,
    required this.roomCode,
    required this.gameType,
    required this.hostPlayerId,
    this.guestPlayerId,
    this.status = RoomStatus.waiting,
    required this.createdAt,
    this.hostScore = 0,
    this.guestScore = 0,
    this.hostReady = false,
    this.guestReady = false,
  });

  final String roomId;
  final String roomCode; // 4-digit code
  final CoupleGameType gameType;
  final String hostPlayerId;
  final String? guestPlayerId;
  final RoomStatus status;
  final DateTime createdAt;
  final int hostScore;
  final int guestScore;
  final bool hostReady;
  final bool guestReady;

  /// Generate a random 4-digit room code (0000–9999)
  static String generateRoomCode() {
    return Random().nextInt(10000).toString().padLeft(4, '0');
  }

  GameRoom copyWith({
    String? roomId,
    String? roomCode,
    CoupleGameType? gameType,
    String? hostPlayerId,
    String? guestPlayerId,
    RoomStatus? status,
    DateTime? createdAt,
    int? hostScore,
    int? guestScore,
    bool? hostReady,
    bool? guestReady,
  }) {
    return GameRoom(
      roomId: roomId ?? this.roomId,
      roomCode: roomCode ?? this.roomCode,
      gameType: gameType ?? this.gameType,
      hostPlayerId: hostPlayerId ?? this.hostPlayerId,
      guestPlayerId: guestPlayerId ?? this.guestPlayerId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      hostScore: hostScore ?? this.hostScore,
      guestScore: guestScore ?? this.guestScore,
      hostReady: hostReady ?? this.hostReady,
      guestReady: guestReady ?? this.guestReady,
    );
  }

  Map<String, dynamic> toJson() => {
        'roomId': roomId,
        'roomCode': roomCode,
        'gameType': gameType.name,
        'hostPlayerId': hostPlayerId,
        'guestPlayerId': guestPlayerId,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'hostScore': hostScore,
        'guestScore': guestScore,
        'hostReady': hostReady,
        'guestReady': guestReady,
      };

  factory GameRoom.fromJson(Map<String, dynamic> json) => GameRoom(
        roomId: json['roomId'] as String,
        roomCode: json['roomCode'] as String,
        gameType: CoupleGameType.values.firstWhere(
            (e) => e.name == json['gameType'],
            orElse: () => CoupleGameType.countTrap),
        hostPlayerId: json['hostPlayerId'] as String,
        guestPlayerId: json['guestPlayerId'] as String?,
        status: RoomStatus.values.firstWhere((e) => e.name == json['status'],
            orElse: () => RoomStatus.waiting),
        createdAt: DateTime.parse(json['createdAt'] as String),
        hostScore: json['hostScore'] as int? ?? 0,
        guestScore: json['guestScore'] as int? ?? 0,
        hostReady: json['hostReady'] as bool? ?? false,
        guestReady: json['guestReady'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [
        roomId,
        roomCode,
        gameType,
        hostPlayerId,
        guestPlayerId,
        status,
        createdAt,
        hostScore,
        guestScore,
        hostReady,
        guestReady,
      ];
}
