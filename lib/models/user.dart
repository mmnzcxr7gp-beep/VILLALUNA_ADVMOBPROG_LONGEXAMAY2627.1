class User {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String gender;
  final String image;
  final String token;
  final String role;
  final String department;
  final String university;

  const User({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.gender = '',
    this.image = '',
    this.token = '',
    this.role = 'Student',
    this.department = 'College of Computing and Information Technologies',
    this.university = 'National University',
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.isNotEmpty ? name : username;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final rawUsername =
        json['username'] ?? json['userName'] ?? json['user_name'] ?? '';
    final rawFirstName =
        json['firstName'] ?? json['first_name'] ?? json['firstname'] ?? '';
    final rawLastName =
        json['lastName'] ?? json['last_name'] ?? json['lastname'] ?? '';
    final rawFullName = json['fullName'] ?? json['name'] ?? '';

    final resolvedFirstName = rawFirstName.toString();
    final resolvedLastName = rawLastName.toString();
    final resolvedUsername = rawUsername.toString();
    final resolvedFullName = rawFullName.toString().trim();
    final fullNameParts = resolvedFullName.split(RegExp(r'\s+'));

    return User(
      id: (json['id'] as num?)?.toInt() ?? 0,
      username: resolvedUsername.isNotEmpty ? resolvedUsername : 'student',
      firstName: resolvedFirstName.isNotEmpty
          ? resolvedFirstName
          : (fullNameParts.length > 1 ? fullNameParts.first : ''),
      lastName: resolvedLastName.isNotEmpty
          ? resolvedLastName
          : (fullNameParts.length > 1
              ? fullNameParts.sublist(1).join(' ')
              : ''),
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      token: (json['token'] ?? json['accessToken'])?.toString() ?? '',
      role: json['role']?.toString() ?? 'Student',
      department: json['department']?.toString() ??
          'College of Computing and Information Technologies',
      university: json['university']?.toString() ?? 'National University',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'gender': gender,
      'image': image,
      'token': token,
      'role': role,
      'department': department,
      'university': university,
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? gender,
    String? image,
    String? token,
    String? role,
    String? department,
    String? university,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      image: image ?? this.image,
      token: token ?? this.token,
      role: role ?? this.role,
      department: department ?? this.department,
      university: university ?? this.university,
    );
  }
}
