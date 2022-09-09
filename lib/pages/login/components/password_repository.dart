class PasswordRepository {
  Future<String> getCurrentPassword() async {
    return 'adminadmin';
  }

  Future<void> changePassword(String password) async {
    print("Map event =============="+password);
    await Future.delayed(Duration(seconds: 1));
    print("Map event =============="+password);

  }
}
