import 'package:balloon_tap/security/safe_links.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('allowlists cabq.gov https only', () {
    expect(isAllowedCabqUrl(Uri.parse('https://www.cabq.gov/')), isTrue);
    expect(isAllowedCabqUrl(Uri.parse('https://cabq.gov/path')), isTrue);
    expect(isAllowedCabqUrl(Uri.parse('https://www.cabq.gov/culturalservices/balloonmuseum')), isTrue);
    expect(isAllowedCabqUrl(Uri.parse('http://www.cabq.gov/')), isFalse);
    expect(isAllowedCabqUrl(Uri.parse('https://phishing-cabq.gov.evil.com/')), isFalse);
    expect(isAllowedCabqUrl(Uri.parse('https://user:pass@www.cabq.gov/')), isFalse);
    expect(isAllowedCabqUrl(Uri.parse('https://www.cabq.gov:8443/')), isFalse);
    expect(isAllowedCabqUrl(Uri.parse('https://www.cabq.gov:443/')), isTrue);
    expect(isAllowedCabqUrl(Uri.parse('javascript:alert(1)')), isFalse);
  });
}
