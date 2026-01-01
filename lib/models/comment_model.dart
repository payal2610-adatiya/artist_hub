// lib/models/comment_model.dart
class CommentModel {
  final int id;
  final int userId;
  final int mediaId;
  final String comment;
  final String userName;
  final String? userAvatar;
  final DateTime createdAt;
  final bool isCurrentUserComment;

  CommentModel({
    required this.id,
    required this.userId,
    required this.mediaId,
    required this.comment,
    required this.userName,
    this.userAvatar,
    required this.createdAt,
    required this.isCurrentUserComment,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json, int currentUserId) {
    return CommentModel(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      mediaId: int.tryParse(json['media_id']?.toString() ?? '0') ?? 0,
      comment: json['comment']?.toString() ?? '',
      userName: json['name']?.toString() ?? 'User',
      userAvatar: json['avatar']?.toString(),
      createdAt: DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toString()),
      isCurrentUserComment: (int.tryParse(json['user_id']?.toString() ?? '0') ?? 0) == currentUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'media_id': mediaId,
      'comment': comment,
      'name': userName,
      'avatar': userAvatar,
      'created_at': createdAt.toIso8601String(),
    };
  }
}