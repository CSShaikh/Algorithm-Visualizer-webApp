import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class LinearSearchScreen extends StatefulWidget {
  const LinearSearchScreen({super.key});

  @override
  State<LinearSearchScreen> createState() => _LinearSearchScreenState();
}

class _LinearSearchScreenState extends State<LinearSearchScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color background = Color(0xFF030712);
  static const Color background2 = Color(0xFF07101F);
  static const Color cardColor = Color(0xFF0B1428);
  static const Color visualizationBackground = Color(0xFF0A1020);

  static const Color cyan = Color(0xFF00E5FF);
  static const Color blue = Color(0xFF2979FF);
  static const Color purple = Color(0xFF9C27FF);
  static const Color green = Color(0xFF00E676);
  static const Color orange = Color(0xFFFFB300);
  static const Color pink = Color(0xFFFF4081);

  // ============================================================
  // DATA
  // ============================================================

  List<int> array = [64, 25, 12, 22, 11];

  int target = 22;

  int currentIndex = -1;
  int foundIndex = -1;

  bool isRunning = false;
  bool isCompleted = false;

  int step = 0;

  double speed = 1.0;

  Timer? timer;

  // Prevent overlapping animated steps.
  bool _stepAnimating = false;

  // Used to invalidate old delayed callbacks.
  int _operationId = 0;

  // ============================================================
  // CODE VISUALIZATION
  // ============================================================

  int activeCodeLine = 0;

  String executionMessage = 'Ready to start Linear Search';

  // ============================================================
  // EXECUTION HISTORY
  // ============================================================

  final List<SearchStep> executionHistory = [];

  // ============================================================
  // INPUT CONTROLLERS
  // ============================================================

  final TextEditingController arrayController = TextEditingController(
    text: '64, 25, 12, 22, 11',
  );

  final TextEditingController targetController = TextEditingController(
    text: '22',
  );

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void dispose() {
    timer?.cancel();
    arrayController.dispose();
    targetController.dispose();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 40),
                child: Column(
                  children: [
                    _buildOverviewCard(),

                    const SizedBox(height: 18),

                    _buildInputCard(),

                    const SizedBox(height: 18),

                    _buildMainWorkspace(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: background2,
        border: Border(bottom: BorderSide(color: cyan.withOpacity(.08))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 18),

          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: cyan.withOpacity(.07),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: cyan.withOpacity(.30)),
            ),
            child: const Icon(Icons.search_rounded, color: cyan, size: 28),
          ),

          const SizedBox(width: 15),

          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Linear Search',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Interactive Algorithm Visualizer',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _buildOverviewCard() {
    return _panel(
      borderColor: cyan.withOpacity(.15),
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionIcon(Icons.school_rounded, cyan),

              const SizedBox(width: 14),

              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ALGORITHM OVERVIEW',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .6,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Understand how Linear Search works step by step',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),

              const Spacer(),

              _badge('BEGINNER', green),
            ],
          ),

          const SizedBox(height: 28),

          const Text(
            'Linear Search',
            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Linear Search checks every element one by one '
            'from the beginning of the array until the target '
            'element is found.',
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.6),
          ),

          const SizedBox(height: 24),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _infoBox('TIME', 'O(n)', pink, Icons.timer_outlined),
              _infoBox('SPACE', 'O(1)', cyan, Icons.memory_rounded),
              _infoBox('TYPE', 'Searching', purple, Icons.alt_route_rounded),
              _infoBox('BEST', 'O(1)', green, Icons.check_circle_outline),
              _infoBox('WORST', 'O(n)', orange, Icons.trending_up_rounded),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INPUT SECTION
  // ============================================================

  Widget _buildInputCard() {
    return _panel(
      borderColor: purple.withOpacity(.18),
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionIcon(Icons.data_array_rounded, purple),

              const SizedBox(width: 14),

              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INPUT SECTION',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Provide input to start the visualization',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 22),

          LayoutBuilder(
            builder: (context, constraints) {
              final bool compact = constraints.maxWidth < 900;

              if (compact) {
                return Column(
                  children: [
                    _inputWithLabel(
                      label: 'ENTER NUMBERS',
                      helper: 'Enter numbers separated by commas',
                      controller: arrayController,
                      icon: Icons.edit_rounded,
                      color: cyan,
                      hint: '64, 25, 12, 22, 11',
                    ),

                    const SizedBox(height: 16),

                    _inputWithLabel(
                      label: 'ENTER TARGET NUMBER',
                      helper: 'The number you want to search',
                      controller: targetController,
                      icon: Icons.gps_fixed_rounded,
                      color: purple,
                      hint: '22',
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(child: _generateButton()),

                        const SizedBox(width: 12),

                        Expanded(child: _loadArrayButton()),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    flex: 4,
                    child: _inputWithLabel(
                      label: 'ENTER NUMBERS',
                      helper: 'Enter numbers separated by commas',
                      controller: arrayController,
                      icon: Icons.edit_rounded,
                      color: cyan,
                      hint: '64, 25, 12, 22, 11',
                    ),
                  ),

                  const SizedBox(width: 16),

                  Expanded(
                    flex: 3,
                    child: _inputWithLabel(
                      label: 'ENTER TARGET NUMBER',
                      helper: 'The number you want to search',
                      controller: targetController,
                      icon: Icons.gps_fixed_rounded,
                      color: purple,
                      hint: '22',
                    ),
                  ),

                  const SizedBox(width: 16),

                  SizedBox(width: 205, child: _generateButton()),

                  const SizedBox(width: 12),

                  SizedBox(width: 205, child: _loadArrayButton()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INPUT FIELD
  // ============================================================

  Widget _inputWithLabel({
    required String label,
    required String helper,
    required TextEditingController controller,
    required IconData icon,
    required Color color,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),

            const SizedBox(width: 7),

            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),

        const SizedBox(height: 9),

        Container(
          height: 58,
          decoration: BoxDecoration(
            color: background2,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: color.withOpacity(.20)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: color, size: 20),
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 18),
            ),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          helper,
          style: const TextStyle(color: Colors.white38, fontSize: 9),
        ),
      ],
    );
  }

  // ============================================================
  // GENERATE RANDOM NUMBERS
  // ============================================================

  Widget _generateButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'GENERATE RANDOM NUMBERS',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 8),

        SizedBox(
          height: 58,
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _generateNumbers,
            icon: const Icon(Icons.shuffle_rounded, size: 19),
            label: const Text(
              'GENERATE NUMBERS',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: cyan,
              side: BorderSide(color: cyan.withOpacity(.35)),
              backgroundColor: cyan.withOpacity(.025),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOAD ARRAY BUTTON
  // ============================================================

  Widget _loadArrayButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'START VISUALIZATION',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 9),

        SizedBox(
          height: 58,
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _loadArray,
            icon: const Icon(Icons.play_arrow_rounded, size: 19),
            label: const Text(
              'LOAD ARRAY',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: cyan,
              foregroundColor: Colors.black,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MAIN WORKSPACE
  // ============================================================

  Widget _buildMainWorkspace() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool mobile = constraints.maxWidth < 950;

        if (mobile) {
          return Column(
            children: [
              _buildVisualizationPanel(),

              const SizedBox(height: 16),

              _buildControls(),

              const SizedBox(height: 16),

              _buildSourceCodePanel(),

              const SizedBox(height: 16),

              _buildExecutionSteps(),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Column(
                children: [
                  _buildVisualizationPanel(),

                  const SizedBox(height: 16),

                  _buildControls(),
                ],
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildSourceCodePanel(),

                  const SizedBox(height: 16),

                  _buildExecutionSteps(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // VISUALIZATION PANEL
  // ============================================================

  Widget _buildVisualizationPanel() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cyan.withOpacity(.15)),
      ),
      child: Column(
        children: [
          _buildPanelHeader(
            icon: Icons.account_tree_rounded,
            color: cyan,
            title: 'Linear Search Visualization',
            subtitle: 'Watch elements being checked one by one',
            badge: '${array.length} ELEMENTS',
            badgeColor: purple,
          ),

          Container(height: 1, color: Colors.white.withOpacity(.06)),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              children: [
                _legend('Ready', purple),
                _legend('Checking', cyan),
                _legend('Found', green),
                _legend('Not Match', pink),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            decoration: const BoxDecoration(
              color: visualizationBackground,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Column(
              children: [
                _buildArray(),

                const SizedBox(height: 14),

                Divider(height: 1, color: Colors.white.withOpacity(.08)),

                const SizedBox(height: 12),

                _buildSearchDetails(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ARRAY
  // ============================================================

  Widget _buildArray() {
    if (array.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'No array loaded.',
          style: TextStyle(color: Colors.white38, fontSize: 11),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(array.length, (index) {
          return _arrayElement(index, array[index]);
        }),
      ),
    );
  }

  Widget _arrayElement(int index, int value) {
    final bool current = currentIndex == index;

    final bool found = foundIndex == index;

    final bool checked = executionHistory.any(
      (step) => step.index == index && !step.isMatch,
    );

    Color borderColor = purple.withOpacity(.35);

    Color textColor = Colors.white70;

    String status = 'READY';

    if (checked) {
      borderColor = pink;
      textColor = pink;
      status = 'NOT MATCH';
    }

    if (current && !found) {
      borderColor = cyan;
      textColor = cyan;
      status = 'CHECKING';
    }

    if (found) {
      borderColor = green;
      textColor = green;
      status = 'FOUND';
    }

    return Container(
      width: 76,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: borderColor.withOpacity(.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'INDEX $index',
              style: TextStyle(
                color: borderColor,
                fontSize: 7,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(height: 5),

          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: borderColor.withOpacity(.08),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: borderColor,
                width: current || found ? 2 : 1,
              ),
              boxShadow: current || found
                  ? [
                      BoxShadow(
                        color: borderColor.withOpacity(.18),
                        blurRadius: 12,
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                '$value',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            status,
            style: TextStyle(
              color: borderColor,
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: .3,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH DETAILS
  // ============================================================

  Widget _buildSearchDetails() {
    if (currentIndex < 0 || array.isEmpty) {
      return _executionStatusCard(
        icon: Icons.play_circle_outline_rounded,
        title: 'READY TO START',
        message: 'Press Play or Next Step to begin checking elements.',
        color: purple,
      );
    }

    final bool found = foundIndex >= 0;

    final int safeIndex = currentIndex.clamp(0, array.length - 1);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _detailBox(
                icon: Icons.tag_rounded,
                label: 'CURRENT INDEX',
                value: '$currentIndex',
                color: cyan,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _detailBox(
                icon: Icons.data_object_rounded,
                label: 'CURRENT ELEMENT',
                value: '${array[safeIndex]}',
                color: purple,
              ),
            ),

            const SizedBox(width: 8),

            Expanded(
              child: _detailBox(
                icon: Icons.gps_fixed_rounded,
                label: 'TARGET',
                value: '$target',
                color: orange,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        _executionStatusCard(
          icon: found
              ? Icons.check_circle_rounded
              : Icons.compare_arrows_rounded,
          title: found ? 'TARGET FOUND' : 'CURRENT COMPARISON',
          message: found
              ? '${array[safeIndex]} == $target → MATCH FOUND!'
              : '${array[safeIndex]} != $target → NOT MATCH',
          color: found ? green : cyan,
        ),
      ],
    );
  }

  // ============================================================
  // SOURCE CODE
  // ============================================================

  Widget _buildSourceCodePanel() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: purple.withOpacity(.18)),
      ),
      child: Column(
        children: [
          _buildPanelHeader(
            icon: Icons.code_rounded,
            color: purple,
            title: 'Linear Search Source Code',
            subtitle: 'LIVE CODE EXECUTION',
            badge: activeCodeLine == 0 ? 'READY' : 'LINE $activeCodeLine',
            badgeColor: cyan,
          ),

          Container(height: 1, color: Colors.white.withOpacity(.06)),

          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Column(
              children: [
                _codeLine(
                  1,
                  'void linearSearch(List<int> arr, int target) {',
                  color: purple,
                ),
                _codeLine(
                  2,
                  '  for (int i = 0; i < arr.length; i++) {',
                  color: cyan,
                ),
                _codeLine(3, '    if (arr[i] == target) {', color: orange),
                _codeLine(
                  4,
                  '      print("Element found at index i");',
                  color: green,
                ),
                _codeLine(5, '      return;', color: green),
                _codeLine(6, '    }'),
                _codeLine(7, '    // Element does not match', color: pink),
                _codeLine(8, '  }'),
                _codeLine(9, '  print("Element not found");', color: pink),
                _codeLine(10, '}'),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: activeCodeLine == 4 || activeCodeLine == 5
                    ? green.withOpacity(.06)
                    : cyan.withOpacity(.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: activeCodeLine == 4 || activeCodeLine == 5
                      ? green.withOpacity(.25)
                      : cyan.withOpacity(.12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    activeCodeLine == 4 || activeCodeLine == 5
                        ? Icons.check_circle_rounded
                        : Icons.play_circle_outline_rounded,
                    color: activeCodeLine == 4 || activeCodeLine == 5
                        ? green
                        : cyan,
                    size: 16,
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      executionMessage,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 9,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EXECUTION STEPS
  // ============================================================

  Widget _buildExecutionSteps() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cyan.withOpacity(.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: cyan.withOpacity(.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: cyan.withOpacity(.15)),
                  ),
                  child: const Icon(
                    Icons.history_rounded,
                    color: cyan,
                    size: 18,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXECUTION STEPS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .5,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Every comparison made by the algorithm',
                        style: TextStyle(color: Colors.white38, fontSize: 8),
                      ),
                    ],
                  ),
                ),

                Text(
                  '${executionHistory.length} STEPS',
                  style: const TextStyle(
                    color: cyan,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (executionHistory.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: background.withOpacity(.4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(.07)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      color: Colors.white30,
                      size: 15,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Execution steps will appear here...',
                      style: TextStyle(color: Colors.white38, fontSize: 9),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: [
                  for (int i = 0; i < executionHistory.length; i++) ...[
                    _executionStepBlock(executionHistory[i]),

                    if (i < executionHistory.length - 1)
                      const SizedBox(height: 6),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _executionStepBlock(SearchStep item) {
    final Color statusColor = item.isMatch ? green : pink;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(.045),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: statusColor.withOpacity(.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(.10),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: Text(
                '${item.stepNumber}',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INDEX ${item.index}',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .4,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  item.isMatch
                      ? '${item.value} == $target  →  MATCH FOUND'
                      : '${item.value} != $target  →  NOT MATCH',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            item.isMatch ? Icons.check_circle_rounded : Icons.close_rounded,
            color: statusColor,
            size: 16,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTROLS
  // ============================================================

  Widget _buildControls() {
    final int maxSteps = array.isEmpty ? 1 : array.length;

    final double progress = (step / maxSteps).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: blue.withOpacity(.18)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _sectionIconSmall(Icons.tune_rounded, cyan),

              const SizedBox(width: 10),

              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ANIMATION CONTROLS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .5,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Control visualization execution',
                    style: TextStyle(color: Colors.white38, fontSize: 8),
                  ),
                ],
              ),

              const Spacer(),

              _badge('STEP $step / $maxSteps', cyan),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              _controlButton(Icons.refresh_rounded, _reset),

              const SizedBox(width: 8),

              _controlButton(Icons.skip_previous_rounded, _previousStep),

              const SizedBox(width: 8),

              _playButton(),

              const SizedBox(width: 8),

              _controlButton(Icons.skip_next_rounded, _nextStep),
            ],
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              const Icon(Icons.speed_rounded, color: purple, size: 16),

              const SizedBox(width: 7),

              const Text(
                'SPEED',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Slider(
                  value: speed,
                  min: .5,
                  max: 2,
                  divisions: 3,
                  activeColor: purple,
                  inactiveColor: Color(0xFF9C27FF).withOpacity(.15),
                  onChanged: (value) {
                    setState(() {
                      speed = value;
                    });
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: purple.withOpacity(.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: purple.withOpacity(.20)),
                ),
                child: Text(
                  '${speed.toStringAsFixed(2)}x',
                  style: const TextStyle(
                    color: purple,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Text(
                'VISUALIZATION PROGRESS',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              ),

              const Spacer(),

              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: green,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(.05),
              valueColor: const AlwaysStoppedAnimation(green),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PLAY BUTTON
  // ============================================================

  Widget _playButton() {
    return InkWell(
      onTap: isCompleted ? null : _togglePlay,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 52,
        height: 48,
        decoration: BoxDecoration(
          color: cyan.withOpacity(isRunning ? .15 : .08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cyan.withOpacity(.25)),
        ),
        child: Icon(
          isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: cyan,
          size: 23,
        ),
      ),
    );
  }

  // ============================================================
  // DETAIL BOX
  // ============================================================

  Widget _detailBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: color.withOpacity(.04),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withOpacity(.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(.09),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 15),
          ),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 6.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS CARD
  // ============================================================

  Widget _executionStatusCard({
    required IconData icon,
    required String title,
    required String message,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(.035),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, color: color, size: 17),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .5,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PANEL HEADER
  // ============================================================

  Widget _buildPanelHeader({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
  }) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _sectionIconSmall(icon, color),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white38, fontSize: 8),
                ),
              ],
            ),
          ),

          _badge(badge, badgeColor),
        ],
      ),
    );
  }

  // ============================================================
  // CODE LINE
  // ============================================================

  Widget _codeLine(int lineNumber, String code, {Color? color}) {
    final bool active = activeCodeLine == lineNumber;

    Color lineColor = color ?? Colors.white60;

    if (active) {
      lineColor = Colors.white;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      margin: const EdgeInsets.symmetric(horizontal: 9, vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: active ? cyan.withOpacity(.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: active ? cyan.withOpacity(.55) : Colors.transparent,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$lineNumber',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: active ? cyan : Colors.white24,
                fontSize: 8,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              code,
              style: TextStyle(
                color: lineColor,
                fontSize: 9,
                height: 1.35,
                fontFamily: 'monospace',
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),

          if (active)
            Container(
              margin: const EdgeInsets.only(top: 3),
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: cyan,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  Widget _panel({
    required Widget child,
    required Color borderColor,
    EdgeInsets padding = const EdgeInsets.all(20),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }

  Widget _sectionIcon(IconData icon, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withOpacity(.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _sectionIconSmall(IconData icon, Color color) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withOpacity(.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(.20)),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 8,
          fontWeight: FontWeight.w900,
          letterSpacing: .6,
        ),
      ),
    );
  }

  Widget _infoBox(String title, String value, Color color, IconData icon) {
    return Container(
      width: 135,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withOpacity(.035),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withOpacity(.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 7),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),

          const SizedBox(width: 5),

          Text(
            text,
            style: const TextStyle(color: Colors.white54, fontSize: 8),
          ),
        ],
      ),
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        width: 50,
        height: 48,
        decoration: BoxDecoration(
          color: background2,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: blue.withOpacity(.20)),
        ),
        child: Icon(icon, color: Colors.white60, size: 20),
      ),
    );
  }

  // ============================================================
  // GENERATE RANDOM NUMBERS
  //
  // IMPORTANT:
  // This function ONLY generates values in the input fields.
  // It does NOT load the visualization.
  // ============================================================

  void _generateNumbers() {
    final Random random = Random();

    // Cancel currently running animation.
    timer?.cancel();

    // Invalidate all old delayed callbacks.
    _operationId++;

    // Generate 8 random numbers.
    final List<int> generated = List.generate(
      8,
      (_) => 10 + random.nextInt(91),
    );

    // Pick target from the generated array.
    final int generatedTarget = generated[random.nextInt(generated.length)];

    setState(() {
      // Update ONLY the input fields.
      arrayController.text = generated.join(', ');

      targetController.text = generatedTarget.toString();

      // Reset visualization state.
      currentIndex = -1;
      foundIndex = -1;

      step = 0;

      isRunning = false;
      isCompleted = false;

      _stepAnimating = false;

      activeCodeLine = 0;

      executionHistory.clear();

      executionMessage =
          'Random numbers generated. Press LOAD ARRAY to visualize.';
    });

    _showMessage('Random numbers generated. Press LOAD ARRAY to start.');
  }

  // ============================================================
  // LOAD ARRAY
  //
  // This is the ONLY function that copies input values
  // into the actual visualization array.
  // ============================================================

  void _loadArray() {
    final String rawArray = arrayController.text.trim();

    final String rawTarget = targetController.text.trim();

    // ----------------------------------------------------------
    // ARRAY VALIDATION
    // ----------------------------------------------------------

    if (rawArray.isEmpty) {
      _showMessage('Please enter numbers separated by commas.');
      return;
    }

    final List<String> parts = rawArray.split(',');

    final List<int> values = [];

    for (final String part in parts) {
      final String valueText = part.trim();

      if (valueText.isEmpty) {
        _showMessage('Invalid array input. Remove empty values.');
        return;
      }

      final int? value = int.tryParse(valueText);

      if (value == null) {
        _showMessage('"$valueText" is not a valid number.');
        return;
      }

      values.add(value);
    }

    // ----------------------------------------------------------
    // TARGET VALIDATION
    // ----------------------------------------------------------

    if (rawTarget.isEmpty) {
      _showMessage('Please enter a target number.');
      return;
    }

    final int? newTarget = int.tryParse(rawTarget);

    if (newTarget == null) {
      _showMessage('Target must be a valid integer.');
      return;
    }

    // ----------------------------------------------------------
    // LOAD
    // ----------------------------------------------------------

    timer?.cancel();

    // Invalidate old delayed callbacks.
    _operationId++;

    setState(() {
      array = List<int>.from(values);

      target = newTarget;

      currentIndex = -1;
      foundIndex = -1;

      step = 0;

      isRunning = false;
      isCompleted = false;

      _stepAnimating = false;

      activeCodeLine = 0;

      executionHistory.clear();

      executionMessage =
          'Array loaded successfully. Ready to start Linear Search.';
    });

    _showMessage('${values.length} elements loaded. Target = $newTarget');
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          backgroundColor: background2,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(milliseconds: 1800),
        ),
      );
  }

  // ============================================================
  // RESET
  // ============================================================

  void _reset() {
    timer?.cancel();

    // Invalidate pending callbacks.
    _operationId++;

    setState(() {
      currentIndex = -1;
      foundIndex = -1;

      step = 0;

      isRunning = false;
      isCompleted = false;

      _stepAnimating = false;

      activeCodeLine = 0;

      executionHistory.clear();

      executionMessage = 'Search reset. Ready to start from index 0.';
    });
  }

  // ============================================================
  // NEXT STEP
  // ============================================================

  void _nextStep() {
    if (isCompleted || array.isEmpty || _stepAnimating) {
      return;
    }

    if (step >= array.length) {
      _completeNotFound();
      return;
    }

    final int operation = _operationId;

    final int index = step;
    final int value = array[index];

    setState(() {
      _stepAnimating = true;

      currentIndex = index;

      step++;

      activeCodeLine = 2;

      executionMessage =
          'Loop iteration started: i = $index. '
          'Accessing arr[$index] = $value.';
    });

    final int firstDelay = (600 / speed).round();

    final int secondDelay = (1100 / speed).round();

    final int finalDelay = (700 / speed).round();

    // ----------------------------------------------------------
    // STEP 1
    // ----------------------------------------------------------

    Future.delayed(Duration(milliseconds: firstDelay), () {
      if (!mounted || isCompleted || operation != _operationId) {
        return;
      }

      setState(() {
        activeCodeLine = 3;

        executionMessage =
            'Evaluating condition: '
            'arr[$index] == target → '
            '$value == $target.';
      });
    });

    // ----------------------------------------------------------
    // STEP 2
    // ----------------------------------------------------------

    Future.delayed(Duration(milliseconds: secondDelay), () {
      if (!mounted || isCompleted || operation != _operationId) {
        return;
      }

      final bool isMatch = value == target;

      setState(() {
        executionHistory.add(
          SearchStep(
            stepNumber: executionHistory.length + 1,
            index: index,
            value: value,
            isMatch: isMatch,
          ),
        );
      });

      // ------------------------------------------------------
      // FOUND
      // ------------------------------------------------------

      if (isMatch) {
        setState(() {
          foundIndex = index;

          activeCodeLine = 4;

          executionMessage =
              'Condition TRUE! '
              '$value == $target. '
              'Element found.';
        });

        Future.delayed(Duration(milliseconds: finalDelay), () {
          if (!mounted || operation != _operationId) {
            return;
          }

          setState(() {
            activeCodeLine = 5;

            isCompleted = true;
            isRunning = false;
            _stepAnimating = false;

            executionMessage =
                'Executing return. '
                'Search completed successfully '
                'at index $index.';
          });

          timer?.cancel();
        });
      }
      // ------------------------------------------------------
      // NOT FOUND YET
      // ------------------------------------------------------
      else {
        setState(() {
          activeCodeLine = 7;

          executionMessage =
              'Condition FALSE! '
              '$value != $target. '
              'Continuing to next iteration.';

          _stepAnimating = false;
        });

        if (step >= array.length) {
          Future.delayed(Duration(milliseconds: finalDelay), () {
            if (!mounted || operation != _operationId) {
              return;
            }

            _completeNotFound();
          });
        }
      }
    });
  }

  // ============================================================
  // COMPLETE NOT FOUND
  // ============================================================

  void _completeNotFound() {
    timer?.cancel();

    setState(() {
      isCompleted = true;

      isRunning = false;

      _stepAnimating = false;

      activeCodeLine = 9;

      executionMessage =
          'Loop completed. All elements were checked. '
          'Target $target was not found.';
    });
  }

  // ============================================================
  // PREVIOUS STEP
  // ============================================================

  void _previousStep() {
    timer?.cancel();

    // Invalidate pending callbacks.
    _operationId++;

    if (step <= 0) {
      return;
    }

    setState(() {
      isRunning = false;
      isCompleted = false;

      _stepAnimating = false;

      foundIndex = -1;

      step--;

      _rebuildExecutionHistory();

      if (step == 0) {
        currentIndex = -1;

        activeCodeLine = 0;

        executionMessage = 'Ready to start Linear Search.';
      } else {
        currentIndex = step - 1;

        final int value = array[currentIndex];

        final bool match = value == target;

        if (match) {
          foundIndex = currentIndex;
          activeCodeLine = 4;
        } else {
          activeCodeLine = 7;
        }

        executionMessage =
            'Returned to step $step. '
            'Reviewing arr[$currentIndex] = $value.';
      }
    });
  }

  // ============================================================
  // REBUILD HISTORY
  // ============================================================

  void _rebuildExecutionHistory() {
    executionHistory.clear();

    for (int i = 0; i < step && i < array.length; i++) {
      final bool isMatch = array[i] == target;

      executionHistory.add(
        SearchStep(
          stepNumber: executionHistory.length + 1,
          index: i,
          value: array[i],
          isMatch: isMatch,
        ),
      );

      if (isMatch) {
        break;
      }
    }
  }

  // ============================================================
  // PLAY / PAUSE
  // ============================================================

  void _togglePlay() {
    if (isRunning) {
      timer?.cancel();

      setState(() {
        isRunning = false;

        executionMessage =
            'Animation paused at index '
            '$currentIndex.';
      });

      return;
    }

    if (isCompleted || array.isEmpty) {
      return;
    }

    setState(() {
      isRunning = true;
    });

    final int interval = (2600 / speed).round();

    timer = Timer.periodic(Duration(milliseconds: interval), (_) {
      if (!mounted) {
        return;
      }

      if (isCompleted) {
        timer?.cancel();

        setState(() {
          isRunning = false;
        });

        return;
      }

      if (!_stepAnimating) {
        _nextStep();
      }
    });

    if (!_stepAnimating) {
      _nextStep();
    }
  }
}

// ============================================================
// SEARCH STEP MODEL
// ============================================================

class SearchStep {
  final int stepNumber;
  final int index;
  final int value;
  final bool isMatch;

  SearchStep({
    required this.stepNumber,
    required this.index,
    required this.value,
    required this.isMatch,
  });
}
