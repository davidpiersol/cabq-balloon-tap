import 'package:balloon_tap/data/score_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('saveIfBest only increases stored value', () async {
    expect(await ScoreStore.loadBest(), 0);
    expect(await ScoreStore.saveIfBest(42), 42);
    expect(await ScoreStore.loadBest(), 42);
    expect(await ScoreStore.saveIfBest(10), 42);
    expect(await ScoreStore.loadBest(), 42);
    expect(await ScoreStore.saveIfBest(100), 100);
    expect(await ScoreStore.loadBest(), 100);
  });

  test('sanitizeScore clamps range', () {
    expect(ScoreStore.sanitizeScore(-5), 0);
    expect(ScoreStore.sanitizeScore(ScoreStore.maxReasonableScore + 1), ScoreStore.maxReasonableScore);
  });

  test('loadBest repairs corrupted huge stored value', () async {
    SharedPreferences.setMockInitialValues({
      'balloon_tap_best_score_v1': 999999999999,
    });
    expect(await ScoreStore.loadBest(), ScoreStore.maxReasonableScore);
  });

  test('saveIfBest ignores negative scores', () async {
    expect(await ScoreStore.saveIfBest(-1), 0);
    expect(await ScoreStore.loadBest(), 0);
  });
}
