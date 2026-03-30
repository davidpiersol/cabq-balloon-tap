import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onPlay});

  final VoidCallback onPlay;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _loadCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _loadCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _loadCtrl.dispose();
    super.dispose();
  }

  TextStyle get _titleStyle => GoogleFonts.playfairDisplay(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        height: 1.05,
        letterSpacing: 0.5,
        color: const Color(0xFFFFF8E7),
        shadows: const [
          Shadow(blurRadius: 18, color: Color(0x88000000), offset: Offset(0, 4)),
          Shadow(blurRadius: 8, color: Color(0x66000000)),
          Shadow(blurRadius: 24, color: Color(0x44FFD54F)),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/images/splash_background.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        // Light vignette only — keep art visible
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0x33000000),
                Colors.transparent,
                Color(0x44000000),
              ],
              stops: [0.0, 0.4, 1.0],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        SafeArea(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  SizedBox(height: mq.size.height * 0.08),
                  // Title — two lines, no version number
                  Text('Balloon', textAlign: TextAlign.center, style: _titleStyle),
                  Text('Tap', textAlign: TextAlign.center, style: _titleStyle),
                  const SizedBox(height: 14),
                  Text(
                    'MASS ASCENSION ADVENTURE',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      letterSpacing: 3.2,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xE6FFF8E7),
                    ),
                  ),
                  const Spacer(),
                  // PLAY + TAP TO PLAY (mockup)
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB74D), Color(0xFFE65100)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x55000000),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Color(0x33FF9800),
                            blurRadius: 24,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: widget.onPlay,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 24,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'PLAY',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 4,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(
                                        blurRadius: 8,
                                        color: Colors.black26,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'TAP TO PLAY',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2,
                                    color: Colors.white.withValues(alpha: 0.95),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Loading bar + balloon thumb
                  _SplashLoadingBar(animation: _loadCtrl),
                  const SizedBox(height: 10),
                  Text(
                    'LOADING...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 10,
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  SizedBox(height: mq.padding.bottom + 20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SplashLoadingBar extends StatelessWidget {
  const _SplashLoadingBar({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        return LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            final fillW = w * (0.25 + 0.65 * ((t * 2) % 1.0));
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: fillW.clamp(0.0, w),
                      height: 8,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFB74D), Color(0xFFFF6D00)],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (fillW - 12).clamp(0.0, w - 24),
                  top: -12,
                  child: const Icon(
                    Icons.wb_sunny_rounded,
                    size: 24,
                    color: Color(0xFFFFB74D),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
