class LoginRequestModel {
  String userName;
  String password;

  LoginRequestModel(
      {required this.userName,
        required this.password,
      });

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'userName': userName.trim(),
      'password': password.trim(),
    };

    return map;
  }
}