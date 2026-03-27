import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

final _allowedHosts = <String>{
  'www.cabq.gov',
  'cabq.gov',
};

bool isAllowedCabqUrl(Uri uri) {
  if (uri.scheme != 'https') return false;
  return _allowedHosts.contains(uri.host.toLowerCase());
}

Future<bool> openCabqLearnMore(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null || !isAllowedCabqUrl(uri)) {
    if (kDebugMode) debugPrint('Blocked URL: $url');
    return false;
  }
  if (!await canLaunchUrl(uri)) return false;
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
