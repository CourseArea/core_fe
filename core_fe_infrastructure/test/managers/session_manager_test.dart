import 'package:core_fe_infrastructure/src/managers/session_manager.dart';
import 'package:core_fe_infrastructure/src/models/user_session.dart';
import 'package:mockito/mockito.dart';
import '../mocks/providers_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:core_fe_dart/src/enums/user_role.dart';

MockISessionProvider _mockISessionProvider = MockISessionProvider();
void main() {
  var _sessionManager = SessionManager(_mockISessionProvider);
  final nowDate = DateTime.now();
  final beforeNowDate = nowDate.subtract(Duration(seconds: 1));
  final tomorrowDate = DateTime.now().add(Duration(days: 1));

  test('valid session start', () async {
    var userSession = UserSession(
        expiryDate: tomorrowDate,
        token: 'TOKEN',
        userRole: UserRole.user,
        userId: 'ID1',
        username: 'UserName');

    await _sessionManager.startSession(
      username: userSession.username,
      token: userSession.token,
      userId: userSession.userId,
      expiryDate: userSession.expiryDate,
      userRole: userSession.userRole,
    );
    verify(_mockISessionProvider.startSession(userSession));
  });
  test('end session', () async {
    await _sessionManager.endSession();
    verify(_mockISessionProvider.endSession());
  });

  group('isAnonymousSession', () {
    var userSession = UserSession(
        expiryDate: tomorrowDate,
        token: 'TOKEN',
        userRole: UserRole.user,
        userId: 'ID1',
        username: 'UserName');

    test('isAnonymousSession when token is NOT empty', () async {
      when(_mockISessionProvider.getCurrentSession())
          .thenAnswer((realInvocation) => Future.value(userSession));

      var isAnonymous = await _sessionManager.isAnonymousSession();
      expect(isAnonymous, false);
    });

    test('isAnonymousSession when token is empty', () async {
      when(_mockISessionProvider.getCurrentSession()).thenAnswer(
          (realInvocation) => Future.value(userSession.updateCredentials(
              token: null, expiryDate: userSession.expiryDate)));

      var isAnonymous = await _sessionManager.isAnonymousSession();
      expect(isAnonymous, true);
    });
  });

  group('get current session', () {
    var userSession = UserSession(
        expiryDate: tomorrowDate,
        token: 'TOKEN',
        userRole: UserRole.user,
        userId: 'ID1',
        username: 'UserName');

    test('get current session', () async {
      await _sessionManager.getCurrentSession();
      verify(_mockISessionProvider.getCurrentSession());
    });
    test('Get session', () async {
      when(_mockISessionProvider.getCurrentSession())
          .thenAnswer((realInvocation) => Future.value(userSession));

      var session = await _sessionManager.getCurrentSession();
      expect(session, userSession);
    });

    test('get current session when token is empty', () async {
      when(_mockISessionProvider.getCurrentSession()).thenAnswer(
          (realInvocation) => Future.value(userSession.updateCredentials(
              token: null, expiryDate: userSession.expiryDate)));

      var session = await _sessionManager.getCurrentSession();
      expect(session, null);
    });
  });

  group('isSession Expired', () {
    var userSession = UserSession(
        expiryDate: tomorrowDate,
        token: 'TOKEN',
        userRole: UserRole.user,
        userId: 'ID1',
        username: 'UserName');

    test('isSessionExpired when date is Not passed ', () async {
      when(_mockISessionProvider.getCurrentSession())
          .thenAnswer((realInvocation) => Future.value(userSession));
      var isExpired = await _sessionManager.isSessionExpired();
      expect(isExpired, false);
    });
    test('isSessionExpired when date is Not passed ', () async {
      when(_mockISessionProvider.getCurrentSession()).thenAnswer(
          (realInvocation) => Future.value(userSession.updateCredentials(
              token: userSession.token, expiryDate: beforeNowDate)));
      var isExpired = await _sessionManager.isSessionExpired();
      expect(isExpired, true);
    });
  });

  group('updateCredentials', () {
    var userSession = UserSession(
        expiryDate: nowDate,
        token: 'TOKEN1',
        userRole: UserRole.user,
        userId: 'ID1',
        username: 'UserName');

    test('update Credentials with valid Credentials', () async {
      var updatedSession = userSession.updateCredentials(
          token: 'TOKEN2', expiryDate: tomorrowDate);
      when(_mockISessionProvider.getCurrentSession())
          .thenAnswer((realInvocation) => Future.value(userSession));
      await _sessionManager.updateCredentials(
          token: 'TOKEN2', expiryDate: tomorrowDate);
      verify(_mockISessionProvider.getCurrentSession());
      verify(_mockISessionProvider.updateSession(updatedSession));
    });
    test('update Credentials with Invalid Credentials ', () async {
      when(_mockISessionProvider.getCurrentSession())
          .thenAnswer((realInvocation) => Future.value(userSession));
      ;
      expect(
          () async => await _sessionManager.updateCredentials(
              token: null, expiryDate: null),
          throwsAssertionError);
      expect(
          () async => await _sessionManager.updateCredentials(
              token: null, expiryDate: tomorrowDate),
          throwsAssertionError);
      expect(
          () async => await _sessionManager.updateCredentials(
              token: 'TOKEN2', expiryDate: null),
          throwsAssertionError);
    });
  });
}