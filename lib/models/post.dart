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
        parsedLikes = (json['reactions']['likes'] as num?)?.toInt() ?? 0;
        parsedDislikes = (json['reactions']['dislikes'] as num?)?.toInt() ?? 0;
      } else if (json['reactions'] is num) {
        parsedLikes = (json['reactions'] as num).toInt();
      }
    } else {
      parsedLikes = (json['likes'] as num?)?.toInt() ?? 0;
      parsedDislikes = (json['dislikes'] as num?)?.toInt() ?? 0;
    }

    final int postIdent = json['id'] ?? json['postId'] ?? json['post_id'] ?? 0;

    return Post(
      id: postIdent,
      postId: json['postId'] ?? json['post_id'] ?? postIdent,
      userId: json['userId'] ?? json['user_id'] ?? 0,
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      tags: (json['tags'] as List?)?.map((t) => t.toString()).toList() ?? [],
      likes: parsedLikes,
      dislikes: parsedDislikes,
      views: (json['views'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
      updatedAt: json['updatedAt'] ?? json['updated_at'] ?? '',
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
