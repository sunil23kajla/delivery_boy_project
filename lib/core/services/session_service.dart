import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:delivery_boy/data/models/user_model.dart';
import 'package:delivery_boy/core/constants/app_constants.dart';

class SessionService extends GetxService {
  final _storage = GetStorage();
  final _token = RxnString();
  final _user = Rxn<UserModel>();

  String? get token => _token.value;
  UserModel? get user => _user.value;

  bool get isLoggedIn => _token.value != null;

  @override
  void onInit() {
    super.onInit();
    _loadSession();
  }

  void _loadSession() {
    final token = _storage.read<String>(AppConstants.tokenKey);
    final userJson = _storage.read<String>('user_data');

    if (token != null) {
      _token.value = token;
    }
    if (userJson != null) {
      try {
        _user.value = UserModel.fromJson(jsonDecode(userJson));
      } catch (e) {
        print('Error decoding user session: $e');
      }
    }
  }

  void saveSession(UserModel userModel) {
    _user.value = userModel;
    _token.value = userModel.token;

    _storage.write(AppConstants.tokenKey, userModel.token);
    _storage.write('user_data', jsonEncode(userModel.toJson()));
  }

  void clearSession() {
    _token.value = null;
    _user.value = null;
    _storage.remove(AppConstants.tokenKey);
    _storage.remove('user_data');
  }
}
