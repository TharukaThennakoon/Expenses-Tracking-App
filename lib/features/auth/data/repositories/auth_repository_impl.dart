import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._dataSource);

  final AuthDataSource _dataSource;

  @override
  Future<AuthUser?> currentUser() => _dataSource.currentUser();

  @override
  Stream<AuthUser?> watchCurrentUser() => _dataSource.watchCurrentUser();

  @override
  Future<AuthUser> signIn({required String email, required String password}) =>
      _dataSource.signIn(email: email, password: password);

  @override
  Future<AuthUser> signUp({
    required String fullName,
    required String email,
    required String password,
  }) =>
      _dataSource.signUp(fullName: fullName, email: email, password: password);

  @override
  Future<void> sendPasswordReset(String email) =>
      _dataSource.sendPasswordReset(email);

  @override
  Future<void> signOut() => _dataSource.signOut();
}
