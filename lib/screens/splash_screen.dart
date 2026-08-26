import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'info_screen.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback? onThemeToggle;

  const SplashScreen({super.key, this.onThemeToggle});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _introController;
  late AnimationController _loadingController;
  late AnimationController _backgroundController;
  late AnimationController _floatingController;

  late Animation<double> _fade;
  late Animation<double> _scale;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    // INTRO ANIMATION

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fade = CurvedAnimation(parent: _introController, curve: Curves.easeOut);

    _scale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: Curves.easeOutBack),
    );

    _slide = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _introController, curve: Curves.easeOutCubic),
        );

    _introController.forward();

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    );

    _loadingController.forward().whenComplete(() {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InfoScreen()),
      );
    });

    // BACKGROUND

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // FLOATING OBJECTS

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _introController.dispose();
    _loadingController.dispose();
    _backgroundController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030817),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          final bool mobile = width < 600;
          final bool tablet = width >= 600 && width < 1000;
          final bool desktop = width >= 1000;

          return AnimatedBuilder(
            animation: Listenable.merge([
              _backgroundController,
              _floatingController,
            ]),
            builder: (context, child) {
              return Stack(
                children: [
                  // MAIN BACKGROUND

                  Positioned.fill(
                    child: CustomPaint(
                      painter: _AdvancedBackgroundPainter(
                        animation: _backgroundController.value,
                      ),
                    ),
                  ),

                  // TOP LEFT GLOW
                  Positioned(
                    top: mobile ? -180 : -250,
                    left: mobile ? -180 : -250,
                    child: const _Glow(size: 480, color: Color(0xFF0066FF)),
                  ),

                  // TOP RIGHT GLOW
                  Positioned(
                    top: mobile ? -180 : -230,
                    right: mobile ? -180 : -230,
                    child: const _Glow(size: 450, color: Color(0xFF9C27FF)),
                  ),

                  // BOTTOM GLOW
                  Positioned(
                    bottom: -260,
                    left: width * .20,
                    child: const _Glow(size: 520, color: Color(0xFF00E5FF)),
                  ),

                  // TOP LEFT COMPLEXITY
                  if (desktop)
                    Positioned(
                      left: 70,
                      top: 85,
                      child: _FloatingBadge(
                        text: 'O(n)',
                        color: const Color(0xFF00E5FF),
                        animation: _floatingController.value,
                        offset: 0,
                      ),
                    ),

                  // TOP RIGHT COMPLEXITY
                  if (desktop)
                    Positioned(
                      right: 80,
                      top: 105,
                      child: _FloatingBadge(
                        text: 'O(log n)',
                        color: const Color(0xFFB52BFF),
                        animation: _floatingController.value,
                        offset: 1.2,
                      ),
                    ),

                  // LOWER LEFT COMPLEXITY
                  // MOVED AWAY FROM GRAPH
                  if (desktop)
                    Positioned(
                      left: 285,
                      bottom: 300,
                      child: _FloatingBadge(
                        text: 'O(n²)',
                        color: const Color(0xFF9C27FF),
                        animation: _floatingController.value,
                        offset: 2.1,
                      ),
                    ),

                  // LOWER RIGHT COMPLEXITY
                  // MOVED AWAY FROM TREE
                  if (desktop)
                    Positioned(
                      right: 285,
                      bottom: 300,
                      child: _FloatingBadge(
                        text: 'O(1)',
                        color: const Color(0xFFFFB300),
                        animation: _floatingController.value,
                        offset: 2.8,
                      ),
                    ),

                  // CODE SYMBOL
                  if (desktop)
                    const Positioned(left: 45, top: 230, child: _CodeSymbol()),

                  // GRAPH
                  // MOVED LOWER + LEFT
                  if (desktop)
                    Positioned(
                      left: 20,
                      bottom: 125,
                      child: const _MiniGraph(),
                    ),

                  // SMALL GRAPH TABLET
                  if (tablet)
                    const Positioned(left: 15, top: 100, child: _SmallGraph()),

                  // TREE
                  // MOVED LOWER + RIGHT
                  if (desktop)
                    Positioned(
                      right: 20,
                      bottom: 125,
                      child: const _MiniTree(),
                    ),

                  // SMALL TREE TABLET
                  if (tablet)
                    const Positioned(right: 15, top: 100, child: _SmallTree()),

                  // SORTING BARS
                  // MOVED TO VERY BOTTOM LEFT
                  if (desktop)
                    const Positioned(
                      left: 55,
                      bottom: 35,
                      child: _SortingBars(),
                    ),

                  // SEARCH ICON
                  // MOVED TO VERY BOTTOM RIGHT
                  if (desktop)
                    Positioned(
                      right: 70,
                      bottom: 35,
                      child: _FloatingIconCard(
                        icon: Icons.search_rounded,
                        color: const Color(0xFFFFB300),
                        animation: _floatingController.value,
                      ),
                    ),

                  // MAIN CONTENT
                  SafeArea(
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: mobile ? 18 : 30,
                          vertical: mobile ? 18 : 25,
                        ),
                        child: FadeTransition(
                          opacity: _fade,
                          child: SlideTransition(
                            position: _slide,
                            child: ScaleTransition(
                              scale: _scale,
                              child: _MainContent(
                                loadingAnimation: _loadingController,
                                mobile: mobile,
                                tablet: tablet,
                                desktop: desktop,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

// MAIN CONTENT

class _MainContent extends StatelessWidget {
  final Animation<double> loadingAnimation;
  final bool mobile;
  final bool tablet;
  final bool desktop;

  const _MainContent({
    required this.loadingAnimation,
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final double logoSize = mobile
        ? 72
        : tablet
        ? 86
        : 96;

    final double titleSize = mobile
        ? 36
        : tablet
        ? 45
        : 58;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: mobile
            ? 390
            : tablet
            ? 560
            : 650,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // LOGO

          _AlgorithmLogo(size: logoSize, mobile: mobile),

          SizedBox(height: mobile ? 16 : 22),

          // TITLE
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              'Algorithm',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: .95,
                letterSpacing: -2,
                shadows: [
                  Shadow(
                    color: const Color(0xFF00E5FF).withOpacity(.20),
                    blurRadius: 25,
                  ),
                ],
              ),
            ),
          ),

          // VISUALIZER
          ShaderMask(
            shaderCallback: (bounds) {
              return const LinearGradient(
                colors: [
                  Color(0xFF00E5FF),
                  Color(0xFF2979FF),
                  Color(0xFFB52BFF),
                  Color(0xFFFF2BD6),
                ],
              ).createShader(bounds);
            },
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Visualizer',
                style: TextStyle(
                  fontSize: titleSize + 3,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1,
                  letterSpacing: -2,
                ),
              ),
            ),
          ),

          SizedBox(height: mobile ? 12 : 17),

          // DECORATIVE LINE
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: mobile ? 25 : 45,
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0xFF00E5FF)],
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Container(
                width: mobile ? 65 : 110,
                height: 3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF00E5FF),
                      Color(0xFF2979FF),
                      Color(0xFFB52BFF),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00E5FF).withOpacity(.6),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Container(
                width: mobile ? 25 : 45,
                height: 2,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB52BFF), Colors.transparent],
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: mobile ? 13 : 17),

          // TAGLINE
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Learn',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const _Dot(color: Color(0xFF00E5FF)),
                const Text(
                  'Explore',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const _Dot(color: Color(0xFFB52BFF)),
                const Text(
                  'Visualize',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // DESCRIPTION
          Text(
            'Understand algorithms through interactive\nvisual representations.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(.55),
              fontSize: mobile ? 11.5 : 14,
              height: 1.45,
              letterSpacing: .2,
            ),
          ),

          SizedBox(height: mobile ? 19 : 25),

          // LOADING BAR
          // EXACTLY 10 SECONDS
          AnimatedBuilder(
            animation: loadingAnimation,
            builder: (context, child) {
              final progress = loadingAnimation.value;

              return Column(
                children: [
                  Container(
                    width: mobile
                        ? width * .78
                        : tablet
                        ? 400
                        : 450,
                    height: mobile ? 8 : 10,
                    padding: const EdgeInsets.all(1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF061126),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF2979FF).withOpacity(.45),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0066FF).withOpacity(.15),
                          blurRadius: 18,
                        ),
                      ],
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF00E5FF),
                                Color(0xFF2979FF),
                                Color(0xFF9C27FF),
                                Color(0xFFFF2BD6),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00E5FF).withOpacity(.65),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        progress < 1 ? 'LOADING...' : 'READY',
                        style: TextStyle(
                          color: const Color(0xFF00E5FF).withOpacity(.65),
                          fontSize: 8,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),

          SizedBox(height: mobile ? 18 : 24),

          // FEATURES
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Feature(
                icon: Icons.bar_chart_rounded,
                label: 'Sorting',
                color: const Color(0xFF00E5FF),
                compact: mobile,
              ),
              SizedBox(width: mobile ? 10 : 23),
              _Feature(
                icon: Icons.account_tree_rounded,
                label: 'Trees',
                color: const Color(0xFFB52BFF),
                compact: mobile,
              ),
              SizedBox(width: mobile ? 10 : 23),
              _Feature(
                icon: Icons.hub_rounded,
                label: 'Graphs',
                color: const Color(0xFF00E676),
                compact: mobile,
              ),
              SizedBox(width: mobile ? 10 : 23),
              _Feature(
                icon: Icons.search_rounded,
                label: 'Search',
                color: const Color(0xFFFFB300),
                compact: mobile,
              ),
            ],
          ),

          // DESKTOP ALGORITHM CARD
          if (desktop) ...[const SizedBox(height: 22)],
        ],
      ),
    );
  }
}

// ALGORITHM LOGO

class _AlgorithmLogo extends StatelessWidget {
  final double size;
  final bool mobile;

  const _AlgorithmLogo({required this.size, required this.mobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00E5FF), Color(0xFF2979FF), Color(0xFFB52BFF)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(.30),
            blurRadius: 35,
            spreadRadius: 5,
          ),
          BoxShadow(
            color: const Color(0xFFB52BFF).withOpacity(.18),
            blurRadius: 45,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF061126),
          border: Border.all(color: Colors.white.withOpacity(.10)),
        ),
        child: CustomPaint(
          size: Size(size, size),
          painter: _LogoGraphPainter(),
        ),
      ),
    );
  }
}

// DOT

class _Dot extends StatelessWidget {
  final Color color;

  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          boxShadow: [BoxShadow(color: color.withOpacity(.7), blurRadius: 8)],
        ),
      ),
    );
  }
}

// FEATURE

class _Feature extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool compact;

  const _Feature({
    required this.icon,
    required this.label,
    required this.color,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final double size = compact ? 40 : 52;

    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(compact ? 12 : 15),
            color: color.withOpacity(.06),
            border: Border.all(color: color.withOpacity(.55)),
            boxShadow: [
              BoxShadow(color: color.withOpacity(.14), blurRadius: 15),
            ],
          ),
          child: Icon(icon, size: compact ? 19 : 24, color: color),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(.42),
            fontSize: compact ? 8.5 : 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// FLOATING BADGE

class _FloatingBadge extends StatelessWidget {
  final String text;
  final Color color;
  final double animation;
  final double offset;

  const _FloatingBadge({
    required this.text,
    required this.color,
    required this.animation,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    final double y = math.sin(animation * math.pi + offset) * 8;

    return Transform.translate(
      offset: Offset(0, y),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF071126).withOpacity(.78),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(.65)),
          boxShadow: [BoxShadow(color: color.withOpacity(.15), blurRadius: 22)],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: .5,
          ),
        ),
      ),
    );
  }
}

// CODE SYMBOL

class _CodeSymbol extends StatelessWidget {
  const _CodeSymbol();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 90,
      decoration: BoxDecoration(
        color: const Color(0xFF071126).withOpacity(.65),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF00E5FF).withOpacity(.35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E5FF).withOpacity(.10),
            blurRadius: 25,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          '</>',
          style: TextStyle(
            color: Color(0xFF00E5FF),
            fontSize: 38,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

// FLOATING ICON CARD

class _FloatingIconCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double animation;

  const _FloatingIconCard({
    required this.icon,
    required this.color,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    final double y = math.sin(animation * math.pi) * 9;

    return Transform.translate(
      offset: Offset(0, y),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF071126).withOpacity(.75),
          border: Border.all(color: color.withOpacity(.55)),
          boxShadow: [BoxShadow(color: color.withOpacity(.18), blurRadius: 25)],
        ),
        child: Icon(icon, color: color, size: 36),
      ),
    );
  }
}

// MINI GRAPH

class _MiniGraph extends StatelessWidget {
  const _MiniGraph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 180,
      child: CustomPaint(painter: _GraphPainter()),
    );
  }
}

// SMALL GRAPH

class _SmallGraph extends StatelessWidget {
  const _SmallGraph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 125,
      height: 105,
      child: CustomPaint(painter: _GraphPainter(small: true)),
    );
  }
}

// GRAPH PAINTER

class _GraphPainter extends CustomPainter {
  final bool small;

  _GraphPainter({this.small = false});

  @override
  void paint(Canvas canvas, Size size) {
    final nodes = [
      Offset(size.width * .50, 18),
      Offset(size.width * .18, 65),
      Offset(size.width * .50, 65),
      Offset(size.width * .82, 65),
      Offset(size.width * .30, 112),
      Offset(size.width * .70, 112),
    ];

    final connections = [
      [0, 1],
      [0, 2],
      [0, 3],
      [1, 2],
      [1, 4],
      [2, 4],
      [2, 5],
      [3, 5],
    ];

    final line = Paint()
      ..strokeWidth = small ? 1 : 1.5
      ..color = const Color(0xFF2979FF).withOpacity(.65);

    for (final connection in connections) {
      canvas.drawLine(nodes[connection[0]], nodes[connection[1]], line);
    }

    for (int i = 0; i < nodes.length; i++) {
      final radius = small ? 11.0 : 18.0;

      canvas.drawCircle(
        nodes[i],
        radius,
        Paint()..color = const Color(0xFF061126),
      );

      canvas.drawCircle(
        nodes[i],
        radius,
        Paint()
          ..color = i.isEven ? const Color(0xFF00E5FF) : const Color(0xFFB52BFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = small ? 1 : 1.5,
      );

      final text = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: TextStyle(
            color: Colors.white,
            fontSize: small ? 6 : 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      text.layout();

      text.paint(canvas, nodes[i] - Offset(text.width / 2, text.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// MINI TREE

class _MiniTree extends StatelessWidget {
  const _MiniTree();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 180,
      child: CustomPaint(painter: _TreePainter()),
    );
  }
}

// SMALL TREE

class _SmallTree extends StatelessWidget {
  const _SmallTree();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 125,
      height: 105,
      child: CustomPaint(painter: _TreePainter(small: true)),
    );
  }
}

// TREE PAINTER

class _TreePainter extends CustomPainter {
  final bool small;

  _TreePainter({this.small = false});

  @override
  void paint(Canvas canvas, Size size) {
    final nodes = {
      10: Offset(size.width * .5, 18),
      6: Offset(size.width * .28, 65),
      15: Offset(size.width * .72, 65),
      3: Offset(size.width * .16, 112),
      8: Offset(size.width * .40, 112),
      12: Offset(size.width * .60, 112),
      18: Offset(size.width * .84, 112),
    };

    final connections = [
      [10, 6],
      [10, 15],
      [6, 3],
      [6, 8],
      [15, 12],
      [15, 18],
    ];

    final line = Paint()
      ..color = const Color(0xFFB52BFF).withOpacity(.65)
      ..strokeWidth = small ? 1 : 1.5;

    for (final connection in connections) {
      canvas.drawLine(nodes[connection[0]]!, nodes[connection[1]]!, line);
    }

    nodes.forEach((value, position) {
      final radius = small ? 10.0 : 16.0;

      canvas.drawCircle(
        position,
        radius,
        Paint()..color = const Color(0xFF061126),
      );

      canvas.drawCircle(
        position,
        radius,
        Paint()
          ..color = const Color(0xFFB52BFF)
          ..style = PaintingStyle.stroke
          ..strokeWidth = small ? 1 : 1.5,
      );

      final text = TextPainter(
        text: TextSpan(
          text: '$value',
          style: TextStyle(
            color: Colors.white,
            fontSize: small ? 5.5 : 8,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      text.layout();

      text.paint(canvas, position - Offset(text.width / 2, text.height / 2));
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// SORTING BARS

class _SortingBars extends StatelessWidget {
  const _SortingBars();

  @override
  Widget build(BuildContext context) {
    const heights = [35.0, 62.0, 45.0, 90.0, 58.0, 110.0, 75.0, 98.0];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(heights.length, (index) {
        return Container(
          margin: const EdgeInsets.only(right: 6),
          width: 17,
          height: heights[index],
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: index.isEven
                  ? const [Color(0xFF00E5FF), Color(0xFF2979FF)]
                  : const [Color(0xFFB52BFF), Color(0xFF6327FF)],
            ),
            boxShadow: [
              BoxShadow(
                color: index.isEven
                    ? const Color(0xFF00E5FF).withOpacity(.25)
                    : const Color(0xFFB52BFF).withOpacity(.25),
                blurRadius: 12,
              ),
            ],
          ),
        );
      }),
    );
  }
}

// LOGO GRAPH PAINTER

class _LogoGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final nodes = [
      center.translate(0, -20),
      center.translate(-20, 8),
      center.translate(20, 8),
      center.translate(-24, 30),
      center.translate(24, 30),
    ];

    final line = Paint()
      ..color = const Color(0xFF00E5FF).withOpacity(.65)
      ..strokeWidth = 1.4;

    canvas.drawLine(nodes[0], nodes[1], line);
    canvas.drawLine(nodes[0], nodes[2], line);
    canvas.drawLine(nodes[1], nodes[3], line);
    canvas.drawLine(nodes[2], nodes[4], line);

    for (final node in nodes) {
      canvas.drawCircle(node, 4, Paint()..color = const Color(0xFF00E5FF));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// GLOW

class _Glow extends StatelessWidget {
  final double size;
  final Color color;

  const _Glow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(.14),
              color.withOpacity(.045),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

// ADVANCED BACKGROUND

class _AdvancedBackgroundPainter extends CustomPainter {
  final double animation;

  _AdvancedBackgroundPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // GRID

    paint.color = const Color(0xFF173064).withOpacity(.18);
    paint.strokeWidth = .5;

    const spacing = 45.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // CIRCUIT LINES

    final circuitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF0066FF).withOpacity(.20);

    for (int i = 0; i < 12; i++) {
      final y = 70.0 + i * 95;

      final path = Path();

      path.moveTo(0, y);

      path.lineTo(size.width * .08, y);
      path.lineTo(size.width * .12, y - 25);
      path.lineTo(size.width * .22, y - 25);

      canvas.drawPath(path, circuitPaint);
    }

    // PARTICLES

    final random = math.Random(42);

    for (int i = 0; i < 75; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      final pulse = (math.sin(animation * math.pi * 2 + i) + 1) / 2;

      paint.color = i.isEven
          ? const Color(0xFF00E5FF).withOpacity(.04 + pulse * .11)
          : const Color(0xFFB52BFF).withOpacity(.03 + pulse * .09);

      canvas.drawCircle(Offset(x, y), .8 + pulse * 1.4, paint);
    }

    // FLOATING CONNECTIONS

    final nodePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF2979FF).withOpacity(.12);

    final points = [
      Offset(size.width * .08, size.height * .25),
      Offset(size.width * .18, size.height * .18),
      Offset(size.width * .30, size.height * .24),
      Offset(size.width * .72, size.height * .20),
      Offset(size.width * .85, size.height * .30),
      Offset(size.width * .92, size.height * .18),
    ];

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], nodePaint);
    }

    // BOTTOM WAVES

    for (int layer = 0; layer < 4; layer++) {
      final path = Path();

      final baseY = size.height - 25 + layer * 18;

      path.moveTo(0, baseY);

      for (double x = 0; x <= size.width; x += 10) {
        final y =
            baseY +
            math.sin(x * .012 + animation * math.pi * 2 + layer) *
                (8 + layer * 4);

        path.lineTo(x, y);
      }

      final wavePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = layer.isEven
            ? const Color(0xFF00E5FF).withOpacity(.13)
            : const Color(0xFFB52BFF).withOpacity(.11);

      canvas.drawPath(path, wavePaint);
    }

    // BINARY DIGITS

    final binaryStyle = TextStyle(
      color: const Color(0xFF2979FF).withOpacity(.12),
      fontSize: 16,
      fontWeight: FontWeight.bold,
    );

    final binaryPainter = TextPainter(
      text: TextSpan(
        text: '101101\n010011\n110101\n001101',
        style: binaryStyle,
      ),
      textDirection: TextDirection.ltr,
    );

    binaryPainter.layout();

    binaryPainter.paint(canvas, Offset(size.width * .04, size.height * .62));

    binaryPainter.paint(canvas, Offset(size.width * .88, size.height * .42));
  }

  @override
  bool shouldRepaint(covariant _AdvancedBackgroundPainter oldDelegate) {
    return true;
  }
}
