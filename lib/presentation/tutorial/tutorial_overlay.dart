import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/app_theme.dart';
import '../../core/extensions/localizations_extension.dart';

class TutorialStep {
  final String title;
  final String body;
  final GlobalKey? spotlightKey;
  final double padding;
  final VoidCallback? onAdvance;

  const TutorialStep({
    required this.title,
    required this.body,
    this.spotlightKey,
    this.padding = 14,
    this.onAdvance,
  });
}

class TutorialOverlay extends StatefulWidget {
  final List<TutorialStep> steps;
  final VoidCallback onComplete;

  const TutorialOverlay({
    super.key,
    required this.steps,
    required this.onComplete,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  late AnimationController _entranceCtrl;
  late Animation<double> _entranceFade;

  Rect? _currentSpotlight;
  Rect? _previousSpotlight;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _entranceFade = CurvedAnimation(
      parent: _entranceCtrl,
      curve: Curves.easeInOutCubic,
    );
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _advance() {
    final current = widget.steps[_step];
    current.onAdvance?.call();

    if (_step >= widget.steps.length - 1) {
      widget.onComplete();
      return;
    }
    _previousSpotlight = _currentSpotlight;
    setState(() => _step++);
  }

  Rect? _spotlightRect(GlobalKey key, double padding) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final pos = box.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
      pos.dx - padding,
      pos.dy - padding,
      box.size.width + padding * 2,
      box.size.height + padding * 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.steps[_step];
    final targetRect = step.spotlightKey != null
        ? _spotlightRect(step.spotlightKey!, step.padding)
        : null;
    _currentSpotlight = targetRect;
    final isLast = _step == widget.steps.length - 1;
    final size = MediaQuery.sizeOf(context);
    final safePad = MediaQuery.paddingOf(context);

    return FadeTransition(
      opacity: _entranceFade,
      child: Stack(
        children: [
          // Dark overlay with animated spotlight cutout
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _advance,
              child: TweenAnimationBuilder<Rect?>(
                tween: _RectTween(begin: _previousSpotlight, end: targetRect),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOutCubic,
                builder: (context, rect, _) => CustomPaint(
                  painter: _SpotlightPainter(rect: rect),
                ),
              ),
            ),
          ),

          // Skip button (top-right)
          Positioned(
            top: safePad.top + 8,
            right: 8,
            child: TextButton(
              onPressed: widget.onComplete,
              child: Text(
                context.l10n.skip,
                style: TextStyle(
                  color: AppTheme.mintMist.withValues(alpha: 0.70),
                  fontSize: 14,
                ),
              ),
            ),
          ),

          // Tooltip card with crossfade + slide
          _TooltipPositioned(
            rect: targetRect,
            screenSize: size,
            safePad: safePad,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.06),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _StepCard(
                key: ValueKey(_step),
                step: step,
                isLast: isLast,
                stepIndex: _step,
                totalSteps: widget.steps.length,
                onNext: _advance,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Nullable Rect tween for smooth spotlight interpolation
// ---------------------------------------------------------------------------

class _RectTween extends Tween<Rect?> {
  _RectTween({super.begin, super.end});

  @override
  Rect? lerp(double t) {
    if (begin == null && end == null) return null;
    if (begin == null) return end;
    if (end == null) return begin;
    return Rect.lerp(begin, end, t);
  }
}

// ---------------------------------------------------------------------------
// Positions the card above or below the spotlight, centred horizontally.
// ---------------------------------------------------------------------------

class _TooltipPositioned extends StatelessWidget {
  final Rect? rect;
  final Size screenSize;
  final EdgeInsets safePad;
  final Widget child;

  const _TooltipPositioned({
    required this.rect,
    required this.screenSize,
    required this.safePad,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    const cardW = 300.0;
    const margin = 20.0;

    double left = (screenSize.width - cardW) / 2;
    left = left.clamp(margin, screenSize.width - cardW - margin);

    double top;
    if (rect == null) {
      // Welcome / done screens: vertically centred
      top = screenSize.height * 0.32;
    } else {
      final spotMidY = rect!.center.dy;
      if (spotMidY < screenSize.height * 0.55) {
        // Spotlight in upper portion — card goes below
        top = rect!.bottom + margin;
      } else {
        // Spotlight in lower portion — card goes above
        top = rect!.top - margin - 180; // approximate card height
      }
      top = top.clamp(
        safePad.top + 60,
        screenSize.height - 220 - safePad.bottom,
      );
    }

    return Positioned(
      top: top,
      left: left,
      width: cardW,
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// The white card with title, body, dot indicators, and Next/Get Started button
// ---------------------------------------------------------------------------

class _StepCard extends StatelessWidget {
  final TutorialStep step;
  final bool isLast;
  final int stepIndex;
  final int totalSteps;
  final VoidCallback onNext;

  const _StepCard({
    super.key,
    required this.step,
    required this.isLast,
    required this.stepIndex,
    required this.totalSteps,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.deepNimbus.withValues(alpha: 0.45),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              step.title,
              style: GoogleFonts.rajdhani(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              step.body,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Dot indicators
                ...List.generate(totalSteps, (i) {
                  final active = i == stepIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 5),
                    width: active ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active ? cs.primary : cs.outlineVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
                const Spacer(),
                FilledButton(
                  onPressed: onNext,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    minimumSize: Size.zero,
                  ),
                  child: Text(isLast ? context.l10n.tutorialGetStarted : context.l10n.next),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Custom painter that darkens everything except the spotlight rect
// ---------------------------------------------------------------------------

class _SpotlightPainter extends CustomPainter {
  final Rect? rect;

  const _SpotlightPainter({this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Paint()
      ..color = AppTheme.deepNimbus.withValues(alpha: 0.72);

    if (rect == null) {
      canvas.drawRect(Offset.zero & size, overlay);
      return;
    }

    final rRect = RRect.fromRectAndRadius(rect!, const Radius.circular(18));

    // Punch spotlight hole out of the dark overlay
    final path = Path.combine(
      PathOperation.difference,
      Path()..addRect(Offset.zero & size),
      Path()..addRRect(rRect),
    );
    canvas.drawPath(path, overlay);

    // Subtle glowing border around the spotlight
    canvas.drawRRect(
      rRect,
      Paint()
        ..color = AppTheme.mintMist.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) => old.rect != rect;
}
