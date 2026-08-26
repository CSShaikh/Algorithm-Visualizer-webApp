import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  // ================================================================
  // COLORS
  // ================================================================

  static const Color background = Color(0xFF030712);
  static const Color background2 = Color(0xFF07101F);
  static const Color cardColor = Color(0xFF0B1428);

  static const Color cyan = Color(0xFF00E5FF);
  static const Color blue = Color(0xFF2979FF);
  static const Color purple = Color(0xFF9C27FF);
  static const Color green = Color(0xFF00E676);
  static const Color orange = Color(0xFFFFB300);
  static const Color pink = Color(0xFFFF4081);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          // ============================================================
          // BACKGROUND GLOW
          // ============================================================

          Positioned(
            top: -160,
            left: -140,
            child: _Glow(size: 420, color: cyan),
          ),

          Positioned(
            top: 280,
            right: -180,
            child: _Glow(size: 400, color: purple),
          ),

          Positioned(
            bottom: -160,
            left: -120,
            child: _Glow(size: 380, color: blue),
          ),

          // ============================================================
          // GRID
          // ============================================================
          const Positioned.fill(
            child: IgnorePointer(child: CustomPaint(painter: _GridPainter())),
          ),

          // ============================================================
          // CONTENT
          // ============================================================
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(
              horizontal: width < 600 ? 16 : 45,
              vertical: 22,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1150),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // HERO
                    // ==================================================

                    const _HeroSection(),

                    const SizedBox(height: 42),

                    // ==================================================
                    // QUICK STATS
                    // ==================================================
                    _SectionTitle(
                      icon: Icons.insights_rounded,
                      title: 'Visualizer Overview',
                      color: cyan,
                    ),

                    const SizedBox(height: 16),

                    _ResponsiveGrid(
                      children: [
                        _StatCard(
                          icon: Icons.category_rounded,
                          value: '12+',
                          label: 'Algorithms',
                          color: cyan,
                        ),
                        _StatCard(
                          icon: Icons.animation_rounded,
                          value: 'Step',
                          label: 'Animations',
                          color: purple,
                        ),
                        _StatCard(
                          icon: Icons.speed_rounded,
                          value: 'Big-O',
                          label: 'Analysis',
                          color: green,
                        ),
                        _StatCard(
                          icon: Icons.school_rounded,
                          value: 'DSA',
                          label: 'Learning',
                          color: orange,
                        ),
                      ],
                    ),

                    const SizedBox(height: 45),

                    // ==================================================
                    // WHAT IS IT
                    // ==================================================
                    _SectionTitle(
                      icon: Icons.lightbulb_outline_rounded,
                      title: 'What is an Algorithm Visualizer?',
                      color: cyan,
                    ),

                    const SizedBox(height: 16),

                    const _InfoCard(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Learn Algorithms Visually',
                      accentColor: cyan,
                      child: Text(
                        'Algorithm Visualizer is an interactive learning platform '
                        'that represents algorithms visually. Instead of only '
                        'reading code or theory, students can actually see how '
                        'an algorithm works step by step.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          height: 1.75,
                        ),
                      ),
                    ),

                    const SizedBox(height: 42),

                    // ==================================================
                    // WHY USE IT
                    // ==================================================
                    _SectionTitle(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Why do we need Algorithm Visualization?',
                      color: purple,
                    ),

                    const SizedBox(height: 16),

                    _ResponsiveGrid(
                      children: [
                        _FeatureCard(
                          icon: Icons.visibility_rounded,
                          title: 'Visual Learning',
                          description:
                              'Understand algorithms easily through animations and visual elements.',
                          color: cyan,
                        ),
                        _FeatureCard(
                          icon: Icons.play_circle_outline_rounded,
                          title: 'Step by Step',
                          description:
                              'Observe and understand every individual step of an algorithm.',
                          color: blue,
                        ),
                        _FeatureCard(
                          icon: Icons.speed_rounded,
                          title: 'Compare Performance',
                          description:
                              'Compare the speed and efficiency of different algorithms.',
                          color: green,
                        ),
                        _FeatureCard(
                          icon: Icons.school_rounded,
                          title: 'Student Friendly',
                          description:
                              'Makes DSA and programming concepts easier for beginners to understand.',
                          color: orange,
                        ),
                      ],
                    ),

                    const SizedBox(height: 45),

                    // ==================================================
                    // WHAT CAN WE DO
                    // ==================================================
                    _SectionTitle(
                      icon: Icons.build_rounded,
                      title: 'What can we do with this Visualizer?',
                      color: blue,
                    ),

                    const SizedBox(height: 16),

                    _InfoCard(
                      icon: Icons.touch_app_rounded,
                      title: 'Interactive Controls',
                      accentColor: blue,
                      child: Column(
                        children: [
                          _Bullet(
                            icon: Icons.play_arrow_rounded,
                            text:
                                'Execute and visualize algorithms step by step.',
                          ),
                          _Bullet(
                            icon: Icons.pause_rounded,
                            text:
                                'Pause the execution to clearly understand any step.',
                          ),
                          _Bullet(
                            icon: Icons.replay_rounded,
                            text:
                                'Run the algorithm again to repeat the process.',
                          ),
                          _Bullet(
                            icon: Icons.speed_rounded,
                            text:
                                'Control the animation speed for a comfortable learning experience.',
                          ),
                          _Bullet(
                            icon: Icons.compare_arrows_rounded,
                            text:
                                'Compare the performance of different algorithms.',
                          ),
                          _Bullet(
                            icon: Icons.analytics_outlined,
                            text:
                                'Understand Time Complexity and Space Complexity.',
                          ),
                          _Bullet(
                            icon: Icons.code_rounded,
                            text:
                                'Understand the logic and implementation of algorithms.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 45),

                    // ==================================================
                    // SORTING
                    // ==================================================
                    _SectionTitle(
                      icon: Icons.sort_rounded,
                      title: 'Sorting Algorithms',
                      color: cyan,
                    ),

                    const SizedBox(height: 16),

                    _ResponsiveGrid(
                      children: [
                        _AlgorithmCard(
                          icon: Icons.swap_vert_rounded,
                          title: 'Bubble Sort',
                          description:
                              'Compares adjacent elements and sorts them into the correct order.',
                          complexity: 'O(n²)',
                          color: cyan,
                        ),
                        _AlgorithmCard(
                          icon: Icons.select_all_rounded,
                          title: 'Selection Sort',
                          description:
                              'Selects the minimum element at each step and places it in the correct position.',
                          complexity: 'O(n²)',
                          color: blue,
                        ),
                        _AlgorithmCard(
                          icon: Icons.call_split_rounded,
                          title: 'Merge Sort',
                          description:
                              'Divides the array, recursively sorts the parts, and then merges them.',
                          complexity: 'O(n log n)',
                          color: purple,
                        ),
                        _AlgorithmCard(
                          icon: Icons.compare_arrows_rounded,
                          title: 'Quick Sort',
                          description:
                              'Partitions the data around a pivot element.',
                          complexity: 'O(n log n)',
                          color: green,
                        ),
                      ],
                    ),

                    const SizedBox(height: 45),

                    // ==================================================
                    // SEARCHING
                    // ==================================================
                    _SectionTitle(
                      icon: Icons.search_rounded,
                      title: 'Searching Algorithms',
                      color: orange,
                    ),

                    const SizedBox(height: 16),

                    _ResponsiveGrid(
                      children: [
                        _AlgorithmCard(
                          icon: Icons.search_rounded,
                          title: 'Linear Search',
                          description:
                              'Checks elements one by one to find the required value.',
                          complexity: 'O(n)',
                          color: orange,
                        ),
                        _AlgorithmCard(
                          icon: Icons.manage_search_rounded,
                          title: 'Binary Search',
                          description:
                              'Repeatedly divides sorted data in half to find the required value.',
                          complexity: 'O(log n)',
                          color: cyan,
                        ),
                      ],
                    ),

                    const SizedBox(height: 45),

                    // ==================================================
                    // GRAPH
                    // ==================================================
                    _SectionTitle(
                      icon: Icons.hub_rounded,
                      title: 'Graph Algorithms',
                      color: green,
                    ),

                    const SizedBox(height: 16),

                    _ResponsiveGrid(
                      children: [
                        _AlgorithmCard(
                          icon: Icons.route_rounded,
                          title: 'Dijkstra',
                          description:
                              'Finds the shortest path from a source vertex in a graph.',
                          complexity: 'O((V+E) log V)',
                          color: green,
                        ),
                        _AlgorithmCard(
                          icon: Icons.explore_rounded,
                          title: 'BFS',
                          description: 'Traverses the graph level by level.',
                          complexity: 'O(V + E)',
                          color: cyan,
                        ),
                        _AlgorithmCard(
                          icon: Icons.account_tree_rounded,
                          title: 'DFS',
                          description:
                              'Explores the graph according to its depth.',
                          complexity: 'O(V + E)',
                          color: purple,
                        ),
                      ],
                    ),

                    const SizedBox(height: 45),

                    // ==================================================
                    // TREES
                    // ==================================================
                    _SectionTitle(
                      icon: Icons.account_tree_rounded,
                      title: 'Tree Data Structures',
                      color: purple,
                    ),

                    const SizedBox(height: 16),

                    _ResponsiveGrid(
                      children: [
                        _AlgorithmCard(
                          icon: Icons.device_hub_rounded,
                          title: 'Binary Tree',
                          description:
                              'Represents hierarchical data using a tree structure.',
                          complexity: 'Depends',
                          color: purple,
                        ),
                        _AlgorithmCard(
                          icon: Icons.schema_rounded,
                          title: 'Binary Search Tree',
                          description:
                              'An ordered tree where searching and insertion can be efficient.',
                          complexity: 'Avg O(log n)',
                          color: blue,
                        ),
                      ],
                    ),

                    const SizedBox(height: 45),

                    // ==================================================
                    // COMPLEXITY
                    // ==================================================
                    _SectionTitle(
                      icon: Icons.speed_rounded,
                      title: 'Time & Space Complexity',
                      color: orange,
                    ),

                    const SizedBox(height: 16),

                    _InfoCard(
                      icon: Icons.analytics_rounded,
                      title: 'Big-O Notation',
                      accentColor: orange,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Big-O notation is a standard method for describing algorithm efficiency. It shows how the execution time of an algorithm grows as the input size increases.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.7,
                            ),
                          ),
                          const SizedBox(height: 22),
                          _ComplexityRow(
                            complexity: 'O(1)',
                            meaning: 'Constant',
                            color: green,
                            percentage: .95,
                          ),
                          _ComplexityRow(
                            complexity: 'O(log n)',
                            meaning: 'Very Efficient',
                            color: cyan,
                            percentage: .78,
                          ),
                          _ComplexityRow(
                            complexity: 'O(n)',
                            meaning: 'Linear',
                            color: blue,
                            percentage: .60,
                          ),
                          _ComplexityRow(
                            complexity: 'O(n log n)',
                            meaning: 'Efficient Sorting',
                            color: purple,
                            percentage: .42,
                          ),
                          _ComplexityRow(
                            complexity: 'O(n²)',
                            meaning: 'Quadratic',
                            color: orange,
                            percentage: .22,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 45),

                    // ==================================================
                    // HOW IT WORKS
                    // ==================================================
                    _SectionTitle(
                      icon: Icons.timeline_rounded,
                      title: 'How does the Visualizer work?',
                      color: cyan,
                    ),

                    const SizedBox(height: 16),

                    _ResponsiveGrid(
                      children: [
                        _StepCard(
                          number: '01',
                          title: 'Choose',
                          description:
                              'Select an algorithm according to your requirements.',
                          color: cyan,
                        ),
                        _StepCard(
                          number: '02',
                          title: 'Input',
                          description:
                              'Provide the data or values on which the algorithm will execute.',
                          color: blue,
                        ),
                        _StepCard(
                          number: '03',
                          title: 'Visualize',
                          description:
                              'Watch the algorithm through an animated visual representation.',
                          color: purple,
                        ),
                        _StepCard(
                          number: '04',
                          title: 'Analyze',
                          description:
                              'Understand the steps, performance, and complexity.',
                          color: green,
                        ),
                      ],
                    ),

                    const SizedBox(height: 45),

                    // ==================================================
                    // BENEFITS
                    // ==================================================
                    _SectionTitle(
                      icon: Icons.school_rounded,
                      title: 'Benefits for College Students',
                      color: cyan,
                    ),

                    const SizedBox(height: 16),

                    _InfoCard(
                      icon: Icons.workspace_premium_rounded,
                      title: 'Why Students Will Love It',
                      accentColor: cyan,
                      child: Column(
                        children: [
                          _Bullet(
                            icon: Icons.check_circle_rounded,
                            text:
                                'Helps you understand Data Structures & Algorithms concepts more easily.',
                          ),
                          _Bullet(
                            icon: Icons.check_circle_rounded,
                            text:
                                'Practical learning through interactive animations.',
                          ),
                          _Bullet(
                            icon: Icons.check_circle_rounded,
                            text:
                                'Useful for DSA preparation for programming interviews.',
                          ),
                          _Bullet(
                            icon: Icons.check_circle_rounded,
                            text:
                                'Useful for college practicals and presentations.',
                          ),
                          _Bullet(
                            icon: Icons.check_circle_rounded,
                            text:
                                'Helps compare the efficiency of different algorithms.',
                          ),
                          _Bullet(
                            icon: Icons.check_circle_rounded,
                            text:
                                'Makes complex concepts easier to remember through visual learning.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 45),

                    // ==================================================
                    // REAL WORLD
                    // ==================================================
                    _SectionTitle(
                      icon: Icons.public_rounded,
                      title: 'Where are Algorithms used in Real Life?',
                      color: green,
                    ),

                    const SizedBox(height: 16),

                    _ResponsiveGrid(
                      children: [
                        _RealWorldCard(
                          icon: Icons.map_rounded,
                          title: 'Google Maps',
                          text:
                              'Graph algorithms are used for shortest-path and route finding.',
                          color: cyan,
                        ),
                        _RealWorldCard(
                          icon: Icons.shopping_cart_rounded,
                          title: 'E-Commerce',
                          text: 'Search, sorting, and recommendation systems.',
                          color: orange,
                        ),
                        _RealWorldCard(
                          icon: Icons.share_rounded,
                          title: 'Social Media',
                          text:
                              'Networks, recommendations, and content ranking.',
                          color: purple,
                        ),
                        _RealWorldCard(
                          icon: Icons.memory_rounded,
                          title: 'Computer Science',
                          text:
                              'Databases, operating systems, and software development.',
                          color: green,
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // ==================================================
                    // FINAL CTA
                    // ==================================================
                    const _FinalCTA(),

                    const SizedBox(height: 25),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // APP BAR
  // ================================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: background.withOpacity(.92),
      elevation: 0,
      centerTitle: false,
      titleSpacing: 18,
      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: const LinearGradient(colors: [cyan, blue, purple]),
              boxShadow: [
                BoxShadow(color: cyan.withOpacity(.18), blurRadius: 18),
              ],
            ),
            child: const Icon(
              Icons.account_tree_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Algorithm Visualizer',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// HERO SECTION
// ====================================================================

class _HeroSection extends StatefulWidget {
  const _HeroSection();

  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _neonController;

  @override
  void initState() {
    super.initState();
    _neonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _neonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return AnimatedBuilder(
      animation: _neonController,
      builder: (context, child) {
        return CustomPaint(
          painter: _NeonBorderPainter(
            progress: _neonController.value,
            radius: 30,
          ),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(3),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 22 : 55,
              vertical: isMobile ? 38 : 58,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF071B36),
                  Color(0xFF080F22),
                  Color(0xFF180A2F),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(.08),
                  blurRadius: 40,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: Colors.purple.withOpacity(.06),
                  blurRadius: 45,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -80,
                  right: -70,
                  child: _Glow(size: 220, color: Colors.purple),
                ),

                if (!isMobile)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.cyan.withOpacity(.08),
                            border: Border.all(
                              color: Colors.cyan.withOpacity(.25),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.withOpacity(.15),
                                blurRadius: 25,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.rocket_launch_rounded,
                            color: Colors.cyan,
                            size: 31,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DashboardScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded, size: 22),
                          label: const Text(
                            'Gets Start',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            foregroundColor: Colors.black,
                            elevation: 10,
                            shadowColor: Colors.cyan.withOpacity(.35),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                Column(
                  children: [
                    if (isMobile) ...[
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.cyan.withOpacity(.08),
                          border: Border.all(
                            color: Colors.cyan.withOpacity(.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.rocket_launch_rounded,
                          color: Colors.cyan,
                          size: 31,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Colors.cyan, Colors.blue, Colors.purple],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withOpacity(.30),
                            blurRadius: 35,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_tree_rounded,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),

                    const SizedBox(height: 25),

                    const Text(
                      'Algorithm Visualizer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.2,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Colors.cyan, Colors.blue, Colors.purple],
                      ).createShader(bounds),
                      child: const Text(
                        'LEARN  •  EXPLORE  •  VISUALIZE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      'Understand complex algorithms through interactive '
                      'visualizations, animations and step-by-step execution.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 15,
                        height: 1.7,
                      ),
                    ),

                    const SizedBox(height: 27),

                    const Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _HeroTag(
                          icon: Icons.animation_rounded,
                          text: 'Interactive',
                        ),
                        _HeroTag(
                          icon: Icons.timeline_rounded,
                          text: 'Step-by-Step',
                        ),
                        _HeroTag(
                          icon: Icons.analytics_rounded,
                          text: 'Complexity',
                        ),
                      ],
                    ),

                    if (isMobile) ...[
                      const SizedBox(height: 28),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DashboardScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.play_arrow_rounded, size: 22),
                        label: const Text(
                          'Start Visualizing',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ====================================================================
// ANIMATED NEON BORDER
// ====================================================================

class _NeonBorderPainter extends CustomPainter {
  final double progress;
  final double radius;

  _NeonBorderPainter({required this.progress, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);

    final rRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final gradient = SweepGradient(
      transform: GradientRotation(progress * 6.28318530718),
      colors: const [
        Colors.cyan,
        Color(0xFF00E5FF),
        Colors.blue,
        Colors.purple,
        Colors.pink,
        Colors.purple,
        Colors.blue,
        Colors.cyan,
      ],
    );

    final glowPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 10);

    canvas.drawRRect(rRect, glowPaint);

    final borderPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(rRect, borderPaint);

    final softGlowPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 4);

    canvas.drawRRect(rRect, softGlowPaint);
  }

  @override
  bool shouldRepaint(covariant _NeonBorderPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// ====================================================================
// HERO TAG
// ====================================================================

class _HeroTag extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeroTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.045),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.cyan, size: 16),
          const SizedBox(width: 7),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// SECTION TITLE
// ====================================================================

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _SectionTitle({
    required this.icon,
    required this.title,
    this.color = Colors.cyan,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: color.withOpacity(.07),
            border: Border.all(color: color.withOpacity(.30)),
            boxShadow: [
              BoxShadow(color: color.withOpacity(.06), blurRadius: 15),
            ],
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 35,
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color, color.withOpacity(0)]),
          ),
        ),
      ],
    );
  }
}

// ====================================================================
// INFO CARD
// ====================================================================

class _InfoCard extends StatelessWidget {
  final Widget child;
  final IconData icon;
  final String title;
  final Color accentColor;

  const _InfoCard({
    required this.child,
    required this.icon,
    required this.title,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1326).withOpacity(.92),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accentColor.withOpacity(.13)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: accentColor.withOpacity(.08),
                ),
                child: Icon(icon, color: accentColor, size: 21),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

// ====================================================================
// RESPONSIVE GRID - 4 COLUMNS ON DESKTOP
// ====================================================================

class _ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;

  const _ResponsiveGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    int columns;

    if (width < 600) {
      // Mobile
      columns = 1;
    } else if (width < 950) {
      // Tablet
      columns = 2;
    } else {
      // Desktop
      columns = 4;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: children.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        mainAxisExtent: 190,
      ),
      itemBuilder: (context, index) {
        return children[index];
      },
    );
  }
}

// ====================================================================
// STAT CARD
// ====================================================================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1428),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: color.withOpacity(.08),
            ),
            child: Icon(icon, color: color, size: 23),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// FEATURE CARD
// ====================================================================

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1428),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.17)),
        boxShadow: [BoxShadow(color: color.withOpacity(.025), blurRadius: 20)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: color.withOpacity(.08),
              border: Border.all(color: color.withOpacity(.12)),
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// ALGORITHM CARD
// ====================================================================

class _AlgorithmCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String complexity;
  final Color color;

  const _AlgorithmCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.complexity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1428),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.17)),
        boxShadow: [BoxShadow(color: color.withOpacity(.025), blurRadius: 18)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  gradient: LinearGradient(
                    colors: [color.withOpacity(.15), color.withOpacity(.035)],
                  ),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(.07),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: color.withOpacity(.10)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.speed_rounded, color: color, size: 14),
                const SizedBox(width: 6),
                Text(
                  complexity,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// STEP CARD
// ====================================================================

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final Color color;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1428),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: TextStyle(
              color: color,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// REAL WORLD CARD
// ====================================================================

class _RealWorldCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final Color color;

  const _RealWorldCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1428),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 47,
            height: 47,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: color.withOpacity(.08),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// BULLET
// ====================================================================

class _Bullet extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Bullet({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.cyan, size: 19),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// COMPLEXITY ROW
// ====================================================================

class _ComplexityRow extends StatelessWidget {
  final String complexity;
  final String meaning;
  final Color color;
  final double percentage;

  const _ComplexityRow({
    required this.complexity,
    required this.meaning,
    required this.color,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.025),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withOpacity(.035)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(
                  complexity,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  meaning,
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 4,
              backgroundColor: Colors.white.withOpacity(.05),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// FINAL CTA
// ====================================================================

class _FinalCTA extends StatelessWidget {
  const _FinalCTA();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF06233B), Color(0xFF10133A), Color(0xFF1D0B38)],
        ),
        border: Border.all(color: Colors.cyan.withOpacity(.25)),
        boxShadow: [
          BoxShadow(color: Colors.cyan.withOpacity(.06), blurRadius: 35),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.cyan.withOpacity(.08),
              border: Border.all(color: Colors.cyan.withOpacity(.25)),
              boxShadow: [
                BoxShadow(color: Colors.cyan.withOpacity(.15), blurRadius: 25),
              ],
            ),
            child: const Icon(
              Icons.rocket_launch_rounded,
              color: Colors.cyan,
              size: 31,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Ready to Explore Algorithms?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Learn algorithms by seeing them in action — '
            'not just by reading about them.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.6),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DashboardScreen(),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded, size: 22),
            label: const Text(
              'Gets Start',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyan,
              foregroundColor: Colors.black,
              elevation: 10,
              shadowColor: Colors.cyan.withOpacity(.35),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// GLOW
// ====================================================================

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
              color.withOpacity(.10),
              color.withOpacity(.025),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// BACKGROUND GRID
// ====================================================================

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(.018)
      ..strokeWidth = .7;

    const double spacing = 45;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
