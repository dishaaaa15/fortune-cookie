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
  late Animation<double> _paperSlide;

  final List<String> fortunes = [
    "🌸 Believe in yourself!",
    "🍀 Lucky surprises await you!",
    "💡 Bright ideas are coming your way.",
    "🌟 You’re destined for something great.",
    "🌈 Happiness is closer than you think."
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 900));

    _paperSlide =
        Tween<double>(begin: -80, end: 0).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutBack,
        ));
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

  Widget _buildCookieHalf({required bool left}) {
    return Transform.rotate(
      angle: left ? -0.3 : 0.3,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.orange.shade300,
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [Colors.orange.shade200, Colors.orange.shade600],
            center: Alignment(-0.3, -0.3),
          ),
          boxShadow: [BoxShadow(color: Colors.brown.shade200, blurRadius: 10)],
        ),
        child: ClipPath(
          clipper: left ? LeftHalfClipper() : RightHalfClipper(),
          child: Container(
            color: Colors.orange.shade400.withOpacity(0.3),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange.shade50,
      appBar: AppBar(
        title: Text("🍪 Fortune Cookie"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _crackCookie,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 600),
                child: _cracked
                    ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                        offset: Offset(-20, 0),
                        child: _buildCookieHalf(left: true)),
                    Transform.translate(
                        offset: Offset(20, 0),
                        child: _buildCookieHalf(left: false)),
                  ],
                )
                    : Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Colors.orange.shade200, Colors.orange.shade600],
                    ),
                    boxShadow: [
                      BoxShadow(color: Colors.brown.shade200, blurRadius: 10)
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            if (_cracked)
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _paperSlide.value),
                    child: Opacity(
                      opacity: _controller.value,
                      child: Container(
                        padding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 6)
                          ],
                        ),
                        child: Text(
                          _fortune,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.pacifico(
                            fontSize: 20,
                            color: Colors.deepOrange,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            if (_cracked) ...[
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _reset,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade100,
                  shape: StadiumBorder(),
                  elevation: 3,
                ),
                child: Text("Reset", style: TextStyle(color: Colors.purple)),
              )
            ]
          ],
        ),
      ),
    );
  }
}

class LeftHalfClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(Rect.fromLTWH(size.width / 2, 0, size.width / 2, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class RightHalfClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(Rect.fromLTWH(0, 0, size.width / 2, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
