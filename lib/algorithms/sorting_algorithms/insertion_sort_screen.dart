import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InsertionSortScreen extends StatefulWidget {
  const InsertionSortScreen({super.key});

  @override
  State<InsertionSortScreen> createState() => _InsertionSortScreenState();
}

// ============================================================================
// EVENT TYPE
// ============================================================================

enum InsertionSortEventType {
  initialize,
  selectKey,
  compare,
  shift,
  insert,
  sorted,
  complete,
}

// ============================================================================
// EVENT MODEL
// ============================================================================

class InsertionSortEvent {
  final InsertionSortEventType type;

  /// Exact array state that should be displayed for this event.
  final List<int> array;

  final int currentIndex;
  final int compareIndex;
  final int keyIndex;

  final int keyValue;
  final int compareValue;

  final int sortedCount;

  final String title;
  final String description;
  final String operation;

  const InsertionSortEvent({
    required this.type,
    required this.array,
    required this.currentIndex,
    required this.compareIndex,
    required this.keyIndex,
    required this.keyValue,
    required this.compareValue,
    required this.sortedCount,
    required this.title,
    required this.description,
    required this.operation,
  });
}

// ============================================================================
// STATE
// ============================================================================

class _InsertionSortScreenState extends State<InsertionSortScreen> {
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
  static const Color red = Color(0xFFFF5252);

  // ==========================================================================
  // DATA
  // ==========================================================================

  List<int> array = [64, 25, 12, 22, 11];

  /// Original array used by Reset.
  List<int> initialArray = [64, 25, 12, 22, 11];

  // ==========================================================================
  // CONTROLLER
  // ==========================================================================

  final TextEditingController arrayController = TextEditingController(
    text: '64, 25, 12, 22, 11',
  );

  // ==========================================================================
  // EVENTS
  // ==========================================================================

  List<InsertionSortEvent> events = [];

  List<InsertionSortEvent> executionHistory = [];

  // ==========================================================================
  // EXECUTION
  // ==========================================================================

  int currentStep = 0;

  bool isRunning = false;
  bool isCompleted = false;

  double speed = 1.0;

  Timer? timer;

  // ==========================================================================
  // VISUAL STATE
  // ==========================================================================

  int currentIndex = -1;
  int compareIndex = -1;
  int keyIndex = -1;

  int keyValue = -1;

  int sortedCount = 0;

  Set<int> sortedIndexes = <int>{};

  int activeCodeLine = 0;

  String executionMessage = 'Ready to start Insertion Sort.';

  // ==========================================================================
  // SOURCE CODE
  // ==========================================================================

  final String sourceCode = '''
void insertionSort(int[] arr) {
  for (int i = 1; i < arr.length; i++) {

    int key = arr[i];
    int j = i - 1;

    while (j >= 0 && arr[j] > key) {
      arr[j + 1] = arr[j];
      j--;
    }

    arr[j + 1] = key;
  }
}
''';

  // ==========================================================================
  // INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    initialArray = [...array];
    _generateEvents();
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

  @override
  void dispose() {
    timer?.cancel();
    arrayController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // GENERATE EVENTS
  // ==========================================================================

  void _generateEvents() {
    final working = [...initialArray];

    final generated = <InsertionSortEvent>[];

    if (working.isEmpty) {
      events = generated;
      return;
    }

    // ------------------------------------------------------------------------
    // INITIALIZE
    // ------------------------------------------------------------------------

    generated.add(
      InsertionSortEvent(
        type: InsertionSortEventType.initialize,
        array: [...working],
        currentIndex: -1,
        compareIndex: -1,
        keyIndex: -1,
        keyValue: -1,
        compareValue: -1,
        sortedCount: 0,
        title: 'Insertion Sort Initialized',
        description:
            'The first element is considered sorted. '
            'Each next element will be inserted into the correct position.',
        operation: 'Start Insertion Sort',
      ),
    );

    // ------------------------------------------------------------------------
    // INSERTION SORT
    // ------------------------------------------------------------------------

    for (int i = 1; i < working.length; i++) {
      final int key = working[i];

      int j = i - 1;

      // ----------------------------------------------------------------------
      // SELECT KEY
      // ----------------------------------------------------------------------

      generated.add(
        InsertionSortEvent(
          type: InsertionSortEventType.selectKey,
          array: [...working],
          currentIndex: i,
          compareIndex: -1,
          keyIndex: i,
          keyValue: key,
          compareValue: -1,
          sortedCount: i,
          title: 'Select Key',
          description:
              'Select $key as the key element to insert into the sorted part.',
          operation: 'key = arr[$i] = $key',
        ),
      );

      // ----------------------------------------------------------------------
      // COMPARE
      // ----------------------------------------------------------------------

      while (j >= 0) {
        final int compareValue = working[j];

        generated.add(
          InsertionSortEvent(
            type: InsertionSortEventType.compare,
            array: [...working],
            currentIndex: i,
            compareIndex: j,
            keyIndex: i,
            keyValue: key,
            compareValue: compareValue,
            sortedCount: i,
            title: 'Compare',
            description: 'Compare $compareValue with key $key.',
            operation: 'arr[$j] > key',
          ),
        );

        // --------------------------------------------------------------------
        // SHIFT
        // --------------------------------------------------------------------

        if (working[j] > key) {
          final int shiftedValue = working[j];

          working[j + 1] = shiftedValue;

          // IMPORTANT:
          // Store the array AFTER shifting so the visualization
          // actually shows the movement.
          generated.add(
            InsertionSortEvent(
              type: InsertionSortEventType.shift,
              array: [...working],
              currentIndex: j + 1,
              compareIndex: j,
              keyIndex: i,
              keyValue: key,
              compareValue: shiftedValue,
              sortedCount: i,
              title: 'Shift Element',
              description:
                  '$shiftedValue is greater than $key, '
                  'so shift it one position to the right.',
              operation: 'arr[${j + 1}] = arr[$j]',
            ),
          );

          j--;
        } else {
          break;
        }
      }

      // ----------------------------------------------------------------------
      // INSERT KEY
      // ----------------------------------------------------------------------

      final int insertIndex = j + 1;

      working[insertIndex] = key;

      generated.add(
        InsertionSortEvent(
          type: InsertionSortEventType.insert,
          array: [...working],
          currentIndex: insertIndex,
          compareIndex: j >= 0 ? j : -1,
          keyIndex: insertIndex,
          keyValue: key,
          compareValue: j >= 0 ? working[j] : -1,
          sortedCount: i + 1,
          title: 'Insert Key',
          description:
              'Insert key $key at index $insertIndex in the correct position.',
          operation: 'arr[$insertIndex] = key',
        ),
      );

      // ----------------------------------------------------------------------
      // SORTED
      // ----------------------------------------------------------------------

      generated.add(
        InsertionSortEvent(
          type: InsertionSortEventType.sorted,
          array: [...working],
          currentIndex: -1,
          compareIndex: -1,
          keyIndex: -1,
          keyValue: -1,
          compareValue: -1,
          sortedCount: i + 1,
          title: 'Sorted Part Expanded',
          description: 'The first ${i + 1} elements are now sorted.',
          operation: 'Sorted range: 0..$i',
        ),
      );
    }

    // ------------------------------------------------------------------------
    // COMPLETE
    // ------------------------------------------------------------------------

    generated.add(
      InsertionSortEvent(
        type: InsertionSortEventType.complete,
        array: [...working],
        currentIndex: -1,
        compareIndex: -1,
        keyIndex: -1,
        keyValue: -1,
        compareValue: -1,
        sortedCount: working.length,
        title: 'Insertion Sort Complete',
        description: 'All elements are sorted in ascending order.',
        operation: 'Sorting completed',
      ),
    );

    events = generated;
  }

  // ==========================================================================
  // LOAD ARRAY
  // ==========================================================================

  void _loadArray() {
    final text = arrayController.text.trim();

    if (text.isEmpty) {
      _showSnackBar('Please enter numbers.', red);
      return;
    }

    final parts = text.split(RegExp(r'[\s,]+'));

    final values = <int>[];

    for (final part in parts) {
      final value = int.tryParse(part);

      if (value != null) {
        values.add(value);
      }
    }

    if (values.isEmpty) {
      _showSnackBar('No valid numbers found.', red);
      return;
    }

    if (values.length > 50) {
      _showSnackBar(
        'Please enter 50 numbers or fewer.',
        orange,
      );
      return;
    }

    _loadNewValues(values);

    _showSnackBar(
      'Array loaded successfully.',
      green,
    );
  }

  // ==========================================================================
  // APPLY NEW VALUES
  // ==========================================================================

  void _loadNewValues(List<int> values) {
    timer?.cancel();

    setState(() {
      initialArray = [...values];
      array = [...values];

      executionHistory.clear();

      currentStep = 0;

      isRunning = false;
      isCompleted = false;

      currentIndex = -1;
      compareIndex = -1;
      keyIndex = -1;

      keyValue = -1;

      sortedCount = 0;
      sortedIndexes.clear();

      activeCodeLine = 0;

      executionMessage =
          'Array loaded. Ready to start Insertion Sort.';
    });

    _generateEvents();
  }

  // ==========================================================================
  // GENERATE NUMBERS
  // ==========================================================================

  void _generateNumbers() {
    final random = Random();

    final generated = List.generate(
      8,
      (_) => random.nextInt(90) + 10,
    );

    arrayController.text = generated.join(', ');

    _loadNewValues(generated);

    _showSnackBar(
      '8 random numbers generated.',
      purple,
    );
  }

  // ==========================================================================
  // PLAY
  // ==========================================================================

  void _play() {
    if (events.isEmpty || isCompleted) {
      return;
    }

    timer?.cancel();

    setState(() {
      isRunning = true;
    });

    final milliseconds = (850 / speed).round().clamp(100, 2000);

    timer = Timer.periodic(
      Duration(milliseconds: milliseconds),
      (_) {
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
      },
    );
  }

  // ==========================================================================
  // PAUSE
  // ==========================================================================

  void _pause() {
    timer?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      isRunning = false;
    });
  }

  // ==========================================================================
  // TOGGLE
  // ==========================================================================

  void _togglePlayPause() {
    if (isRunning) {
      _pause();
    } else {
      _play();
    }
  }

  // ==========================================================================
  // NEXT
  // ==========================================================================

  void _nextStep() {
    if (currentStep >= events.length) {
      return;
    }

    _nextStepInternal();
  }

  void _nextStepInternal() {
    if (currentStep >= events.length) {
      return;
    }

    final event = events[currentStep];

    executionHistory.add(event);

    currentStep++;

    _applyEvent(event);

    if (currentStep >= events.length) {
      timer?.cancel();

      if (mounted) {
        setState(() {
          isRunning = false;
          isCompleted = true;
        });
      }
    }
  }

  // ==========================================================================
  // PREVIOUS
  // ==========================================================================

  void _previousStep() {
    if (executionHistory.isEmpty) {
      return;
    }

    timer?.cancel();

    executionHistory.removeLast();

    currentStep = executionHistory.length;

    _rebuildVisualState();

    if (mounted) {
      setState(() {
        isRunning = false;
        isCompleted = false;
      });
    }
  }

  // ==========================================================================
  // REBUILD VISUAL STATE
  // ==========================================================================

  void _rebuildVisualState() {
    // Restore everything to original state first.
    array = [...initialArray];

    currentIndex = -1;
    compareIndex = -1;
    keyIndex = -1;

    keyValue = -1;

    sortedCount = 0;
    sortedIndexes.clear();

    activeCodeLine = 0;

    executionMessage = 'Ready to start Insertion Sort.';

    // Replay all executed events.
    for (final event in executionHistory) {
      _applyEvent(
        event,
        updateState: false,
      );
    }

    if (executionHistory.isEmpty) {
      array = [...initialArray];
    }
  }

  // ==========================================================================
  // APPLY EVENT
  // ==========================================================================

  void _applyEvent(
    InsertionSortEvent event, {
    bool updateState = true,
  }) {
    // IMPORTANT:
    // Every event owns an exact array snapshot.
    // Restore it before rendering the event.
    array = [...event.array];

    currentIndex = event.currentIndex;
    compareIndex = event.compareIndex;
    keyIndex = event.keyIndex;

    keyValue = event.keyValue;

    sortedCount = event.sortedCount;

    executionMessage =
        '${event.title}: ${event.description}';

    activeCodeLine = _codeLineForEvent(event.type);

    // ------------------------------------------------------------------------
    // SORTED INDEXES
    // ------------------------------------------------------------------------

    sortedIndexes.clear();

    if (event.type == InsertionSortEventType.initialize) {
      // At initialization no sorting operation has started yet.
      // Keep all items ready.
    } else {
      for (int i = 0; i < event.sortedCount; i++) {
        sortedIndexes.add(i);
      }
    }

    // ------------------------------------------------------------------------
    // COMPLETE
    // ------------------------------------------------------------------------

    if (event.type == InsertionSortEventType.complete) {
      sortedIndexes = Set<int>.from(
        List.generate(
          array.length,
          (index) => index,
        ),
      );

      currentIndex = -1;
      compareIndex = -1;
      keyIndex = -1;
      keyValue = -1;

      sortedCount = array.length;
    }

    if (updateState && mounted) {
      setState(() {});
    }
  }

  // ==========================================================================
  // RESET
  // ==========================================================================

  void _reset() {
    timer?.cancel();

    setState(() {
      array = [...initialArray];

      executionHistory.clear();

      currentStep = 0;

      isRunning = false;
      isCompleted = false;

      currentIndex = -1;
      compareIndex = -1;
      keyIndex = -1;

      keyValue = -1;

      sortedCount = 0;

      sortedIndexes.clear();

      activeCodeLine = 0;

      executionMessage =
          'Ready to start Insertion Sort.';
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
      _play();
    }
  }

  // ==========================================================================
  // CODE LINE
  // ==========================================================================

  int _codeLineForEvent(
    InsertionSortEventType type,
  ) {
    switch (type) {
      case InsertionSortEventType.initialize:
        return 1;

      case InsertionSortEventType.selectKey:
        return 4;

      case InsertionSortEventType.compare:
        return 7;

      case InsertionSortEventType.shift:
        return 8;

      case InsertionSortEventType.insert:
        return 12;

      case InsertionSortEventType.sorted:
        return 2;

      case InsertionSortEventType.complete:
        return 1;
    }
  }

  // ==========================================================================
  // EVENT COLOR
  // ==========================================================================

  Color _eventColor(
    InsertionSortEventType type,
  ) {
    switch (type) {
      case InsertionSortEventType.initialize:
        return blue;

      case InsertionSortEventType.selectKey:
        return purple;

      case InsertionSortEventType.compare:
        return cyan;

      case InsertionSortEventType.shift:
        return orange;

      case InsertionSortEventType.insert:
        return pink;

      case InsertionSortEventType.sorted:
        return green;

      case InsertionSortEventType.complete:
        return green;
    }
  }

  // ==========================================================================
  // EVENT ICON
  // ==========================================================================

  IconData _eventIcon(
    InsertionSortEventType type,
  ) {
    switch (type) {
      case InsertionSortEventType.initialize:
        return Icons.play_arrow_rounded;

      case InsertionSortEventType.selectKey:
        return Icons.push_pin_rounded;

      case InsertionSortEventType.compare:
        return Icons.compare_arrows_rounded;

      case InsertionSortEventType.shift:
        return Icons.arrow_forward_rounded;

      case InsertionSortEventType.insert:
        return Icons.input_rounded;

      case InsertionSortEventType.sorted:
        return Icons.check_circle_rounded;

      case InsertionSortEventType.complete:
        return Icons.flag_rounded;
    }
  }

  // ==========================================================================
  // COPY
  // ==========================================================================

  Future<void> _copyCode() async {
    await Clipboard.setData(
      ClipboardData(text: sourceCode),
    );

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
        backgroundColor: color.withOpacity(0.88),
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

                  _buildMainWorkspace(
                    constraints.maxWidth,
                  ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: background2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: pink.withOpacity(0.16),
        ),
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
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
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
              gradient: const LinearGradient(
                colors: [
                  pink,
                  purple,
                ],
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.low_priority_rounded,
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
                  'Insertion Sort',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Insert each element into its correct position',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.55),
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
  // STATUS BADGE
  // ==========================================================================

  Widget _statusBadge() {
    Color color = cyan;
    String text = 'READY';

    if (isRunning) {
      color = orange;
      text = 'RUNNING';
    } else if (isCompleted) {
      color = green;
      text = 'SORTED';
    } else if (currentStep > 0) {
      color = purple;
      text = 'PAUSED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
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
  // ALGORITHM INFORMATION
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
            'Insertion Sort builds the sorted array one '
            'element at a time. It takes the next element '
            'as a key, shifts larger elements to the right, '
            'and inserts the key into its correct position.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.64),
              height: 1.5,
              fontSize: 12.5,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoBox('Time', 'O(n²)', orange),
              _infoBox('Space', 'O(1)', blue),
              _infoBox('Type', 'Sorting', purple),
              _infoBox('Best', 'O(n)', green),
              _infoBox('Worst', 'O(n²)', red),
              _infoBox('In-Place', 'Yes', cyan),
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
          _sectionTitle(
            Icons.input_rounded,
            'Input',
            cyan,
          ),

          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) {
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: _inputField(),
                  ),

                  const SizedBox(width: 10),

                  SizedBox(
                    height: 46,
                    child: _generateButton(),
                  ),

                  const SizedBox(width: 10),

                  SizedBox(
                    height: 46,
                    child: _loadButton(),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: orange.withOpacity(0.85),
                size: 15,
              ),

              const SizedBox(width: 7),

              Expanded(
                child: Text(
                  'The sorted portion grows from left to right during every pass.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
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
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      cursorColor: cyan,
      decoration: InputDecoration(
        labelText: 'Enter Numbers',
        hintText: '64, 25, 12, 22, 11...',
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.58),
          fontSize: 12,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.25),
          fontSize: 12,
        ),
        prefixIcon: Icon(
          Icons.data_array_rounded,
          color: cyan.withOpacity(0.8),
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
          borderSide: BorderSide(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: cyan.withOpacity(0.55),
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // GENERATE BUTTON
  // ==========================================================================

  Widget _generateButton() {
    return ElevatedButton.icon(
      onPressed: _generateNumbers,
      icon: const Icon(
        Icons.auto_awesome_rounded,
        size: 17,
      ),
      label: const Text(
        'Generate Numbers',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: purple,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ==========================================================================
  // LOAD BUTTON
  // ==========================================================================

  Widget _loadButton() {
    return ElevatedButton.icon(
      onPressed: _loadArray,
      icon: const Icon(
        Icons.download_rounded,
        size: 17,
      ),
      label: const Text(
        'LOAD ARRAY',
        style: TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: cyan,
        foregroundColor: background,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  // ==========================================================================
  // MAIN WORKSPACE
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
          _sectionTitle(
            Icons.bar_chart_rounded,
            'Visualization',
            cyan,
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              _miniBadge(
                'CURRENT',
                currentIndex >= 0 ? '$currentIndex' : '-',
                purple,
              ),

              const SizedBox(width: 8),

              _miniBadge(
                'COMPARE',
                compareIndex >= 0 ? '$compareIndex' : '-',
                cyan,
              ),

              const SizedBox(width: 8),

              _miniBadge(
                'KEY',
                keyIndex >= 0 ? '$keyValue' : '-',
                pink,
              ),

              const SizedBox(width: 8),

              _miniBadge(
                'SORTED',
                sortedCount.toString(),
                green,
              ),
            ],
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 10,
            ),
            decoration: BoxDecoration(
              color: visualizationColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
              ),
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
    final int value = array[index];

    final bool isCurrent = index == currentIndex;
    final bool isCompare = index == compareIndex;
    final bool isKey = index == keyIndex;
    final bool isSorted = sortedIndexes.contains(index);

    Color itemColor = Colors.white.withOpacity(0.08);
    Color borderColor = Colors.white.withOpacity(0.08);
    Color textColor = Colors.white;

    String label = '';

    // ------------------------------------------------------------------------
    // SORTED
    // ------------------------------------------------------------------------

    if (isSorted) {
      itemColor = green.withOpacity(0.18);
      borderColor = green;
      textColor = green;
      label = 'SORTED';
    }

    // ------------------------------------------------------------------------
    // CURRENT
    // ------------------------------------------------------------------------

    if (isCurrent) {
      itemColor = purple.withOpacity(0.18);
      borderColor = purple;
      textColor = purple;
      label = 'CURRENT';
    }

    // ------------------------------------------------------------------------
    // KEY
    // ------------------------------------------------------------------------

    if (isKey) {
      itemColor = pink.withOpacity(0.20);
      borderColor = pink;
      textColor = pink;
      label = 'KEY';
    }

    // ------------------------------------------------------------------------
    // COMPARE
    // ------------------------------------------------------------------------

    if (isCompare) {
      itemColor = cyan.withOpacity(0.18);
      borderColor = cyan;
      textColor = cyan;
      label = 'COMPARE';
    }

    // ------------------------------------------------------------------------
    // If the same element has multiple states,
    // priority is Compare > Key > Current > Sorted.
    // ------------------------------------------------------------------------

    return Container(
      width: 70,
      margin: const EdgeInsets.symmetric(
        horizontal: 5,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 19,
            child: Center(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: borderColor,
                  fontSize: 7.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: itemColor,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: borderColor,
                width:
                    isCurrent ||
                            isCompare ||
                            isKey ||
                            isSorted
                        ? 1.6
                        : 1,
              ),
              boxShadow:
                  isCurrent ||
                          isCompare ||
                          isKey ||
                          isSorted
                      ? [
                          BoxShadow(
                            color: borderColor.withOpacity(0.18),
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
              color: Colors.white.withOpacity(0.4),
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
        _legendItem(
          'Ready',
          Colors.white,
        ),
        _legendItem(
          'Current',
          purple,
        ),
        _legendItem(
          'Compare',
          cyan,
        ),
        _legendItem(
          'Key',
          pink,
        ),
        _legendItem(
          'Sorted',
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
            color: Colors.white.withOpacity(0.58),
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

    if (keyIndex >= 0) {
      message = 'Key = $keyValue at index $keyIndex';
    }

    if (compareIndex >= 0 &&
        compareIndex < array.length &&
        keyValue >= 0) {
      message =
          'Comparing ${array[compareIndex]} with key $keyValue';
    }

    if (isCompleted) {
      message = 'Array sorted successfully';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: cyan.withOpacity(0.14),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: pink.withOpacity(0.09),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.push_pin_rounded,
              color: pink,
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
                    color: Colors.white.withOpacity(0.42),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              '$sortedCount sorted',
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
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 18,
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Text(
              executionMessage,
              style: TextStyle(
                color: Colors.white.withOpacity(0.72),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 600;

          return Column(
            children: [
              if (compact)
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _controlButton(
                            icon: Icons.skip_previous_rounded,
                            label: 'Previous',
                            onPressed:
                                executionHistory.isEmpty
                                    ? null
                                    : _previousStep,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _controlButton(
                            icon: isRunning
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            label: isRunning ? 'Pause' : 'Play',
                            onPressed: isCompleted
                                ? null
                                : _togglePlayPause,
                            primary: true,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: _controlButton(
                            icon: Icons.skip_next_rounded,
                            label: 'Next Step',
                            onPressed:
                                currentStep >= events.length
                                    ? null
                                    : _nextStep,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _controlButton(
                            icon: Icons.restart_alt_rounded,
                            label: 'Reset',
                            onPressed: _reset,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _controlButton(
                        icon: Icons.skip_previous_rounded,
                        label: 'Previous',
                        onPressed:
                            executionHistory.isEmpty
                                ? null
                                : _previousStep,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      flex: 2,
                      child: _controlButton(
                        icon: isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        label: isRunning ? 'Pause' : 'Play',
                        onPressed: isCompleted
                            ? null
                            : _togglePlayPause,
                        primary: true,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: _controlButton(
                        icon: Icons.skip_next_rounded,
                        label: 'Next Step',
                        onPressed:
                            currentStep >= events.length
                                ? null
                                : _nextStep,
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: _controlButton(
                        icon: Icons.restart_alt_rounded,
                        label: 'Reset',
                        onPressed: _reset,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 12),

              Row(
                children: [
                  const Icon(
                    Icons.speed_rounded,
                    color: cyan,
                    size: 17,
                  ),

                  const SizedBox(width: 8),

                  Text(
                    'Speed',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
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
                      inactiveColor:
                          Colors.white.withOpacity(0.08),
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
                  value: events.isEmpty
                      ? 0
                      : (currentStep / events.length).clamp(
                          0.0,
                          1.0,
                        ),
                  minHeight: 4,
                  backgroundColor:
                      Colors.white.withOpacity(0.06),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(
                    cyan,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Step $currentStep / ${events.length}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.45),
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
                              : currentStep == 0
                                  ? cyan
                                  : Colors.white
                                      .withOpacity(0.4),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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
        icon: Icon(
          icon,
          size: 17,
        ),
        label: Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? cyan : cardColor,
          foregroundColor: primary ? background : Colors.white,
          disabledBackgroundColor:
              Colors.white.withOpacity(0.04),
          disabledForegroundColor:
              Colors.white.withOpacity(0.20),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
            side: BorderSide(
              color: primary
                  ? cyan
                  : Colors.white.withOpacity(0.08),
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
              _sectionTitle(
                Icons.code_rounded,
                'Source Code',
                purple,
              ),

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
                    color: purple.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: purple.withOpacity(0.20),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        color: purple,
                        size: 14,
                      ),
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
            constraints: const BoxConstraints(
              minHeight: 280,
              maxHeight: 500,
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF050A14),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  lines.length,
                  (index) {
                    final lineNumber = index + 1;

                    final active =
                        lineNumber == activeCodeLine;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      color: active
                          ? cyan.withOpacity(0.09)
                          : Colors.transparent,
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 25,
                            child: Text(
                              '$lineNumber',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: active
                                    ? cyan
                                    : Colors.white
                                        .withOpacity(0.20),
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
                                    : Colors.white
                                        .withOpacity(0.65),
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
                  },
                ),
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
              _sectionTitle(
                Icons.history_rounded,
                'Execution Steps',
                cyan,
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: cyan.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: cyan.withOpacity(0.14),
                  ),
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
              constraints: const BoxConstraints(
                maxHeight: 460,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: executionHistory.length,
                itemBuilder: (context, index) {
                  final event = executionHistory[index];

                  return _executionStepItem(
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
  // EMPTY EXECUTION STATE
  // ==========================================================================

  Widget _emptyExecutionState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 35,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        color: visualizationColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.timeline_rounded,
            color: Colors.white.withOpacity(0.20),
            size: 32,
          ),

          const SizedBox(height: 10),

          Text(
            'No steps executed yet',
            style: TextStyle(
              color: Colors.white.withOpacity(0.55),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Press Next Step or Play to start',
            style: TextStyle(
              color: Colors.white.withOpacity(0.30),
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

  Widget _executionStepItem(
    int index,
    InsertionSortEvent event,
  ) {
    final color = _eventColor(event.type);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 7,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.045),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: color.withOpacity(0.14),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 27,
            height: 27,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(
              _eventIcon(event.type),
              color: color,
              size: 15,
            ),
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
                        color: Colors.white.withOpacity(0.22),
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
                    color: Colors.white.withOpacity(0.53),
                    fontSize: 9.5,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  event.operation,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.30),
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

  Widget _card({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.065),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
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

  Widget _sectionTitle(
    IconData icon,
    String title,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.09),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 17,
          ),
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

  Widget _infoBox(
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.055),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: color.withOpacity(0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
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

  Widget _miniBadge(
    String title,
    String value,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: color.withOpacity(0.18),
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              overflow: TextOverflow.ellipsis,
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