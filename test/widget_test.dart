import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:villaluna_advmobprog_longexam1/main.dart';
import 'package:villaluna_advmobprog_longexam1/models/post.dart';
import 'package:villaluna_advmobprog_longexam1/models/user.dart';
import 'package:villaluna_advmobprog_longexam1/models/comment.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('Post model serialization and deserialization', () {
    final json = {
      'id': 1,
      'title': 'Test Post',
      'body': 'This is a test post body',
      'userId': 5,
      'reactions': {'likes': 15, 'dislikes': 2},
      'views': 120,
      'tags': ['flutter', 'mobile'],
      'createdAt': '2026-08-27',
      'updatedAt': '2026-08-27',
    };

    final post = Post.fromJson(json);
    expect(post.id, 1);
    expect(post.body, 'This is a test post body');
    expect(post.likes, 15);
    expect(post.dislikes, 2);
    expect(post.tags.length, 2);

    final serialized = post.toJson();
    expect(serialized['id'], 1);
    expect(serialized['reactions']['likes'], 15);
  });

  test('User model serialization and deserialization', () {
    final json = {
      'id': 10,
      'username': 'samirian',
      'firstName': 'Sam Irian',
      'lastName': 'Villaluna',
      'email': 'sam@nu.edu.ph',
      'role': 'Student',
    };

    final user = User.fromJson(json);
    expect(user.id, 10);
    expect(user.fullName, 'Sam Irian Villaluna');
    expect(user.username, 'samirian');
  });

  test('Comment model serialization and deserialization', () {
    final json = {
      'id': 101,
      'body': 'Awesome post!',
      'postId': 1,
      'likes': 4,
      'user': {
        'id': 10,
        'username': 'samirian',
        'fullName': 'Sam Irian Villaluna',
      }
    };

    final comment = Comment.fromJson(json);
    expect(comment.id, 101);
    expect(comment.body, 'Awesome post!');
    expect(comment.likes, 4);
    expect(comment.user.fullName, 'Sam Irian Villaluna');
  });

  test('Models handle alternate API field names and nested reactions', () {
    final user = User.fromJson({
      'id': 12,
      'fullName': 'Jane Doe',
      'email': 'jane@example.com',
    });
    expect(user.firstName, 'Jane');
    expect(user.lastName, 'Doe');

    final comment = Comment.fromJson({
      'id': 202,
      'body': 'Nice work',
      'postId': 7,
      'reactions': {'likes': 9},
      'user': {
        'id': 12,
        'firstName': 'Jane',
        'lastName': 'Doe',
      },
    });
    expect(comment.likes, 9);
    expect(comment.user.fullName, 'Jane Doe');
  });

  testWidgets('App smoke test and splash screen rendering', (WidgetTester tester) async {
    await tester.pumpWidget(const VillalunaApp());
    expect(find.byType(VillalunaApp), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
