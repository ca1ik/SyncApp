import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/game_model.dart';
import '../../data/models/game_room_model.dart';

/// Service for managing game rooms.
/// Currently uses SharedPreferences (local-only).
/// Ready for online migration — swap persistence layer to Firestore/WebSocket.
class GameRoomService {
  GameRoomService({required SharedPreferences prefs}) : _prefs = prefs;

  final SharedPreferences _prefs;
  static const String _roomsKey = 'sync_game_rooms';
  static const String _activeRoomKey = 'sync_active_room';
  static const _uuid = Uuid();

  /// Create a new room and return it
  Future<GameRoom> createRoom({
    required CoupleGameType gameType,
    required String hostPlayerId,
  }) async {
    final room = GameRoom(
      roomId: _uuid.v4(),
      roomCode: GameRoom.generateRoomCode(),
      gameType: gameType,
      hostPlayerId: hostPlayerId,
      createdAt: DateTime.now(),
      hostReady: true,
    );

    final rooms = await _getAllRooms();
    rooms.add(room);
    await _saveAllRooms(rooms);
    await _prefs.setString(_activeRoomKey, room.roomId);
    return room;
  }

  /// Join a room by 4-digit code
  Future<GameRoom?> joinRoom({
    required String roomCode,
    required String guestPlayerId,
  }) async {
    final rooms = await _getAllRooms();
    final idx = rooms.indexWhere(
        (r) => r.roomCode == roomCode && r.status == RoomStatus.waiting);
    if (idx == -1) return null;

    final updated = rooms[idx].copyWith(
      guestPlayerId: guestPlayerId,
      guestReady: true,
      status: RoomStatus.ready,
    );
    rooms[idx] = updated;
    await _saveAllRooms(rooms);
    await _prefs.setString(_activeRoomKey, updated.roomId);
    return updated;
  }

  /// Get active room
  Future<GameRoom?> getActiveRoom() async {
    final activeId = _prefs.getString(_activeRoomKey);
    if (activeId == null) return null;
    final rooms = await _getAllRooms();
    try {
      return rooms.firstWhere((r) => r.roomId == activeId);
    } catch (_) {
      return null;
    }
  }

  /// Update room status
  Future<void> updateRoomStatus(String roomId, RoomStatus status) async {
    final rooms = await _getAllRooms();
    final idx = rooms.indexWhere((r) => r.roomId == roomId);
    if (idx == -1) return;
    rooms[idx] = rooms[idx].copyWith(status: status);
    await _saveAllRooms(rooms);
  }

  /// Update scores
  Future<void> updateScores(
      String roomId, int hostScore, int guestScore) async {
    final rooms = await _getAllRooms();
    final idx = rooms.indexWhere((r) => r.roomId == roomId);
    if (idx == -1) return;
    rooms[idx] = rooms[idx].copyWith(
      hostScore: hostScore,
      guestScore: guestScore,
    );
    await _saveAllRooms(rooms);
  }

  /// Close active room
  Future<void> closeActiveRoom() async {
    final activeId = _prefs.getString(_activeRoomKey);
    if (activeId != null) {
      await updateRoomStatus(activeId, RoomStatus.finished);
    }
    await _prefs.remove(_activeRoomKey);
  }

  /// Get room history
  Future<List<GameRoom>> getRoomHistory() async {
    final rooms = await _getAllRooms();
    rooms.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return rooms.take(50).toList();
  }

  Future<List<GameRoom>> _getAllRooms() async {
    final raw = _prefs.getString(_roomsKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => GameRoom.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAllRooms(List<GameRoom> rooms) async {
    final json = jsonEncode(rooms.map((r) => r.toJson()).toList());
    await _prefs.setString(_roomsKey, json);
  }
}
