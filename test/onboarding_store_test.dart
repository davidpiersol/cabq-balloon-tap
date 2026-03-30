import 'package:balloon_tap/data/onboarding_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('isOnboardingComplete is false by default', () async {
    expect(await OnboardingStore.isOnboardingComplete(), false);
  });

  test('markOnboardingComplete persists', () async {
    await OnboardingStore.markOnboardingComplete();
    expect(await OnboardingStore.isOnboardingComplete(), true);
  });
}
