import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/strings.dart';
import '../theme.dart';
import '../widgets/khatam_logo.dart';
import '../widgets/zellige.dart';

/// true mlli tsali l animation dyal dekhla (l router kaytsennaha).
class SplashDone extends Notifier<bool> {
  @override
  bool build() => false;
  void finish() => state = true;
}

final splashDoneProvider = NotifierProvider<SplashDone, bool>(SplashDone.new);

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(() {
      if (mounted) ref.read(splashDoneProvider.notifier).finish();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ila l user tlab "t9lil l 7araka", nbanno l logo kamel dghya.
    if (MediaQuery.of(context).disableAnimations && !_c.isCompleted) {
      _c.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(splashDoneProvider.notifier).finish());
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _seg(double a, double b) => ((_c.value - a) / (b - a)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: dark ? const Color(0xFF0B1F17) : const Color(0xFF134232),
      body: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          // L logo kayakhod 0 → 0.75 dyal l wa9t, mn ba3d l ism o l slogan.
          final logoT = _seg(0, 0.75);
          final word = Curves.easeOut.transform(_seg(0.6, 0.85));
          final tag = _seg(0.75, 1);
          final ring = _seg(0.35, 0.8);
          return Stack(children: [
            Positioned.fill(child: CustomPaint(painter: ZelligePainter(opacity: 0.28))),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.9,
                    colors: [dark ? const Color(0xFF0B1F17) : AppColors.deepGreen, (dark ? const Color(0xFF0B1F17) : AppColors.deepGreen).withValues(alpha: 0.35)],
                    stops: const [0.35, 1],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: Stack(alignment: Alignment.center, children: [
                    if (ring > 0 && ring < 1)
                      Opacity(
                        opacity: (1 - ring) * 0.6,
                        child: Container(
                          width: 60 + 120 * ring,
                          height: 60 + 120 * ring,
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.gold, width: 2)),
                        ),
                      ),
                    KhatamLogo(size: 140, progress: logoT),
                  ]),
                ),
                const SizedBox(height: 18),
                Opacity(
                  opacity: word,
                  child: Transform.translate(
                    offset: Offset(0, 18 * (1 - word)),
                    child: Text(S.appName, style: display(40, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 8),
                Opacity(
                  opacity: tag,
                  child: Text(S.slogan.replaceAll('\n', ' '), style: const TextStyle(fontSize: 15, color: AppColors.gold)),
                ),
              ]),
            ),
            Positioned(
              left: 120,
              right: 120,
              bottom: 96,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _seg(0.7, 1),
                  minHeight: 4,
                  color: AppColors.gold,
                  backgroundColor: Colors.white.withValues(alpha: 0.14),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}
