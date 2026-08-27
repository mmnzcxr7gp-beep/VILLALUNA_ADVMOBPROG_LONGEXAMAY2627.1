class CommentUser {
  final int id;
  final String username;
  final String fullName;

  CommentUser({
    required this.id,
    required this.username,
    required this.fullName,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: json['username']?.toString() ?? '',
      fullName: json['fullName']?.toString() ??
          json['username']?.toString() ??
          'Community Member',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'fullName': fullName,
      };
}

class Comment {
  final int id;
  final String body;
  final int postId;
  int likes;
  final CommentUser user;
  bool isLiked;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.body,
    required this.postId,
    required this.likes,
    required this.user,
    this.isLiked = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Comment.fromJson(Map<String, dynamic> json) {
    CommentUser userObj;
    if (json['user'] is Map<String, dynamic>) {
      userObj = CommentUser.fromJson(json['user']);
    } else if (json['user'] is Map) {
      userObj = CommentUser.fromJson(Map<String, dynamic>.from(json['user']));
    } else {
      userObj = CommentUser(
        id: (json['userId'] as num?)?.toInt() ?? 0,
        username: json['username']?.toString() ?? 'member',
        fullName: json['fullName']?.toString() ?? 'Community Member',
      );
    }

    return Comment(
      id: (json['id'] as num?)?.toInt() ?? 0,
      body: json['body']?.toString() ?? '',
      postId: (json['postId'] as num?)?.toInt() ??
          (json['post_id'] as num?)?.toInt() ??
          0,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      user: userObj,
      isLiked: false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'body': body,
        'postId': postId,
        'likes': likes,
        'user': user.toJson(),
      };
}
