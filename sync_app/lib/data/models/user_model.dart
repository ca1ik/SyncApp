import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.partnerUid,
    this.coupleId,
    this.isPro = false,
    this.fcmToken = '',
    this.createdAt,
    this.lastActiveAt,
  });

  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? partnerUid;
  final String? coupleId;
  final bool isPro;
  final String fcmToken;
  final DateTime? createdAt;
  final DateTime? lastActiveAt;

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? partnerUid,
    String? coupleId,
    bool? isPro,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? lastActiveAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      partnerUid: partnerUid ?? this.partnerUid,
      coupleId: coupleId ?? this.coupleId,
      isPro: isPro ?? this.isPro,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'partnerUid': partnerUid,
        'coupleId': coupleId,
        'isPro': isPro,
        'fcmToken': fcmToken,
        'createdAt': createdAt?.toIso8601String(),
        'lastActiveAt': lastActiveAt?.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String?,
        photoUrl: json['photoUrl'] as String?,
        partnerUid: json['partnerUid'] as String?,
        coupleId: json['coupleId'] as String?,
        isPro: json['isPro'] as bool? ?? false,
        fcmToken: json['fcmToken'] as String? ?? '',
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        lastActiveAt: json['lastActiveAt'] != null
            ? DateTime.parse(json['lastActiveAt'] as String)
            : null,
      );

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoUrl,
        partnerUid,
        coupleId,
        isPro,
        fcmToken,
        createdAt,
        lastActiveAt,
      ];
}
