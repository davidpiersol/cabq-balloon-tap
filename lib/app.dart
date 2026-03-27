import 'package:flutter/material.dart';

import 'theme/cabq_theme.dart';
import 'ui/game_shell.dart';

class BalloonTapApp extends StatelessWidget {
  const BalloonTapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Balloon Tap',
      debugShowCheckedModeBanner: false,
      theme: CabqTheme.light,
      home: const GameShell(),
    );
  }
}
