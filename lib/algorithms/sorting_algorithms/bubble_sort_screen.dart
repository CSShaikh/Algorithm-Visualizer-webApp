import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class BubbleSortScreen extends StatefulWidget {
  const BubbleSortScreen({super.key});

  @override
  State<BubbleSortScreen> createState() => _BubbleSortScreenState();
}

class _BubbleSortScreenState extends State<BubbleSortScreen> {
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

  int outerIndex = 0;
  int innerIndex = 0;
  int compareLeft = -1;
  int compareRight = -1;
  int sortedFrom = 5;

  bool isRunning = false;
  bool isCompleted = false;
  bool _stepAnimating = false;

  int step = 0;
  double speed = 1.0;

  Timer? timer;
  int _operationId = 0;

  // ============================================================
  // CODE VISUALIZATION
  // ============================================================

  int activeCodeLine = 0;
  String executionMessage = 'Ready to start Bubble Sort';

  // ============================================================
  // EXECUTION HISTORY
  // ============================================================

  final List<SortStep> executionHistory = [];

  // ============================================================
  // INPUT
  // ============================================================

  final TextEditingController arrayController = TextEditingController(
    text: '64, 25, 12, 22, 11',
  );

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void dispose() {
    timer?.cancel();
    arrayController.dispose();
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
            onPressed: () => Navigator.pop(context),
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
            child: const Icon(Icons.swap_vert_rounded, color: cyan, size: 30),
          ),
          const SizedBox(width: 15),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bubble Sort',
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
              const Expanded(
                child: Column(
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
                      'Understand how Bubble Sort works step by step',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              _badge('BEGINNER', green),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Bubble Sort',
            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Bubble Sort repeatedly compares adjacent elements and '
            'swaps them when they are in the wrong order. After each '
            'pass, the largest unsorted element moves to the end.',
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.6),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _infoBox('TIME', 'O(n²)', pink, Icons.timer_outlined),
              _infoBox('SPACE', 'O(1)', cyan, Icons.memory_rounded),
              _infoBox('TYPE', 'Sorting', purple, Icons.swap_vert_rounded),
              _infoBox('BEST', 'O(n)', green, Icons.check_circle_outline),
              _infoBox('WORST', 'O(n²)', orange, Icons.trending_up_rounded),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INPUT
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
                    'Provide an array to start the visualization',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 850;

              if (compact) {
                return Column(
                  children: [
                    _inputWithLabel(
                      label: 'ENTER NUMBERS',
                      helper: 'Enter integers separated by commas',
                      controller: arrayController,
                      icon: Icons.edit_rounded,
                      color: cyan,
                      hint: '64, 25, 12, 22, 11',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _generateButton()),
                        const SizedBox(width: 12),
                        Expanded(child: _loadButton()),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _inputWithLabel(
                      label: 'ENTER NUMBERS',
                      helper: 'Enter integers separated by commas',
                      controller: arrayController,
                      icon: Icons.edit_rounded,
                      color: cyan,
                      hint: '64, 25, 12, 22, 11',
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(width: 220, child: _generateButton()),
                  const SizedBox(width: 12),
                  SizedBox(width: 220, child: _loadButton()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

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

  Widget _loadButton() {
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
        final mobile = constraints.maxWidth < 950;

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
  // VISUALIZATION
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
            icon: Icons.bar_chart_rounded,
            color: cyan,
            title: 'Bubble Sort Visualization',
            subtitle: 'Compare adjacent elements and swap when needed',
            badge: '${array.length} ELEMENTS',
            badgeColor: purple,
          ),
          Container(height: 1, color: Colors.white.withOpacity(.06)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _legend('Ready', purple),
                _legend('Comparing', cyan),
                _legend('Swap', pink),
                _legend('Sorted', green),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
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
                const SizedBox(height: 16),
                Divider(height: 1, color: Colors.white.withOpacity(.08)),
                const SizedBox(height: 12),
                _buildSortDetails(),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
        children: List.generate(
          array.length,
          (index) => _arrayElement(index, array[index]),
        ),
      ),
    );
  }

  Widget _arrayElement(int index, int value) {
    final bool comparing = index == compareLeft || index == compareRight;

    final bool sorted = index >= sortedFrom;

    Color borderColor = purple.withOpacity(.35);

    Color textColor = Colors.white70;

    String status = 'READY';

    if (sorted) {
      borderColor = green;
      textColor = green;
      status = 'SORTED';
    }

    if (comparing) {
      borderColor = cyan;
      textColor = cyan;
      status = 'COMPARE';
    }

    if (comparing && _stepAnimating) {
      borderColor = pink;
      textColor = pink;
      status = 'SWAP / CHECK';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 82,
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
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: borderColor.withOpacity(.08),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: borderColor,
                width: comparing || sorted ? 2 : 1,
              ),
              boxShadow: comparing || sorted
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

  Widget _buildSortDetails() {
    if (compareLeft < 0 || compareRight < 0) {
      return _executionStatusCard(
        icon: Icons.play_circle_outline_rounded,
        title: 'READY TO START',
        message: 'Press Play or Next Step to compare adjacent elements.',
        color: purple,
      );
    }

    final left = array[compareLeft];
    final right = array[compareRight];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _detailBox(
                icon: Icons.tag_rounded,
                label: 'PASS',
                value: '${outerIndex + 1}',
                color: purple,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _detailBox(
                icon: Icons.compare_arrows_rounded,
                label: 'COMPARISON',
                value: '$compareLeft ↔ $compareRight',
                color: cyan,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _detailBox(
                icon: Icons.swap_horiz_rounded,
                label: 'VALUES',
                value: '$left ↔ $right',
                color: orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _executionStatusCard(
          icon: left > right
              ? Icons.swap_horiz_rounded
              : Icons.check_circle_outline_rounded,
          title: left > right ? 'SWAP REQUIRED' : 'ORDER IS CORRECT',
          message: left > right
              ? '$left > $right → swapping adjacent elements.'
              : '$left ≤ $right → no swap required.',
          color: left > right ? pink : green,
        ),
      ],
    );
  }

  // ============================================================
  // CONTROLS
  // ============================================================

  Widget _buildControls() {
    final maxSteps = _maxSteps();

    final progress = maxSteps == 0 ? 0.0 : (step / maxSteps).clamp(0.0, 1.0);

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
              Expanded(child: _playButton()),
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
                  inactiveColor: purple.withOpacity(.15),
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

  Widget _playButton() {
    return InkWell(
      onTap: isCompleted ? null : _togglePlay,
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
            title: 'Bubble Sort Source Code',
            subtitle: 'LIVE CODE EXECUTION',
            badge: activeCodeLine == 0 ? 'READY' : 'LINE $activeCodeLine',
            badgeColor: cyan,
          ),
          Container(height: 1, color: Colors.white.withOpacity(.06)),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Column(
              children: [
                _codeLine(1, 'void bubbleSort(List<int> arr) {', color: purple),
                _codeLine(
                  2,
                  '  for (int i = 0; i < arr.length - 1; i++) {',
                  color: cyan,
                ),
                _codeLine(
                  3,
                  '    for (int j = 0; j < arr.length - i - 1; j++) {',
                  color: cyan,
                ),
                _codeLine(4, '      if (arr[j] > arr[j + 1]) {', color: orange),
                _codeLine(5, '        swap(arr[j], arr[j + 1]);', color: pink),
                _codeLine(6, '      }', color: Colors.white60),
                _codeLine(7, '    }', color: Colors.white60),
                _codeLine(8, '  }', color: Colors.white60),
                _codeLine(9, '  // Array is sorted', color: green),
                _codeLine(10, '}', color: Colors.white60),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: activeCodeLine == 5
                    ? pink.withOpacity(.06)
                    : cyan.withOpacity(.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: activeCodeLine == 5
                      ? pink.withOpacity(.25)
                      : cyan.withOpacity(.12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    activeCodeLine == 5
                        ? Icons.swap_horiz_rounded
                        : Icons.play_circle_outline_rounded,
                    color: activeCodeLine == 5 ? pink : cyan,
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

  Widget _codeLine(int lineNumber, String code, {Color? color}) {
    final active = activeCodeLine == lineNumber;

    final lineColor = active ? Colors.white : (color ?? Colors.white60);

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
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionIconSmall(Icons.history_rounded, cyan),
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
                      'Every comparison and swap made by the algorithm',
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
                  Icon(Icons.history_rounded, color: Colors.white30, size: 15),
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
    );
  }

  Widget _executionStepBlock(SortStep item) {
    final statusColor = item.swapped ? pink : green;

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
                  'PASS ${item.passNumber + 1}  •  INDEX '
                  '${item.leftIndex} ↔ ${item.rightIndex}',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.swapped
                      ? '${item.leftValue} > ${item.rightValue}  →  SWAP'
                      : '${item.leftValue} ≤ ${item.rightValue}  →  NO SWAP',
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
            item.swapped
                ? Icons.swap_horiz_rounded
                : Icons.check_circle_rounded,
            color: statusColor,
            size: 16,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INPUT ACTIONS
  // ============================================================

  void _generateNumbers() {
    final random = Random();

    timer?.cancel();
    _operationId++;

    final generated = List.generate(8, (_) => 10 + random.nextInt(91));

    setState(() {
      arrayController.text = generated.join(', ');

      array = List<int>.from(generated);
      _resetStateOnly();

      executionMessage =
          'Random numbers generated. Press LOAD ARRAY to visualize.';
    });

    _showMessage('Random numbers generated. Press LOAD ARRAY to start.');
  }

  void _loadArray() {
    final raw = arrayController.text.trim();

    if (raw.isEmpty) {
      _showMessage('Please enter numbers separated by commas.');
      return;
    }

    final parts = raw.split(',');
    final values = <int>[];

    for (final part in parts) {
      final text = part.trim();

      if (text.isEmpty) {
        _showMessage('Invalid input. Remove empty values.');
        return;
      }

      final value = int.tryParse(text);

      if (value == null) {
        _showMessage('"$text" is not a valid integer.');
        return;
      }

      values.add(value);
    }

    if (values.length < 2) {
      _showMessage('Enter at least 2 numbers for Bubble Sort.');
      return;
    }

    if (values.length > 30) {
      _showMessage('Please use 30 or fewer numbers.');
      return;
    }

    timer?.cancel();
    _operationId++;

    setState(() {
      array = List<int>.from(values);
      _resetStateOnly();
      executionMessage =
          'Array loaded successfully. Ready to start Bubble Sort.';
    });

    _showMessage('${values.length} elements loaded.');
  }

  // ============================================================
  // RESET
  // ============================================================

  void _resetStateOnly() {
    outerIndex = 0;
    innerIndex = 0;
    compareLeft = -1;
    compareRight = -1;
    sortedFrom = array.length;

    isRunning = false;
    isCompleted = false;
    _stepAnimating = false;

    step = 0;
    activeCodeLine = 0;
    executionHistory.clear();
  }

  void _reset() {
    timer?.cancel();
    _operationId++;

    setState(() {
      _resetStateOnly();
      executionMessage = 'Sort reset. Ready to start Bubble Sort.';
    });
  }

  // ============================================================
  // STEP ENGINE
  // ============================================================

  int _maxSteps() {
    final n = array.length;

    if (n < 2) {
      return 1;
    }

    return n * (n - 1) ~/ 2;
  }

  void _togglePlay() {
    if (isCompleted || array.length < 2) {
      return;
    }

    if (isRunning) {
      _pause();
    } else {
      setState(() {
        isRunning = true;
      });

      _runNextAutomatically();
    }
  }

  void _pause() {
    timer?.cancel();

    setState(() {
      isRunning = false;
      executionMessage = 'Animation paused. Press Play to continue.';
    });
  }

  void _runNextAutomatically() {
    if (!mounted || !isRunning || isCompleted) {
      return;
    }

    _nextStep();

    if (!mounted || !isRunning || isCompleted) {
      return;
    }

    timer?.cancel();

    timer = Timer(
      Duration(milliseconds: (1150 / speed).round()),
      _runNextAutomatically,
    );
  }

  void _nextStep() {
    if (array.length < 2 || isCompleted || _stepAnimating) {
      return;
    }

    if (innerIndex >= array.length - outerIndex - 1) {
      _finishPass();
      return;
    }

    final operation = _operationId;

    final leftIndex = innerIndex;

    final rightIndex = innerIndex + 1;

    final leftValue = array[leftIndex];

    final rightValue = array[rightIndex];

    setState(() {
      _stepAnimating = true;

      compareLeft = leftIndex;

      compareRight = rightIndex;

      activeCodeLine = 4;

      executionMessage =
          'Comparing arr[$leftIndex] = $leftValue with '
          'arr[$rightIndex] = $rightValue.';
    });

    final compareDelay = (500 / speed).round();

    final finishDelay = (750 / speed).round();

    Future.delayed(Duration(milliseconds: compareDelay), () {
      if (!mounted || operation != _operationId || isCompleted) {
        return;
      }

      final shouldSwap = leftValue > rightValue;

      setState(() {
        executionHistory.add(
          SortStep(
            stepNumber: executionHistory.length + 1,
            passNumber: outerIndex,
            leftIndex: leftIndex,
            rightIndex: rightIndex,
            leftValue: leftValue,
            rightValue: rightValue,
            swapped: shouldSwap,
          ),
        );

        step++;

        activeCodeLine = shouldSwap ? 5 : 4;

        executionMessage = shouldSwap
            ? '$leftValue > $rightValue → swapping adjacent elements.'
            : '$leftValue ≤ $rightValue → no swap required.';
      });

      if (shouldSwap) {
        setState(() {
          _stepAnimating = true;
        });

        Future.delayed(Duration(milliseconds: finishDelay), () {
          if (!mounted || operation != _operationId || isCompleted) {
            return;
          }

          setState(() {
            array[leftIndex] = rightValue;

            array[rightIndex] = leftValue;

            innerIndex++;

            compareLeft = -1;
            compareRight = -1;

            _stepAnimating = false;

            activeCodeLine = 3;

            executionMessage =
                'Swap complete. Moving to the next adjacent pair.';
          });

          _checkPassEnd();
        });
      } else {
        Future.delayed(Duration(milliseconds: finishDelay), () {
          if (!mounted || operation != _operationId || isCompleted) {
            return;
          }

          setState(() {
            innerIndex++;

            compareLeft = -1;
            compareRight = -1;

            _stepAnimating = false;

            activeCodeLine = 3;

            executionMessage =
                'No swap needed. Moving to the next adjacent pair.';
          });

          _checkPassEnd();
        });
      }
    });
  }

  void _checkPassEnd() {
    if (!mounted || isCompleted) {
      return;
    }

    if (innerIndex >= array.length - outerIndex - 1) {
      _finishPass();
    } else if (isRunning) {
      _runNextAutomatically();
    }
  }

  void _finishPass() {
    if (array.isEmpty) {
      return;
    }

    setState(() {
      sortedFrom = array.length - outerIndex - 1;

      activeCodeLine = 7;

      executionMessage =
          'Pass ${outerIndex + 1} completed. '
          '${array[sortedFrom]} is now in its final position.';

      innerIndex = 0;

      outerIndex++;

      compareLeft = -1;
      compareRight = -1;

      _stepAnimating = false;
    });

    if (outerIndex >= array.length - 1) {
      _completeSort();
      return;
    }

    if (isRunning) {
      Future.delayed(Duration(milliseconds: (450 / speed).round()), () {
        if (mounted && isRunning && !isCompleted) {
          _runNextAutomatically();
        }
      });
    }
  }

  void _completeSort() {
    timer?.cancel();

    setState(() {
      isCompleted = true;
      isRunning = false;

      _stepAnimating = false;

      compareLeft = -1;
      compareRight = -1;

      sortedFrom = 0;

      activeCodeLine = 9;

      executionMessage =
          'Bubble Sort completed successfully. The array is sorted.';
    });
  }

  // ============================================================
  // PREVIOUS STEP
  // ============================================================

  void _previousStep() {
    timer?.cancel();
    _operationId++;

    if (step <= 0) {
      return;
    }

    final history = List<SortStep>.from(executionHistory);

    history.removeLast();

    final values = _initialArrayFromHistory(history);

    setState(() {
      isRunning = false;
      isCompleted = false;
      _stepAnimating = false;

      executionHistory
        ..clear()
        ..addAll(history);

      array = values;

      _recalculatePositionFromHistory();

      executionMessage = history.isEmpty
          ? 'Ready to start Bubble Sort.'
          : 'Returned to step $step. Reviewing previous comparison.';
    });
  }

  List<int> _initialArrayFromHistory(List<SortStep> history) {
    final result = List<int>.from(array);

    for (int i = history.length; i < executionHistory.length; i++) {
      final item = executionHistory[i];

      if (item.swapped) {
        final temp = result[item.leftIndex];

        result[item.leftIndex] = result[item.rightIndex];

        result[item.rightIndex] = temp;
      }
    }

    return result;
  }

  void _recalculatePositionFromHistory() {
    outerIndex = 0;
    innerIndex = 0;

    compareLeft = -1;
    compareRight = -1;

    sortedFrom = array.length;

    activeCodeLine = 0;

    for (final item in executionHistory) {
      outerIndex = item.passNumber;

      innerIndex = item.rightIndex;
    }

    if (executionHistory.isNotEmpty) {
      final last = executionHistory.last;

      outerIndex = last.passNumber;

      innerIndex = last.rightIndex;

      activeCodeLine = last.swapped ? 5 : 4;

      final completedPasses = executionHistory
          .where((e) => e.passNumber < outerIndex)
          .length;

      if (completedPasses > 0) {
        sortedFrom = (array.length - outerIndex - 1).clamp(0, array.length);
      }
    }

    step = executionHistory.length;
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(color: Colors.white54, fontSize: 8)),
      ],
    );
  }

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
                    fontSize: 12,
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
}

// ================================================================
// EXECUTION MODEL
// ================================================================

class SortStep {
  final int stepNumber;
  final int passNumber;
  final int leftIndex;
  final int rightIndex;
  final int leftValue;
  final int rightValue;
  final bool swapped;

  const SortStep({
    required this.stepNumber,
    required this.passNumber,
    required this.leftIndex,
    required this.rightIndex,
    required this.leftValue,
    required this.rightValue,
    required this.swapped,
  });
}
