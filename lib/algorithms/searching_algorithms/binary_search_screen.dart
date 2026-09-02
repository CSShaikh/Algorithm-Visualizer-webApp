import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BinarySearchScreen extends StatefulWidget {
  const BinarySearchScreen({super.key});

  @override
  State<BinarySearchScreen> createState() =>
      _BinarySearchScreenState();
}

// ================================================================
// EVENT TYPES
// ================================================================

enum BinarySearchEventType {
  initialize,
  compare,
  moveLeft,
  moveRight,
  found,
  notFound,
  complete,
}

// ================================================================
// EVENT MODEL
// ================================================================

class BinarySearchEvent {
  final BinarySearchEventType type;
  final List<int> array;

  final int low;
  final int mid;
  final int high;

  final int target;
  final int activeValue;

  final String title;
  final String description;
  final String operation;

  const BinarySearchEvent({
    required this.type,
    required this.array,
    required this.low,
    required this.mid,
    required this.high,
    required this.target,
    required this.activeValue,
    required this.title,
    required this.description,
    required this.operation,
  });
}

// ================================================================
// SCREEN STATE
// ================================================================

class _BinarySearchScreenState
    extends State<BinarySearchScreen> {
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
    11,
    22,
    25,
    34,
    47,
    58,
    64,
    72,
    81,
    90,
  ];

  List<int> originalArray = [
    11,
    22,
    25,
    34,
    47,
    58,
    64,
    72,
    81,
    90,
  ];

  // ==============================================================
  // TARGET
  // ==============================================================

  int target = 64;

  // ==============================================================
  // CONTROLLERS
  // ==============================================================

  late final TextEditingController arrayController;
  late final TextEditingController targetController;

  // ==============================================================
  // EVENTS
  // ==============================================================

  List<BinarySearchEvent> events = [];

  List<BinarySearchEvent> executionHistory = [];

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

  int low = -1;
  int mid = -1;
  int high = -1;

  int foundIndex = -1;

  int activeIndex = -1;

  int activeCodeLine = 0;

  String executionMessage =
      'Ready to start Binary Search';

  // ==============================================================
  // SOURCE CODE
  // ==============================================================

  static const String sourceCode = '''
int binarySearch(int[] arr, int target) {
  int low = 0;
  int high = arr.length - 1;

  while (low <= high) {
    int mid = low + (high - low) ~/ 2;

    if (arr[mid] == target) {
      return mid;
    }

    if (arr[mid] < target) {
      low = mid + 1;
    } else {
      high = mid - 1;
    }
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

    final working =
        List<int>.from(array)..sort();

    final int n = working.length;

    int searchLow = 0;
    int searchHigh = n - 1;

    // --------------------------------------------------------------
    // INITIALIZE
    // --------------------------------------------------------------

    events.add(
      BinarySearchEvent(
        type: BinarySearchEventType.initialize,
        array: List<int>.from(working),
        low: searchLow,
        mid: -1,
        high: searchHigh,
        target: target,
        activeValue: -1,
        title: 'Initialize Search',
        description:
            'Binary Search starts with the complete sorted array.',
        operation: 'INITIALIZE',
      ),
    );

    // --------------------------------------------------------------
    // SEARCH
    // --------------------------------------------------------------

    while (searchLow <= searchHigh) {
      final int searchMid =
          searchLow +
              ((searchHigh - searchLow) ~/ 2);

      events.add(
        BinarySearchEvent(
          type: BinarySearchEventType.compare,
          array: List<int>.from(working),
          low: searchLow,
          mid: searchMid,
          high: searchHigh,
          target: target,
          activeValue: working[searchMid],
          title: 'Compare Middle Element',
          description:
              'Compare ${working[searchMid]} with target $target.',
          operation: 'COMPARE',
        ),
      );

      // ------------------------------------------------------------
      // FOUND
      // ------------------------------------------------------------

      if (working[searchMid] == target) {
        events.add(
          BinarySearchEvent(
            type: BinarySearchEventType.found,
            array: List<int>.from(working),
            low: searchLow,
            mid: searchMid,
            high: searchHigh,
            target: target,
            activeValue: working[searchMid],
            title: 'Target Found',
            description:
                'Target $target is found at index $searchMid.',
            operation: 'FOUND',
          ),
        );

        events.add(
          BinarySearchEvent(
            type: BinarySearchEventType.complete,
            array: List<int>.from(working),
            low: searchLow,
            mid: searchMid,
            high: searchHigh,
            target: target,
            activeValue: working[searchMid],
            title: 'Search Complete',
            description:
                'Binary Search completed successfully.',
            operation: 'COMPLETE',
          ),
        );

        return;
      }

      // ------------------------------------------------------------
      // TARGET IS GREATER
      // ------------------------------------------------------------

      if (working[searchMid] < target) {
        final int newLow =
            searchMid + 1;

        events.add(
          BinarySearchEvent(
            type: BinarySearchEventType.moveRight,
            array: List<int>.from(working),
            low: newLow,
            mid: -1,
            high: searchHigh,
            target: target,
            activeValue: working[searchMid],
            title: 'Move Right',
            description:
                '$target is greater than ${working[searchMid]}. '
                'Discard the left half.',
            operation: 'LOW = MID + 1',
          ),
        );

        searchLow = newLow;
      }

      // ------------------------------------------------------------
      // TARGET IS SMALLER
      // ------------------------------------------------------------

      else {
        final int newHigh =
            searchMid - 1;

        events.add(
          BinarySearchEvent(
            type: BinarySearchEventType.moveLeft,
            array: List<int>.from(working),
            low: searchLow,
            mid: -1,
            high: newHigh,
            target: target,
            activeValue: working[searchMid],
            title: 'Move Left',
            description:
                '$target is smaller than ${working[searchMid]}. '
                'Discard the right half.',
            operation: 'HIGH = MID - 1',
          ),
        );

        searchHigh = newHigh;
      }
    }

    // --------------------------------------------------------------
    // NOT FOUND
    // --------------------------------------------------------------

    events.add(
      BinarySearchEvent(
        type: BinarySearchEventType.notFound,
        array: List<int>.from(working),
        low: searchLow,
        mid: -1,
        high: searchHigh,
        target: target,
        activeValue: -1,
        title: 'Target Not Found',
        description:
            'Target $target does not exist in the array.',
        operation: 'NOT FOUND',
      ),
    );

    events.add(
      BinarySearchEvent(
        type: BinarySearchEventType.complete,
        array: List<int>.from(working),
        low: searchLow,
        mid: -1,
        high: searchHigh,
        target: target,
        activeValue: -1,
        title: 'Search Complete',
        description:
            'Binary Search finished without finding the target.',
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
          const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: background2,
        border: Border(
          bottom: BorderSide(
            color: cyan.withOpacity(0.10),
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () =>
                Navigator.of(context).pop(),
            borderRadius:
                BorderRadius.circular(10),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius:
                    BorderRadius.circular(10),
                border: Border.all(
                  color:
                      Colors.white.withOpacity(0.08),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  cyan,
                  blue,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.search_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'Binary Search',
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
                const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color:
                  cyan.withOpacity(0.07),
              borderRadius:
                  BorderRadius.circular(8),
              border: Border.all(
                color:
                    cyan.withOpacity(0.20),
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
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
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
  // ALGORITHM INFORMATION
  // ==============================================================

  Widget _buildAlgorithmInfo() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              Colors.white.withOpacity(0.07),
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
            'Binary Search repeatedly divides a sorted array '
            'into halves and eliminates the half that cannot '
            'contain the target.',
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
                          ((count - 1) * 10)) /
                      count;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _infoBox(
                    'TIME',
                    'O(log n)',
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
                    'O(log n)',
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
      decoration: BoxDecoration(
        color:
            color.withOpacity(0.05),
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color:
              color.withOpacity(0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
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
            style: const TextStyle(
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
  // INPUT SECTION
  // ==============================================================

  Widget _buildInputSection() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              Colors.white.withOpacity(0.07),
        ),
      ),
      child: LayoutBuilder(
        builder:
            (context, constraints) {
          final bool compact =
              constraints.maxWidth < 800;

          if (compact) {
            return Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child:
                          _buildArrayInput(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child:
                          _buildTargetInput(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child:
                          _generateButton(),
                    ),
                    const SizedBox(width: 10),
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
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child:
                    _buildTargetInput(),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 160,
                child:
                    _generateButton(),
              ),
              const SizedBox(width: 10),
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
          keyboardType:
              TextInputType.number,
          decoration:
              InputDecoration(
            hintText:
                '64, 25, 12, 22, 11',
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
  // TARGET INPUT
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
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight:
                FontWeight.w600,
          ),
          keyboardType:
              TextInputType.number,
          decoration:
              InputDecoration(
            hintText: '64',
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
  // GENERATE BUTTON
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
            letterSpacing: .4,
          ),
        ),
        style:
            OutlinedButton.styleFrom(
          foregroundColor: cyan,
          side: BorderSide(
            color:
                cyan.withOpacity(.30),
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
                    10),
          ),
          backgroundColor:
              cyan.withOpacity(.04),
        ),
      ),
    );
  }

  // ==============================================================
  // LOAD BUTTON
  // ==============================================================

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
            letterSpacing: .4,
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
  // VISUALIZATION PANEL
  // ==============================================================

  Widget _buildVisualizationPanel() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
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
            Icons.search_rounded,
            'Binary Search Visualization',
            cyan,
          ),
          const SizedBox(height: 12),
          _buildLegend(),
          const SizedBox(height: 18),
          _buildSearchRange(),
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
          'Low',
          blue,
        ),
        _legendItem(
          'Mid',
          orange,
        ),
        _legendItem(
          'High',
          purple,
        ),
        _legendItem(
          'Comparing',
          cyan,
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
  // SEARCH RANGE
  // ==============================================================

  Widget _buildSearchRange() {
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
        // ----------------------------------------------------------
        // RANGE HEADER
        // ----------------------------------------------------------

        Row(
          children: [
            _rangeBadge(
              'LOW',
              low,
              blue,
            ),
            const SizedBox(width: 8),
            _rangeBadge(
              'MID',
              mid,
              orange,
            ),
            const SizedBox(width: 8),
            _rangeBadge(
              'HIGH',
              high,
              purple,
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
                    orange.withOpacity(
                        .06),
                borderRadius:
                    BorderRadius.circular(
                        8),
                border: Border.all(
                  color:
                      orange.withOpacity(
                          .15),
                ),
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Icon(
                    Icons
                        .my_location_rounded,
                    color: orange,
                    size: 13,
                  ),
                  const SizedBox(
                      width: 5),
                  Text(
                    'TARGET: $target',
                    style:
                        const TextStyle(
                      color: orange,
                      fontSize: 9,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ----------------------------------------------------------
        // ARRAY
        // ----------------------------------------------------------

        SizedBox(
          height: 175,
          child: LayoutBuilder(
            builder:
                (context,
                    constraints) {
              return SingleChildScrollView(
                scrollDirection:
                    Axis.horizontal,
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
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
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // ----------------------------------------------------------
        // RANGE INFORMATION
        // ----------------------------------------------------------

        _buildRangeInformation(),
      ],
    );
  }

  // ==============================================================
  // RANGE BADGE
  // ==============================================================

  Widget _rangeBadge(
    String label,
    int index,
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
        '$label: ${index >= 0 ? index : "-"}',
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
    final bool isLow =
        index == low;

    final bool isMid =
        index == mid;

    final bool isHigh =
        index == high;

    final bool isFound =
        index == foundIndex;

    final bool isActive =
        index == activeIndex;

    Color color =
        Colors.white24;

    if (isFound) {
      color = green;
    } else if (isMid) {
      color = orange;
    } else if (isActive) {
      color = cyan;
    } else if (isLow) {
      color = blue;
    } else if (isHigh) {
      color = purple;
    } else if (low >= 0 &&
        high >= 0 &&
        (index < low ||
            index > high)) {
      color = Colors.white12;
    }

    final bool eliminated =
        low >= 0 &&
            high >= 0 &&
            (index < low ||
                index > high);

    return SizedBox(
      width: 62,
      child: Column(
        children: [
          SizedBox(
            height: 26,
            child: Center(
              child:
                  _positionIndicator(
                index,
              ),
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
                  color.withOpacity(
                eliminated
                    ? .025
                    : .09,
              ),
              borderRadius:
                  BorderRadius.circular(
                      11),
              border: Border.all(
                color:
                    color.withOpacity(
                  eliminated
                      ? .12
                      : .85,
                ),
                width:
                    isFound ||
                            isMid ||
                            isActive
                        ? 2
                        : 1,
              ),
              boxShadow:
                  isFound ||
                          isMid ||
                          isActive
                      ? [
                          BoxShadow(
                            color:
                                color.withOpacity(
                              .22,
                            ),
                            blurRadius:
                                14,
                            spreadRadius:
                                1,
                          ),
                        ]
                      : null,
            ),
            child: Center(
              child: Text(
                '${array[index]}',
                style: TextStyle(
                  color: eliminated
                      ? Colors.white24
                      : Colors.white,
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
                  color.withOpacity(.75),
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
  // POSITION INDICATOR
  // ==============================================================

  Widget _positionIndicator(
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
          letterSpacing: .5,
        ),
      );
    }

    if (index == mid) {
      return const Text(
        'MID',
        style: TextStyle(
          color: orange,
          fontSize: 8,
          fontWeight:
              FontWeight.w900,
        ),
      );
    }

    if (index == low) {
      return const Text(
        'LOW',
        style: TextStyle(
          color: blue,
          fontSize: 8,
          fontWeight:
              FontWeight.w900,
        ),
      );
    }

    if (index == high) {
      return const Text(
        'HIGH',
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
  // RANGE INFORMATION
  // ==============================================================

  Widget _buildRangeInformation() {
    String text;

    if (low < 0 ||
        high < 0) {
      text =
          'Search range not initialized.';
    } else if (low > high) {
      text =
          'Search range is empty.';
    } else {
      text =
          'Searching indices $low → $high '
          '(${high - low + 1} elements)';
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
            blue.withOpacity(.045),
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color:
              blue.withOpacity(.12),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.filter_center_focus_rounded,
            color: blue,
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
  // STATUS CARD
  // ==============================================================

  Widget _buildStatusCard() {
    Color color = cyan;

    if (executionHistory
        .isNotEmpty) {
      color = _eventColor(
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
                  BorderRadius.circular(9),
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
  // OPERATION ICON
  // ==============================================================

  IconData _operationIcon() {
    if (executionHistory
        .isEmpty) {
      return Icons.play_arrow_rounded;
    }

    switch (
        executionHistory.last.type) {
      case BinarySearchEventType
          .initialize:
        return Icons
            .start_rounded;

      case BinarySearchEventType
          .compare:
        return Icons
            .compare_arrows_rounded;

      case BinarySearchEventType
          .moveLeft:
        return Icons
            .keyboard_arrow_left_rounded;

      case BinarySearchEventType
          .moveRight:
        return Icons
            .keyboard_arrow_right_rounded;

      case BinarySearchEventType
          .found:
        return Icons
            .check_circle_rounded;

      case BinarySearchEventType
          .notFound:
        return Icons
            .cancel_rounded;

      case BinarySearchEventType
          .complete:
        return Icons
            .done_all_rounded;
    }
  }

  // ==============================================================
  // EVENT COLOR
  // ==============================================================

  Color _eventColor(
    BinarySearchEventType type,
  ) {
    switch (type) {
      case BinarySearchEventType
          .initialize:
        return blue;

      case BinarySearchEventType
          .compare:
        return cyan;

      case BinarySearchEventType
          .moveLeft:
        return purple;

      case BinarySearchEventType
          .moveRight:
        return blue;

      case BinarySearchEventType
          .found:
        return green;

      case BinarySearchEventType
          .notFound:
        return red;

      case BinarySearchEventType
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
                        letterSpacing:
                            .6,
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
                  fontWeight:
                      FontWeight.w600,
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
  // SOURCE + EXECUTION
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
    BinarySearchEvent event,
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
                  color.withOpacity(
                      .10),
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
  // NEXT STEP
  // ==============================================================

  void _nextStep() {
    if (events.isEmpty) {
      return;
    }

    if (currentStep >=
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

      low = event.low;
      mid = event.mid;
      high = event.high;

      activeIndex =
          event.mid;

      executionMessage =
          event.description;

      activeCodeLine =
          _codeLineForEvent(
              event);

      if (event.type ==
          BinarySearchEventType
              .found) {
        foundIndex =
            event.mid;
      }

      if (event.type ==
          BinarySearchEventType
              .complete) {
        isCompleted = true;

        activeIndex =
            foundIndex;

        if (foundIndex >=
            0) {
          executionMessage =
              'Target $target found at index $foundIndex.';
        }
      }
    });
  }

  // ==============================================================
  // PREVIOUS STEP
  // ==============================================================

  void _previousStep() {
    if (executionHistory
        .isEmpty) {
      return;
    }

    executionHistory
        .removeLast();

    final int newStep =
        executionHistory.length;

    setState(() {
      currentStep =
          newStep;

      foundIndex = -1;

      if (executionHistory
          .isEmpty) {
        array =
            List<int>.from(
                originalArray);

        low = -1;
        mid = -1;
        high = -1;

        activeIndex = -1;

        activeCodeLine = 0;

        executionMessage =
            'Ready to start Binary Search';

        isCompleted = false;

        return;
      }

      final event =
          executionHistory
              .last;

      array =
          List<int>.from(
              event.array);

      low = event.low;
      mid = event.mid;
      high = event.high;

      activeIndex =
          event.mid;

      activeCodeLine =
          _codeLineForEvent(
              event);

      executionMessage =
          event.description;

      for (final item
          in executionHistory) {
        if (item.type ==
            BinarySearchEventType
                .found) {
          foundIndex =
              item.mid;
        }
      }

      isCompleted =
          event.type ==
              BinarySearchEventType
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
              isCompleted =
                  true;
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

      low = -1;
      mid = -1;
      high = -1;

      foundIndex = -1;
      activeIndex = -1;

      activeCodeLine = 0;

      executionMessage =
          'Ready to start Binary Search';
    });
  }

  // ==============================================================
  // LOAD ARRAY
  // ==============================================================

  void _loadArray() {
    final arrayText =
        arrayController.text.trim();

    final targetText =
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

      final parsedTarget =
          int.parse(
        targetText,
      );

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
            List<int>.from(
                values);

        originalArray =
            List<int>.from(
                values);

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

        low = -1;
        mid = -1;
        high = -1;

        foundIndex = -1;
        activeIndex = -1;

        activeCodeLine = 0;

        executionMessage =
            'Array loaded. Ready to start Binary Search.';

        _generateEvents();
      });
    } catch (_) {
      _showMessage(
        'Invalid input. Use numbers like: 11, 22, 34, 64',
        red,
      );
    }
  }

  // ==============================================================
  // GENERATE NUMBERS
  // ==============================================================

  void _generateNumbers() {
    final random =
        Random();

    final generated =
        List.generate(
      10,
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
  // ACTIVE CODE LINE
  // ==============================================================

  int _codeLineForEvent(
    BinarySearchEvent event,
  ) {
    switch (event.type) {
      case BinarySearchEventType
          .initialize:
        return 2;

      case BinarySearchEventType
          .compare:
        return 6;

      case BinarySearchEventType
          .moveLeft:
        return 13;

      case BinarySearchEventType
          .moveRight:
        return 11;

      case BinarySearchEventType
          .found:
        return 9;

      case BinarySearchEventType
          .notFound:
        return 17;

      case BinarySearchEventType
          .complete:
        return 18;
    }
  }

  // ==============================================================
  // COPY CODE
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
  // SNACKBAR
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