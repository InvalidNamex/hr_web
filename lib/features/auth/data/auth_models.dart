import 'package:equatable/equatable.dart';

class LoginRequest extends Equatable {
  const LoginRequest({required this.username, required this.password});

  final String username;
  final String password;

  Map<String, dynamic> toJson() => {'Username': username, 'Password': password};

  @override
  List<Object?> get props => [username, password];
}

class LoginResponse extends Equatable {
  const LoginResponse({
    required this.token,
    required this.hrGroupId,
    required this.hrGroupName,
    this.userId = 0,
  });

  final String token;
  final String hrGroupId;
  final String hrGroupName;

  /// The logged-in user's ID.
  final int userId;

  /// Backward-compatible alias used across existing feature code.
  int get empId => userId;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // API wraps data in a "data" key
    final data = json['data'] as Map<String, dynamic>? ?? json;
    final userIdRaw =
          data['userId'] ??
          data['UserId'] ??
          data['userID'] ??
          data['UserID'] ??
          data['empId'] ??
          data['EmpId'] ??
          data['empID'] ??
          data['EmpID'] ??
          data['employeeId'] ??
          data['EmployeeId'] ??
          data['id'] ??
          data['ID'] ??
          0;
    return LoginResponse(
      token: data['token'] as String,
      hrGroupId: data['hrGroupId'] as String,
      hrGroupName: data['hrGroupName'] as String,
      userId: userIdRaw is int ? userIdRaw : int.tryParse('$userIdRaw') ?? 0,
    );
  }

  @override
  List<Object?> get props => [token, hrGroupId, hrGroupName, userId];
}
