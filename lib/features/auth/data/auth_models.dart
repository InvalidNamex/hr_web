import 'package:equatable/equatable.dart';

class LoginRequest extends Equatable {
  const LoginRequest({required this.username, required this.password});

  final String username;
  final String password;

  Map<String, dynamic> toJson() => {
        'Username': username,
        'Password': password,
      };

  @override
  List<Object?> get props => [username, password];
}

class LoginResponse extends Equatable {
  const LoginResponse({
    required this.token,
    required this.hrGroupId,
    required this.hrGroupName,
  });

  final String token;
  final String hrGroupId;
  final String hrGroupName;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // API wraps data in a "data" key
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return LoginResponse(
      token: data['token'] as String,
      hrGroupId: data['hrGroupId'] as String,
      hrGroupName: data['hrGroupName'] as String,
    );
  }

  @override
  List<Object?> get props => [token, hrGroupId, hrGroupName];
}
