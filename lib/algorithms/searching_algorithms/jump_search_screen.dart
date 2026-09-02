import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class JumpSearchScreen extends StatefulWidget {
  const JumpSearchScreen({super.key});

  @override
  State<JumpSearchScreen> createState() =>
      _JumpSearchScreenState();
}

// ================================================================
// EVENT TYPES
// ================================================================

enum JumpSearchEventType {
  initialize,
  jump,
  compareBlock,
  moveInsideBlock,
  found,
  notFound,
  complete,
}

// ================================================================
// EVENT MODEL
// ================================================================

class JumpSearchEvent {
  final JumpSearchEventType type;
  final List<int> array;

  final int blockStart;
  final int blockEnd;
  final int currentIndex;
  final int previousIndex;
  final int jumpSize;

  final int target;
  final int activeValue;

  final String title;
  final String description;
  final String operation;

  const JumpSearchEvent({
    required this.type,
    required this.array,
    required this.blockStart,
    required this.blockEnd,
    required this.currentIndex,
    required this.previousIndex,
    required this.jumpSize,
    required this.target,
    required this.activeValue,
    required this.title,
    required this.description,
    required this.operation,
  });
}

// ================================================================
// SCREEN
// ================================================================

class _JumpSearchScreenState
    extends State<JumpSearchScreen> {
  // ==============================================================
  // COLORS
  // ==============================================================

  static const Color background =
      Color(0xFF030712);

  static const Color background2 =
      Color(0xFF07101F);

  static const Color cardColor =
      Color(0xFF0B1428);

  static const Color visualizationColor =
      Color(0xFF0A1020);

  static const Color cyan =
      Color(0xFF00E5FF);

  static const Color blue =
      Color(0xFF2979FF);

  static const Color purple =
      Color(0xFF9C27FF);

  static const Color green =
      Color(0xFF00E676);

  static const Color orange =
      Color(0xFFFFB300);

  static const Color pink =
      Color(0xFFFF4081);

  static const Color red =
      Color(0xFFFF5252);

  // ==============================================================
  // ARRAY
  // ==============================================================

  List<int> array = [
    10,
    18,
    23,
    31,
    39,
    45,
    52,
    61,
    68,
    74,
    82,
    91,
  ];

  List<int> originalArray = [
    10,
    18,
    23,
    31,
    39,
    45,
    52,
    61,
    68,
    74,
    82,
    91,
  ];

  // ==============================================================
  // TARGET
  // ==============================================================

  int target = 61;

  // ==============================================================
  // CONTROLLERS
  // ==============================================================

  late final TextEditingController arrayController;
  late final TextEditingController targetController;

  // ==============================================================
  // EVENTS
  // ==============================================================

  List<JumpSearchEvent> events = [];

  List<JumpSearchEvent> executionHistory = [];

  int currentStep = 0;

  // ==============================================================
  // EXECUTION
  // ==============================================================

  bool isRunning = false;
  bool isCompleted = false;

  double speed = 1.0;

  Timer? timer;

  // ==============================================================
  // VISUALIZATION STATE
  // ==============================================================

  int blockStart = -1;
  int blockEnd = -1;

  int currentIndex = -1;
  int previousIndex = -1;

  int jumpSize = 1;

  int foundIndex = -1;

  int activeIndex = -1;

  int activeCodeLine = 0;

  String executionMessage =
      'Ready to start Jump Search';

  // ==============================================================
  // SOURCE CODE
  // ==============================================================

  static const String sourceCode = '''
int jumpSearch(int[] arr, int target) {
  int n = arr.length;
  int jump = sqrt(n).toInt();
  int prev = 0;

  while (arr[min(jump, n) - 1] < target) {
    prev = jump;
    jump += sqrt(n).toInt();

    if (prev >= n) {
      return -1;
    }
  }

  while (arr[prev] < target) {
    prev++;

    if (prev == min(jump, n)) {
      return -1;
    }
  }

  if (arr[prev] == target) {
    return prev;
  }

  return -1;
}''';

  late final List<String> sourceLines;

  // ==============================================================
  // INIT
  // ==============================================================

  @override
  void initState() {
    super.initState();

    arrayController = TextEditingController(
      text: array.join(', '),
    );

    targetController = TextEditingController(
      text: '$target',
    );

    sourceLines = sourceCode.split('\n');

    _generateEvents();
  }

  // ==============================================================
  // DISPOSE
  // ==============================================================

  @override
  void dispose() {
    timer?.cancel();

    arrayController.dispose();
    targetController.dispose();

    super.dispose();
  }

  // ==============================================================
  // GENERATE EVENTS
  // ==============================================================

  void _generateEvents() {
    events.clear();

    if (array.isEmpty) {
      return;
    }

    final List<int> working =
        List<int>.from(array)..sort();

    final int n = working.length;

    final int calculatedJump =
        max(1, sqrt(n).floor());

    int previous = 0;
    int step = calculatedJump;

    // --------------------------------------------------------------
    // INITIALIZE
    // --------------------------------------------------------------

    events.add(
      JumpSearchEvent(
        type: JumpSearchEventType.initialize,
        array: List<int>.from(working),
        blockStart: 0,
        blockEnd:
            min(step, n) - 1,
        currentIndex: -1,
        previousIndex: -1,
        jumpSize: calculatedJump,
        target: target,
        activeValue: -1,
        title: 'Initialize Jump Search',
        description:
            'Array is sorted and divided into blocks of size $calculatedJump.',
        operation: 'INITIALIZE',
      ),
    );

    // --------------------------------------------------------------
    // JUMP THROUGH BLOCKS
    // --------------------------------------------------------------

    while (
        min(step, n) > 0 &&
            working[min(step, n) - 1] <
                target) {
      final int jumpIndex =
          min(step, n) - 1;

      events.add(
        JumpSearchEvent(
          type: JumpSearchEventType.jump,
          array: List<int>.from(working),
          blockStart: previous,
          blockEnd: jumpIndex,
          currentIndex: jumpIndex,
          previousIndex: previous,
          jumpSize: calculatedJump,
          target: target,
          activeValue: working[jumpIndex],
          title: 'Jump to Next Block',
          description:
              'Check block boundary at index $jumpIndex '
              'with value ${working[jumpIndex]}.',
          operation: 'JUMP',
        ),
      );

      events.add(
        JumpSearchEvent(
          type: JumpSearchEventType.compareBlock,
          array: List<int>.from(working),
          blockStart: previous,
          blockEnd: jumpIndex,
          currentIndex: jumpIndex,
          previousIndex: previous,
          jumpSize: calculatedJump,
          target: target,
          activeValue: working[jumpIndex],
          title: 'Compare Block Boundary',
          description:
              '${working[jumpIndex]} < $target, '
              'so the target may exist in the next block.',
          operation: 'COMPARE BLOCK',
        ),
      );

      previous = step;
      step += calculatedJump;

      if (previous >= n) {
        events.add(
          JumpSearchEvent(
            type: JumpSearchEventType.notFound,
            array:
                List<int>.from(working),
            blockStart:
                min(previous, n),
            blockEnd:
                n - 1,
            currentIndex: -1,
            previousIndex: previous,
            jumpSize:
                calculatedJump,
            target: target,
            activeValue: -1,
            title: 'Target Not Found',
            description:
                'The search jumped beyond the array.',
            operation: 'NOT FOUND',
          ),
        );

        events.add(
          JumpSearchEvent(
            type: JumpSearchEventType.complete,
            array:
                List<int>.from(working),
            blockStart:
                min(previous, n),
            blockEnd:
                n - 1,
            currentIndex: -1,
            previousIndex: previous,
            jumpSize:
                calculatedJump,
            target: target,
            activeValue: -1,
            title: 'Search Complete',
            description:
                'Jump Search finished without finding the target.',
            operation: 'COMPLETE',
          ),
        );

        return;
      }
    }

    // --------------------------------------------------------------
    // FINAL BLOCK
    // --------------------------------------------------------------

    final int finalBlockEnd =
        min(step, n) - 1;

    events.add(
      JumpSearchEvent(
        type: JumpSearchEventType.jump,
        array: List<int>.from(working),
        blockStart: previous,
        blockEnd: finalBlockEnd,
        currentIndex: finalBlockEnd,
        previousIndex: previous,
        jumpSize: calculatedJump,
        target: target,
        activeValue:
            finalBlockEnd >= 0
                ? working[finalBlockEnd]
                : -1,
        title: 'Target Block Located',
        description:
            'Target can only exist between index $previous '
            'and $finalBlockEnd.',
        operation: 'BLOCK FOUND',
      ),
    );

    // --------------------------------------------------------------
    // LINEAR SEARCH INSIDE BLOCK
    // --------------------------------------------------------------

    final int searchEnd =
        min(step, n);

    int index = previous;

    while (index < searchEnd) {
      events.add(
        JumpSearchEvent(
          type:
              JumpSearchEventType
                  .moveInsideBlock,
          array: List<int>.from(working),
          blockStart: previous,
          blockEnd:
              searchEnd - 1,
          currentIndex: index,
          previousIndex:
              index > previous
                  ? index - 1
                  : -1,
          jumpSize: calculatedJump,
          target: target,
          activeValue:
              working[index],
          title:
              'Search Inside Block',
          description:
              'Check index $index: '
              '${working[index]} against target $target.',
          operation: 'LINEAR CHECK',
        ),
      );

      // ------------------------------------------------------------
      // FOUND
      // ------------------------------------------------------------

      if (working[index] == target) {
        events.add(
          JumpSearchEvent(
            type:
                JumpSearchEventType.found,
            array:
                List<int>.from(
                    working),
            blockStart: previous,
            blockEnd:
                searchEnd - 1,
            currentIndex: index,
            previousIndex:
                index > previous
                    ? index - 1
                    : -1,
            jumpSize:
                calculatedJump,
            target: target,
            activeValue:
                working[index],
            title: 'Target Found',
            description:
                'Target $target found at index $index.',
            operation: 'FOUND',
          ),
        );

        events.add(
          JumpSearchEvent(
            type:
                JumpSearchEventType
                    .complete,
            array:
                List<int>.from(
                    working),
            blockStart: previous,
            blockEnd:
                searchEnd - 1,
            currentIndex: index,
            previousIndex:
                index > previous
                    ? index - 1
                    : -1,
            jumpSize:
                calculatedJump,
            target: target,
            activeValue:
                working[index],
            title: 'Search Complete',
            description:
                'Jump Search completed successfully.',
            operation: 'COMPLETE',
          ),
        );

        return;
      }

      index++;
    }

    // --------------------------------------------------------------
    // NOT FOUND
    // --------------------------------------------------------------

    events.add(
      JumpSearchEvent(
        type:
            JumpSearchEventType.notFound,
        array:
            List<int>.from(working),
        blockStart: previous,
        blockEnd:
            searchEnd - 1,
        currentIndex: -1,
        previousIndex:
            searchEnd - 1,
        jumpSize:
            calculatedJump,
        target: target,
        activeValue: -1,
        title: 'Target Not Found',
        description:
            'Target $target does not exist inside the selected block.',
        operation: 'NOT FOUND',
      ),
    );

    events.add(
      JumpSearchEvent(
        type:
            JumpSearchEventType.complete,
        array:
            List<int>.from(working),
        blockStart: previous,
        blockEnd:
            searchEnd - 1,
        currentIndex: -1,
        previousIndex:
            searchEnd - 1,
        jumpSize:
            calculatedJump,
        target: target,
        activeValue: -1,
        title: 'Search Complete',
        description:
            'Jump Search finished without finding the target.',
        operation: 'COMPLETE',
      ),
    );
  }

  // ==============================================================
  // HEADER
  // ==============================================================

  Widget _buildHeader() {
    return Container(
      height: 68,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: background2,
        border: Border(
          bottom: BorderSide(
            color:
                cyan.withOpacity(.10),
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () =>
                Navigator.of(context)
                    .pop(),
            borderRadius:
                BorderRadius.circular(
                    10),
            child: Container(
              width: 40,
              height: 40,
              decoration:
                  BoxDecoration(
                color: cardColor,
                borderRadius:
                    BorderRadius.circular(
                        10),
                border: Border.all(
                  color: Colors.white
                      .withOpacity(.08),
                ),
              ),
              child: const Icon(
                Icons
                    .arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  cyan,
                  blue,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(
                      11),
            ),
            child: const Icon(
              Icons
                  .vertical_align_center_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            mainAxisAlignment:
                MainAxisAlignment
                    .center,
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                'Jump Search',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Searching Algorithm Visualizer',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration:
                BoxDecoration(
              color:
                  cyan.withOpacity(.07),
              borderRadius:
                  BorderRadius.circular(
                      8),
              border: Border.all(
                color:
                    cyan.withOpacity(.20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration:
                      const BoxDecoration(
                    color: cyan,
                    shape:
                        BoxShape.circle,
                  ),
                ),
                const SizedBox(
                    width: 7),
                const Text(
                  'SEARCH',
                  style: TextStyle(
                    color: cyan,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // INFORMATION
  // ==============================================================

  Widget _buildAlgorithmInfo() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration:
          BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              Colors.white.withOpacity(.07),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.info_outline_rounded,
            'Algorithm Information',
            cyan,
          ),
          const SizedBox(height: 14),
          const Text(
            'Jump Search works on a sorted array by jumping '
            'ahead by fixed blocks and then performing a '
            'linear search inside the possible block.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder:
                (context, constraints) {
              final width =
                  constraints.maxWidth;

              int count = 2;

              if (width >= 1000) {
                count = 6;
              } else if (width >= 650) {
                count = 3;
              }

              final itemWidth =
                  (width -
                          ((count - 1) *
                              10)) /
                      count;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _infoBox(
                    'TIME',
                    'O(√n)',
                    cyan,
                    itemWidth,
                  ),
                  _infoBox(
                    'SPACE',
                    'O(1)',
                    blue,
                    itemWidth,
                  ),
                  _infoBox(
                    'TYPE',
                    'Searching',
                    purple,
                    itemWidth,
                  ),
                  _infoBox(
                    'BEST',
                    'O(1)',
                    green,
                    itemWidth,
                  ),
                  _infoBox(
                    'WORST',
                    'O(√n)',
                    orange,
                    itemWidth,
                  ),
                  _infoBox(
                    'REQUIRES',
                    'Sorted Array',
                    pink,
                    itemWidth,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _infoBox(
    String title,
    String value,
    Color color,
    double width,
  ) {
    return Container(
      width: width,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration:
          BoxDecoration(
        color:
            color.withOpacity(.05),
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color:
              color.withOpacity(.14),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // INPUT
  // ==============================================================

  Widget _buildInputSection() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              Colors.white.withOpacity(.07),
        ),
      ),
      child: LayoutBuilder(
        builder:
            (context, constraints) {
          final bool compact =
              constraints.maxWidth <
                  800;

          if (compact) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child:
                          _buildArrayInput(),
                    ),
                    const SizedBox(
                        width: 10),
                    Expanded(
                      child:
                          _buildTargetInput(),
                    ),
                  ],
                ),
                const SizedBox(
                    height: 10),
                Row(
                  children: [
                    Expanded(
                      child:
                          _generateButton(),
                    ),
                    const SizedBox(
                        width: 10),
                    Expanded(
                      child:
                          _loadButton(),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 5,
                child:
                    _buildArrayInput(),
              ),
              const SizedBox(
                  width: 12),
              Expanded(
                flex: 2,
                child:
                    _buildTargetInput(),
              ),
              const SizedBox(
                  width: 12),
              SizedBox(
                width: 160,
                child:
                    _generateButton(),
              ),
              const SizedBox(
                  width: 10),
              SizedBox(
                width: 140,
                child:
                    _loadButton(),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==============================================================
  // ARRAY INPUT
  // ==============================================================

  Widget _buildArrayInput() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Numbers',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight:
                FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller:
              arrayController,
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
          keyboardType:
              TextInputType.number,
          decoration:
              InputDecoration(
            hintText:
                '10, 18, 23, 31, 39...',
            hintStyle:
                const TextStyle(
              color: Colors.white30,
              fontSize: 12,
            ),
            prefixIcon:
                const Icon(
              Icons
                  .format_list_numbered_rounded,
              color: cyan,
              size: 19,
            ),
            filled: true,
            fillColor:
                visualizationColor,
            contentPadding:
                const EdgeInsets
                    .symmetric(
              horizontal: 12,
              vertical: 13,
            ),
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                      10),
              borderSide:
                  BorderSide(
                color: Colors.white
                    .withOpacity(.06),
              ),
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                      10),
              borderSide:
                  BorderSide(
                color: Colors.white
                    .withOpacity(.06),
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                      10),
              borderSide:
                  const BorderSide(
                color: cyan,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // TARGET
  // ==============================================================

  Widget _buildTargetInput() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Target Number',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight:
                FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller:
              targetController,
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight:
                FontWeight.w600,
          ),
          keyboardType:
              TextInputType.number,
          decoration:
              InputDecoration(
            hintText: '61',
            hintStyle:
                const TextStyle(
              color: Colors.white30,
              fontSize: 12,
            ),
            prefixIcon:
                const Icon(
              Icons
                  .my_location_rounded,
              color: orange,
              size: 18,
            ),
            filled: true,
            fillColor:
                visualizationColor,
            contentPadding:
                const EdgeInsets
                    .symmetric(
              horizontal: 12,
              vertical: 13,
            ),
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                      10),
              borderSide:
                  BorderSide(
                color: Colors.white
                    .withOpacity(.06),
              ),
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                      10),
              borderSide:
                  BorderSide(
                color: Colors.white
                    .withOpacity(.06),
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                      10),
              borderSide:
                  const BorderSide(
                color: orange,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // BUTTONS
  // ==============================================================

  Widget _generateButton() {
    return SizedBox(
      height: 45,
      child: OutlinedButton.icon(
        onPressed:
            isRunning
                ? null
                : _generateNumbers,
        icon: const Icon(
          Icons.auto_awesome_rounded,
          size: 17,
        ),
        label: const Text(
          'GENERATE NUMBERS',
          style: TextStyle(
            fontSize: 10,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        style:
            OutlinedButton.styleFrom(
          foregroundColor: cyan,
          side: BorderSide(
            color:
                cyan.withOpacity(.30),
          ),
          backgroundColor:
              cyan.withOpacity(.04),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
                    10),
          ),
        ),
      ),
    );
  }

  Widget _loadButton() {
    return SizedBox(
      height: 45,
      child: ElevatedButton.icon(
        onPressed:
            isRunning
                ? null
                : _loadArray,
        icon: const Icon(
          Icons.download_rounded,
          size: 17,
        ),
        label: const Text(
          'LOAD ARRAY',
          style: TextStyle(
            fontSize: 10,
            fontWeight:
                FontWeight.w800,
          ),
        ),
        style:
            ElevatedButton.styleFrom(
          backgroundColor: blue,
          foregroundColor:
              Colors.white,
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
                    10),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // MAIN WORKSPACE
  // ==============================================================

  Widget _buildMainWorkspace(
    double width,
  ) {
    final bool mobile =
        width < 900;

    if (mobile) {
      return Column(
        children: [
          _buildVisualizationPanel(),
          const SizedBox(height: 16),
          _buildSourceAndStepsPanel(),
          const SizedBox(height: 16),
          _buildControls(),
        ],
      );
    }

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
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
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child:
              _buildSourceAndStepsPanel(),
        ),
      ],
    );
  }

  // ==============================================================
  // VISUALIZATION
  // ==============================================================

  Widget _buildVisualizationPanel() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color:
            visualizationColor,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              Colors.white.withOpacity(.07),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons
                .vertical_align_center_rounded,
            'Jump Search Visualization',
            cyan,
          ),
          const SizedBox(height: 12),
          _buildLegend(),
          const SizedBox(height: 18),
          _buildJumpVisualization(),
          const SizedBox(height: 18),
          _buildStatusCard(),
        ],
      ),
    );
  }

  // ==============================================================
  // LEGEND
  // ==============================================================

  Widget _buildLegend() {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        _legendItem(
          'Block',
          blue,
        ),
        _legendItem(
          'Jump',
          purple,
        ),
        _legendItem(
          'Checking',
          cyan,
        ),
        _legendItem(
          'Target',
          orange,
        ),
        _legendItem(
          'Found',
          green,
        ),
      ],
    );
  }

  Widget _legendItem(
    String title,
    Color color,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration:
              BoxDecoration(
            color: color,
            shape:
                BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style:
              const TextStyle(
            color:
                Colors.white54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // JUMP VISUALIZATION
  // ==============================================================

  Widget _buildJumpVisualization() {
    if (array.isEmpty) {
      return const SizedBox(
        height: 260,
        child: Center(
          child: Text(
            'No array loaded',
            style: TextStyle(
              color:
                  Colors.white38,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            _smallBadge(
              'BLOCK SIZE',
              jumpSize,
              cyan,
            ),
            const SizedBox(width: 8),
            _smallBadge(
              'CURRENT',
              currentIndex,
              orange,
            ),
            const Spacer(),
            Container(
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration:
                  BoxDecoration(
                color:
                    orange.withOpacity(.06),
                borderRadius:
                    BorderRadius.circular(
                        8),
                border: Border.all(
                  color:
                      orange.withOpacity(.15),
                ),
              ),
              child: Text(
                'TARGET: $target',
                style:
                    const TextStyle(
                  color: orange,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          height: 190,
          child:
              SingleChildScrollView(
            scrollDirection:
                Axis.horizontal,
            child: Row(
              children:
                  List.generate(
                array.length,
                (index) {
                  return Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 4,
                    ),
                    child:
                        _buildArrayItem(
                      index,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildBlockInfo(),
      ],
    );
  }

  // ==============================================================
  // BADGE
  // ==============================================================

  Widget _smallBadge(
    String label,
    int value,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration:
          BoxDecoration(
        color:
            color.withOpacity(.06),
        borderRadius:
            BorderRadius.circular(8),
        border: Border.all(
          color:
              color.withOpacity(.15),
        ),
      ),
      child: Text(
        '$label: ${value >= 0 ? value : "-"}',
        style:
            TextStyle(
          color: color,
          fontSize: 9,
          fontWeight:
              FontWeight.w800,
        ),
      ),
    );
  }

  // ==============================================================
  // ARRAY ITEM
  // ==============================================================

  Widget _buildArrayItem(
    int index,
  ) {
    final bool insideBlock =
        blockStart >= 0 &&
            blockEnd >= 0 &&
            index >= blockStart &&
            index <= blockEnd;

    final bool isCurrent =
        index == currentIndex;

    final bool isFound =
        index == foundIndex;

    final bool isJumpPoint =
        jumpSize > 0 &&
            index % jumpSize == 0;

    Color color =
        Colors.white24;

    if (isFound) {
      color = green;
    } else if (isCurrent) {
      color = orange;
    } else if (insideBlock) {
      color = cyan;
    } else if (isJumpPoint) {
      color = purple;
    }

    return SizedBox(
      width: 62,
      child: Column(
        children: [
          SizedBox(
            height: 30,
            child: Center(
              child:
                  _indexLabel(index),
            ),
          ),
          AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 180,
            ),
            width: 56,
            height: 56,
            decoration:
                BoxDecoration(
              color:
                  color.withOpacity(.08),
              borderRadius:
                  BorderRadius.circular(
                      11),
              border: Border.all(
                color:
                    color.withOpacity(
                  isCurrent ||
                          isFound
                      ? .9
                      : .35,
                ),
                width:
                    isCurrent ||
                            isFound
                        ? 2
                        : 1,
              ),
              boxShadow:
                  isCurrent ||
                          isFound
                      ? [
                          BoxShadow(
                            color:
                                color.withOpacity(
                              .22,
                            ),
                            blurRadius:
                                14,
                          ),
                        ]
                      : null,
            ),
            child: Center(
              child: Text(
                '${array[index]}',
                style: TextStyle(
                  color:
                      Colors.white,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '[$index]',
            style: TextStyle(
              color:
                  color.withOpacity(.8),
              fontSize: 9,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // INDEX LABEL
  // ==============================================================

  Widget _indexLabel(
    int index,
  ) {
    if (index == foundIndex) {
      return const Text(
        'FOUND',
        style: TextStyle(
          color: green,
          fontSize: 8,
          fontWeight:
              FontWeight.w900,
        ),
      );
    }

    if (index == currentIndex) {
      return const Text(
        'CHECK',
        style: TextStyle(
          color: orange,
          fontSize: 8,
          fontWeight:
              FontWeight.w900,
        ),
      );
    }

    if (jumpSize > 0 &&
        index % jumpSize == 0) {
      return const Text(
        'JUMP',
        style: TextStyle(
          color: purple,
          fontSize: 8,
          fontWeight:
              FontWeight.w900,
        ),
      );
    }

    return const SizedBox();
  }

  // ==============================================================
  // BLOCK INFO
  // ==============================================================

  Widget _buildBlockInfo() {
    String text;

    if (blockStart < 0 ||
        blockEnd < 0) {
      text =
          'Waiting for the first jump...';
    } else if (blockStart >
        blockEnd) {
      text =
          'No valid block remains.';
    } else {
      text =
          'Active block: $blockStart → $blockEnd '
          '(${blockEnd - blockStart + 1} elements)';
    }

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration:
          BoxDecoration(
        color:
            purple.withOpacity(.045),
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color:
              purple.withOpacity(.12),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons
                .view_module_rounded,
            color: purple,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style:
                  const TextStyle(
                color:
                    Colors.white60,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // STATUS
  // ==============================================================

  Widget _buildStatusCard() {
    Color color = cyan;

    if (executionHistory
        .isNotEmpty) {
      color =
          _eventColor(
        executionHistory.last.type,
      );
    }

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(13),
      decoration:
          BoxDecoration(
        color:
            color.withOpacity(.05),
        borderRadius:
            BorderRadius.circular(11),
        border: Border.all(
          color:
              color.withOpacity(.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration:
                BoxDecoration(
              color:
                  color.withOpacity(.10),
              borderRadius:
                  BorderRadius.circular(
                      9),
            ),
            child: Icon(
              _operationIcon(),
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  executionHistory
                          .isEmpty
                      ? 'READY'
                      : executionHistory
                          .last
                          .title
                          .toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w800,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(
                    height: 3),
                Text(
                  executionMessage,
                  style:
                      const TextStyle(
                    color:
                        Colors.white70,
                    fontSize: 11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // ICON
  // ==============================================================

  IconData _operationIcon() {
    if (executionHistory
        .isEmpty) {
      return Icons.play_arrow_rounded;
    }

    switch (
        executionHistory.last.type) {
      case JumpSearchEventType
          .initialize:
        return Icons
            .start_rounded;

      case JumpSearchEventType.jump:
        return Icons
            .skip_next_rounded;

      case JumpSearchEventType
          .compareBlock:
        return Icons
            .compare_arrows_rounded;

      case JumpSearchEventType
          .moveInsideBlock:
        return Icons
            .search_rounded;

      case JumpSearchEventType.found:
        return Icons
            .check_circle_rounded;

      case JumpSearchEventType
          .notFound:
        return Icons
            .cancel_rounded;

      case JumpSearchEventType
          .complete:
        return Icons
            .done_all_rounded;
    }
  }

  // ==============================================================
  // EVENT COLOR
  // ==============================================================

  Color _eventColor(
    JumpSearchEventType type,
  ) {
    switch (type) {
      case JumpSearchEventType
          .initialize:
        return blue;

      case JumpSearchEventType.jump:
        return purple;

      case JumpSearchEventType
          .compareBlock:
        return cyan;

      case JumpSearchEventType
          .moveInsideBlock:
        return orange;

      case JumpSearchEventType.found:
        return green;

      case JumpSearchEventType
          .notFound:
        return red;

      case JumpSearchEventType
          .complete:
        return green;
    }
  }

  // ==============================================================
  // CONTROLS
  // ==============================================================

  Widget _buildControls() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration:
          BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              Colors.white.withOpacity(.07),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _controlButton(
                icon:
                    Icons.skip_previous_rounded,
                label: 'Previous',
                onPressed:
                    currentStep > 0 &&
                            !isRunning
                        ? _previousStep
                        : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child:
                      ElevatedButton.icon(
                    onPressed:
                        isCompleted
                            ? null
                            : isRunning
                                ? _pause
                                : _play,
                    icon: Icon(
                      isRunning
                          ? Icons
                              .pause_rounded
                          : Icons
                              .play_arrow_rounded,
                      size: 18,
                    ),
                    label: Text(
                      isRunning
                          ? 'PAUSE'
                          : isCompleted
                              ? 'COMPLETED'
                              : 'PLAY',
                      style:
                          const TextStyle(
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          isRunning
                              ? orange
                              : green,
                      foregroundColor:
                          background,
                      elevation: 0,
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius
                                .circular(
                          9,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _controlButton(
                icon:
                    Icons.skip_next_rounded,
                label: 'Next',
                onPressed:
                    !isCompleted &&
                            !isRunning
                        ? _nextStep
                        : null,
              ),
              const SizedBox(width: 8),
              _controlButton(
                icon:
                    Icons.restart_alt_rounded,
                label: 'Reset',
                onPressed:
                    isRunning
                        ? null
                        : _reset,
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(
                Icons.speed_rounded,
                color: cyan,
                size: 17,
              ),
              const SizedBox(width: 8),
              const Text(
                'Speed',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                ),
              ),
              Expanded(
                child: Slider(
                  value: speed,
                  min: .5,
                  max: 2.5,
                  divisions: 4,
                  activeColor: cyan,
                  inactiveColor:
                      Colors.white
                          .withOpacity(.10),
                  onChanged:
                      _setSpeed,
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '${speed.toStringAsFixed(1)}x',
                  textAlign:
                      TextAlign.right,
                  style:
                      const TextStyle(
                    color: cyan,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 42,
      child:
          OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 16,
        ),
        label: Text(
          label,
          style:
              const TextStyle(
            fontSize: 9,
            fontWeight:
                FontWeight.w700,
          ),
        ),
        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              Colors.white70,
          side: BorderSide(
            color: Colors.white
                .withOpacity(.09),
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
                    9),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // SOURCE + STEPS
  // ==============================================================

  Widget _buildSourceAndStepsPanel() {
    return Column(
      children: [
        _buildSourceCode(),
        const SizedBox(height: 16),
        _buildExecutionSteps(),
      ],
    );
  }

  // ==============================================================
  // SOURCE CODE
  // ==============================================================

  Widget _buildSourceCode() {
    return Container(
      width: double.infinity,
      constraints:
          const BoxConstraints(
        minHeight: 400,
      ),
      decoration:
          BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              Colors.white.withOpacity(.07),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              15,
              13,
              10,
              13,
            ),
            child: Row(
              children: [
                _sectionTitle(
                  Icons.code_rounded,
                  'Source Code',
                  cyan,
                ),
                const Spacer(),
                InkWell(
                  onTap: _copyCode,
                  borderRadius:
                      BorderRadius.circular(
                          8),
                  child: Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          cyan.withOpacity(
                              .06),
                      borderRadius:
                          BorderRadius
                              .circular(
                                  8),
                      border: Border.all(
                        color:
                            cyan.withOpacity(
                                .15),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons
                              .copy_rounded,
                          color: cyan,
                          size: 13,
                        ),
                        SizedBox(
                            width: 5),
                        Text(
                          'COPY',
                          style:
                              TextStyle(
                            color:
                                cyan,
                            fontSize: 9,
                            fontWeight:
                                FontWeight
                                    .w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color:
                Colors.white.withOpacity(
                    .06),
          ),
          SizedBox(
            height: 390,
            child:
                ListView.builder(
              padding:
                  const EdgeInsets
                      .symmetric(
                vertical: 10,
              ),
              itemCount:
                  sourceLines.length,
              itemBuilder:
                  (context, index) {
                final bool active =
                    index + 1 ==
                        activeCodeLine;

                return Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  color: active
                      ? cyan.withOpacity(
                          .08)
                      : Colors
                          .transparent,
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${index + 1}',
                          textAlign:
                              TextAlign
                                  .right,
                          style: TextStyle(
                            color: active
                                ? cyan
                                : Colors
                                    .white24,
                            fontSize: 10,
                            fontFamily:
                                'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(
                          width: 10),
                      Expanded(
                        child: Text(
                          sourceLines[
                              index],
                          style:
                              TextStyle(
                            color: active
                                ? Colors
                                    .white
                                : Colors
                                    .white60,
                            fontSize: 10.5,
                            height: 1.45,
                            fontFamily:
                                'monospace',
                            fontWeight: active
                                ? FontWeight
                                    .w600
                                : FontWeight
                                    .normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // EXECUTION STEPS
  // ==============================================================

  Widget _buildExecutionSteps() {
    return Container(
      width: double.infinity,
      constraints:
          const BoxConstraints(
        minHeight: 260,
      ),
      padding:
          const EdgeInsets.all(15),
      decoration:
          BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              Colors.white.withOpacity(.07),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.timeline_rounded,
            'Execution Steps',
            orange,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child:
                executionHistory.isEmpty
                    ? _emptySteps()
                    : ListView.builder(
                        itemCount:
                            executionHistory
                                .length,
                        itemBuilder:
                            (context,
                                index) {
                          final event =
                              executionHistory[
                                  index];

                          return _stepTile(
                            index,
                            event,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _emptySteps() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons
                .timeline_outlined,
            color: Colors.white
                .withOpacity(.16),
            size: 34,
          ),
          const SizedBox(height: 8),
          const Text(
            'No steps executed yet',
            style: TextStyle(
              color:
                  Colors.white38,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Press Next Step or Play',
            style: TextStyle(
              color:
                  Colors.white24,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepTile(
    int index,
    JumpSearchEvent event,
  ) {
    final Color color =
        _eventColor(event.type);

    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 7,
      ),
      padding:
          const EdgeInsets.all(9),
      decoration:
          BoxDecoration(
        color:
            color.withOpacity(.045),
        borderRadius:
            BorderRadius.circular(9),
        border: Border.all(
          color:
              color.withOpacity(.10),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Container(
            width: 25,
            height: 25,
            decoration:
                BoxDecoration(
              color:
                  color.withOpacity(.10),
              shape:
                  BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(
              width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(
                    height: 3),
                Text(
                  event.description,
                  style:
                      const TextStyle(
                    color:
                        Colors.white54,
                    fontSize: 9.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // SECTION TITLE
  // ==============================================================

  Widget _sectionTitle(
    IconData icon,
    String title,
    Color color,
  ) {
    return Row(
      mainAxisSize:
          MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration:
              BoxDecoration(
            color:
                color.withOpacity(.08),
            borderRadius:
                BorderRadius.circular(
                    8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(
            width: 9),
        Text(
          title,
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // NEXT
  // ==============================================================

  void _nextStep() {
    if (events.isEmpty ||
        currentStep >=
            events.length) {
      return;
    }

    final event =
        events[currentStep];

    setState(() {
      executionHistory
          .add(event);

      currentStep++;

      array =
          List<int>.from(
              event.array);

      blockStart =
          event.blockStart;

      blockEnd =
          event.blockEnd;

      currentIndex =
          event.currentIndex;

      previousIndex =
          event.previousIndex;

      jumpSize =
          event.jumpSize;

      activeIndex =
          event.currentIndex;

      executionMessage =
          event.description;

      activeCodeLine =
          _codeLineForEvent(
              event);

      if (event.type ==
          JumpSearchEventType
              .found) {
        foundIndex =
            event.currentIndex;
      }

      if (event.type ==
          JumpSearchEventType
              .complete) {
        isCompleted = true;
      }
    });
  }

  // ==============================================================
  // PREVIOUS
  // ==============================================================

  void _previousStep() {
    if (executionHistory
        .isEmpty) {
      return;
    }

    executionHistory
        .removeLast();

    currentStep =
        executionHistory.length;

    setState(() {
      foundIndex = -1;

      if (executionHistory
          .isEmpty) {
        array =
            List<int>.from(
                originalArray);

        blockStart = -1;
        blockEnd = -1;

        currentIndex = -1;
        previousIndex = -1;

        activeIndex = -1;

        jumpSize =
            max(
          1,
          sqrt(
            array.length,
          ).floor(),
        );

        activeCodeLine = 0;

        executionMessage =
            'Ready to start Jump Search';

        isCompleted = false;

        return;
      }

      final event =
          executionHistory
              .last;

      array =
          List<int>.from(
              event.array);

      blockStart =
          event.blockStart;

      blockEnd =
          event.blockEnd;

      currentIndex =
          event.currentIndex;

      previousIndex =
          event.previousIndex;

      jumpSize =
          event.jumpSize;

      activeIndex =
          event.currentIndex;

      activeCodeLine =
          _codeLineForEvent(
              event);

      executionMessage =
          event.description;

      for (final item
          in executionHistory) {
        if (item.type ==
            JumpSearchEventType
                .found) {
          foundIndex =
              item.currentIndex;
        }
      }

      isCompleted =
          event.type ==
              JumpSearchEventType
                  .complete;
    });
  }

  // ==============================================================
  // PLAY
  // ==============================================================

  void _play() {
    if (isCompleted) {
      return;
    }

    setState(() {
      isRunning = true;
    });

    _startTimer();
  }

  // ==============================================================
  // PAUSE
  // ==============================================================

  void _pause() {
    _stopTimer();

    setState(() {
      isRunning = false;
    });
  }

  // ==============================================================
  // TIMER
  // ==============================================================

  void _startTimer() {
    _stopTimer();

    final int milliseconds =
        max(
      120,
      (850 / speed).round(),
    );

    timer = Timer.periodic(
      Duration(
        milliseconds:
            milliseconds,
      ),
      (_) {
        if (currentStep >=
            events.length) {
          _stopTimer();

          if (mounted) {
            setState(() {
              isRunning = false;
              isCompleted = true;
            });
          }

          return;
        }

        _nextStep();

        if (isCompleted) {
          _stopTimer();

          if (mounted) {
            setState(() {
              isRunning = false;
            });
          }
        }
      },
    );
  }

  void _stopTimer() {
    timer?.cancel();
    timer = null;
  }

  // ==============================================================
  // RESET
  // ==============================================================

  void _reset() {
    _stopTimer();

    setState(() {
      isRunning = false;
      isCompleted = false;

      currentStep = 0;

      executionHistory
          .clear();

      array =
          List<int>.from(
              originalArray);

      blockStart = -1;
      blockEnd = -1;

      currentIndex = -1;
      previousIndex = -1;

      foundIndex = -1;
      activeIndex = -1;

      jumpSize =
          max(
        1,
        sqrt(
          array.length,
        ).floor(),
      );

      activeCodeLine = 0;

      executionMessage =
          'Ready to start Jump Search';
    });
  }

  // ==============================================================
  // LOAD ARRAY
  // ==============================================================

  void _loadArray() {
    final String arrayText =
        arrayController.text.trim();

    final String targetText =
        targetController.text.trim();

    if (arrayText.isEmpty) {
      _showMessage(
        'Please enter some numbers.',
        red,
      );
      return;
    }

    if (targetText.isEmpty) {
      _showMessage(
        'Please enter a target number.',
        red,
      );
      return;
    }

    try {
      final values = arrayText
          .split(
            RegExp(
              r'[,;\s]+',
            ),
          )
          .where(
            (value) =>
                value.isNotEmpty,
          )
          .map(
            (value) =>
                int.parse(value),
          )
          .toList();

      final int parsedTarget =
          int.parse(targetText);

      if (values.isEmpty) {
        throw const FormatException();
      }

      if (values.length > 40) {
        _showMessage(
          'Please use 40 numbers or fewer for clear visualization.',
          orange,
        );
        return;
      }

      values.sort();

      _stopTimer();

      setState(() {
        array =
            List<int>.from(values);

        originalArray =
            List<int>.from(values);

        target =
            parsedTarget;

        arrayController.text =
            values.join(', ');

        targetController.text =
            '$parsedTarget';

        events.clear();

        executionHistory
            .clear();

        currentStep = 0;

        isRunning = false;
        isCompleted = false;

        blockStart = -1;
        blockEnd = -1;

        currentIndex = -1;
        previousIndex = -1;

        foundIndex = -1;
        activeIndex = -1;

        jumpSize =
            max(
          1,
          sqrt(
            values.length,
          ).floor(),
        );

        activeCodeLine = 0;

        executionMessage =
            'Array loaded. Ready to start Jump Search.';

        _generateEvents();
      });
    } catch (_) {
      _showMessage(
        'Invalid input. Use numbers like: 10, 18, 31, 45',
        red,
      );
    }
  }

  // ==============================================================
  // GENERATE
  // ==============================================================

  void _generateNumbers() {
    final random =
        Random();

    final generated =
        List.generate(
      12,
      (_) => 10 +
          random.nextInt(90),
    );

    generated.sort();

    final generatedTarget =
        generated[
            random.nextInt(
                generated.length)];

    arrayController.text =
        generated.join(', ');

    targetController.text =
        '$generatedTarget';

    _loadArray();
  }

  // ==============================================================
  // SPEED
  // ==============================================================

  void _setSpeed(
    double value,
  ) {
    setState(() {
      speed = value;
    });

    if (isRunning) {
      _startTimer();
    }
  }

  // ==============================================================
  // CODE LINE
  // ==============================================================

  int _codeLineForEvent(
    JumpSearchEvent event,
  ) {
    switch (event.type) {
      case JumpSearchEventType
          .initialize:
        return 2;

      case JumpSearchEventType.jump:
        return 7;

      case JumpSearchEventType
          .compareBlock:
        return 6;

      case JumpSearchEventType
          .moveInsideBlock:
        return 15;

      case JumpSearchEventType.found:
        return 20;

      case JumpSearchEventType
          .notFound:
        return 23;

      case JumpSearchEventType
          .complete:
        return 24;
    }
  }

  // ==============================================================
  // COPY
  // ==============================================================

  Future<void> _copyCode() async {
    await Clipboard.setData(
      const ClipboardData(
        text: sourceCode,
      ),
    );

    if (!mounted) {
      return;
    }

    _showMessage(
      'Source code copied to clipboard.',
      green,
    );
  }

  // ==============================================================
  // MESSAGE
  // ==============================================================

  void _showMessage(
    String message,
    Color color,
  ) {
    ScaffoldMessenger.of(
      context,
    )
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style:
                const TextStyle(
              fontSize: 12,
            ),
          ),
          backgroundColor:
              cardColor,
          behavior:
              SnackBarBehavior
                  .floating,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
                    10),
          ),
          duration:
              const Duration(
            seconds: 2,
          ),
        ),
      );
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child:
                  LayoutBuilder(
                builder: (
                  context,
                  constraints,
                ) {
                  return SingleChildScrollView(
                    padding:
                        const EdgeInsets
                            .all(18),
                    child: Center(
                      child:
                          ConstrainedBox(
                        constraints:
                            const BoxConstraints(
                          maxWidth: 1450,
                        ),
                        child:
                            Column(
                          children: [
                            _buildAlgorithmInfo(),
                            const SizedBox(
                                height:
                                    16),
                            _buildInputSection(),
                            const SizedBox(
                                height:
                                    16),
                            _buildMainWorkspace(
                              constraints
                                  .maxWidth,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}