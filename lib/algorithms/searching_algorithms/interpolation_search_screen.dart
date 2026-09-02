import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InterpolationSearchScreen extends StatefulWidget {
  const InterpolationSearchScreen({super.key});

  @override
  State<InterpolationSearchScreen> createState() =>
      _InterpolationSearchScreenState();
}

// ============================================================================
// EVENT TYPES
// ============================================================================

enum InterpolationSearchEventType {
  initialize,
  calculatePosition,
  compareLow,
  compareHigh,
  probe,
  moveLow,
  moveHigh,
  found,
  notFound,
  complete,
}

// ============================================================================
// EVENT MODEL
// ============================================================================

class InterpolationSearchEvent {
  final InterpolationSearchEventType type;
  final List<int> array;

  final int low;
  final int high;
  final int probeIndex;
  final int previousProbeIndex;

  final int target;
  final int probeValue;

  final String title;
  final String description;
  final String operation;

  const InterpolationSearchEvent({
    required this.type,
    required this.array,
    required this.low,
    required this.high,
    required this.probeIndex,
    required this.previousProbeIndex,
    required this.target,
    required this.probeValue,
    required this.title,
    required this.description,
    required this.operation,
  });
}

// ============================================================================
// STATE
// ============================================================================

class _InterpolationSearchScreenState
    extends State<InterpolationSearchScreen> {
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
  // DEFAULT DATA
  // ==========================================================================

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

  int target = 61;

  // ==========================================================================
  // CONTROLLERS
  // ==========================================================================

  final TextEditingController arrayController = TextEditingController(
    text: '10, 18, 23, 31, 39, 45, 52, 61, 68, 74, 82, 91',
  );

  final TextEditingController targetController = TextEditingController(
    text: '61',
  );

  // ==========================================================================
  // EXECUTION
  // ==========================================================================

  List<InterpolationSearchEvent> events = [];
  List<InterpolationSearchEvent> executionHistory = [];

  int currentStep = 0;

  bool isRunning = false;
  bool isCompleted = false;

  double speed = 1.0;

  Timer? timer;

  // ==========================================================================
  // VISUALIZATION STATE
  // ==========================================================================

  int low = -1;
  int high = -1;
  int probeIndex = -1;
  int previousProbeIndex = -1;
  int foundIndex = -1;

  int activeCodeLine = 0;

  String executionMessage = 'Ready to start Interpolation Search';

  // ==========================================================================
  // SOURCE CODE
  // ==========================================================================

  final String sourceCode = '''
int interpolationSearch(int[] arr, int target) {
  int low = 0;
  int high = arr.length - 1;

  while (low <= high &&
         target >= arr[low] &&
         target <= arr[high]) {

    if (low == high) {
      if (arr[low] == target) {
        return low;
      }
      return -1;
    }

    int pos = low +
        ((target - arr[low]) * (high - low)) ~/
        (arr[high] - arr[low]);

    if (arr[pos] == target) {
      return pos;
    }

    if (arr[pos] < target) {
      low = pos + 1;
    } else {
      high = pos - 1;
    }
  }

  return -1;
}
''';

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

  @override
  void initState() {
    super.initState();
    _generateEvents();
  }

  @override
  void dispose() {
    timer?.cancel();
    arrayController.dispose();
    targetController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // GENERATE EVENTS
  // ==========================================================================

  void _generateEvents() {
    final working = [...array]..sort();

    final parsedTarget = target;

    final generated = <InterpolationSearchEvent>[];

    if (working.isEmpty) {
      events = generated;
      return;
    }

    generated.add(
      InterpolationSearchEvent(
        type: InterpolationSearchEventType.initialize,
        array: [...working],
        low: 0,
        high: working.length - 1,
        probeIndex: -1,
        previousProbeIndex: -1,
        target: parsedTarget,
        probeValue: -1,
        title: 'Search Initialized',
        description:
            'Array is sorted and ready. Target = $parsedTarget.',
        operation: 'Initialize Interpolation Search',
      ),
    );

    int left = 0;
    int right = working.length - 1;
    int lastProbe = -1;

    while (
        left <= right &&
        parsedTarget >= working[left] &&
        parsedTarget <= working[right]) {
      // ---------------------------------------------------------------
      // COMPARE LOW
      // ---------------------------------------------------------------

      generated.add(
        InterpolationSearchEvent(
          type: InterpolationSearchEventType.compareLow,
          array: [...working],
          low: left,
          high: right,
          probeIndex: -1,
          previousProbeIndex: lastProbe,
          target: parsedTarget,
          probeValue: working[left],
          title: 'Check Lower Bound',
          description:
              'Target $parsedTarget is compared with lower bound '
              '${working[left]} at index $left.',
          operation: 'Check arr[low]',
        ),
      );

      // ---------------------------------------------------------------
      // COMPARE HIGH
      // ---------------------------------------------------------------

      generated.add(
        InterpolationSearchEvent(
          type: InterpolationSearchEventType.compareHigh,
          array: [...working],
          low: left,
          high: right,
          probeIndex: -1,
          previousProbeIndex: lastProbe,
          target: parsedTarget,
          probeValue: working[right],
          title: 'Check Upper Bound',
          description:
              'Target $parsedTarget is compared with upper bound '
              '${working[right]} at index $right.',
          operation: 'Check arr[high]',
        ),
      );

      // ---------------------------------------------------------------
      // SAME POSITION
      // ---------------------------------------------------------------

      if (left == right) {
        generated.add(
          InterpolationSearchEvent(
            type: InterpolationSearchEventType.probe,
            array: [...working],
            low: left,
            high: right,
            probeIndex: left,
            previousProbeIndex: lastProbe,
            target: parsedTarget,
            probeValue: working[left],
            title: 'Probe Position',
            description:
                'Only one element remains. Probe index = $left.',
            operation: 'Probe arr[$left]',
          ),
        );

        if (working[left] == parsedTarget) {
          generated.add(
            InterpolationSearchEvent(
              type: InterpolationSearchEventType.found,
              array: [...working],
              low: left,
              high: right,
              probeIndex: left,
              previousProbeIndex: lastProbe,
              target: parsedTarget,
              probeValue: working[left],
              title: 'Target Found',
              description:
                  'Target $parsedTarget found at index $left.',
              operation: 'Match Found',
            ),
          );

          generated.add(
            InterpolationSearchEvent(
              type: InterpolationSearchEventType.complete,
              array: [...working],
              low: left,
              high: right,
              probeIndex: left,
              previousProbeIndex: lastProbe,
              target: parsedTarget,
              probeValue: working[left],
              title: 'Search Complete',
              description:
                  'Interpolation Search completed successfully.',
              operation: 'Complete',
            ),
          );

          events = generated;
          return;
        }

        generated.add(
          InterpolationSearchEvent(
            type: InterpolationSearchEventType.notFound,
            array: [...working],
            low: left,
            high: right,
            probeIndex: left,
            previousProbeIndex: lastProbe,
            target: parsedTarget,
            probeValue: working[left],
            title: 'Target Not Found',
            description:
                'Remaining element does not match target $parsedTarget.',
            operation: 'No Match',
          ),
        );

        generated.add(
          InterpolationSearchEvent(
            type: InterpolationSearchEventType.complete,
            array: [...working],
            low: left,
            high: right,
            probeIndex: left,
            previousProbeIndex: lastProbe,
            target: parsedTarget,
            probeValue: working[left],
            title: 'Search Complete',
            description: 'Interpolation Search finished.',
            operation: 'Complete',
          ),
        );

        events = generated;
        return;
      }

      // ---------------------------------------------------------------
      // DIVISION BY ZERO SAFETY
      // ---------------------------------------------------------------

      if (working[right] == working[left]) {
        generated.add(
          InterpolationSearchEvent(
            type: InterpolationSearchEventType.probe,
            array: [...working],
            low: left,
            high: right,
            probeIndex: left,
            previousProbeIndex: lastProbe,
            target: parsedTarget,
            probeValue: working[left],
            title: 'Equal Boundary Values',
            description:
                'Lower and upper values are equal. '
                'Interpolation position cannot be calculated normally.',
            operation: 'Handle Equal Values',
          ),
        );

        if (working[left] == parsedTarget) {
          generated.add(
            InterpolationSearchEvent(
              type: InterpolationSearchEventType.found,
              array: [...working],
              low: left,
              high: right,
              probeIndex: left,
              previousProbeIndex: lastProbe,
              target: parsedTarget,
              probeValue: working[left],
              title: 'Target Found',
              description:
                  'Target $parsedTarget matches the boundary value.',
              operation: 'Match Found',
            ),
          );

          generated.add(
            InterpolationSearchEvent(
              type: InterpolationSearchEventType.complete,
              array: [...working],
              low: left,
              high: right,
              probeIndex: left,
              previousProbeIndex: lastProbe,
              target: parsedTarget,
              probeValue: working[left],
              title: 'Search Complete',
              description: 'Interpolation Search completed.',
              operation: 'Complete',
            ),
          );

          events = generated;
          return;
        }

        break;
      }

      // ---------------------------------------------------------------
      // CALCULATE INTERPOLATION POSITION
      // ---------------------------------------------------------------

      final numerator =
          (parsedTarget - working[left]) * (right - left);

      final denominator = working[right] - working[left];

      int position = left + (numerator ~/ denominator);

      if (position < left) {
        position = left;
      }

      if (position > right) {
        position = right;
      }

      generated.add(
        InterpolationSearchEvent(
          type: InterpolationSearchEventType.calculatePosition,
          array: [...working],
          low: left,
          high: right,
          probeIndex: position,
          previousProbeIndex: lastProbe,
          target: parsedTarget,
          probeValue: working[position],
          title: 'Calculate Probe Position',
          description:
              'Interpolation estimates index $position '
              'using the target value distribution.',
          operation: 'Calculate pos',
        ),
      );

      // ---------------------------------------------------------------
      // PROBE
      // ---------------------------------------------------------------

      lastProbe = position;

      generated.add(
        InterpolationSearchEvent(
          type: InterpolationSearchEventType.probe,
          array: [...working],
          low: left,
          high: right,
          probeIndex: position,
          previousProbeIndex: -1,
          target: parsedTarget,
          probeValue: working[position],
          title: 'Probe Element',
          description:
              'Checking value ${working[position]} at index $position '
              'against target $parsedTarget.',
          operation: 'Check arr[$position]',
        ),
      );

      // ---------------------------------------------------------------
      // FOUND
      // ---------------------------------------------------------------

      if (working[position] == parsedTarget) {
        generated.add(
          InterpolationSearchEvent(
            type: InterpolationSearchEventType.found,
            array: [...working],
            low: left,
            high: right,
            probeIndex: position,
            previousProbeIndex: -1,
            target: parsedTarget,
            probeValue: working[position],
            title: 'Target Found',
            description:
                'Target $parsedTarget found at index $position.',
            operation: 'Match Found',
          ),
        );

        generated.add(
          InterpolationSearchEvent(
            type: InterpolationSearchEventType.complete,
            array: [...working],
            low: left,
            high: right,
            probeIndex: position,
            previousProbeIndex: -1,
            target: parsedTarget,
            probeValue: working[position],
            title: 'Search Complete',
            description:
                'Interpolation Search completed successfully.',
            operation: 'Complete',
          ),
        );

        events = generated;
        return;
      }

      // ---------------------------------------------------------------
      // MOVE LOW
      // ---------------------------------------------------------------

      if (working[position] < parsedTarget) {
        generated.add(
          InterpolationSearchEvent(
            type: InterpolationSearchEventType.moveLow,
            array: [...working],
            low: left,
            high: right,
            probeIndex: position,
            previousProbeIndex: -1,
            target: parsedTarget,
            probeValue: working[position],
            title: 'Move Lower Bound',
            description:
                'Value ${working[position]} is smaller than target '
                '$parsedTarget. Move low to ${position + 1}.',
            operation: 'low = pos + 1',
          ),
        );

        left = position + 1;
      } else {
        // -------------------------------------------------------------
        // MOVE HIGH
        // -------------------------------------------------------------

        generated.add(
          InterpolationSearchEvent(
            type: InterpolationSearchEventType.moveHigh,
            array: [...working],
            low: left,
            high: right,
            probeIndex: position,
            previousProbeIndex: -1,
            target: parsedTarget,
            probeValue: working[position],
            title: 'Move Upper Bound',
            description:
                'Value ${working[position]} is greater than target '
                '$parsedTarget. Move high to ${position - 1}.',
            operation: 'high = pos - 1',
          ),
        );

        right = position - 1;
      }
    }

    // -----------------------------------------------------------------------
    // NOT FOUND
    // -----------------------------------------------------------------------

    generated.add(
      InterpolationSearchEvent(
        type: InterpolationSearchEventType.notFound,
        array: [...working],
        low: left,
        high: right,
        probeIndex: lastProbe,
        previousProbeIndex: -1,
        target: parsedTarget,
        probeValue:
            lastProbe >= 0 && lastProbe < working.length
                ? working[lastProbe]
                : -1,
        title: 'Target Not Found',
        description:
            'Target $parsedTarget is outside the valid search range.',
        operation: 'No Match',
      ),
    );

    generated.add(
      InterpolationSearchEvent(
        type: InterpolationSearchEventType.complete,
        array: [...working],
        low: left,
        high: right,
        probeIndex: lastProbe,
        previousProbeIndex: -1,
        target: parsedTarget,
        probeValue:
            lastProbe >= 0 && lastProbe < working.length
                ? working[lastProbe]
                : -1,
        title: 'Search Complete',
        description: 'Interpolation Search finished without a match.',
        operation: 'Complete',
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
      _showSnackBar(
        'Please enter numbers.',
        red,
      );
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
      _showSnackBar(
        'No valid numbers found.',
        red,
      );
      return;
    }

    final parsedTarget = int.tryParse(
      targetController.text.trim(),
    );

    if (parsedTarget == null) {
      _showSnackBar(
        'Please enter a valid target number.',
        red,
      );
      return;
    }

    values.sort();

    timer?.cancel();

    setState(() {
      array = values;
      target = parsedTarget;

      executionHistory.clear();
      currentStep = 0;

      isRunning = false;
      isCompleted = false;

      low = -1;
      high = -1;
      probeIndex = -1;
      previousProbeIndex = -1;
      foundIndex = -1;

      activeCodeLine = 0;

      executionMessage =
          'Array loaded. Ready to start Interpolation Search.';

      _generateEvents();
    });

    _showSnackBar(
      'Array loaded and sorted successfully.',
      green,
    );
  }

  // ==========================================================================
  // GENERATE RANDOM NUMBERS
  // ==========================================================================

  void _generateNumbers() {
    final random = Random();

    final generated = List.generate(
      12,
      (_) => random.nextInt(90) + 10,
    );

    generated.sort();

    final randomTarget =
        generated[random.nextInt(generated.length)];

    arrayController.text = generated.join(', ');
    targetController.text = randomTarget.toString();

    setState(() {
      array = generated;
      target = randomTarget;

      executionHistory.clear();
      currentStep = 0;

      isRunning = false;
      isCompleted = false;

      low = -1;
      high = -1;
      probeIndex = -1;
      previousProbeIndex = -1;
      foundIndex = -1;

      activeCodeLine = 0;

      executionMessage =
          'New numbers generated. Ready to search.';

      _generateEvents();
    });
  }

  // ==========================================================================
  // PLAY
  // ==========================================================================

  void _play() {
    if (events.isEmpty) {
      return;
    }

    if (isCompleted) {
      return;
    }

    setState(() {
      isRunning = true;
    });

    timer?.cancel();

    final milliseconds =
        (900 / speed).round().clamp(100, 2000);

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
  // NEXT STEP
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

      setState(() {
        isRunning = false;
        isCompleted = true;
      });
    } else {
      setState(() {});
    }
  }

  // ==========================================================================
  // PREVIOUS STEP
  // ==========================================================================

  void _previousStep() {
    if (executionHistory.isEmpty) {
      return;
    }

    timer?.cancel();

    executionHistory.removeLast();

    final historyLength = executionHistory.length;

    currentStep = historyLength;

    if (historyLength == 0) {
      _resetVisualState();
      return;
    }

    final lastEvent = executionHistory.last;

    _rebuildVisualState(historyLength);

    setState(() {
      isRunning = false;
      isCompleted = false;
    });
  }

  // ==========================================================================
  // REBUILD VISUAL STATE
  // ==========================================================================

  void _rebuildVisualState(int count) {
    _resetVisualState();

    for (int i = 0; i < count && i < executionHistory.length; i++) {
      _applyEvent(
        executionHistory[i],
        updateState: false,
      );
    }

    setState(() {});
  }

  // ==========================================================================
  // APPLY EVENT
  // ==========================================================================

  void _applyEvent(
    InterpolationSearchEvent event, {
    bool updateState = true,
  }) {
    low = event.low;
    high = event.high;
    probeIndex = event.probeIndex;
    previousProbeIndex = event.previousProbeIndex;

    executionMessage =
        '${event.title}: ${event.description}';

    activeCodeLine = _codeLineForEvent(event.type);

    if (event.type == InterpolationSearchEventType.found) {
      foundIndex = event.probeIndex;
    }

    if (event.type == InterpolationSearchEventType.notFound) {
      foundIndex = -1;
    }

    if (event.type == InterpolationSearchEventType.complete) {
      if (foundIndex >= 0) {
        isCompleted = true;
      }
    }

    if (updateState) {
      setState(() {});
    }
  }

  // ==========================================================================
  // RESET VISUAL STATE
  // ==========================================================================

  void _resetVisualState() {
    setState(() {
      currentStep = 0;

      executionHistory.clear();

      isRunning = false;
      isCompleted = false;

      low = -1;
      high = -1;
      probeIndex = -1;
      previousProbeIndex = -1;
      foundIndex = -1;

      activeCodeLine = 0;

      executionMessage =
          'Ready to start Interpolation Search.';
    });
  }

  // ==========================================================================
  // RESET
  // ==========================================================================

  void _reset() {
    timer?.cancel();

    setState(() {
      executionHistory.clear();
      currentStep = 0;

      isRunning = false;
      isCompleted = false;

      low = -1;
      high = -1;
      probeIndex = -1;
      previousProbeIndex = -1;
      foundIndex = -1;

      activeCodeLine = 0;

      executionMessage =
          'Ready to start Interpolation Search.';
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
    InterpolationSearchEventType type,
  ) {
    switch (type) {
      case InterpolationSearchEventType.initialize:
        return 1;

      case InterpolationSearchEventType.compareLow:
        return 4;

      case InterpolationSearchEventType.compareHigh:
        return 5;

      case InterpolationSearchEventType.calculatePosition:
        return 14;

      case InterpolationSearchEventType.probe:
        return 16;

      case InterpolationSearchEventType.moveLow:
        return 21;

      case InterpolationSearchEventType.moveHigh:
        return 23;

      case InterpolationSearchEventType.found:
        return 17;

      case InterpolationSearchEventType.notFound:
        return 28;

      case InterpolationSearchEventType.complete:
        return 28;
    }
  }

  // ==========================================================================
  // EVENT COLOR
  // ==========================================================================

  Color _eventColor(
    InterpolationSearchEventType type,
  ) {
    switch (type) {
      case InterpolationSearchEventType.initialize:
        return blue;

      case InterpolationSearchEventType.calculatePosition:
        return purple;

      case InterpolationSearchEventType.compareLow:
      case InterpolationSearchEventType.compareHigh:
        return orange;

      case InterpolationSearchEventType.probe:
        return cyan;

      case InterpolationSearchEventType.moveLow:
      case InterpolationSearchEventType.moveHigh:
        return pink;

      case InterpolationSearchEventType.found:
        return green;

      case InterpolationSearchEventType.notFound:
        return red;

      case InterpolationSearchEventType.complete:
        return green;
    }
  }

  // ==========================================================================
  // EVENT ICON
  // ==========================================================================

  IconData _eventIcon(
    InterpolationSearchEventType type,
  ) {
    switch (type) {
      case InterpolationSearchEventType.initialize:
        return Icons.play_arrow_rounded;

      case InterpolationSearchEventType.calculatePosition:
        return Icons.calculate_rounded;

      case InterpolationSearchEventType.compareLow:
        return Icons.keyboard_arrow_down_rounded;

      case InterpolationSearchEventType.compareHigh:
        return Icons.keyboard_arrow_up_rounded;

      case InterpolationSearchEventType.probe:
        return Icons.gps_fixed_rounded;

      case InterpolationSearchEventType.moveLow:
        return Icons.arrow_forward_rounded;

      case InterpolationSearchEventType.moveHigh:
        return Icons.arrow_back_rounded;

      case InterpolationSearchEventType.found:
        return Icons.check_circle_rounded;

      case InterpolationSearchEventType.notFound:
        return Icons.cancel_rounded;

      case InterpolationSearchEventType.complete:
        return Icons.flag_rounded;
    }
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
        backgroundColor: color.withOpacity(0.85),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================================================
  // COPY CODE
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
          color: cyan.withOpacity(0.16),
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
                  cyan,
                  blue,
                ],
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.insights_rounded,
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
                  'Interpolation Search',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Position-based searching for sorted data',
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
    } else if (foundIndex >= 0) {
      color = green;
      text = 'FOUND';
    } else if (isCompleted) {
      color = red;
      text = 'NOT FOUND';
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
            'Interpolation Search improves searching by estimating '
            'the probable position of the target based on the values '
            'at the current low and high boundaries. It works best '
            'when sorted values are approximately uniformly distributed.',
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
              _infoBox(
                'Time',
                'O(log log n)',
                cyan,
              ),
              _infoBox(
                'Space',
                'O(1)',
                blue,
              ),
              _infoBox(
                'Type',
                'Searching',
                purple,
              ),
              _infoBox(
                'Best',
                'O(1)',
                green,
              ),
              _infoBox(
                'Worst',
                'O(n)',
                orange,
              ),
              _infoBox(
                'Requirement',
                'Sorted Array',
                pink,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // INPUT SECTION
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
                    _inputField(
                      controller: arrayController,
                      label: 'Enter Numbers',
                      hint: '10, 20, 30, 40...',
                      icon: Icons.data_array_rounded,
                    ),

                    const SizedBox(height: 10),

                    _inputField(
                      controller: targetController,
                      label: 'Enter a target number',
                      hint: 'Target',
                      icon: Icons.gps_fixed_rounded,
                    ),

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
                    flex: 3,
                    child: _inputField(
                      controller: arrayController,
                      label: 'Enter Numbers',
                      hint: '10, 20, 30, 40...',
                      icon: Icons.data_array_rounded,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    flex: 2,
                    child: _inputField(
                      controller: targetController,
                      label: 'Enter a target number',
                      hint: 'Target',
                      icon: Icons.gps_fixed_rounded,
                    ),
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
                Icons.sort_rounded,
                color: orange.withOpacity(0.85),
                size: 15,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Interpolation Search requires a sorted array. '
                  'The array will be sorted automatically when loaded.',
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

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      cursorColor: cyan,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.58),
          fontSize: 12,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.25),
          fontSize: 12,
        ),
        prefixIcon: Icon(
          icon,
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
                'LOW',
                low >= 0 ? low.toString() : '-',
                blue,
              ),

              const SizedBox(width: 8),

              _miniBadge(
                'HIGH',
                high >= 0 ? high.toString() : '-',
                orange,
              ),

              const SizedBox(width: 8),

              _miniBadge(
                'PROBE',
                probeIndex >= 0 ? probeIndex.toString() : '-',
                cyan,
              ),

              const SizedBox(width: 8),

              _miniBadge(
                'TARGET',
                target.toString(),
                pink,
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

          _buildSearchRange(),

          const SizedBox(height: 12),

          _buildStatusCard(),
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

  // ==========================================================================
  // ARRAY ITEM
  // ==========================================================================

  Widget _buildArrayItem(int index) {
    final value = array[index];

    Color itemColor = Colors.white.withOpacity(0.12);
    Color borderColor = Colors.white.withOpacity(0.08);

    bool isLow = index == low;
    bool isHigh = index == high;
    bool isProbe = index == probeIndex;
    bool isFound = index == foundIndex;

    final bool insideRange =
        low >= 0 &&
        high >= 0 &&
        index >= low &&
        index <= high;

    if (isFound) {
      itemColor = green.withOpacity(0.20);
      borderColor = green;
    } else if (isProbe) {
      itemColor = cyan.withOpacity(0.20);
      borderColor = cyan;
    } else if (isLow) {
      itemColor = blue.withOpacity(0.17);
      borderColor = blue;
    } else if (isHigh) {
      itemColor = orange.withOpacity(0.17);
      borderColor = orange;
    } else if (insideRange) {
      itemColor = purple.withOpacity(0.07);
      borderColor = purple.withOpacity(0.16);
    }

    return Container(
      width: 64,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          SizedBox(
            height: 19,
            child: Center(
              child: Text(
                isFound
                    ? 'FOUND'
                    : isProbe
                        ? 'PROBE'
                        : isLow
                            ? 'LOW'
                            : isHigh
                                ? 'HIGH'
                                : '',
                style: TextStyle(
                  color: isFound
                      ? green
                      : isProbe
                          ? cyan
                          : isLow
                              ? blue
                              : orange,
                  fontSize: 8,
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
                width:
                    isProbe || isFound ? 1.6 : 1,
              ),
              boxShadow: isProbe || isFound
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
                  color: isFound
                      ? green
                      : isProbe
                          ? cyan
                          : Colors.white,
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
          'Search Range',
          purple,
        ),
        _legendItem(
          'Low',
          blue,
        ),
        _legendItem(
          'High',
          orange,
        ),
        _legendItem(
          'Probe',
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
  // SEARCH RANGE
  // ==========================================================================

  Widget _buildSearchRange() {
    String rangeText = 'Not started';

    if (low >= 0 && high >= 0) {
      rangeText = 'Index $low → $high';

      if (low > high) {
        rangeText = 'Search range exhausted';
      }
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: purple.withOpacity(0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: purple.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.compare_arrows_rounded,
              color: purple,
              size: 18,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Search Range',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  rangeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          if (probeIndex >= 0)
            Text(
              'Probe: $probeIndex',
              style: const TextStyle(
                color: cyan,
                fontSize: 11,
                fontWeight: FontWeight.w800,
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

    if (foundIndex >= 0) {
      color = green;
    } else if (isCompleted) {
      color = red;
    } else if (isRunning) {
      color = orange;
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
            foundIndex >= 0
                ? Icons.check_circle_rounded
                : isCompleted
                    ? Icons.cancel_rounded
                    : Icons.info_outline_rounded,
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
      child: Column(
        children: [
          Row(
            children: [
              _controlButton(
                icon: Icons.skip_previous_rounded,
                label: 'Previous',
                onPressed: executionHistory.isEmpty
                    ? null
                    : _previousStep,
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

              const SizedBox(width: 8),

              _controlButton(
                icon: Icons.skip_next_rounded,
                label: 'Next Step',
                onPressed:
                    currentStep >= events.length
                        ? null
                        : _nextStep,
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
                  inactiveColor: Colors.white.withOpacity(0.08),
                  onChanged: _setSpeed,
                ),
              ),

              Container(
                width: 48,
                alignment: Alignment.center,
                child: Text(
                  '${speed.toStringAsFixed(1)}x',
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
                  : currentStep / events.length,
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
                        : 'Paused',
                style: TextStyle(
                  color: isCompleted
                      ? green
                      : isRunning
                          ? orange
                          : Colors.white.withOpacity(0.4),
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
    final bool enabled = onPressed != null;

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
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary
              ? cyan
              : cardColor,
          foregroundColor: primary
              ? background
              : Colors.white,
          disabledBackgroundColor:
              Colors.white.withOpacity(0.04),
          disabledForegroundColor:
              Colors.white.withOpacity(0.20),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
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
              minHeight: 350,
              maxHeight: 520,
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

                    final bool active =
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
                  final event =
                      executionHistory[index];

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
  // EMPTY EXECUTION
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
  // EXECUTION STEP ITEM
  // ==========================================================================

  Widget _executionStepItem(
    int index,
    InterpolationSearchEvent event,
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
                        color: Colors.white
                            .withOpacity(0.22),
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
                    color: Colors.white
                        .withOpacity(0.53),
                    fontSize: 9.5,
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  event.operation,
                  style: TextStyle(
                    color: Colors.white
                        .withOpacity(0.30),
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
}