import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MergeSortScreen extends StatefulWidget {
  const MergeSortScreen({super.key});

  @override
  State<MergeSortScreen> createState() => _MergeSortScreenState();
}

// ============================================================================
// EVENT TYPES
// ============================================================================

enum MergeEventType {
  split,
  compare,
  takeLeft,
  takeRight,
  appendLeft,
  appendRight,
  merged,
  complete,
}

// ============================================================================
// EVENT MODEL
// ============================================================================

class MergeSortEvent {
  final MergeEventType type;
  final List<int> values;
  final List<int> activeIndices;
  final List<int> sortedIndices;

  final int? leftIndex;
  final int? rightIndex;
  final int? mid;

  final int? rangeStart;
  final int? rangeEnd;

  final String title;
  final String description;
  final String operation;

  const MergeSortEvent({
    required this.type,
    required this.values,
    this.activeIndices = const [],
    this.sortedIndices = const [],
    this.leftIndex,
    this.rightIndex,
    this.mid,
    this.rangeStart,
    this.rangeEnd,
    required this.title,
    required this.description,
    required this.operation,
  });
}

// ============================================================================
// SCREEN STATE
// ============================================================================

class _MergeSortScreenState extends State<MergeSortScreen> {
  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color background = Color(0xFF030712);
  static const Color background2 = Color(0xFF07101F);
  static const Color cardColor = Color(0xFF0B1428);

  static const Color cyan = Color(0xFF00E5FF);
  static const Color blue = Color(0xFF2979FF);
  static const Color purple = Color(0xFF9C27FF);
  static const Color green = Color(0xFF00E676);
  static const Color orange = Color(0xFFFFB300);
  static const Color pink = Color(0xFFFF4081);
  static const Color red = Color(0xFFFF5252);

  // ==========================================================================
  // ARRAY
  // ==========================================================================

  List<int> array = [
    38,
    27,
    43,
    3,
    9,
    82,
    10,
  ];

  List<int> workingArray = [];

  // ==========================================================================
  // ALL ALGORITHM EVENTS
  //
  // IMPORTANT:
  // These events are NOT displayed directly.
  // They are only the algorithm's execution plan.
  //
  // executionHistory is what the user actually sees.
  // ==========================================================================

  List<MergeSortEvent> events = [];

  // ==========================================================================
  // LIVE EXECUTION HISTORY
  // ==========================================================================

  final List<MergeSortEvent> executionHistory = [];

  // ==========================================================================
  // EXECUTION
  // ==========================================================================

  int currentStep = -1;

  int? activeLeft;
  int? activeRight;
  int? currentMid;

  int rangeStart = -1;
  int rangeEnd = -1;

  bool isRunning = false;
  bool isCompleted = false;

  double speed = 1.0;

  Timer? timer;

  // ==========================================================================
  // RANDOM
  // ==========================================================================

  final Random random = Random();

  // ==========================================================================
  // INPUT
  // ==========================================================================

  final TextEditingController numberController =
      TextEditingController(
    text: '38, 27, 43, 3, 9, 82, 10',
  );

  // ==========================================================================
  // SOURCE CODE
  // ==========================================================================

  final String sourceCode = '''
void mergeSort(List<int> arr, int left, int right) {
  if (left >= right) return;

  int mid = (left + right) ~/ 2;

  mergeSort(arr, left, mid);
  mergeSort(arr, mid + 1, right);

  merge(arr, left, mid, right);
}

void merge(
  List<int> arr,
  int left,
  int mid,
  int right,
) {
  List<int> temp = [];

  int i = left;
  int j = mid + 1;

  while (i <= mid && j <= right) {
    if (arr[i] <= arr[j]) {
      temp.add(arr[i]);
      i++;
    } else {
      temp.add(arr[j]);
      j++;
    }
  }

  while (i <= mid) {
    temp.add(arr[i]);
    i++;
  }

  while (j <= right) {
    temp.add(arr[j]);
    j++;
  }

  for (int k = 0; k < temp.length; k++) {
    arr[left + k] = temp[k];
  }
}
''';

  final List<String> codeLines = [
    'void mergeSort(List<int> arr, int left, int right) {',
    '  if (left >= right) return;',
    '',
    '  int mid = (left + right) ~/ 2;',
    '',
    '  mergeSort(arr, left, mid);',
    '  mergeSort(arr, mid + 1, right);',
    '',
    '  merge(arr, left, mid, right);',
    '}',
    '',
    'void merge(',
    '  List<int> arr,',
    '  int left,',
    '  int mid,',
    '  int right,',
    ') {',
    '  List<int> temp = [];',
    '',
    '  int i = left;',
    '  int j = mid + 1;',
    '',
    '  while (i <= mid && j <= right) {',
    '    if (arr[i] <= arr[j]) {',
    '      temp.add(arr[i]);',
    '      i++;',
    '    } else {',
    '      temp.add(arr[j]);',
    '      j++;',
    '    }',
    '  }',
    '',
    '  while (i <= mid) {',
    '    temp.add(arr[i]);',
    '    i++;',
    '  }',
    '',
    '  while (j <= right) {',
    '    temp.add(arr[j]);',
    '    j++;',
    '  }',
    '',
    '  for (int k = 0; k < temp.length; k++) {',
    '    arr[left + k] = temp[k];',
    '  }',
    '}',
  ];

  // ==========================================================================
  // INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    workingArray = List<int>.from(array);

    _generateEvents();
  }

  @override
  void dispose() {
    timer?.cancel();
    numberController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // PARSE INPUT
  // ==========================================================================

  List<int>? _parseInput() {
    final text = numberController.text.trim();

    if (text.isEmpty) {
      _showMessage('Please enter some numbers.');
      return null;
    }

    try {
      final parts = text
          .split(RegExp(r'[, ]+'))
          .where((e) => e.trim().isNotEmpty)
          .toList();

      final values = parts.map(int.parse).toList();

      if (values.isEmpty) {
        _showMessage('Please enter valid numbers.');
        return null;
      }

      if (values.length > 20) {
        _showMessage(
          'Maximum 20 numbers are allowed.',
        );
        return null;
      }

      return values;
    } catch (_) {
      _showMessage(
        'Please enter valid integers separated by commas.',
      );
      return null;
    }
  }

  // ==========================================================================
  // GENERATE NUMBERS
  // ==========================================================================

  void _generateNumbers() {
    _stop();

    final count = 7 + random.nextInt(4);

    final values = List.generate(
      count,
      (_) => 5 + random.nextInt(96),
    );

    numberController.text = values.join(', ');

    setState(() {
      array = List<int>.from(values);
      workingArray = List<int>.from(values);

      currentStep = -1;

      activeLeft = null;
      activeRight = null;
      currentMid = null;

      rangeStart = -1;
      rangeEnd = -1;

      isCompleted = false;

      executionHistory.clear();
    });

    _generateEvents();
  }

  // ==========================================================================
  // LOAD ARRAY
  // ==========================================================================

  void _loadArray() {
    final values = _parseInput();

    if (values == null) {
      return;
    }

    _stop();

    setState(() {
      array = List<int>.from(values);
      workingArray = List<int>.from(values);

      currentStep = -1;

      activeLeft = null;
      activeRight = null;
      currentMid = null;

      rangeStart = -1;
      rangeEnd = -1;

      isCompleted = false;

      executionHistory.clear();
    });

    _generateEvents();

    _showMessage(
      '${values.length} numbers loaded successfully.',
    );
  }

  // ==========================================================================
  // GENERATE ALGORITHM EVENTS
  //
  // Again:
  // This creates the plan.
  // It does NOT mean the steps are already executed.
  // ==========================================================================

  void _generateEvents() {
    events.clear();

    final values = List<int>.from(array);

    if (values.length > 1) {
      _buildMergeSortEvents(
        values,
        0,
        values.length - 1,
      );
    }

    events.add(
      MergeSortEvent(
        type: MergeEventType.complete,
        values: List<int>.from(values),
        sortedIndices: List.generate(
          values.length,
          (i) => i,
        ),
        title: 'Merge Sort Complete',
        description:
            'All elements have been merged into ascending order.',
        operation: 'SORTED',
      ),
    );
  }

  // ==========================================================================
  // BUILD MERGE SORT EVENTS
  // ==========================================================================

  void _buildMergeSortEvents(
    List<int> values,
    int left,
    int right,
  ) {
    if (left >= right) {
      return;
    }

    final mid = (left + right) ~/ 2;

    events.add(
      MergeSortEvent(
        type: MergeEventType.split,
        values: List<int>.from(values),
        activeIndices: List.generate(
          right - left + 1,
          (index) => left + index,
        ),
        mid: mid,
        rangeStart: left,
        rangeEnd: right,
        title: 'Split Array',
        description:
            'Split range [$left, $right] at middle index $mid.',
        operation: 'SPLIT',
      ),
    );

    _buildMergeSortEvents(
      values,
      left,
      mid,
    );

    _buildMergeSortEvents(
      values,
      mid + 1,
      right,
    );

    _buildMergeEvents(
      values,
      left,
      mid,
      right,
    );
  }

  // ==========================================================================
  // BUILD MERGE EVENTS
  // ==========================================================================

  void _buildMergeEvents(
    List<int> values,
    int left,
    int mid,
    int right,
  ) {
    int i = left;
    int j = mid + 1;

    final temp = <int>[];

    // ------------------------------------------------------------------------
    // COMPARE
    // ------------------------------------------------------------------------

    while (i <= mid && j <= right) {
      events.add(
        MergeSortEvent(
          type: MergeEventType.compare,
          values: List<int>.from(values),
          activeIndices: [
            i,
            j,
          ],
          leftIndex: i,
          rightIndex: j,
          mid: mid,
          rangeStart: left,
          rangeEnd: right,
          title: 'Compare Elements',
          description:
              'Compare ${values[i]} from the left half with '
              '${values[j]} from the right half.',
          operation: 'COMPARE',
        ),
      );

      if (values[i] <= values[j]) {
        temp.add(values[i]);

        events.add(
          MergeSortEvent(
            type: MergeEventType.takeLeft,
            values: List<int>.from(values),
            activeIndices: [
              i,
            ],
            leftIndex: i,
            rightIndex: j,
            mid: mid,
            rangeStart: left,
            rangeEnd: right,
            title: 'Take From Left',
            description:
                '${values[i]} is smaller or equal, so take it from the left half.',
            operation: 'LEFT → TEMP',
          ),
        );

        i++;
      } else {
        temp.add(values[j]);

        events.add(
          MergeSortEvent(
            type: MergeEventType.takeRight,
            values: List<int>.from(values),
            activeIndices: [
              j,
            ],
            leftIndex: i,
            rightIndex: j,
            mid: mid,
            rangeStart: left,
            rangeEnd: right,
            title: 'Take From Right',
            description:
                '${values[j]} is smaller, so take it from the right half.',
            operation: 'RIGHT → TEMP',
          ),
        );

        j++;
      }
    }

    // ------------------------------------------------------------------------
    // LEFT REMAINDER
    // ------------------------------------------------------------------------

    while (i <= mid) {
      temp.add(values[i]);

      events.add(
        MergeSortEvent(
          type: MergeEventType.appendLeft,
          values: List<int>.from(values),
          activeIndices: [
            i,
          ],
          leftIndex: i,
          mid: mid,
          rangeStart: left,
          rangeEnd: right,
          title: 'Append Left Remainder',
          description:
              '${values[i]} remains in the left half and is appended.',
          operation: 'APPEND LEFT',
        ),
      );

      i++;
    }

    // ------------------------------------------------------------------------
    // RIGHT REMAINDER
    // ------------------------------------------------------------------------

    while (j <= right) {
      temp.add(values[j]);

      events.add(
        MergeSortEvent(
          type: MergeEventType.appendRight,
          values: List<int>.from(values),
          activeIndices: [
            j,
          ],
          rightIndex: j,
          mid: mid,
          rangeStart: left,
          rangeEnd: right,
          title: 'Append Right Remainder',
          description:
              '${values[j]} remains in the right half and is appended.',
          operation: 'APPEND RIGHT',
        ),
      );

      j++;
    }

    // ------------------------------------------------------------------------
    // ACTUAL MERGE
    // ------------------------------------------------------------------------

    for (int k = 0; k < temp.length; k++) {
      values[left + k] = temp[k];
    }

    events.add(
      MergeSortEvent(
        type: MergeEventType.merged,
        values: List<int>.from(values),
        activeIndices: List.generate(
          right - left + 1,
          (index) => left + index,
        ),
        sortedIndices: List.generate(
          right - left + 1,
          (index) => left + index,
        ),
        mid: mid,
        rangeStart: left,
        rangeEnd: right,
        title: 'Merge Complete',
        description:
            'The two halves have been merged into a sorted range.',
        operation: 'MERGED',
      ),
    );
  }

  // ==========================================================================
  // EXECUTE ONE EVENT
  //
  // This is the ONLY place where an event becomes visible in the history.
  // ==========================================================================

  void _executeEvent(int index) {
    if (index < 0 || index >= events.length) {
      return;
    }

    final event = events[index];

    setState(() {
      currentStep = index;

      workingArray = List<int>.from(
        event.values,
      );

      activeLeft = event.leftIndex;
      activeRight = event.rightIndex;
      currentMid = event.mid;

      rangeStart = event.rangeStart ?? -1;
      rangeEnd = event.rangeEnd ?? -1;

      isCompleted =
          event.type == MergeEventType.complete;

      // LIVE PROCESS LOG
      //
      // Only the currently executed event gets added.
      executionHistory.add(event);
    });
  }

  // ==========================================================================
  // NEXT STEP
  // ==========================================================================

  void _nextStep() {
    if (events.isEmpty) {
      return;
    }

    if (currentStep < events.length - 1) {
      _executeEvent(
        currentStep + 1,
      );
    } else {
      _stop();
    }
  }

  // ==========================================================================
  // PREVIOUS STEP
  // ==========================================================================

  void _previousStep() {
    _stop();

    if (currentStep > 0) {
      final previousIndex = currentStep - 1;

      final event = events[previousIndex];

      setState(() {
        currentStep = previousIndex;

        workingArray = List<int>.from(
          event.values,
        );

        activeLeft = event.leftIndex;
        activeRight = event.rightIndex;
        currentMid = event.mid;

        rangeStart =
            event.rangeStart ?? -1;

        rangeEnd =
            event.rangeEnd ?? -1;

        isCompleted =
            event.type == MergeEventType.complete;

        // Remove current event from visible history.
        if (executionHistory.isNotEmpty) {
          executionHistory.removeLast();
        }
      });

      return;
    }

    if (currentStep == 0) {
      setState(() {
        currentStep = -1;

        workingArray =
            List<int>.from(array);

        activeLeft = null;
        activeRight = null;
        currentMid = null;

        rangeStart = -1;
        rangeEnd = -1;

        isCompleted = false;

        executionHistory.clear();
      });
    }
  }

  // ==========================================================================
  // PLAY
  // ==========================================================================

  void _play() {
    if (events.isEmpty) {
      return;
    }

    if (currentStep >= events.length - 1) {
      _reset();
    }

    setState(() {
      isRunning = true;
      isCompleted = false;
    });

    _startTimer();
  }

  // ==========================================================================
  // TIMER
  // ==========================================================================

  void _startTimer() {
    timer?.cancel();

    final milliseconds = max(
      100,
      (850 / speed).round(),
    );

    timer = Timer.periodic(
      Duration(
        milliseconds: milliseconds,
      ),
      (_) {
        if (!mounted) {
          return;
        }

        if (currentStep >= events.length - 1) {
          _stop();
          return;
        }

        _nextStep();
      },
    );
  }

  // ==========================================================================
  // PAUSE
  // ==========================================================================

  void _pause() {
    timer?.cancel();
    timer = null;

    setState(() {
      isRunning = false;
    });
  }

  // ==========================================================================
  // STOP
  // ==========================================================================

  void _stop() {
    timer?.cancel();
    timer = null;

    if (mounted) {
      setState(() {
        isRunning = false;
      });
    }
  }

  // ==========================================================================
  // RESET
  // ==========================================================================

  void _reset() {
    _stop();

    setState(() {
      currentStep = -1;

      workingArray =
          List<int>.from(array);

      activeLeft = null;
      activeRight = null;
      currentMid = null;

      rangeStart = -1;
      rangeEnd = -1;

      isCompleted = false;

      // IMPORTANT:
      // Process log completely clear.
      executionHistory.clear();
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
  // SNACKBAR
  // ==========================================================================

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: cardColor,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(
            seconds: 2,
          ),
        ),
      );
  }

  // ==========================================================================
  // COPY
  // ==========================================================================

  Future<void> _copyCode() async {
    await Clipboard.setData(
      ClipboardData(
        text: sourceCode,
      ),
    );

    _showMessage(
      'Merge Sort source code copied.',
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
                    padding:
                        const EdgeInsets.fromLTRB(
                      18,
                      18,
                      18,
                      30,
                    ),
                    child: Column(
                      children: [
                        _buildOverviewCard(),
                        const SizedBox(height: 16),
                        _buildInputCard(),
                        const SizedBox(height: 16),
                        _buildWorkspace(
                          constraints.maxWidth,
                        ),
                      ],
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
            color: Color(0x4400E5FF),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),

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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  purple,
                  blue,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color:
                      purple.withOpacity(0.25),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Icon(
              Icons.call_split_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Merge Sort',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Interactive Algorithm Visualizer',
                  style: TextStyle(
                    color:
                        Color(0xFF94A3B8),
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          if (MediaQuery.of(context)
                  .size
                  .width >
              600)
            Container(
              margin:
                  const EdgeInsets.only(
                right: 18,
              ),
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 8,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(0x1200E5FF),
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                border: Border.all(
                  color:
                      const Color(0x3300E5FF),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons
                        .account_tree_rounded,
                    color: cyan,
                    size: 16,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'DIVIDE & CONQUER',
                    style: TextStyle(
                      color: cyan,
                      fontSize: 10,
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing: 0.8,
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
  // OVERVIEW CARD
  // ==========================================================================

  Widget _buildOverviewCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color:
                      const Color(0x149C27FF),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              const Text(
                'Algorithm Information',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Text(
            'Merge Sort is a divide-and-conquer sorting algorithm. '
            'It repeatedly divides the array into smaller halves, '
            'then merges those halves back together in sorted order.',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13,
              height: 1.55,
            ),
          ),

          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (
              context,
              constraints,
            ) {
              final compact =
                  constraints.maxWidth < 650;

              final boxes = [
                _infoBox(
                  'TIME',
                  'O(n log n)',
                  cyan,
                  Icons.timer_outlined,
                ),
                _infoBox(
                  'SPACE',
                  'O(n)',
                  purple,
                  Icons.memory_rounded,
                ),
                _infoBox(
                  'BEST',
                  'O(n log n)',
                  green,
                  Icons.trending_up_rounded,
                ),
                _infoBox(
                  'WORST',
                  'O(n log n)',
                  orange,
                  Icons.warning_amber_rounded,
                ),
              ];

              if (compact) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: boxes,
                );
              }

              return Row(
                children: [
                  for (
                    int i = 0;
                    i < boxes.length;
                    i++
                  ) ...[
                    Expanded(
                      child: boxes[i],
                    ),
                    if (i != boxes.length - 1)
                      const SizedBox(
                        width: 8,
                      ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // INFO BOX
  // ==========================================================================

  Widget _infoBox(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      width: 150,
      padding:
          const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            const Color(0x0BFFFFFF),
        borderRadius:
            BorderRadius.circular(11),
        border: Border.all(
          color:
              const Color(0x18FFFFFF),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 9),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color:
                      Color(0xFF64748B),
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w800,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // INPUT CARD
  // ==========================================================================

  Widget _buildInputCard() {
    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color:
                      const Color(0x1400E5FF),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: cyan,
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              const Expanded(
                child: Text(
                  'Input Configuration',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          LayoutBuilder(
            builder: (
              context,
              constraints,
            ) {
              final compact =
                  constraints.maxWidth < 760;

              if (compact) {
                return Column(
                  children: [
                    _buildNumberField(),
                    const SizedBox(height: 10),
                    _buildGenerateButton(),
                    const SizedBox(height: 10),
                    _buildLoadButton(),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    flex: 5,
                    child:
                        _buildNumberField(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child:
                        _buildGenerateButton(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child:
                        _buildLoadButton(),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 9),

          const Row(
            children: [
              Icon(
                Icons
                    .lightbulb_outline_rounded,
                color: orange,
                size: 14,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Enter numbers separated by commas. Maximum 20 numbers.',
                  style: TextStyle(
                    color:
                        Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // NUMBER FIELD
  // ==========================================================================

  Widget _buildNumberField() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color:
            const Color(0x0AFFFFFF),
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color:
              const Color(0x22FFFFFF),
        ),
      ),
      child: TextField(
        controller: numberController,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight:
              FontWeight.w600,
        ),
        cursorColor: cyan,
        decoration:
            const InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(
            Icons.numbers_rounded,
            color: cyan,
            size: 19,
          ),
          labelText: 'Enter Numbers',
          labelStyle: TextStyle(
            color:
                Color(0xFF64748B),
            fontSize: 12,
          ),
          contentPadding:
              EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
        keyboardType:
            TextInputType.number,
      ),
    );
  }

  // ==========================================================================
  // GENERATE BUTTON
  // ==========================================================================

  Widget _buildGenerateButton() {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed:
            _generateNumbers,
        icon: const Icon(
          Icons.auto_awesome_rounded,
          size: 17,
        ),
        label: const Text(
          'GENERATE NUMBERS',
          style: TextStyle(
            fontSize: 11,
            fontWeight:
                FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        style:
            OutlinedButton.styleFrom(
          foregroundColor:
              purple,
          side: const BorderSide(
            color:
                Color(0x559C27FF),
          ),
          backgroundColor:
              const Color(0x0D9C27FF),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              10,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // LOAD BUTTON
  // ==========================================================================

  Widget _buildLoadButton() {
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _loadArray,
        icon: const Icon(
          Icons
              .playlist_add_check_rounded,
          size: 17,
        ),
        label: const Text(
          'LOAD ARRAY',
          style: TextStyle(
            fontSize: 11,
            fontWeight:
                FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        style:
            ElevatedButton.styleFrom(
          foregroundColor:
              Colors.black,
          backgroundColor:
              cyan,
          elevation: 0,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(
              10,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // WORKSPACE
  // ==========================================================================

  Widget _buildWorkspace(
    double width,
  ) {
    final mobile = width < 950;

    if (mobile) {
      return Column(
        children: [
          _buildVisualizationCard(),
          const SizedBox(height: 16),
          _buildControlsCard(),
          const SizedBox(height: 16),
          _buildCodeCard(),
          const SizedBox(height: 16),
          _buildStepsCard(),
        ],
      );
    }

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Column(
            children: [
              _buildVisualizationCard(),
              const SizedBox(height: 16),
              _buildControlsCard(),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildCodeCard(),
              const SizedBox(height: 16),
              _buildStepsCard(),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // VISUALIZATION CARD
  // ==========================================================================

  Widget _buildVisualizationCard() {
    final currentEvent =
        currentStep >= 0 &&
                currentStep < events.length
            ? events[currentStep]
            : null;

    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildPanelHeader(
            icon:
                Icons.account_tree_rounded,
            iconColor: purple,
            title:
                'Merge Sort Visualization',
            subtitle:
                'Watch elements split, compare and merge',
            trailing:
                '${array.length} ELEMENTS',
          ),

          const Divider(
            height: 1,
            color:
                Color(0x12FFFFFF),
          ),

          Padding(
            padding:
                const EdgeInsets.all(15),
            child: Column(
              children: [
                _buildLegend(),
                const SizedBox(height: 16),
                _buildArrayVisualization(),
                const SizedBox(height: 18),
                if (currentEvent != null)
                  _buildCurrentOperation(
                    currentEvent,
                  )
                else
                  _buildReadyMessage(),
                const SizedBox(height: 14),
                _buildRangeInfo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // PANEL HEADER
  // ==========================================================================

  Widget _buildPanelHeader({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String trailing,
  }) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(
        16,
        15,
        16,
        14,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration:
                BoxDecoration(
              color:
                  iconColor.withOpacity(
                0.12,
              ),
              borderRadius:
                  BorderRadius.circular(
                10,
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF64748B),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration:
                BoxDecoration(
              color:
                  const Color(0x0AFFFFFF),
              borderRadius:
                  BorderRadius.circular(
                8,
              ),
              border: Border.all(
                color:
                    const Color(0x18FFFFFF),
              ),
            ),
            child: Text(
              trailing,
              style:
                  const TextStyle(
                color:
                    Color(0xFF94A3B8),
                fontSize: 9,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // LEGEND
  // ==========================================================================

  Widget _buildLegend() {
    return Wrap(
      spacing: 13,
      runSpacing: 8,
      children: [
        _legendItem(
          'Ready',
          const Color(0xFF334155),
        ),
        _legendItem(
          'Left',
          cyan,
        ),
        _legendItem(
          'Right',
          orange,
        ),
        _legendItem(
          'Comparing',
          pink,
        ),
        _legendItem(
          'Merged',
          green,
        ),
      ],
    );
  }

  Widget _legendItem(
    String text,
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
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          text,
          style:
              const TextStyle(
            color:
                Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // ARRAY
  // ==========================================================================

  Widget _buildArrayVisualization() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 10,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0x08000000),
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color:
              const Color(0x12FFFFFF),
        ),
      ),
      child:
          SingleChildScrollView(
        scrollDirection:
            Axis.horizontal,
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children:
              List.generate(
            workingArray.length,
            (index) {
              return _buildArrayItem(
                index,
                workingArray[index],
              );
            },
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // ARRAY ITEM
  // ==========================================================================

  Widget _buildArrayItem(
    int index,
    int value,
  ) {
    final event =
        currentStep >= 0 &&
                currentStep < events.length
            ? events[currentStep]
            : null;

    final isActive =
        event?.activeIndices
                .contains(index) ??
            false;

    final isLeft =
        event?.leftIndex == index;

    final isRight =
        event?.rightIndex == index;

    final isInRange =
        rangeStart >= 0 &&
            rangeEnd >= 0 &&
            index >= rangeStart &&
            index <= rangeEnd;

    final isMerged =
        event?.type ==
                MergeEventType.merged &&
            isInRange;

    Color borderColor =
        const Color(0x24FFFFFF);

    Color fillColor =
        const Color(0x0DFFFFFF);

    Color valueColor =
        Colors.white;

    if (isMerged) {
      borderColor = green;
      fillColor =
          const Color(0x1600E676);
      valueColor = green;
    } else if (isActive) {
      if (isLeft) {
        borderColor = cyan;
        fillColor =
            const Color(0x1800E5FF);
        valueColor = cyan;
      } else if (isRight) {
        borderColor = orange;
        fillColor =
            const Color(0x18FFB300);
        valueColor = orange;
      } else {
        borderColor = pink;
        fillColor =
            const Color(0x18FF4081);
        valueColor = pink;
      }
    } else if (isInRange) {
      borderColor =
          const Color(0x337C3AED);
      fillColor =
          const Color(0x0D7C3AED);
    }

    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 4,
      ),
      child: Column(
        children: [
          Text(
            '[$index]',
            style: TextStyle(
              color: isActive
                  ? valueColor
                  : const Color(
                      0xFF64748B,
                    ),
              fontSize: 9,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          AnimatedContainer(
            duration:
                const Duration(
              milliseconds: 220,
            ),
            width: 58,
            height: 64,
            decoration:
                BoxDecoration(
              color: fillColor,
              borderRadius:
                  BorderRadius.circular(
                11,
              ),
              border: Border.all(
                color: borderColor,
                width:
                    isActive ||
                            isMerged
                        ? 1.5
                        : 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color:
                            borderColor
                                .withOpacity(
                          0.18,
                        ),
                        blurRadius: 14,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '$value',
                style: TextStyle(
                  color: valueColor,
                  fontSize: 17,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CURRENT OPERATION
  // ==========================================================================

  Widget _buildCurrentOperation(
    MergeSortEvent event,
  ) {
    final Color color;

    switch (event.type) {
      case MergeEventType.split:
        color = purple;
        break;

      case MergeEventType.compare:
        color = pink;
        break;

      case MergeEventType.takeLeft:
      case MergeEventType.appendLeft:
        color = cyan;
        break;

      case MergeEventType.takeRight:
      case MergeEventType.appendRight:
        color = orange;
        break;

      case MergeEventType.merged:
      case MergeEventType.complete:
        color = green;
        break;
    }

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(13),
      decoration:
          BoxDecoration(
        color:
            color.withOpacity(0.07),
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color:
              color.withOpacity(
            0.22,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration:
                BoxDecoration(
              color:
                  color.withOpacity(
                0.13,
              ),
              borderRadius:
                  BorderRadius.circular(
                9,
              ),
            ),
            child: Icon(
              _eventIcon(
                event.type,
              ),
              color: color,
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
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
                        style:
                            TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            color.withOpacity(
                          0.10,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          5,
                        ),
                      ),
                      child: Text(
                        event.operation,
                        style:
                            TextStyle(
                          color: color,
                          fontSize: 8,
                          fontWeight:
                              FontWeight
                                  .w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  event.description,
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF94A3B8),
                    fontSize: 10,
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

  // ==========================================================================
  // READY
  // ==========================================================================

  Widget _buildReadyMessage() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration:
          BoxDecoration(
        color:
            const Color(0x0800E5FF),
        borderRadius:
            BorderRadius.circular(
          11,
        ),
        border: Border.all(
          color:
              const Color(0x1800E5FF),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons
                .play_circle_outline_rounded,
            color: cyan,
            size: 21,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Ready to start Merge Sort. Press Play or Next Step.',
              style: TextStyle(
                color:
                    Color(0xFF94A3B8),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // RANGE INFO
  // ==========================================================================

  Widget _buildRangeInfo() {
    final hasRange =
        rangeStart >= 0 &&
            rangeEnd >= 0;

    return Row(
      children: [
        Expanded(
          child: _smallStatus(
            'CURRENT RANGE',
            hasRange
                ? '[$rangeStart ... $rangeEnd]'
                : '—',
            purple,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _smallStatus(
            'MIDDLE',
            currentMid?.toString() ??
                '—',
            cyan,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _smallStatus(
            'STEP',
            currentStep < 0
                ? '0 / ${events.length}'
                : '${currentStep + 1} / ${events.length}',
            orange,
          ),
        ),
      ],
    );
  }

  Widget _smallStatus(
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 9,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0x08000000),
        borderRadius:
            BorderRadius.circular(9),
        border: Border.all(
          color:
              const Color(0x12FFFFFF),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                const TextStyle(
              color:
                  Color(0xFF475569),
              fontSize: 8,
              fontWeight:
                  FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // EVENT ICON
  // ==========================================================================

  IconData _eventIcon(
    MergeEventType type,
  ) {
    switch (type) {
      case MergeEventType.split:
        return Icons
            .call_split_rounded;

      case MergeEventType.compare:
        return Icons
            .compare_arrows_rounded;

      case MergeEventType.takeLeft:
        return Icons
            .keyboard_double_arrow_left_rounded;

      case MergeEventType.takeRight:
        return Icons
            .keyboard_double_arrow_right_rounded;

      case MergeEventType.appendLeft:
      case MergeEventType.appendRight:
        return Icons.add_rounded;

      case MergeEventType.merged:
        return Icons.merge_rounded;

      case MergeEventType.complete:
        return Icons
            .check_circle_outline_rounded;
    }
  }

  // ==========================================================================
  // CONTROLS
  // ==========================================================================

  Widget _buildControlsCard() {
    final progress =
        events.isEmpty
            ? 0.0
            : currentStep < 0
                ? 0.0
                : (currentStep + 1) /
                    events.length;

    return _card(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.tune_rounded,
                color: cyan,
                size: 19,
              ),
              const SizedBox(width: 9),
              const Text(
                'Visualization Controls',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style:
                    const TextStyle(
                  color: cyan,
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius:
                BorderRadius.circular(
              4,
            ),
            child:
                LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor:
                  const Color(
                0x14FFFFFF,
              ),
              valueColor:
                  const AlwaysStoppedAnimation<
                      Color>(
                cyan,
              ),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              _controlButton(
                icon:
                    Icons.first_page_rounded,
                tooltip: 'Reset',
                onPressed: _reset,
              ),
              const SizedBox(width: 7),
              _controlButton(
                icon:
                    Icons.chevron_left_rounded,
                tooltip:
                    'Previous Step',
                onPressed:
                    currentStep >= 0
                        ? _previousStep
                        : null,
              ),
              const SizedBox(width: 7),

              Expanded(
                child: SizedBox(
                  height: 42,
                  child:
                      ElevatedButton.icon(
                    onPressed: isRunning
                        ? _pause
                        : _play,
                    icon: Icon(
                      isRunning
                          ? Icons.pause_rounded
                          : Icons
                              .play_arrow_rounded,
                      size: 19,
                    ),
                    label: Text(
                      isRunning
                          ? 'PAUSE'
                          : 'PLAY',
                      style:
                          const TextStyle(
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    style:
                        ElevatedButton
                            .styleFrom(
                      foregroundColor:
                          Colors.black,
                      backgroundColor:
                          cyan,
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

              const SizedBox(width: 7),

              _controlButton(
                icon:
                    Icons.chevron_right_rounded,
                tooltip:
                    'Next Step',
                onPressed:
                    currentStep <
                            events.length -
                                1
                        ? _nextStep
                        : null,
              ),

              const SizedBox(width: 7),

              _controlButton(
                icon:
                    Icons.refresh_rounded,
                tooltip:
                    'Restart',
                onPressed: _reset,
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(
                Icons.speed_rounded,
                color:
                    Color(0xFF64748B),
                size: 17,
              ),
              const SizedBox(width: 8),
              const Text(
                'Speed',
                style:
                    TextStyle(
                  color:
                      Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
              Expanded(
                child: Slider(
                  value: speed,
                  min: 0.5,
                  max: 3,
                  divisions: 5,
                  activeColor: cyan,
                  inactiveColor:
                      const Color(
                    0x22FFFFFF,
                  ),
                  onChanged:
                      _setSpeed,
                ),
              ),
              SizedBox(
                width: 44,
                child: Text(
                  '${speed.toStringAsFixed(1)}x',
                  textAlign:
                      TextAlign.center,
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

  // ==========================================================================
  // CONTROL BUTTON
  // ==========================================================================

  Widget _controlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 42,
        height: 42,
        child: OutlinedButton(
          onPressed:
              onPressed,
          style:
              OutlinedButton.styleFrom(
            foregroundColor:
                onPressed == null
                    ? const Color(
                        0xFF334155,
                      )
                    : const Color(
                        0xFFCBD5E1,
                      ),
            side:
                const BorderSide(
              color:
                  Color(0x22FFFFFF),
            ),
            backgroundColor:
                const Color(
              0x08FFFFFF,
            ),
            padding: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                9,
              ),
            ),
          ),
          child: Icon(
            icon,
            size: 19,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // SOURCE CODE
  // ==========================================================================

  Widget _buildCodeCard() {
    final activeLine =
        _activeCodeLine();

    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              15,
              12,
              14,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0x149C27FF,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      9,
                    ),
                  ),
                  child: const Icon(
                    Icons.code_rounded,
                    color: purple,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'Source Code',
                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Dart implementation',
                        style:
                            TextStyle(
                          color:
                              Color(
                            0xFF64748B,
                          ),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed:
                      _copyCode,
                  tooltip:
                      'Copy Code',
                  icon: const Icon(
                    Icons.copy_rounded,
                    color: cyan,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            color:
                Color(0x12FFFFFF),
          ),

          Container(
            height: 390,
            width: double.infinity,
            color:
                const Color(
              0x06000000,
            ),
            child: Scrollbar(
              child:
                  ListView.builder(
                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 10,
                ),
                itemCount:
                    codeLines.length,
                itemBuilder:
                    (
                  context,
                  index,
                ) {
                  final lineNumber =
                      index + 1;

                  final isActive =
                      activeLine ==
                          lineNumber;

                  return _buildCodeLine(
                    lineNumber,
                    codeLines[index],
                    isActive,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ACTIVE CODE LINE
  // ==========================================================================

  int _activeCodeLine() {
    if (currentStep < 0 ||
        currentStep >=
            events.length) {
      return 0;
    }

    final type =
        events[currentStep].type;

    switch (type) {
      case MergeEventType.split:
        return 4;

      case MergeEventType.compare:
        return 25;

      case MergeEventType.takeLeft:
        return 26;

      case MergeEventType.takeRight:
        return 29;

      case MergeEventType.appendLeft:
        return 34;

      case MergeEventType.appendRight:
        return 39;

      case MergeEventType.merged:
        return 43;

      case MergeEventType.complete:
        return 10;
    }
  }

  // ==========================================================================
  // CODE LINE
  // ==========================================================================

  Widget _buildCodeLine(
    int number,
    String text,
    bool active,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 9,
      ),
      color: active
          ? const Color(
              0x1600E5FF,
            )
          : Colors.transparent,
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$number',
              textAlign:
                  TextAlign.right,
              style: TextStyle(
                color: active
                    ? cyan
                    : const Color(
                        0xFF334155,
                      ),
                fontSize: 9,
                fontFamily:
                    'monospace',
              ),
            ),
          ),

          const SizedBox(width: 10),

          if (active)
            Container(
              width: 2,
              height: 15,
              margin:
                  const EdgeInsets.only(
                right: 7,
                top: 1,
              ),
              decoration:
                  BoxDecoration(
                color: cyan,
                borderRadius:
                    BorderRadius.circular(
                  2,
                ),
              ),
            ),

          Expanded(
            child: Text(
              text.isEmpty
                  ? ' '
                  : text,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : const Color(
                        0xFF94A3B8,
                      ),
                fontSize: 10,
                height: 1.45,
                fontFamily:
                    'monospace',
                fontWeight: active
                    ? FontWeight.w700
                    : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // EXECUTION STEPS
  //
  // IMPORTANT:
  // Only executionHistory is displayed.
  // Therefore initial screen = EMPTY.
  // ==========================================================================

  Widget _buildStepsCard() {
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.fromLTRB(
              16,
              15,
              16,
              14,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0x1400E676,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      9,
                    ),
                  ),
                  child: const Icon(
                    Icons
                        .list_alt_rounded,
                    color: green,
                    size: 19,
                  ),
                ),

                const SizedBox(width: 10),

                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'Execution Steps',
                        style:
                            TextStyle(
                          color:
                              Colors.white,
                          fontSize: 14,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Live process log',
                        style:
                            TextStyle(
                          color:
                              Color(
                            0xFF64748B,
                          ),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0x0AFFFFFF,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      6,
                    ),
                  ),
                  child: Text(
                    '${executionHistory.length}',
                    style:
                        const TextStyle(
                      color:
                          Color(
                        0xFF94A3B8,
                      ),
                      fontSize: 9,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(
            height: 1,
            color:
                Color(0x12FFFFFF),
          ),

          SizedBox(
            height: 330,
            child: executionHistory
                    .isEmpty
                ? _buildEmptySteps()
                : ListView.builder(
                    padding:
                        const EdgeInsets
                            .all(
                      10,
                    ),
                    itemCount:
                        executionHistory
                            .length,
                    itemBuilder:
                        (
                      context,
                      index,
                    ) {
                      final event =
                          executionHistory[
                              index];

                      return _buildLiveStepItem(
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

  // ==========================================================================
  // EMPTY EXECUTION STEPS
  // ==========================================================================

  Widget _buildEmptySteps() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0x0D00E5FF,
                ),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child: const Icon(
                Icons
                    .play_circle_outline_rounded,
                color: cyan,
                size: 25,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No steps executed yet',
              style:
                  TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Press PLAY or NEXT STEP to start the algorithm.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    Color(0xFF64748B),
                fontSize: 10,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // LIVE STEP ITEM
  // ==========================================================================

  Widget _buildLiveStepItem(
    int index,
    MergeSortEvent event,
  ) {
    final isLatest =
        index ==
            executionHistory.length -
                1;

    final Color color;

    switch (event.type) {
      case MergeEventType.split:
        color = purple;
        break;

      case MergeEventType.compare:
        color = pink;
        break;

      case MergeEventType.takeLeft:
      case MergeEventType.appendLeft:
        color = cyan;
        break;

      case MergeEventType.takeRight:
      case MergeEventType.appendRight:
        color = orange;
        break;

      case MergeEventType.merged:
      case MergeEventType.complete:
        color = green;
        break;
    }

    return AnimatedContainer(
      duration:
          const Duration(
        milliseconds: 180,
      ),
      margin:
          const EdgeInsets.only(
        bottom: 7,
      ),
      padding:
          const EdgeInsets.all(9),
      decoration:
          BoxDecoration(
        color: isLatest
            ? color.withOpacity(
                0.08,
              )
            : const Color(
                0x05000000,
              ),
        borderRadius:
            BorderRadius.circular(
          9,
        ),
        border: Border.all(
          color: isLatest
              ? color.withOpacity(
                  0.35,
                )
              : const Color(
                  0x0DFFFFFF,
                ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration:
                BoxDecoration(
              color:
                  color.withOpacity(
                0.12,
              ),
              borderRadius:
                  BorderRadius.circular(
                7,
              ),
            ),
            child: Center(
              child: Icon(
                isLatest
                    ? Icons
                        .play_arrow_rounded
                    : Icons
                        .check_rounded,
                color: color,
                size: 14,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets
                              .symmetric(
                        horizontal: 5,
                        vertical: 3,
                      ),
                      decoration:
                          BoxDecoration(
                        color:
                            color.withOpacity(
                          0.10,
                        ),
                        borderRadius:
                            BorderRadius
                                .circular(
                          4,
                        ),
                      ),
                      child: Text(
                        'STEP ${index + 1}',
                        style:
                            TextStyle(
                          color: color,
                          fontSize: 7,
                          fontWeight:
                              FontWeight
                                  .w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        event.title,
                        style:
                            TextStyle(
                          color:
                              isLatest
                                  ? Colors
                                      .white
                                  : const Color(
                                      0xFFCBD5E1,
                                    ),
                          fontSize: 10,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  event.description,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF64748B,
                    ),
                    fontSize: 9,
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

  // ==========================================================================
  // CARD
  // ==========================================================================

  Widget _card({
    required Widget child,
    EdgeInsetsGeometry padding =
        const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration:
          BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(
          15,
        ),
        border: Border.all(
          color:
              const Color(0x16FFFFFF),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.18,
            ),
            blurRadius: 18,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}