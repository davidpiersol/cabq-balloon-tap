import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

/// Balloon Tap — lightweight endless game with Albuquerque / Balloon Fiesta flair.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const BalloonTapApp());
}
