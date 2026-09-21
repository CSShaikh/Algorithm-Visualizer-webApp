import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TwoPointerScreen extends StatefulWidget {
  const TwoPointerScreen({super.key});

  @override
  State<TwoPointerScreen> createState() => _TwoPointerScreenState();
}

// ============================================================================
// EVENT TYPES
// ============================================================================

enum TwoPointerEventType {
  initialize,
  compare,
  moveLeft,
  moveRight,
  found,
  complete,
}

// ============================================================================
// EVENT MODEL
// ============================================================================

class TwoPointerEvent {
  final TwoPointerEventType type;
  final List<int> array;
  final int index;
  final int secondIndex;
  final int firstValue;
  final int secondValue;
  final int sortedCount;
  final String title;
  final String description;
  final String operation;

  const TwoPointerEvent({
    required this.type,
    required this.array,
    required this.index,
    required this.secondIndex,
    required this.firstValue,
    required this.secondValue,
    required this.sortedCount,
    required this.title,
    required this.description,
    required this.operation,
  });
}

// ============================================================================
// STATE
// ============================================================================

class _TwoPointerScreenState extends State<TwoPointerScreen> {
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
  static const Color red = Color(0xFFFF5252);

  List<int> array = [1, 2, 3, 4, 6, 8, 9];
  List<int> originalArray = [1, 2, 3, 4, 6, 8, 9];

  final TextEditingController arrayController = TextEditingController(
    text: '1, 2, 3, 4, 6, 8, 9',
  );

  final TextEditingController targetController = TextEditingController(
    text: '10',
  );

  List<TwoPointerEvent> events = [];
  List<TwoPointerEvent> executionHistory = [];

  int currentStep = 0;
  bool isRunning = false;
  bool isCompleted = false;
  double speed = 1.0;
  Timer? timer;

  int comparingIndex = -1;
  int secondComparingIndex = -1;
  int swappingIndex = -1;
  int secondSwappingIndex = -1;
  int sortedCount = 0;
  Set<int> sortedIndexes = {};
  int activeCodeLine = 0;
  String executionMessage = 'Ready to start Two Pointer Search.';
  bool pairFound = false;
  int target = 10;

  final String sourceCode = '''
List<int> twoPointerSearch(int[] arr, int target) {
  int left = 0;
  int right = arr.length - 1;

  while (left < right) {
    int sum = arr[left] + arr[right];

    if (sum == target) {
      return [arr[left], arr[right]];
    }

    if (sum < target) {
      left++;
    } else {
      right--;
    }
  }

  return [];
}
''';

  @override
  void initState() {
    super.initState();
    originalArray = [...array];
    _generateEvents();
  }

  @override
  void dispose() {
    timer?.cancel();
    arrayController.dispose();
    targetController.dispose();
    super.dispose();
  }

  void _generateEvents() {
    final working = [...array]..sort();
    final generated = <TwoPointerEvent>[];

    if (working.length < 2) {
      events = generated;
      return;
    }

    generated.add(
      TwoPointerEvent(
        type: TwoPointerEventType.initialize,
        array: [...working],
        index: 0,
        secondIndex: working.length - 1,
        firstValue: working.first,
        secondValue: working.last,
        sortedCount: 0,
        title: 'Two Pointer Initialized',
        description:
            'Start with one pointer at the beginning and one at the end of the sorted array.',
        operation: 'left = 0, right = arr.length - 1',
      ),
    );

    int left = 0;
    int right = working.length - 1;
    int found = 0;

    while (left < right) {
      final leftValue = working[left];
      final rightValue = working[right];
      final sum = leftValue + rightValue;

      generated.add(
        TwoPointerEvent(
          type: TwoPointerEventType.compare,
          array: [...working],
          index: left,
          secondIndex: right,
          firstValue: leftValue,
          secondValue: rightValue,
          sortedCount: found,
          title: 'Compare Two Pointers',
          description:
              '$leftValue + $rightValue = $sum. Compare the sum with target $target.',
          operation: 'sum = arr[$left] + arr[$right] = $sum',
        ),
      );

      if (sum == target) {
        found = 1;
        generated.add(
          TwoPointerEvent(
            type: TwoPointerEventType.found,
            array: [...working],
            index: left,
            secondIndex: right,
            firstValue: leftValue,
            secondValue: rightValue,
            sortedCount: found,
            title: 'Pair Found',
            description:
                '$leftValue + $rightValue = $target, so the target pair is found.',
            operation: 'sum == target',
          ),
        );
        break;
      }

      if (sum < target) {
        generated.add(
          TwoPointerEvent(
            type: TwoPointerEventType.moveLeft,
            array: [...working],
            index: left,
            secondIndex: right,
            firstValue: leftValue,
            secondValue: rightValue,
            sortedCount: found,
            title: 'Move Left Pointer',
            description:
                '$sum is smaller than $target, so move the left pointer to the right.',
            operation: 'left++',
          ),
        );
        left++;
      } else {
        generated.add(
          TwoPointerEvent(
            type: TwoPointerEventType.moveRight,
            array: [...working],
            index: left,
            secondIndex: right,
            firstValue: leftValue,
            secondValue: rightValue,
            sortedCount: found,
            title: 'Move Right Pointer',
            description:
                '$sum is greater than $target, so move the right pointer to the left.',
            operation: 'right--',
          ),
        );
        right--;
      }
    }

    generated.add(
      TwoPointerEvent(
        type: TwoPointerEventType.complete,
        array: [...working],
        index: -1,
        secondIndex: -1,
        firstValue: -1,
        secondValue: -1,
        sortedCount: found,
        title: 'Two Pointer Search Complete',
        description: found == 1
            ? 'The target pair has been found.'
            : 'No pair with the target sum exists in this array.',
        operation: 'Search completed',
      ),
    );

    events = generated;
  }

  // ==========================================================================
  // LOAD ARRAY
  // ==========================================================================

  void _loadArray() {
    final text = arrayController.text.trim();
    final parsedTarget = int.tryParse(targetController.text.trim());

    if (text.isEmpty) {
      _showSnackBar('Please enter numbers.', red);
      return;
    }
    if (parsedTarget == null) {
      _showSnackBar('Please enter a valid target.', red);
      return;
    }

    final values = <int>[];
    for (final part in text.split(RegExp(r'[\s,]+'))) {
      final value = int.tryParse(part);
      if (value != null) values.add(value);
    }

    if (values.length < 2) {
      _showSnackBar('Enter at least two numbers.', red);
      return;
    }

    values.sort();
    timer?.cancel();

    setState(() {
      array = [...values];
      originalArray = [...values];
      target = parsedTarget;
      arrayController.text = values.join(', ');
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      comparingIndex = -1;
      secondComparingIndex = -1;
      swappingIndex = -1;
      secondSwappingIndex = -1;
      sortedCount = 0;
      sortedIndexes.clear();
      activeCodeLine = 0;
      pairFound = false;
      executionMessage = 'Array loaded. Ready to search for target $target.';
    });

    _generateEvents();
    _showSnackBar('Array loaded and sorted for Two Pointer Search.', green);
  }

  void _generateNumbers() {
    final random = Random();
    final generated = List.generate(8, (_) => random.nextInt(90) + 10)..sort();
    final generatedTarget = generated.first + generated.last;

    arrayController.text = generated.join(', ');
    targetController.text = generatedTarget.toString();
    timer?.cancel();

    setState(() {
      array = [...generated];
      originalArray = [...generated];
      target = generatedTarget;
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      comparingIndex = -1;
      secondComparingIndex = -1;
      swappingIndex = -1;
      secondSwappingIndex = -1;
      sortedCount = 0;
      sortedIndexes.clear();
      activeCodeLine = 0;
      pairFound = false;
      executionMessage = 'New sorted numbers generated. Ready to search.';
    });

    _generateEvents();
    _showSnackBar('New numbers and target generated.', purple);
  }

  void _play() {
    if (events.isEmpty || isCompleted) return;
    timer?.cancel();
    setState(() => isRunning = true);
    final milliseconds = (900 / speed).round().clamp(100, 2000);
    timer = Timer.periodic(Duration(milliseconds: milliseconds), (_) {
      if (!mounted) {
        timer?.cancel();
        return;
      }
      if (currentStep >= events.length) {
        timer?.cancel();
        setState(() {
          isRunning = false;
          isCompleted = true;
        });
        return;
      }
      _nextStepInternal();
    });
  }

  void _pause() {
    timer?.cancel();
    if (!mounted) return;
    setState(() => isRunning = false);
  }

  void _togglePlayPause() {
    if (isRunning) {
      _pause();
    } else {
      _play();
    }
  }

  void _nextStep() {
    if (currentStep >= events.length) return;
    _nextStepInternal();
  }

  void _nextStepInternal() {
    if (currentStep >= events.length) return;
    final event = events[currentStep];
    executionHistory.add(event);
    currentStep++;
    _applyEvent(event);
    if (currentStep >= events.length) {
      timer?.cancel();
      setState(() {
        isRunning = false;
        isCompleted = true;
      });
    }
  }

  void _previousStep() {
    if (executionHistory.isEmpty) return;
    timer?.cancel();
    executionHistory.removeLast();
    currentStep = executionHistory.length;
    _rebuildVisualState();
    setState(() {
      isRunning = false;
      isCompleted = false;
    });
  }

  void _rebuildVisualState() {
    array = [...originalArray];
    comparingIndex = -1;
    secondComparingIndex = -1;
    swappingIndex = -1;
    secondSwappingIndex = -1;
    sortedCount = 0;
    sortedIndexes.clear();
    activeCodeLine = 0;
    pairFound = false;
    executionMessage = 'Ready to start Two Pointer Search.';
    for (final event in executionHistory) {
      _applyEvent(event, updateState: false);
    }
  }

  void _applyEvent(TwoPointerEvent event, {bool updateState = true}) {
    array = [...event.array];
    comparingIndex = -1;
    secondComparingIndex = -1;
    swappingIndex = -1;
    secondSwappingIndex = -1;
    sortedCount = event.sortedCount;
    executionMessage = '${event.title}: ${event.description}';
    activeCodeLine = _codeLineForEvent(event.type);

    if (event.type == TwoPointerEventType.compare ||
        event.type == TwoPointerEventType.moveLeft ||
        event.type == TwoPointerEventType.moveRight ||
        event.type == TwoPointerEventType.found) {
      comparingIndex = event.index;
      secondComparingIndex = event.secondIndex;
    }

    if (event.type == TwoPointerEventType.found) {
      pairFound = true;
      if (event.index >= 0) sortedIndexes.add(event.index);
      if (event.secondIndex >= 0) sortedIndexes.add(event.secondIndex);
    }

    if (event.type == TwoPointerEventType.complete) {
      pairFound = event.sortedCount > 0;
      comparingIndex = -1;
      secondComparingIndex = -1;
      swappingIndex = -1;
      secondSwappingIndex = -1;
      executionMessage = event.description;
    }

    if (updateState) setState(() {});
  }

  void _reset() {
    timer?.cancel();
    setState(() {
      array = [...originalArray];
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      comparingIndex = -1;
      secondComparingIndex = -1;
      swappingIndex = -1;
      secondSwappingIndex = -1;
      sortedCount = 0;
      sortedIndexes.clear();
      activeCodeLine = 0;
      pairFound = false;
      executionMessage = 'Ready to start Two Pointer Search.';
    });
    _generateEvents();
  }

  void _setSpeed(double value) {
    setState(() => speed = value);
    if (isRunning) _play();
  }

  int _codeLineForEvent(TwoPointerEventType type) {
    switch (type) {
      case TwoPointerEventType.initialize:
        return 2;
      case TwoPointerEventType.compare:
        return 7;
      case TwoPointerEventType.moveLeft:
        return 14;
      case TwoPointerEventType.moveRight:
        return 16;
      case TwoPointerEventType.found:
        return 10;
      case TwoPointerEventType.complete:
        return 20;
    }
  }

  Color _eventColor(TwoPointerEventType type) {
    switch (type) {
      case TwoPointerEventType.initialize:
        return blue;
      case TwoPointerEventType.compare:
        return cyan;
      case TwoPointerEventType.moveLeft:
        return orange;
      case TwoPointerEventType.moveRight:
        return pink;
      case TwoPointerEventType.found:
        return green;
      case TwoPointerEventType.complete:
        return green;
    }
  }

  IconData _eventIcon(TwoPointerEventType type) {
    switch (type) {
      case TwoPointerEventType.initialize:
        return Icons.play_arrow_rounded;
      case TwoPointerEventType.compare:
        return Icons.compare_arrows_rounded;
      case TwoPointerEventType.moveLeft:
        return Icons.arrow_forward_rounded;
      case TwoPointerEventType.moveRight:
        return Icons.arrow_back_rounded;
      case TwoPointerEventType.found:
        return Icons.check_circle_rounded;
      case TwoPointerEventType.complete:
        return Icons.flag_rounded;
    }
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: sourceCode));
    _showSnackBar('Source code copied.', cyan);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color.withValues(alpha: 0.85),
        behavior: SnackBarBehavior.floating,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 16),

                  _buildAlgorithmInfo(),

                  const SizedBox(height: 16),

                  _buildInputSection(),

                  const SizedBox(height: 16),

                  _buildMainWorkspace(constraints.maxWidth),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: orange.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [orange, pink]),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.compare_arrows_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Two Pointer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Find a target pair using left and right pointers',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          _statusBadge(),
        ],
      ),
    );
  }

  // ==========================================================================
  // STATUS
  // ==========================================================================

  Widget _statusBadge() {
    Color color = cyan;

    String text = 'READY';

    if (isRunning) {
      color = orange;
      text = 'RUNNING';
    } else if (isCompleted) {
      color = green;
      text = 'FOUND';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),

          const SizedBox(width: 7),

          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.info_outline_rounded,
            'Algorithm Information',
            cyan,
          ),

          const SizedBox(height: 14),

          Text(
            'Two Pointer Search uses two indexes, one at the left '
            'and one at the right of a sorted array. The '
            'sum of the two values decides which pointer '
            'moves until the target pair is found or the '
            'pointers meet.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.64),
              height: 1.5,
              fontSize: 12.5,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoBox('Time', 'O(n)', orange),
              _infoBox('Space', 'O(1)', blue),
              _infoBox('Type', 'Searching', purple),
              _infoBox('Best', 'O(n)', green),
              _infoBox('Worst', 'O(n)', red),
              _infoBox('Input', 'Sorted', cyan),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.input_rounded, 'Input', cyan),

          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) {
                return Column(
                  children: [
                    _inputField(),

                    const SizedBox(height: 10),

                    _targetField(),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(child: _generateButton()),

                        const SizedBox(width: 10),

                        Expanded(child: _loadButton()),
                      ],
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _inputField()),

                  const SizedBox(width: 10),

                  SizedBox(width: 130, height: 46, child: _targetField()),

                  const SizedBox(width: 10),

                  SizedBox(height: 46, child: _generateButton()),

                  const SizedBox(width: 10),

                  SizedBox(height: 46, child: _loadButton()),
                ],
              );
            },
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: orange.withValues(alpha: 0.85),
                size: 15,
              ),

              const SizedBox(width: 7),

              Expanded(
                child: Text(
                  'Enter numbers and a target sum. The app sorts the input before the search.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
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
  // INPUT FIELD
  // ==========================================================================

  Widget _inputField() {
    return TextField(
      controller: arrayController,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      cursorColor: cyan,
      decoration: InputDecoration(
        labelText: 'Enter Numbers',
        hintText: '1, 2, 3, 4, 6, 8, 9...',
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.58),
          fontSize: 12,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.25),
          fontSize: 12,
        ),
        prefixIcon: Icon(
          Icons.data_array_rounded,
          color: cyan.withValues(alpha: 0.8),
          size: 19,
        ),
        filled: true,
        fillColor: visualizationColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cyan.withValues(alpha: 0.55)),
        ),
      ),
    );
  }

  // ==========================================================================
  // TARGET FIELD
  // ==========================================================================

  Widget _targetField() {
    return TextField(
      controller: targetController,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      cursorColor: orange,
      decoration: InputDecoration(
        labelText: 'Target Sum',
        hintText: '10',
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.58),
          fontSize: 12,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.25),
          fontSize: 12,
        ),
        prefixIcon: Icon(
          Icons.track_changes_rounded,
          color: orange.withValues(alpha: 0.8),
          size: 19,
        ),
        filled: true,
        fillColor: visualizationColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: orange.withValues(alpha: 0.55)),
        ),
      ),
    );
  }

  // ==========================================================================
  // GENERATE
  // ==========================================================================

  Widget _generateButton() {
    return ElevatedButton.icon(
      onPressed: _generateNumbers,
      icon: const Icon(Icons.auto_awesome_rounded, size: 17),
      label: const Text(
        'Generate Numbers',
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: purple,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ==========================================================================
  // LOAD
  // ==========================================================================

  Widget _loadButton() {
    return ElevatedButton.icon(
      onPressed: _loadArray,
      icon: const Icon(Icons.download_rounded, size: 17),
      label: const Text(
        'LOAD ARRAY',
        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: cyan,
        foregroundColor: background,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ==========================================================================
  // WORKSPACE
  // ==========================================================================

  Widget _buildMainWorkspace(double width) {
    if (width < 900) {
      return Column(
        children: [
          _buildVisualization(),

          const SizedBox(height: 14),

          _buildControls(),

          const SizedBox(height: 14),

          _buildSourceCode(),

          const SizedBox(height: 14),

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
              _buildVisualization(),

              const SizedBox(height: 14),

              _buildControls(),
            ],
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildSourceCode(),

              const SizedBox(height: 14),

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.bar_chart_rounded, 'Visualization', cyan),

          const SizedBox(height: 12),

          Row(
            children: [
              _miniBadge(
                'LEFT',
                comparingIndex >= 0 ? '$comparingIndex' : '-',
                cyan,
              ),

              const SizedBox(width: 8),

              _miniBadge(
                'RIGHT',
                secondComparingIndex >= 0 ? '$secondComparingIndex' : '-',
                blue,
              ),

              const SizedBox(width: 8),

              _miniBadge('FOUND', sortedIndexes.length.toString(), green),

              const SizedBox(width: 8),

              _miniBadge('STEPS', executionHistory.length.toString(), purple),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
            decoration: BoxDecoration(
              color: visualizationColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  array.length,
                  (index) => _buildArrayItem(index),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          _buildLegend(),

          const SizedBox(height: 12),

          _buildCurrentInfo(),

          const SizedBox(height: 12),

          _buildStatusCard(),
        ],
      ),
    );
  }

  // ==========================================================================
  // ARRAY ITEM
  // ==========================================================================

  Widget _buildArrayItem(int index) {
    final value = array[index];

    final bool isComparing =
        index == comparingIndex || index == secondComparingIndex;

    final bool isSwapping =
        index == swappingIndex || index == secondSwappingIndex;

    final bool isSorted = sortedIndexes.contains(index);

    Color itemColor = Colors.white.withValues(alpha: 0.08);

    Color borderColor = Colors.white.withValues(alpha: 0.08);

    Color textColor = Colors.white;

    String label = '';

    // ------------------------------------------------------------------------
    // SORTED
    // ------------------------------------------------------------------------

    if (isSorted) {
      itemColor = green.withValues(alpha: 0.18);
      borderColor = green;
      textColor = green;
      label = 'FOUND';
    }

    // ------------------------------------------------------------------------
    // COMPARE
    // ------------------------------------------------------------------------

    if (isComparing) {
      itemColor = cyan.withValues(alpha: 0.18);
      borderColor = cyan;
      textColor = cyan;
      label = index == comparingIndex ? 'LEFT' : 'RIGHT';
    }

    // ------------------------------------------------------------------------
    // SWAP
    // ------------------------------------------------------------------------

    if (isSwapping) {
      itemColor = pink.withValues(alpha: 0.20);
      borderColor = pink;
      textColor = pink;
      label = 'MOVE';
    }

    return Container(
      width: 70,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          SizedBox(
            height: 19,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isSorted
                      ? green
                      : index == comparingIndex
                      ? cyan
                      : index == secondComparingIndex
                      ? blue
                      : Colors.white.withValues(alpha: 0.35),
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: itemColor,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: borderColor,
                width: isComparing || isSwapping || isSorted ? 1.6 : 1,
              ),
              boxShadow: isComparing || isSwapping || isSorted
                  ? [
                      BoxShadow(
                        color: borderColor.withValues(alpha: 0.18),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                value.toString(),
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(height: 5),

          Text(
            '[$index]',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w600,
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
      spacing: 14,
      runSpacing: 8,
      children: [
        _legendItem('Ready', Colors.white),
        _legendItem('Left Pointer', cyan),
        _legendItem('Right Pointer', blue),
        _legendItem('Found', green),
      ],
    );
  }

  Widget _legendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),

        const SizedBox(width: 6),

        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.58),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // CURRENT INFO
  // ==========================================================================

  Widget _buildCurrentInfo() {
    String message = 'Waiting for execution';

    if (comparingIndex >= 0 &&
        secondComparingIndex >= 0 &&
        comparingIndex < array.length &&
        secondComparingIndex < array.length) {
      message =
          'Left ${array[comparingIndex]} + Right ${array[secondComparingIndex]} = ${array[comparingIndex] + array[secondComparingIndex]} (target $target)';
    }

    if (swappingIndex >= 0 &&
        secondSwappingIndex >= 0 &&
        swappingIndex < array.length &&
        secondSwappingIndex < array.length) {
      message = 'Moving pointers to narrow the search';
    }

    if (isCompleted) {
      message = pairFound
          ? 'Target pair found successfully'
          : 'No matching pair found';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cyan.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cyan.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.compare_arrows_rounded,
              color: cyan,
              size: 18,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Operation',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.42),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              '$sortedCount found',
              style: const TextStyle(
                color: green,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // STATUS CARD
  // ==========================================================================

  Widget _buildStatusCard() {
    Color color = cyan;

    IconData icon = Icons.info_outline_rounded;

    if (isRunning) {
      color = orange;
      icon = Icons.play_circle_rounded;
    } else if (isCompleted) {
      color = green;
      icon = Icons.check_circle_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              executionMessage,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // CONTROLS
  // ==========================================================================

  Widget _buildControls() {
    return _card(
      child: Column(
        children: [
          Row(
            children: [
              _controlButton(
                icon: Icons.skip_previous_rounded,
                label: 'Previous',
                onPressed: executionHistory.isEmpty ? null : _previousStep,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _controlButton(
                  icon: isRunning
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  label: isRunning ? 'Pause' : 'Play',
                  onPressed: isCompleted ? null : _togglePlayPause,
                  primary: true,
                ),
              ),

              const SizedBox(width: 8),

              _controlButton(
                icon: Icons.skip_next_rounded,
                label: 'Next Step',
                onPressed: currentStep >= events.length ? null : _nextStep,
              ),

              const SizedBox(width: 8),

              _controlButton(
                icon: Icons.restart_alt_rounded,
                label: 'Reset',
                onPressed: _reset,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.speed_rounded, color: cyan, size: 17),

              const SizedBox(width: 8),

              Text(
                'Speed',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),

              Expanded(
                child: Slider(
                  value: speed,
                  min: 0.5,
                  max: 3.0,
                  divisions: 5,
                  activeColor: cyan,
                  inactiveColor: Colors.white.withValues(alpha: 0.08),
                  onChanged: _setSpeed,
                ),
              ),

              SizedBox(
                width: 48,
                child: Text(
                  '${speed.toStringAsFixed(1)}x',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: cyan,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: events.isEmpty ? 0 : currentStep / events.length,
              minHeight: 4,
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: const AlwaysStoppedAnimation<Color>(cyan),
            ),
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $currentStep / ${events.length}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 10,
                ),
              ),

              Text(
                isCompleted
                    ? 'Execution Finished'
                    : isRunning
                    ? 'Running...'
                    : currentStep == 0
                    ? 'Ready'
                    : 'Paused',
                style: TextStyle(
                  color: isCompleted
                      ? green
                      : isRunning
                      ? orange
                      : Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
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
    required String label,
    required VoidCallback? onPressed,
    bool primary = false,
  }) {
    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 17),
        label: Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? cyan : cardColor,
          foregroundColor: primary ? background : Colors.white,
          disabledBackgroundColor: Colors.white.withValues(alpha: 0.04),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.20),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
            side: BorderSide(
              color: primary ? cyan : Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // SOURCE CODE
  // ==========================================================================

  Widget _buildSourceCode() {
    final lines = sourceCode.trimRight().split('\n');

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionTitle(Icons.code_rounded, 'Source Code', purple),

              const Spacer(),

              InkWell(
                onTap: _copyCode,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: purple.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: purple.withValues(alpha: 0.20)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.copy_rounded, color: purple, size: 14),

                      SizedBox(width: 5),

                      Text(
                        'Copy',
                        style: TextStyle(
                          color: purple,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 280, maxHeight: 500),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF050A14),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(lines.length, (index) {
                  final lineNumber = index + 1;

                  final active = lineNumber == activeCodeLine;

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    color: active
                        ? cyan.withValues(alpha: 0.09)
                        : Colors.transparent,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 25,
                          child: Text(
                            '$lineNumber',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: active
                                  ? cyan
                                  : Colors.white.withValues(alpha: 0.20),
                              fontSize: 9,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            lines[index],
                            style: TextStyle(
                              color: active
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.65),
                              fontSize: 10,
                              height: 1.45,
                              fontFamily: 'monospace',
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionTitle(Icons.history_rounded, 'Execution Steps', cyan),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: cyan.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: cyan.withValues(alpha: 0.14)),
                ),
                child: Text(
                  '${executionHistory.length}',
                  style: const TextStyle(
                    color: cyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (executionHistory.isEmpty)
            _emptyExecutionState()
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 460),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: executionHistory.length,
                itemBuilder: (context, index) {
                  final event = executionHistory[index];

                  return _executionStepItem(index, event);
                },
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================================
  // EMPTY
  // ==========================================================================

  Widget _emptyExecutionState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 15),
      decoration: BoxDecoration(
        color: visualizationColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.timeline_rounded,
            color: Colors.white.withValues(alpha: 0.20),
            size: 32,
          ),

          const SizedBox(height: 10),

          Text(
            'No steps executed yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Press Next Step or Play to start the search',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.30),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // EXECUTION ITEM
  // ==========================================================================

  Widget _executionStepItem(int index, TwoPointerEvent event) {
    final color = _eventColor(event.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(_eventIcon(event.type), color: color, size: 15),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: TextStyle(
                          color: color,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    Text(
                      '#${index + 1}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.22),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  event.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.53),
                    fontSize: 9.5,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  event.operation,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.30),
                    fontSize: 8.5,
                    fontFamily: 'monospace',
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

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.065)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }

  // ==========================================================================
  // SECTION TITLE
  // ==========================================================================

  Widget _sectionTitle(IconData icon, String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 17),
        ),

        const SizedBox(width: 9),

        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // INFO BOX
  // ==========================================================================

  Widget _infoBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // MINI BADGE
  // ==========================================================================

  Widget _miniBadge(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.7,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
