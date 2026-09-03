class Post {
  final int id;
  final int postId;
  final int userId;
  final String title;
  final String body;
  final List<String> tags;
  int likes;
  int dislikes;
  final int views;
  final String createdAt;
  final String updatedAt;
  bool isLiked;

  Post({
    required this.id,
    required this.postId,
    required this.userId,
    this.title = '',
    required this.body,
    this.tags = const [],
    required this.likes,
    required this.dislikes,
    this.views = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isLiked = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    int parsedLikes = 0;
    int parsedDislikes = 0;

    if (json['reactions'] != null) {
      if (json['reactions'] is Map) {
        final reactionMap = Map<String, dynamic>.from(json['reactions'] as Map);
        parsedLikes =
            (reactionMap['likes'] as num?)?.toInt() ??
                (reactionMap['like'] as num?)?.toInt() ??
                0;
        parsedDislikes =
            (reactionMap['dislikes'] as num?)?.toInt() ??
                (reactionMap['dislike'] as num?)?.toInt() ??
                0;
      } else if (json['reactions'] is num) {
        parsedLikes = (json['reactions'] as num).toInt();
      }
    } else {
      parsedLikes = (json['likes'] as num?)?.toInt() ?? 0;
      parsedDislikes = (json['dislikes'] as num?)?.toInt() ?? 0;
    }

    final tags = (json['tags'] as List?)?.map((tag) {
      if (tag is Map) {
        return (tag['name'] ?? tag['value'] ?? tag['tag'] ?? '').toString();
      }
      return tag.toString();
    }).where((tag) => tag.isNotEmpty).toList() ?? <String>[];

    final int postIdent =
        (json['id'] as num?)?.toInt() ??
            (json['postId'] as num?)?.toInt() ??
            (json['post_id'] as num?)?.toInt() ??
            0;

    return Post(
      id: postIdent,
      postId: (json['postId'] as num?)?.toInt() ??
          (json['post_id'] as num?)?.toInt() ??
          postIdent,
      userId: (json['userId'] as num?)?.toInt() ??
          (json['user_id'] as num?)?.toInt() ??
          0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      tags: tags,
      likes: parsedLikes,
      dislikes: parsedDislikes,
      views: (json['views'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? json['updated_at']?.toString() ?? '',
      isLiked: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'title': title,
      'body': body,
      'tags': tags,
      'reactions': {
        'likes': likes,
        'dislikes': dislikes,
      },
      'views': views,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Post copyWith({
    int? id,
    int? postId,
    int? userId,
    String? title,
    String? body,
    List<String>? tags,
    int? likes,
    int? dislikes,
    int? views,
    String? createdAt,
    String? updatedAt,
    bool? isLiked,
  }) {
    return Post(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      tags: tags ?? this.tags,
      likes: likes ?? this.likes,
      dislikes: dislikes ?? this.dislikes,
      views: views ?? this.views,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
