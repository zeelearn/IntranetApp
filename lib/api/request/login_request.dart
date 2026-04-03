class LoginRequestModel {
  String? userName;
  String? password;
  String? token;
  String? source;

  LoginRequestModel({this.userName, this.password, this.token,this.source});

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'userName': userName,
      'password': password,
      'token': token,
      'source': source,
    };

    return map;
  }
}
