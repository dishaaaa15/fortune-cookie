import 'package:flutter/material.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(FortuneCookieApp());

class FortuneCookieApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FortuneCookieScreen(),
    );
  }
}

class FortuneCookieScreen extends StatefulWidget {
  @override
  _FortuneCookieScreenState createState() => _FortuneCookieScreenState();
}

class _FortuneCookieScreenState extends State<FortuneCookieScreen>
    with SingleTickerProviderStateMixin {
  bool _cracked = false;
  String _fortune = "";

  late AnimationController _controller;
  late Animation<double> spreadAnim, slipAnim, crumbsAnim;

  final List<String> fortunes = [
    "🌸 Believe in yourself!",
    "🍀 Lucky surprises await you!",
    "💡 Bright ideas are coming your way.",
    "🌟 You’re destined for something great.",
    "🌈 Happiness is closer than you think.",
    "🧿 You will get full marks in this mini project",
    "🧿 You will get 10 cgpa this semester",
    "🧿 Project will go well"
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1000));
    setupAnimations();
  }

  void setupAnimations() {
    spreadAnim = Tween<double>(begin: 0, end: 60).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    slipAnim = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    crumbsAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  void _crackCookie() {
    if (_cracked) return;
    setState(() {
      _cracked = true;
      _fortune = fortunes[Random().nextInt(fortunes.length)];
    });
    _controller.forward();
  }

  void _reset() {
    setState(() {
      _cracked = false;
      _fortune = "";
    });
    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: Text("🍪 Fortune Cookie"),
        backgroundColor: Colors.brown,
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Cookie(cracked: _cracked, spreadAnim: spreadAnim),
                SizedBox(height: 20),
                if (!_cracked)
                  ElevatedButton(
                    onPressed: _crackCookie,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade200,
                      shape: StadiumBorder(),
                      elevation: 4,
                    ),
                    child: Text("Crack open to see your fortune",
                        style: TextStyle(color: Colors.brown.shade800)),
                  ),
                if (_cracked)
                  PaperSlip(
                      controller: _controller,
                      slipAnim: slipAnim,
                      fortune: _fortune),
                if (_cracked) ...[
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _reset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade100,
                      shape: StadiumBorder(),
                      elevation: 3,
                    ),
                    child: Text("Reset",
                        style: TextStyle(color: Colors.purple)),
                  )
                ]
              ],
            ),
          ),
          Crumbs(cracked: _cracked, crumbsAnim: crumbsAnim),
        ],
      ),
    );
  }
}

//// ---------------- Widgets ----------------

/// Cookie (whole or cracked halves)
class Cookie extends StatelessWidget {
  final bool cracked;
  final Animation<double> spreadAnim;
  const Cookie({required this.cracked, required this.spreadAnim});

  Widget _buildHalf(bool left) {
    return CustomPaint(size: Size(100, 100), painter: CookieHalfPainter(left));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: spreadAnim,
      builder: (_, __) {
        return cracked
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
                offset: Offset(-spreadAnim.value, 0),
                child: _buildHalf(true)),
            Transform.translate(
                offset: Offset(spreadAnim.value, 0),
                child: _buildHalf(false)),
          ],
        )
            : SizedBox(
            width: 150,
            height: 150,
            child: CustomPaint(painter: WholeCookiePainter()));
      },
    );
  }
}

/// Paper slip with curled edges
class PaperSlip extends StatelessWidget {
  final AnimationController controller;
  final Animation<double> slipAnim;
  final String fortune;
  const PaperSlip(
      {required this.controller, required this.slipAnim, required this.fortune});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, slipAnim.value),
        child: Opacity(
          opacity: controller.value,
          child: CustomPaint(
            painter: PaperSlipPainter(),
            child: Container(
              width: 260,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              alignment: Alignment.center,
              child: Text(fortune,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pacifico(
                      fontSize: 18, color: Colors.deepOrange)),
            ),
          ),
        ),
      ),
    );
  }
}

/// Flying crumbs
class Crumbs extends StatelessWidget {
  final bool cracked;
  final Animation<double> crumbsAnim;
  const Crumbs({required this.cracked, required this.crumbsAnim});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: crumbsAnim,
      builder: (_, __) {
        if (!cracked) return SizedBox.shrink();
        final rand = Random();
        return Stack(
          children: List.generate(12, (i) {
            final angle = rand.nextDouble() * 2 * pi;
            final dist = (20 + rand.nextDouble() * 80) * crumbsAnim.value;
            final dx = cos(angle) * dist;
            final dy = sin(angle) * dist;
            return Positioned(
              left: MediaQuery.of(context).size.width / 2 + dx,
              top: MediaQuery.of(context).size.height / 2 + dy,
              child: Transform.scale(
                scale: crumbsAnim.value,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                      color: Colors.brown.shade600, shape: BoxShape.circle),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

//// ---------------- Painters ----------------

/// Whole cookie with fixed dots and crumbled edges
class WholeCookiePainter extends CustomPainter {
  final List<Offset> _dots = List.generate(
      22, (_) => Offset(Random().nextDouble() * 80 - 40,
      Random().nextDouble() * 80 - 40));

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = 70.0;

    // Base cookie with crumbled edges
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.orange.shade500, Colors.brown.shade600],
      ).createShader(Rect.fromCircle(center: center, radius: r));

    Path path = Path();
    for (int i = 0; i <= 50; i++) {
      final angle = (2 * pi / 50) * i;
      final jitter = (i % 5 == 0) ? -5 : (i % 3 == 0 ? 3 : 0);
      final x = center.dx + (r + jitter) * cos(angle);
      final y = center.dy + (r + jitter) * sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);

    // Cookie dots
    final dotPaint = Paint()..color = Colors.brown.shade700;
    for (final d in _dots) canvas.drawCircle(center + d, 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Half cookie with jagged crack
class CookieHalfPainter extends CustomPainter {
  final bool left;
  CookieHalfPainter(this.left);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.orange.shade500, Colors.brown.shade600],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    if (left) {
      path.addArc(Rect.fromLTWH(0, 0, size.width, size.height), pi / 2, pi);
      for (double y = 0; y <= size.height; y += 12) {
        path.lineTo(size.width / 2 + (y % 24 == 0 ? -6 : 6), y);
      }
    } else {
      path.addArc(Rect.fromLTWH(0, 0, size.width, size.height), -pi / 2, pi);
      for (double y = 0; y <= size.height; y += 12) {
        path.lineTo(size.width / 2 + (y % 24 == 0 ? 6 : -6), y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Paper slip with curled edges
class PaperSlipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 2);

    final path = Path();
    const curve = 15.0;
    path.moveTo(curve, 0);
    path.quadraticBezierTo(0, size.height / 2, curve, size.height);
    path.lineTo(size.width - curve, size.height);
    path.quadraticBezierTo(size.width, size.height / 2, size.width - curve, 0);
    path.close();

    canvas.drawShadow(path, Colors.black26, 4, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
