import 'package:core_fe_infrastructure/src/constants/storage_keys.dart';
import 'package:core_fe_infrastructure/src/models/user_session.dart';
import 'package:core_fe_infrastructure/src/providers/session_provider.dart';
import 'package:mockito/mockito.dart';
import '../mocks/managers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core_fe_dart/src/enums/user_role.dart';

MockINoSqlStorageManager _mockCachedINoSqlStorageManager =
    MockINoSqlStorageManager();
MockINoSqlStorageManager _mockINoSqlStorageManager = MockINoSqlStorageManager();
void main() {
  var _sessionProvider = SessionProvider(
      _mockINoSqlStorageManager, _mockCachedINoSqlStorageManager);
  final tomorrowDate = DateTime.now().add(Duration(days: 1));
  var userSession = UserSession(
      expiryDate: tomorrowDate,
      token: 'TOKEN',
      userRole: UserRole.user,
      userId: 'ID1',
      username: 'UserName');
  test('valid session start', () async {
    when(
      _mockINoSqlStorageManager.addOrUpdate(
          key: currentUserFolder,
          data: userSession,
          expiryDate: userSession.expiryDate,
          shared: true),
    ).thenAnswer((realInvocation) => Future.value());
    when(
      _mockCachedINoSqlStorageManager.addOrUpdate(
          key: currentUserFolder,
          data: userSession,
          expiryDate: userSession.expiryDate,
          shared: true),
    ).thenAnswer((realInvocation) => Future.value());

    await _sessionProvider.startSession(userSession);
    verify(_mockINoSqlStorageManager.addOrUpdate(
        key: currentUserFolder,
        data: userSession,
        expiryDate: userSession.expiryDate,
        shared: true));
    verify(_mockCachedINoSqlStorageManager.addOrUpdate(
        key: currentUserFolder,
        data: userSession,
        expiryDate: userSession.expiryDate,
        shared: true));
  });

  test('end session', () async {
    when(_mockINoSqlStorageManager.delete(currentUserFolder, shared: true))
        .thenAnswer((realInvocation) => Future.value());
    when(_mockCachedINoSqlStorageManager.delete(currentUserFolder,
            shared: true))
        .thenAnswer((realInvocation) => Future.value());

    await _sessionProvider.endSession();

    verify(_mockINoSqlStorageManager.delete(currentUserFolder, shared: true));
    verify(_mockCachedINoSqlStorageManager.delete(currentUserFolder,
        shared: true));
  });

  test('get current sessoin from cached storage', () async {
    when(_mockCachedINoSqlStorageManager.get<UserSession>(currentUserFolder,
            shared: true, ignoreExpiry: true))
        .thenAnswer((realInvocation) => Future.value(userSession));
    var currentSession = await _sessionProvider.getCurrentSession();

    verify(
      _mockCachedINoSqlStorageManager.get<UserSession>(currentUserFolder,
          shared: true, ignoreExpiry: true),
    );
    verifyNever(
      _mockINoSqlStorageManager.get<UserSession>(currentUserFolder,
          shared: true, ignoreExpiry: true),
    );
    expect(currentSession, userSession);
  });

  test('get current sessoin from disk storage', () async {
    when(_mockCachedINoSqlStorageManager.get<UserSession>(currentUserFolder,
            shared: true, ignoreExpiry: true))
        .thenAnswer((realInvocation) => Future.value(null));

    when(_mockINoSqlStorageManager.get<UserSession>(currentUserFolder,
            shared: true, ignoreExpiry: true))
        .thenAnswer((realInvocation) => Future.value(userSession));
    var currentSession = await _sessionProvider.getCurrentSession();

    verify(
      _mockCachedINoSqlStorageManager.get<UserSession>(currentUserFolder,
          shared: true, ignoreExpiry: true),
    );
    verify(
      _mockINoSqlStorageManager.get<UserSession>(currentUserFolder,
          shared: true, ignoreExpiry: true),
    );
    expect(currentSession, userSession);
  });

  test('update Credentials with valid Credentials', () async {
    when(_mockCachedINoSqlStorageManager.addOrUpdate<UserSession>(
            key: currentUserFolder,
            data: userSession,
            shared: true,
            expiryDate: userSession.expiryDate))
        .thenAnswer((realInvocation) => Future.value());
    when(_mockINoSqlStorageManager.addOrUpdate<UserSession>(
            key: currentUserFolder,
            data: userSession,
            shared: true,
            expiryDate: userSession.expiryDate))
        .thenAnswer((realInvocation) => Future.value());

    await _sessionProvider.updateSession(userSession);

    verify(_mockCachedINoSqlStorageManager.addOrUpdate<UserSession>(
        key: currentUserFolder,
        data: userSession,
        shared: true,
        expiryDate: userSession.expiryDate));
    verify(_mockINoSqlStorageManager.addOrUpdate<UserSession>(
        key: currentUserFolder,
        data: userSession,
        shared: true,
        expiryDate: userSession.expiryDate));
  });
}
