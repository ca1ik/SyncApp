import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';

/// Yerel auth repository — SharedPreferences ile kullanıcı oturumu yönetimi.
/// Firebase kullanılmıyor; tüm veriler cihaz üzerinde saklanır.
class AuthRepository {
  AuthRepository({required SharedPreferences prefs, required Logger logger})
      : _prefs = prefs,
        _logger = logger {
    // Başlangıçta kayıtlı kullanıcıyı yükle
    final json = _prefs.getString(_currentUserKey);
    if (json != null) {
      try {
        _currentUser =
            UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
      } on Object catch (e) {
        _logger.e('Kayıtlı kullanıcı parse hatası', error: e);
      }
    }
    _authController.add(_currentUser);
  }

  final SharedPreferences _prefs;
  final Logger _logger;

  static const String _currentUserKey = 'sync_current_user';
  static const String _usersDbKey = 'sync_users_db';

  UserModel? _currentUser;
  final _authController = StreamController<UserModel?>.broadcast();

  /// Oturum durumu değişikliklerini dinle.
  Stream<UserModel?> get authStateChanges => _authController.stream;

  /// Şu anda oturum açmış kullanıcı.
  UserModel? get currentUser => _currentUser;

  /// E-posta ile kayıt ol.
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final usersDb = _getUsersDb();

    // E-posta kontrolü
    if (usersDb.containsKey(email)) {
      throw AuthException('Bu e-posta adresi zaten kayıtlı.');
    }

    final now = DateTime.now();
    final user = UserModel(
      uid: const Uuid().v4(),
      email: email,
      displayName: displayName ?? email.split('@').first,
      createdAt: now,
      lastActiveAt: now,
    );

    // Kullanıcıyı kaydet
    usersDb[email] = {
      ...user.toJson(),
      'password': password, // Basit yerel kayıt — üretimde hash kullanılır
    };
    await _saveUsersDb(usersDb);
    await _setCurrentUser(user);

    _logger.i('Yeni kullanıcı kayıt: ${user.email}');
    return user;
  }

  /// E-posta + şifre ile giriş yap.
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final usersDb = _getUsersDb();
    final userData = usersDb[email];

    if (userData == null) {
      throw AuthException('Kullanıcı bulunamadı.');
    }

    if (userData['password'] != password) {
      throw AuthException('Şifre hatalı.');
    }

    final user = UserModel.fromJson(userData).copyWith(
      lastActiveAt: DateTime.now(),
    );

    // Güncellenmiş kullanıcıyı kaydet
    usersDb[email] = {
      ...user.toJson(),
      'password': password,
    };
    await _saveUsersDb(usersDb);
    await _setCurrentUser(user);

    _logger.i('Giriş yapıldı: ${user.email}');
    return user;
  }

  /// Çıkış yap.
  Future<void> signOut() async {
    _logger.i('Çıkış yapıldı: ${_currentUser?.email}');
    _currentUser = null;
    await _prefs.remove(_currentUserKey);
    _authController.add(null);
  }

  /// Partner e-posta ile bağla.
  Future<UserModel> linkPartnerByEmail(String partnerEmail) async {
    if (_currentUser == null) {
      throw AuthException('Oturum açmanız gerekiyor.');
    }

    final usersDb = _getUsersDb();
    final partnerData = usersDb[partnerEmail];

    if (partnerData == null) {
      throw AuthException('Partner bulunamadı — kayıtlı olması gerekiyor.');
    }

    final partner = UserModel.fromJson(partnerData);

    if (partner.uid == _currentUser!.uid) {
      throw AuthException('Kendinizi partner olarak ekleyemezsiniz.');
    }

    final coupleId = const Uuid().v4();

    // Her iki kullanıcıyı da güncelle
    final updatedUser = _currentUser!.copyWith(
      partnerUid: partner.uid,
      coupleId: coupleId,
    );
    final updatedPartner = partner.copyWith(
      partnerUid: _currentUser!.uid,
      coupleId: coupleId,
    );

    // Kaydet
    usersDb[_currentUser!.email] = {
      ...updatedUser.toJson(),
      'password': usersDb[_currentUser!.email]!['password'],
    };
    usersDb[partnerEmail] = {
      ...updatedPartner.toJson(),
      'password': partnerData['password'],
    };
    await _saveUsersDb(usersDb);
    await _setCurrentUser(updatedUser);

    _logger.i('Partner bağlandı: $partnerEmail');
    return updatedUser;
  }

  /// Mevcut kullanıcı profilini getir.
  Future<UserModel?> getCurrentUserProfile() async {
    return _currentUser;
  }

  /// Kullanıcı profilini güncelle.
  Future<UserModel> updateProfile(UserModel updated) async {
    final usersDb = _getUsersDb();
    final password = usersDb[updated.email]?['password'] ?? '';
    usersDb[updated.email] = {
      ...updated.toJson(),
      'password': password,
    };
    await _saveUsersDb(usersDb);
    await _setCurrentUser(updated);
    return updated;
  }

  // ── Private Helpers ──

  Future<void> _setCurrentUser(UserModel user) async {
    _currentUser = user;
    await _prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    _authController.add(user);
  }

  Map<String, dynamic> _getUsersDb() {
    final raw = _prefs.getString(_usersDbKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw);
    return (decoded as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)),
    );
  }

  Future<void> _saveUsersDb(Map<String, dynamic> db) async {
    await _prefs.setString(_usersDbKey, jsonEncode(db));
  }

  void dispose() {
    _authController.close();
  }
}

/// Auth işlem hatası.
class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => 'AuthException: $message';
}
