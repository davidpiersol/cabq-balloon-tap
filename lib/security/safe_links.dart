import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

final _allowedHosts = <String>{
  'www.cabq.gov',
  'cabq.gov',
};

/// True only for fixed https://cabq.gov or https://www.cabq.gov URLs on port 443, no credentials.
bool isAllowedCabqUrl(Uri uri) {
  if (uri.scheme != 'https') return false;
  if (uri.userInfo.isNotEmpty) return false;
  if (!uri.hasAuthority || uri.host.isEmpty) return false;
  final port = uri.hasPort ? uri.port : 443;
  if (port != 443) return false;
  final host = uri.host.toLowerCase();
  return _allowedHosts.contains(host);
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
