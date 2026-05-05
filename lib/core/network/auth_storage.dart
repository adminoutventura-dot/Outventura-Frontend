import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final authStorageProvider = Provider<AuthStorage>((ref) => AuthStorage());

class AuthStorage {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  final _storage = const FlutterSecureStorage();

  Future<String?> getToken() => _storage.read(key: _accessKey);
  Future<void> setToken(String token) => _storage.write(key: _accessKey, value: token);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshKey);
  Future<void> setRefreshToken(String token) => _storage.write(key: _refreshKey, value: token);

  Future<void> saveTokens(String access, String refresh) async {
    await setToken(access);
    await setRefreshToken(refresh);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}
