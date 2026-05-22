class ChangePasswordRequest {
  final String userName;
  final String password;

  ChangePasswordRequest({required this.userName, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'password': password,
    };
  }
}
