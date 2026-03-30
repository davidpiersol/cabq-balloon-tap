import 'package:balloon_tap/theme/concept_assets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('concept PNGs load from asset bundle', () async {
    for (final path in ConceptAssets.all) {
      final data = await rootBundle.load(path);
      expect(data.lengthInBytes, greaterThan(50 * 1024),
          reason: 'expected real PNG payload for $path');
    }
  });
}
