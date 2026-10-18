import 'dart:math';
import 'package:flutter/material.dart';

class CompletionMessage extends StatefulWidget {
  const CompletionMessage({
    super.key,
    required this.onNewGame,
    required this.moves,
    required this.time,
    this.onHome,
    this.gridSize = 3,
  });

  final VoidCallback onNewGame;
  final VoidCallback? onHome;
  final int moves;
  final String time;
  final int gridSize;

  @override
  State<CompletionMessage> createState() => _CompletionMessageState();
}

class _CompletionMessageState extends State<CompletionMessage> with TickerProviderStateMixin {
  late final AnimationController _cardCtrl;
  late final AnimationController _confettiCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;
  late final List<_ConfettiParticle> _particles;

  @override
  void initState() {
    super.initState();
    _cardCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _scale = CurvedAnimation(parent: _cardCtrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _cardCtrl, curve: Curves.easeIn);

    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _particles = List.generate(45, (_) => _ConfettiParticle());
    _cardCtrl.forward();
  }

  @override
  void dispose() {
    _cardCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  int get _starCount {
    final moves = widget.moves;
    if (widget.gridSize == 3) {
      if (moves <= 40) return 3;
      if (moves <= 70) return 2;
      return 1;
    } else if (widget.gridSize == 4) {
      if (moves <= 110) return 3;
      if (moves <= 180) return 2;
      return 1;
    } else {
      if (moves <= 250) return 3;
      if (moves <= 400) return 2;
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stars = _starCount;

    return Stack(
      children: [
        // Confetti celebration overlay
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _confettiCtrl,
              builder: (_, __) => CustomPaint(
                painter: _ConfettiPainter(particles: _particles, progress: _confettiCtrl.value),
              ),
            ),
          ),
        ),

        // Centered Celebration Dialog Card
        Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF2A1B0E),
                      Color(0xFF1E130A),
                      Color(0xFF140D07),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFFFFD54F), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withValues(alpha: 0.35),
                      blurRadius: 36,
                      spreadRadius: 4,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Glowing Trophy Icon
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const RadialGradient(
                            colors: [
                              Color(0xFFFFE082),
                              Color(0xFFFFB300),
                              Color(0xFFFF8F00),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFC107).withValues(alpha: 0.6),
                              blurRadius: 24,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          size: 42,
                          color: Color(0xFF5D2E0C),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Victory Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [
                                Color(0xFFFFF9C4),
                                Color(0xFFFFD54F),
                                Color(0xFFFFB300),
                              ],
                            ).createShader(bounds),
                            child: const Text(
                              'PUZZLE\nSOLVED!',
                              style: TextStyle(
                                fontFamily: 'Georgia',
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Spectacular performance! You unlocked victory.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Stars Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final isEarned = index < stars;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.star_rounded,
                              size: index == 1 ? 40 : 32,
                              color: isEarned ? const Color(0xFFFFD54F) : Colors.white24,
                              shadows: isEarned
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFFFFC107).withValues(alpha: 0.8),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 16),

                      // Performance Stats Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatColumn(
                              icon: Icons.timer_outlined,
                              label: 'TIME',
                              value: widget.time,
                              color: const Color(0xFF81D4FA),
                            ),
                            Container(width: 1, height: 36, color: Colors.white24),
                            _StatColumn(
                              icon: Icons.touch_app_rounded,
                              label: 'MOVES',
                              value: '${widget.moves}',
                              color: const Color(0xFFA5D6A7),
                            ),
                            Container(width: 1, height: 36, color: Colors.white24),
                            _StatColumn(
                              icon: Icons.speed_rounded,
                              label: 'RANK',
                              value: stars == 3 ? 'Master' : (stars == 2 ? 'Great' : 'Clear'),
                              color: const Color(0xFFFFCC80),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        children: [
                          if (widget.onHome != null) ...[
                            Expanded(
                              flex: 1,
                              child: OutlinedButton.icon(
                                onPressed: widget.onHome,
                                icon: const Icon(Icons.home_rounded, size: 18),
                                label: const Text('Home'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFFFA000),
                                    Color(0xFFFF6F00),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF8F00).withValues(alpha: 0.45),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton.icon(
                                onPressed: widget.onNewGame,
                                icon: const Icon(Icons.replay_rounded, size: 20, color: Colors.white),
                                label: const Text(
                                  'Play Again',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Confetti Animation Painter
// ─────────────────────────────────────────────────────────────────────────────

class _ConfettiParticle {
  _ConfettiParticle() {
    reset();
  }

  late double x;
  late double y;
  late double size;
  late double speed;
  late double angle;
  late double rotationSpeed;
  late Color color;

  void reset() {
    final random = Random();
    x = random.nextDouble();
    y = -random.nextDouble() * 0.4;
    size = random.nextDouble() * 8 + 6;
    speed = random.nextDouble() * 0.6 + 0.3;
    angle = random.nextDouble() * 2 * pi;
    rotationSpeed = (random.nextDouble() - 0.5) * 8;
    color = _palette[random.nextInt(_palette.length)];
  }

  static const _palette = [
    Color(0xFFFFD54F),
    Color(0xFFFF5252),
    Color(0xFF69F0AE),
    Color(0xFF40C4FF),
    Color(0xFFE040FB),
    Color(0xFFFFAB40),
  ];
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles, required this.progress});

  final List<_ConfettiParticle> particles;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final currentY = (p.y + progress * p.speed) % 1.2;
      final px = (p.x * size.width) + sin(progress * 6 + p.angle) * 16;
      final py = currentY * size.height;

      final paint = Paint()
        ..color = p.color.withValues(alpha: currentY > 0.95 ? (1.2 - currentY) / 0.25 : 1.0)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(progress * p.rotationSpeed + p.angle);
      canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.6), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

