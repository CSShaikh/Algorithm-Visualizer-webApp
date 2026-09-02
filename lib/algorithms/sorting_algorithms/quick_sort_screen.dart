import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuickSortScreen extends StatefulWidget {
  const QuickSortScreen({super.key});

  @override
  State<QuickSortScreen> createState() => _QuickSortScreenState();
}

// ============================================================================
// QUICK SORT EVENT
// ============================================================================

enum QuickSortEventType {
  pivot,
  compare,
  leftMove,
  rightMove,
  swap,
  partition,
  complete,
}

class QuickSortEvent {
  final QuickSortEventType type;
  final List<int> array;

  final int? pivotIndex;
  final int? leftIndex;
  final int? rightIndex;
  final int? low;
  final int? high;

  final String title;
  final String description;
  final String operation;

  const QuickSortEvent({
    required this.type,
    required this.array,
    this.pivotIndex,
    this.leftIndex,
    this.rightIndex,
    this.low,
    this.high,
    required this.title,
    required this.description,
    required this.operation,
  });
}

// ============================================================================
// SCREEN
// ============================================================================

class _QuickSortScreenState extends State<QuickSortScreen> {
  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color background = Color(0xFF030712);
  static const Color background2 = Color(0xFF07101F);
  static const Color cardColor = Color(0xFF0B1428);
  static const Color visualizationColor = Color(0xFF0A1020);

  static const Color cyan = Color(0xFF00E5FF);
  static const Color blue = Color(0xFF2979FF);
  static const Color purple = Color(0xFF9C27FF);
  static const Color green = Color(0xFF00E676);
  static const Color orange = Color(0xFFFFB300);
  static const Color pink = Color(0xFFFF4081);

  // ==========================================================================
  // ARRAY
  // ==========================================================================

  List<int> array = [64, 25, 12, 22, 11];

  List<int> workingArray = [64, 25, 12, 22, 11];

  final TextEditingController arrayController =
      TextEditingController(
    text: '64, 25, 12, 22, 11',
  );

  // ==========================================================================
  // QUICK SORT EVENTS
  // ==========================================================================

  final List<QuickSortEvent> events = [];

  // Only executed events appear here.
  final List<QuickSortEvent> executionHistory = [];

  // ==========================================================================
  // EXECUTION STATE
  // ==========================================================================

  int currentStep = -1;

  bool isRunning = false;
  bool isCompleted = false;

  double speed = 1.0;

  Timer? timer;

  String executionMessage = 'Ready to start Quick Sort';

  int activeCodeLine = -1;

  int pivotIndex = -1;
  int leftIndex = -1;
  int rightIndex = -1;

  int rangeLow = -1;
  int rangeHigh = -1;

  final Set<int> partitionedIndices = {};

  // ==========================================================================
  // SOURCE CODE
  // ==========================================================================

  static const String sourceCode = '''
void quickSort(List<int> arr, int low, int high) {
  if (low >= high) return;

  int pivotIndex = partition(arr, low, high);

  quickSort(arr, low, pivotIndex - 1);
  quickSort(arr, pivotIndex + 1, high);
}

int partition(List<int> arr, int low, int high) {
  int pivot = arr[high];
  int i = low - 1;

  for (int j = low; j < high; j++) {
    if (arr[j] < pivot) {
      i++;

      int temp = arr[i];
      arr[i] = arr[j];
      arr[j] = temp;
    }
  }

  int temp = arr[i + 1];
  arr[i + 1] = arr[high];
  arr[high] = temp;

  return i + 1;
}''';

  static const List<String> sourceLines = [
    'void quickSort(List<int> arr, int low, int high) {',
    '  if (low >= high) return;',
    '',
    '  int pivotIndex = partition(arr, low, high);',
    '',
    '  quickSort(arr, low, pivotIndex - 1);',
    '  quickSort(arr, pivotIndex + 1, high);',
    '}',
    '',
    'int partition(List<int> arr, int low, int high) {',
    '  int pivot = arr[high];',
    '  int i = low - 1;',
    '',
    '  for (int j = low; j < high; j++) {',
    '    if (arr[j] < pivot) {',
    '      i++;',
    '',
    '      int temp = arr[i];',
    '      arr[i] = arr[j];',
    '      arr[j] = temp;',
    '    }',
    '  }',
    '',
    '  int temp = arr[i + 1];',
    '  arr[i + 1] = arr[high];',
    '  arr[high] = temp;',
    '',
    '  return i + 1;',
    '}',
  ];

  // ==========================================================================
  // INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();
    _prepareEvents();
  }

  @override
  void dispose() {
    timer?.cancel();
    arrayController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // GENERATE ARRAY
  // ==========================================================================

  void _generateNumbers() {
    final random = Random();

    final generated = List.generate(
      8,
      (_) => random.nextInt(90) + 10,
    );

    arrayController.text = generated.join(', ');

    _stopTimer();

    setState(() {
      array = List<int>.from(generated);
      workingArray = List<int>.from(generated);

      events.clear();
      executionHistory.clear();
      partitionedIndices.clear();

      currentStep = -1;

      pivotIndex = -1;
      leftIndex = -1;
      rightIndex = -1;

      rangeLow = -1;
      rangeHigh = -1;

      isRunning = false;
      isCompleted = false;

      executionMessage = 'New numbers generated';

      activeCodeLine = -1;
    });

    _prepareEvents();
  }

  // ==========================================================================
  // LOAD ARRAY
  // ==========================================================================

  void _loadArray() {
    final text = arrayController.text.trim();

    if (text.isEmpty) {
      _showSnackBar(
        'Please enter numbers.',
        orange,
      );
      return;
    }

    try {
      final values = text
          .split(RegExp(r'[\s,]+'))
          .where((e) => e.trim().isNotEmpty)
          .map((e) => int.parse(e.trim()))
          .toList();

      if (values.isEmpty) {
        throw Exception();
      }

      if (values.length > 30) {
        _showSnackBar(
          'Maximum 30 numbers are allowed.',
          orange,
        );
        return;
      }

      _stopTimer();

      setState(() {
        array = List<int>.from(values);
        workingArray = List<int>.from(values);

        events.clear();
        executionHistory.clear();
        partitionedIndices.clear();

        currentStep = -1;

        pivotIndex = -1;
        leftIndex = -1;
        rightIndex = -1;

        rangeLow = -1;
        rangeHigh = -1;

        isRunning = false;
        isCompleted = false;

        executionMessage =
            'Array loaded. Ready to start Quick Sort';

        activeCodeLine = -1;
      });

      _prepareEvents();
    } catch (_) {
      _showSnackBar(
        'Invalid input. Example: 64, 25, 12, 22, 11',
        pink,
      );
    }
  }

  // ==========================================================================
  // PREPARE EVENTS
  // ==========================================================================

  void _prepareEvents() {
    events.clear();

    final values = List<int>.from(array);

    if (values.length <= 1) {
      events.add(
        QuickSortEvent(
          type: QuickSortEventType.complete,
          array: List<int>.from(values),
          title: 'Quick Sort Complete',
          description: 'Array is already sorted.',
          operation: 'COMPLETE',
        ),
      );
      return;
    }

    _quickSortEvents(
      values,
      0,
      values.length - 1,
      {},
    );

    events.add(
      QuickSortEvent(
        type: QuickSortEventType.complete,
        array: List<int>.from(values),
        pivotIndex: -1,
        leftIndex: -1,
        rightIndex: -1,
        low: 0,
        high: values.length - 1,
        title: 'Quick Sort Complete',
        description: 'All elements are sorted successfully.',
        operation: 'COMPLETE',
      ),
    );
  }

  // ==========================================================================
  // QUICK SORT EVENT GENERATOR
  // ==========================================================================

  void _quickSortEvents(
    List<int> values,
    int low,
    int high,
    Set<int> fixedPositions,
  ) {
    if (low >= high) {
      if (low >= 0 && low < values.length) {
        fixedPositions.add(low);
      }
      return;
    }

    // ------------------------------------------------------------------------
    // SELECT PIVOT
    // ------------------------------------------------------------------------

    final pivotValue = values[high];

    events.add(
      QuickSortEvent(
        type: QuickSortEventType.pivot,
        array: List<int>.from(values),
        pivotIndex: high,
        leftIndex: low,
        rightIndex: high,
        low: low,
        high: high,
        title: 'Pivot Selected',
        description:
            'Select $pivotValue as the pivot for the range $low → $high.',
        operation: 'PIVOT',
      ),
    );

    // ------------------------------------------------------------------------
    // LOMUTO PARTITION
    // ------------------------------------------------------------------------

    int i = low - 1;

    for (int j = low; j < high; j++) {
      // ----------------------------------------------------------------------
      // COMPARE
      // ----------------------------------------------------------------------

      events.add(
        QuickSortEvent(
          type: QuickSortEventType.compare,
          array: List<int>.from(values),
          pivotIndex: high,
          leftIndex: i + 1,
          rightIndex: j,
          low: low,
          high: high,
          title: 'Compare Element',
          description:
              'Compare ${values[j]} with pivot $pivotValue.',
          operation: 'COMPARE',
        ),
      );

      if (values[j] < pivotValue) {
        i++;

        // --------------------------------------------------------------------
        // MOVE LEFT
        // --------------------------------------------------------------------

        events.add(
          QuickSortEvent(
            type: QuickSortEventType.leftMove,
            array: List<int>.from(values),
            pivotIndex: high,
            leftIndex: i,
            rightIndex: j,
            low: low,
            high: high,
            title: 'Move Left Pointer',
            description:
                '${values[j]} is smaller than pivot. Move left pointer to index $i.',
            operation: 'LEFT',
          ),
        );

        // --------------------------------------------------------------------
        // SWAP
        // --------------------------------------------------------------------

        if (i != j) {
          final temp = values[i];
          values[i] = values[j];
          values[j] = temp;

          events.add(
            QuickSortEvent(
              type: QuickSortEventType.swap,
              array: List<int>.from(values),
              pivotIndex: high,
              leftIndex: i,
              rightIndex: j,
              low: low,
              high: high,
              title: 'Swap Elements',
              description:
                  'Swap elements at index $i and index $j.',
              operation: 'SWAP',
            ),
          );
        }
      } else {
        // --------------------------------------------------------------------
        // MOVE RIGHT
        // --------------------------------------------------------------------

        events.add(
          QuickSortEvent(
            type: QuickSortEventType.rightMove,
            array: List<int>.from(values),
            pivotIndex: high,
            leftIndex: i + 1,
            rightIndex: j,
            low: low,
            high: high,
            title: 'Move Right Pointer',
            description:
                '${values[j]} is not smaller than pivot. Continue scanning.',
            operation: 'RIGHT',
          ),
        );
      }
    }

    // ------------------------------------------------------------------------
    // PLACE PIVOT
    // ------------------------------------------------------------------------

    final pivotFinalIndex = i + 1;

    if (pivotFinalIndex != high) {
      final temp = values[pivotFinalIndex];
      values[pivotFinalIndex] = values[high];
      values[high] = temp;

      events.add(
        QuickSortEvent(
          type: QuickSortEventType.swap,
          array: List<int>.from(values),
          pivotIndex: pivotFinalIndex,
          leftIndex: pivotFinalIndex,
          rightIndex: high,
          low: low,
          high: high,
          title: 'Place Pivot',
          description:
              'Move pivot $pivotValue to its final position at index $pivotFinalIndex.',
          operation: 'PIVOT SWAP',
        ),
      );
    }

    fixedPositions.add(pivotFinalIndex);

    // ------------------------------------------------------------------------
    // PARTITION COMPLETE
    // ------------------------------------------------------------------------

    events.add(
      QuickSortEvent(
        type: QuickSortEventType.partition,
        array: List<int>.from(values),
        pivotIndex: pivotFinalIndex,
        leftIndex: low,
        rightIndex: high,
        low: low,
        high: high,
        title: 'Partition Complete',
        description:
            'Pivot $pivotValue is correctly placed at index $pivotFinalIndex.',
        operation: 'PARTITION',
      ),
    );

    // ------------------------------------------------------------------------
    // LEFT PARTITION
    // ------------------------------------------------------------------------

    _quickSortEvents(
      values,
      low,
      pivotFinalIndex - 1,
      fixedPositions,
    );

    // ------------------------------------------------------------------------
    // RIGHT PARTITION
    // ------------------------------------------------------------------------

    _quickSortEvents(
      values,
      pivotFinalIndex + 1,
      high,
      fixedPositions,
    );
  }

  // ==========================================================================
  // NEXT STEP
  // ==========================================================================

  void _nextStep() {
    if (events.isEmpty) {
      return;
    }

    final nextIndex = currentStep + 1;

    if (nextIndex >= events.length) {
      _stopTimer();

      setState(() {
        isRunning = false;
        isCompleted = true;
      });

      return;
    }

    final event = events[nextIndex];

    setState(() {
      currentStep = nextIndex;

      workingArray = List<int>.from(event.array);

      pivotIndex = event.pivotIndex ?? -1;
      leftIndex = event.leftIndex ?? -1;
      rightIndex = event.rightIndex ?? -1;

      rangeLow = event.low ?? -1;
      rangeHigh = event.high ?? -1;

      executionHistory.add(event);

      executionMessage = event.description;

      activeCodeLine = _codeLineForEvent(event.type);

      if (event.type == QuickSortEventType.partition) {
        if (event.pivotIndex != null) {
          partitionedIndices.add(
            event.pivotIndex!,
          );
        }
      }

      if (event.type == QuickSortEventType.complete) {
        isCompleted = true;
        isRunning = false;
      }
    });

    if (currentStep >= events.length - 1) {
      _stopTimer();

      setState(() {
        isRunning = false;
        isCompleted = true;
      });
    }
  }

  // ==========================================================================
  // PREVIOUS STEP
  // ==========================================================================

  void _previousStep() {
    _stopTimer();

    if (currentStep <= 0) {
      setState(() {
        currentStep = -1;

        workingArray = List<int>.from(array);

        executionHistory.clear();
        partitionedIndices.clear();

        pivotIndex = -1;
        leftIndex = -1;
        rightIndex = -1;

        rangeLow = -1;
        rangeHigh = -1;

        isRunning = false;
        isCompleted = false;

        executionMessage = 'Ready to start Quick Sort';

        activeCodeLine = -1;
      });

      return;
    }

    final previousIndex = currentStep - 1;
    final event = events[previousIndex];

    setState(() {
      currentStep = previousIndex;

      workingArray = List<int>.from(event.array);

      pivotIndex = event.pivotIndex ?? -1;
      leftIndex = event.leftIndex ?? -1;
      rightIndex = event.rightIndex ?? -1;

      rangeLow = event.low ?? -1;
      rangeHigh = event.high ?? -1;

      if (executionHistory.isNotEmpty) {
        executionHistory.removeLast();
      }

      partitionedIndices.clear();

      for (final historyEvent in executionHistory) {
        if (historyEvent.type ==
            QuickSortEventType.partition) {
          if (historyEvent.pivotIndex != null) {
            partitionedIndices.add(
              historyEvent.pivotIndex!,
            );
          }
        }
      }

      executionMessage = event.description;

      activeCodeLine = _codeLineForEvent(event.type);

      isRunning = false;
      isCompleted = false;
    });
  }

  // ==========================================================================
  // PLAY
  // ==========================================================================

  void _play() {
    if (isCompleted) {
      _reset();
    }

    if (isRunning) {
      _pause();
      return;
    }

    if (currentStep >= events.length - 1) {
      return;
    }

    setState(() {
      isRunning = true;
    });

    _startTimer();
  }

  // ==========================================================================
  // PAUSE
  // ==========================================================================

  void _pause() {
    _stopTimer();

    setState(() {
      isRunning = false;
    });
  }

  // ==========================================================================
  // TIMER
  // ==========================================================================

  void _startTimer() {
    _stopTimer();

    final milliseconds =
        max(100, (850 / speed).round());

    timer = Timer.periodic(
      Duration(milliseconds: milliseconds),
      (_) {
        if (!mounted) {
          return;
        }

        if (currentStep >= events.length - 1) {
          _stopTimer();

          setState(() {
            isRunning = false;
            isCompleted = true;
          });

          return;
        }

        _nextStep();
      },
    );
  }

  void _stopTimer() {
    timer?.cancel();
    timer = null;
  }

  // ==========================================================================
  // RESET
  // ==========================================================================

  void _reset() {
    _stopTimer();

    setState(() {
      currentStep = -1;

      workingArray = List<int>.from(array);

      executionHistory.clear();
      partitionedIndices.clear();

      pivotIndex = -1;
      leftIndex = -1;
      rightIndex = -1;

      rangeLow = -1;
      rangeHigh = -1;

      isRunning = false;
      isCompleted = false;

      executionMessage = 'Ready to start Quick Sort';

      activeCodeLine = -1;
    });
  }

  // ==========================================================================
  // SPEED
  // ==========================================================================

  void _setSpeed(double value) {
    setState(() {
      speed = value;
    });

    if (isRunning) {
      _startTimer();
    }
  }

  // ==========================================================================
  // CODE LINE
  // ==========================================================================

  int _codeLineForEvent(
    QuickSortEventType type,
  ) {
    switch (type) {
      case QuickSortEventType.pivot:
        return 10;

      case QuickSortEventType.compare:
        return 14;

      case QuickSortEventType.leftMove:
        return 16;

      case QuickSortEventType.rightMove:
        return 14;

      case QuickSortEventType.swap:
        return 19;

      case QuickSortEventType.partition:
        return 26;

      case QuickSortEventType.complete:
        return 30;
    }
  }

  // ==========================================================================
  // COPY CODE
  // ==========================================================================

  Future<void> _copyCode() async {
    await Clipboard.setData(
      const ClipboardData(
        text: sourceCode,
      ),
    );

    if (!mounted) {
      return;
    }

    _showSnackBar(
      'Source code copied.',
      cyan,
    );
  }

  // ==========================================================================
  // SNACKBAR
  // ==========================================================================

  void _showSnackBar(
    String message,
    Color color,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: cardColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),

            Expanded(
              child: LayoutBuilder(
                builder: (
                  context,
                  constraints,
                ) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(18),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 1450,
                        ),
                        child: Column(
                          children: [
                            _buildAlgorithmInfo(),

                            const SizedBox(height: 16),

                            _buildInputSection(),

                            const SizedBox(height: 16),

                            // IMPORTANT:
                            // Controls are now handled only
                            // inside _buildMainWorkspace().
                            _buildMainWorkspace(
                              constraints.maxWidth,
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

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _buildHeader() {
    return Container(
      height: 82,
      decoration: const BoxDecoration(
        color: background2,
        border: Border(
          bottom: BorderSide(
            color: cyan,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).maybePop();
              },
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 8),

            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: purple.withOpacity(0.10),
                borderRadius:
                    BorderRadius.circular(12),
                border: Border.all(
                  color: purple.withOpacity(0.30),
                ),
              ),
              child: const Icon(
                Icons.sort_rounded,
                color: purple,
                size: 25,
              ),
            ),

            const SizedBox(width: 13),

            const Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Sort',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Interactive Algorithm Visualizer',
                  style: TextStyle(
                    color: Color(0x99FFFFFF),
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const Spacer(),

            _buildStatusBadge(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color = cyan;
    String label = 'READY';

    if (isRunning) {
      color = orange;
      label = 'RUNNING';
    } else if (isCompleted) {
      color = green;
      label = 'COMPLETED';
    } else if (currentStep >= 0) {
      color = purple;
      label = 'PAUSED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.28),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: 6),

          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ALGORITHM INFO
  // ==========================================================================

  Widget _buildAlgorithmInfo() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.info_outline_rounded,
            'Algorithm Information',
            cyan,
          ),

          const SizedBox(height: 15),

          const Text(
            'Quick Sort',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Quick Sort is a divide-and-conquer sorting algorithm. '
            'It selects a pivot, partitions the array around the pivot, '
            'and recursively sorts the left and right partitions.',
            style: TextStyle(
              color: Color(0xB3FFFFFF),
              fontSize: 12,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 15),

          LayoutBuilder(
            builder: (
              context,
              constraints,
            ) {
              final width =
                  constraints.maxWidth < 650
                      ? constraints.maxWidth
                      : (constraints.maxWidth - 36) / 4;

              return Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  SizedBox(
                    width: width,
                    child: _infoBox(
                      'Average',
                      'O(n log n)',
                      cyan,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _infoBox(
                      'Worst',
                      'O(n²)',
                      pink,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _infoBox(
                      'Space',
                      'O(log n)',
                      purple,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: _infoBox(
                      'Type',
                      'Divide & Conquer',
                      green,
                    ),
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
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x06000000),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0x15FFFFFF),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius:
                  BorderRadius.circular(3),
            ),
          ),

          const SizedBox(width: 9),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0x70FFFFFF),
                  fontSize: 9,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // INPUT
  // ==========================================================================

  Widget _buildInputSection() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.input_rounded,
            'Input Array',
            orange,
          ),

          const SizedBox(height: 14),

          LayoutBuilder(
            builder: (
              context,
              constraints,
            ) {
              if (constraints.maxWidth < 760) {
                return Column(
                  children: [
                    _inputField(),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _generateButton(),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _loadButton(),
                        ),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: _inputField(),
                  ),

                  const SizedBox(width: 10),

                  _generateButton(),

                  const SizedBox(width: 10),

                  _loadButton(),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _inputField() {
    return TextField(
      controller: arrayController,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      cursorColor: cyan,
      decoration: InputDecoration(
        labelText: 'Enter Numbers',
        labelStyle: const TextStyle(
          color: Color(0x99FFFFFF),
          fontSize: 11,
        ),
        hintText: '64, 25, 12, 22, 11',
        hintStyle: const TextStyle(
          color: Color(0x45FFFFFF),
          fontSize: 11,
        ),
        prefixIcon: const Icon(
          Icons.numbers_rounded,
          color: cyan,
          size: 19,
        ),
        filled: true,
        fillColor: const Color(0x06000000),
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: Color(0x18FFFFFF),
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: Color(0x18FFFFFF),
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(9),
          borderSide: const BorderSide(
            color: cyan,
          ),
        ),
      ),
    );
  }

  Widget _generateButton() {
    return SizedBox(
      height: 46,
      child: OutlinedButton.icon(
        onPressed: _generateNumbers,
        icon: const Icon(
          Icons.casino_rounded,
          size: 17,
        ),
        label: const Text(
          'Generate Numbers',
          style: TextStyle(fontSize: 11),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: purple,
          side: BorderSide(
            color: purple.withOpacity(0.35),
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(9),
          ),
        ),
      ),
    );
  }

  Widget _loadButton() {
    return SizedBox(
      height: 46,
      child: ElevatedButton.icon(
        onPressed: _loadArray,
        icon: const Icon(
          Icons.download_rounded,
          size: 17,
        ),
        label: const Text(
          'LOAD ARRAY',
          style: TextStyle(fontSize: 11),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: cyan,
          foregroundColor: background,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(9),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // MAIN WORKSPACE
  // ==========================================================================

  Widget _buildMainWorkspace(double width) {
    final bool mobile = width < 900;

    if (mobile) {
      return Column(
        children: [
          _buildVisualization(),

          const SizedBox(height: 16),

          // Controls appear ONCE.
          _buildControls(),

          const SizedBox(height: 16),

          _buildSourceCode(),

          const SizedBox(height: 16),

          _buildExecutionSteps(),
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
              _buildVisualization(),

              const SizedBox(height: 16),

              // Controls appear ONCE.
              _buildControls(),
            ],
          ),
        ),

        const SizedBox(width: 16),

        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildSourceCode(),

              const SizedBox(height: 16),

              _buildExecutionSteps(),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // VISUALIZATION
  // ==========================================================================

  Widget _buildVisualization() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.auto_graph_rounded,
            'Visualization',
            cyan,
          ),

          const SizedBox(height: 14),

          _buildLegend(),

          const SizedBox(height: 16),

          _buildArrayView(),

          const SizedBox(height: 14),

          _buildOperationBox(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final items = [
      ('Ready', const Color(0xFF607D8B)),
      ('Pivot', purple),
      ('Left', cyan),
      ('Right', orange),
      ('Comparing', pink),
      ('Partitioned', green),
    ];

    return Wrap(
      spacing: 13,
      runSpacing: 8,
      children: items.map(
        (item) {
          return Row(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: item.$2,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 5),

              Text(
                item.$1,
                style: const TextStyle(
                  color: Color(0x99FFFFFF),
                  fontSize: 9,
                ),
              ),
            ],
          );
        },
      ).toList(),
    );
  }

  // ==========================================================================
  // ARRAY VIEW
  // ==========================================================================

  Widget _buildArrayView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: visualizationColor,
        borderRadius:
            BorderRadius.circular(11),
        border: Border.all(
          color: const Color(0x12FFFFFF),
        ),
      ),
      child: workingArray.isEmpty
          ? const SizedBox(
              height: 180,
              child: Center(
                child: Text(
                  'No numbers available',
                  style: TextStyle(
                    color: Color(0x70FFFFFF),
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              scrollDirection:
                  Axis.horizontal,
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: List.generate(
                  workingArray.length,
                  (index) {
                    return Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      child: _arrayElement(
                        index,
                        workingArray[index],
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _arrayElement(
    int index,
    int value,
  ) {
    bool isPivot =
        index == pivotIndex;

    bool isLeft =
        index == leftIndex;

    bool isRight =
        index == rightIndex;

    bool isPartitioned =
        partitionedIndices.contains(index);

    bool isComparing =
        currentStep >= 0 &&
        currentStep < events.length &&
        events[currentStep].type ==
            QuickSortEventType.compare &&
        (isLeft || isRight);

    Color color =
        const Color(0xFF607D8B);

    if (isPartitioned) {
      color = green;
    }

    if (isPivot) {
      color = purple;
    }

    if (isLeft) {
      color = cyan;
    }

    if (isRight) {
      color = orange;
    }

    if (isComparing) {
      color = pink;
    }

    final bool activeRange =
        rangeLow >= 0 &&
        rangeHigh >= 0 &&
        index >= rangeLow &&
        index <= rangeHigh;

    return SizedBox(
      width: 70,
      height: 205,
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 18,
            child: isPivot
                ? _pointerLabel(
                    'PIVOT',
                    purple,
                  )
                : isLeft
                    ? _pointerLabel(
                        'LEFT',
                        cyan,
                      )
                    : isRight
                        ? _pointerLabel(
                            'RIGHT',
                            orange,
                          )
                        : null,
          ),

          const SizedBox(height: 5),

          AnimatedContainer(
            duration:
                const Duration(milliseconds: 220),
            width: 58,
            height:
                (65 + value.abs() * 0.72)
                    .clamp(65.0, 155.0),
            decoration: BoxDecoration(
              color: color.withOpacity(
                activeRange ? 0.12 : 0.06,
              ),
              borderRadius:
                  BorderRadius.circular(10),
              border: Border.all(
                color: color.withOpacity(
                  activeRange ? 0.75 : 0.30,
                ),
                width:
                    isPivot ||
                            isLeft ||
                            isRight ||
                            isComparing
                        ? 2
                        : 1,
              ),
              boxShadow: [
                if (isPivot ||
                    isLeft ||
                    isRight ||
                    isComparing)
                  BoxShadow(
                    color:
                        color.withOpacity(0.18),
                    blurRadius: 12,
                  ),
              ],
            ),
            child: Center(
              child: Text(
                '$value',
                style: TextStyle(
                  color: color,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            '[$index]',
            style: const TextStyle(
              color: Color(0x65FFFFFF),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pointerLabel(
    String text,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 5,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius:
            BorderRadius.circular(4),
        border: Border.all(
          color: color.withOpacity(0.35),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 7,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // ==========================================================================
  // OPERATION
  // ==========================================================================

  Widget _buildOperationBox() {
    Color color = cyan;

    IconData icon =
        Icons.play_arrow_rounded;

    if (currentStep >= 0 &&
        currentStep < events.length) {
      final event =
          events[currentStep];

      color = _eventColor(event.type);
      icon = _eventIcon(event.type);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius:
            BorderRadius.circular(9),
        border: Border.all(
          color: color.withOpacity(0.20),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius:
                  BorderRadius.circular(7),
            ),
            child: Icon(
              icon,
              color: color,
              size: 17,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  currentStep >= 0 &&
                          currentStep <
                              events.length
                      ? events[currentStep].title
                      : 'Current Operation',
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  executionMessage,
                  style: const TextStyle(
                    color: Color(0x99FFFFFF),
                    fontSize: 10,
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

  Color _eventColor(
    QuickSortEventType type,
  ) {
    switch (type) {
      case QuickSortEventType.pivot:
        return purple;

      case QuickSortEventType.compare:
        return pink;

      case QuickSortEventType.leftMove:
        return cyan;

      case QuickSortEventType.rightMove:
        return orange;

      case QuickSortEventType.swap:
        return orange;

      case QuickSortEventType.partition:
        return green;

      case QuickSortEventType.complete:
        return green;
    }
  }

  IconData _eventIcon(
    QuickSortEventType type,
  ) {
    switch (type) {
      case QuickSortEventType.pivot:
        return Icons.adjust_rounded;

      case QuickSortEventType.compare:
        return Icons.compare_arrows_rounded;

      case QuickSortEventType.leftMove:
        return Icons.arrow_back_rounded;

      case QuickSortEventType.rightMove:
        return Icons.arrow_forward_rounded;

      case QuickSortEventType.swap:
        return Icons.swap_vert_rounded;

      case QuickSortEventType.partition:
        return Icons.check_circle_outline_rounded;

      case QuickSortEventType.complete:
        return Icons.verified_rounded;
    }
  }

  // ==========================================================================
  // CONTROLS
  // ==========================================================================

  Widget _buildControls() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.tune_rounded,
            'Visualization Controls',
            orange,
          ),

          const SizedBox(height: 13),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed:
                    currentStep >= 0
                        ? _previousStep
                        : null,
                icon: const Icon(
                  Icons.skip_previous_rounded,
                  size: 16,
                ),
                label: const Text(
                  'Previous',
                  style:
                      TextStyle(fontSize: 10),
                ),
                style:
                    OutlinedButton.styleFrom(
                  foregroundColor:
                      const Color(0xCCFFFFFF),
                  side: const BorderSide(
                    color: Color(0x20FFFFFF),
                  ),
                ),
              ),

              ElevatedButton.icon(
                onPressed: _play,
                icon: Icon(
                  isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  size: 16,
                ),
                label: Text(
                  isRunning
                      ? 'Pause'
                      : 'Play',
                  style:
                      const TextStyle(
                    fontSize: 10,
                  ),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: cyan,
                  foregroundColor: background,
                  elevation: 0,
                ),
              ),

              ElevatedButton.icon(
                onPressed:
                    isCompleted
                        ? null
                        : _nextStep,
                icon: const Icon(
                  Icons.skip_next_rounded,
                  size: 16,
                ),
                label: const Text(
                  'Next Step',
                  style:
                      TextStyle(fontSize: 10),
                ),
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  foregroundColor:
                      Colors.white,
                  elevation: 0,
                ),
              ),

              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 16,
                ),
                label: const Text(
                  'Reset',
                  style:
                      TextStyle(fontSize: 10),
                ),
                style:
                    OutlinedButton.styleFrom(
                  foregroundColor: orange,
                  side: BorderSide(
                    color:
                        orange.withOpacity(
                      0.30,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.speed_rounded,
                color: Color(0x80FFFFFF),
                size: 17,
              ),

              const SizedBox(width: 7),

              const Text(
                'Speed',
                style: TextStyle(
                  color: Color(0x80FFFFFF),
                  fontSize: 10,
                ),
              ),

              Expanded(
                child: Slider(
                  value: speed,
                  min: 0.5,
                  max: 3.0,
                  divisions: 5,
                  activeColor: cyan,
                  inactiveColor:
                      const Color(0x20FFFFFF),
                  onChanged: _setSpeed,
                ),
              ),

              Text(
                '${speed.toStringAsFixed(1)}x',
                style: const TextStyle(
                  color: cyan,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // SOURCE CODE
  // ==========================================================================

  Widget _buildSourceCode() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionTitle(
                Icons.code_rounded,
                'Source Code',
                blue,
              ),

              const Spacer(),

              IconButton(
                tooltip: 'Copy',
                onPressed: _copyCode,
                icon: const Icon(
                  Icons.copy_rounded,
                  color: Color(0x80FFFFFF),
                  size: 16,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Container(
            height: 430,
            decoration: BoxDecoration(
              color: visualizationColor,
              borderRadius:
                  BorderRadius.circular(9),
              border: Border.all(
                color: const Color(0x12FFFFFF),
              ),
            ),
            child: ListView.builder(
              padding:
                  const EdgeInsets.symmetric(
                vertical: 8,
              ),
              itemCount: sourceLines.length,
              itemBuilder: (
                context,
                index,
              ) {
                final bool active =
                    index == activeCodeLine;

                return Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: active
                        ? cyan.withOpacity(
                            0.08,
                          )
                        : Colors.transparent,
                    border: active
                        ? const Border(
                            left: BorderSide(
                              color: cyan,
                              width: 2,
                            ),
                          )
                        : null,
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 25,
                        child: Text(
                          '${index + 1}',
                          textAlign:
                              TextAlign.right,
                          style: TextStyle(
                            color: active
                                ? cyan
                                : const Color(
                                    0x45FFFFFF,
                                  ),
                            fontFamily:
                                'monospace',
                            fontSize: 9,
                          ),
                        ),
                      ),

                      const SizedBox(width: 9),

                      Expanded(
                        child: Text(
                          sourceLines[index]
                                  .isEmpty
                              ? ' '
                              : sourceLines[index],
                          style: TextStyle(
                            color: active
                                ? Colors.white
                                : const Color(
                                    0xAFFFFFFF,
                                  ),
                            fontFamily:
                                'monospace',
                            fontSize: 9.5,
                            height: 1.35,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
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

  // ==========================================================================
  // EXECUTION STEPS
  // ==========================================================================

  Widget _buildExecutionSteps() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionTitle(
                Icons.timeline_rounded,
                'Execution Steps',
                green,
              ),

              const Spacer(),

              Text(
                '${executionHistory.length} steps',
                style: const TextStyle(
                  color: Color(0x70FFFFFF),
                  fontSize: 9,
                ),
              ),
            ],
          ),

          const SizedBox(height: 11),

          if (executionHistory.isEmpty)
            _emptySteps()
          else
            ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxHeight: 350,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount:
                    executionHistory.length,
                itemBuilder: (
                  context,
                  index,
                ) {
                  return _stepItem(
                    index,
                    executionHistory[index],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptySteps() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 30,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        color: visualizationColor,
        borderRadius:
            BorderRadius.circular(9),
        border: Border.all(
          color: const Color(0x12FFFFFF),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            color: Color(0x5570FFFFFF),
            size: 30,
          ),

          SizedBox(height: 8),

          Text(
            'No steps executed yet',
            style: TextStyle(
              color: Color(0x99FFFFFF),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 4),

          Text(
            'Press Next Step or Play to begin.',
            style: TextStyle(
              color: Color(0x5570FFFFFF),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepItem(
    int index,
    QuickSortEvent event,
  ) {
    final color =
        _eventColor(event.type);

    return Container(
      margin:
          const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: color.withOpacity(0.045),
        borderRadius:
            BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 25,
            height: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: color,
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: TextStyle(
                          color: color,
                          fontSize: 9.5,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),

                    Text(
                      event.operation,
                      style: TextStyle(
                        color:
                            color.withOpacity(
                          0.70,
                        ),
                        fontSize: 7,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 3),

                Text(
                  event.description,
                  style: const TextStyle(
                    color: Color(0x8FFFFFFF),
                    fontSize: 8.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CARD
  // ==========================================================================

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(13),
        border: Border.all(
          color: const Color(0x15FFFFFF),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x18000000),
            blurRadius: 15,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  // ==========================================================================
  // SECTION TITLE
  // ==========================================================================

  Widget _sectionTitle(
    IconData icon,
    String title,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.09),
            borderRadius:
                BorderRadius.circular(7),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),

        const SizedBox(width: 9),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}