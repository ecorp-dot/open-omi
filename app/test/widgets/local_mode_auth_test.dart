import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:omi/backend/preferences.dart';
import 'package:omi/l10n/app_localizations.dart';
import 'package:omi/pages/onboarding/auth.dart';
import 'package:omi/providers/auth_provider.dart';
import 'package:omi/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('continue locally creates local identity without Firebase sign-in', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferencesUtil.init();
    final authProvider = AuthenticationProvider(initializeListeners: false);
    addTearDown(authProvider.dispose);

    var continued = false;
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthenticationProvider>.value(
        value: authProvider,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: AuthComponent(onSignIn: () => continued = true)),
        ),
      ),
    );

    await tester.tap(find.text('Continue locally'));
    await tester.pump();

    expect(continued, isTrue);
    expect(SharedPreferencesUtil().localModeEnabled, isTrue);
    expect(SharedPreferencesUtil().uid, startsWith('local-'));
    expect(SharedPreferencesUtil().autoSyncOfflineRecordings, isFalse);
    expect(authProvider.isSignedIn(), isTrue);
    expect(AuthService.instance.isSignedIn(), isTrue);
  });
}
