import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/algorithm_screen_shell.dart';
import 'package:flutter/services.dart';

class LinearSearchScreen extends StatefulWidget {
  const LinearSearchScreen({super.key});

  @override
  State<LinearSearchScreen> createState() => _LinearSearchScreenState();
}

// ============================================================================
// EVENT TYPES
// ============================================================================

enum LinearSearchEventType { initialize, check, notMatch, found, complete }

// ============================================================================
// EVENT MODEL
// ============================================================================

class LinearSearchEvent {
  final LinearSearchEventType type;

  final List<int> array;

  final int currentIndex;
  final int previousIndex;

  final int target;
  final int currentValue;

  final String title;
  final String description;
  final String operation;

  const LinearSearchEvent({
    required this.type,
    required this.array,
    required this.currentIndex,
    required this.previousIndex,
    required this.target,
    required this.currentValue,
    required this.title,
    required this.description,
    required this.operation,
  });
}

// ============================================================================
// SCREEN STATE
// ============================================================================

class _LinearSearchScreenState extends State<LinearSearchScreen> {
  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const Color background = AppColors.background;
  static const Color background2 = AppColors.background2;
  static const Color cardColor = AppColors.card;
  static const Color visualizationColor = AppColors.visualizationBackground;

  static const Color cyan = AppColors.cyan;
  static const Color blue = AppColors.blue;
  static const Color purple = AppColors.purple;
  static const Color green = AppColors.green;
  static const Color orange = AppColors.orange;
  static const Color pink = AppColors.pink;
  static const Color red = AppColors.error;

  // ==========================================================================
  // DEFAULT DATA
  // ==========================================================================

  List<int> array = [64, 25, 12, 22, 11];

  int target = 22;

  // ==========================================================================
  // CONTROLLERS
  // ==========================================================================

  final TextEditingController arrayController = TextEditingController(
    text: '64, 25, 12, 22, 11',
  );

  final TextEditingController targetController = TextEditingController(
    text: '22',
  );

  // ==========================================================================
  // EXECUTION
  // ==========================================================================

  List<LinearSearchEvent> events = [];

  List<LinearSearchEvent> executionHistory = [];

  int currentStep = 0;

  bool isRunning = false;
  bool isCompleted = false;

  double speed = 1.0;

  Timer? timer;

  // ==========================================================================
  // VISUALIZATION STATE
  // ==========================================================================

  int currentIndex = -1;
  int previousIndex = -1;
  int foundIndex = -1;

  int activeCodeLine = 0;

  String executionMessage = 'Ready to start Linear Search';

  // ==========================================================================
  // SOURCE CODE
  // ==========================================================================

  final String sourceCode = '''
int linearSearch(int[] arr, int target) {
  for (int i = 0; i < arr.length; i++) {

    if (arr[i] == target) {
      return i;
    }

  }

  return -1;
}
''';

  // ==========================================================================
  // INIT
  // ==========================================================================

  @override
  void initState() {
    super.initState();

    _generateEvents();
  }

  // ==========================================================================
  // DISPOSE
  // ==========================================================================

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
    final working = [...array];

    final generated = <LinearSearchEvent>[];

    if (working.isEmpty) {
      events = generated;
      return;
    }

    // ------------------------------------------------------------------------
    // INITIALIZE
    // ------------------------------------------------------------------------

    generated.add(
      LinearSearchEvent(
        type: LinearSearchEventType.initialize,
        array: [...working],
        currentIndex: -1,
        previousIndex: -1,
        target: target,
        currentValue: -1,
        title: 'Search Initialized',
        description:
            'Linear Search will check every element from left to right.',
        operation: 'Initialize Search',
      ),
    );

    // ------------------------------------------------------------------------
    // CHECK EACH ELEMENT
    // ------------------------------------------------------------------------

    int previous = -1;

    for (int i = 0; i < working.length; i++) {
      final value = working[i];

      // CHECK
      generated.add(
        LinearSearchEvent(
          type: LinearSearchEventType.check,
          array: [...working],
          currentIndex: i,
          previousIndex: previous,
          target: target,
          currentValue: value,
          title: 'Checking Element',
          description:
              'Checking value $value at index $i against target $target.',
          operation: 'Compare arr[$i] == target',
        ),
      );

      // FOUND
      if (value == target) {
        generated.add(
          LinearSearchEvent(
            type: LinearSearchEventType.found,
            array: [...working],
            currentIndex: i,
            previousIndex: previous,
            target: target,
            currentValue: value,
            title: 'Target Found',
            description: 'Target $target found at index $i.',
            operation: 'Match Found',
          ),
        );

        generated.add(
          LinearSearchEvent(
            type: LinearSearchEventType.complete,
            array: [...working],
            currentIndex: i,
            previousIndex: previous,
            target: target,
            currentValue: value,
            title: 'Search Complete',
            description: 'Linear Search completed successfully.',
            operation: 'Return index $i',
          ),
        );

        events = generated;

        return;
      }

      // NOT MATCH
      generated.add(
        LinearSearchEvent(
          type: LinearSearchEventType.notMatch,
          array: [...working],
          currentIndex: i,
          previousIndex: previous,
          target: target,
          currentValue: value,
          title: 'Not a Match',
          description:
              'Value $value does not match target $target. Move to next element.',
          operation: 'arr[$i] != target',
        ),
      );

      previous = i;
    }

    // ------------------------------------------------------------------------
    // NOT FOUND
    // ------------------------------------------------------------------------

    generated.add(
      LinearSearchEvent(
        type: LinearSearchEventType.complete,
        array: [...working],
        currentIndex: -1,
        previousIndex: previous,
        target: target,
        currentValue: -1,
        title: 'Target Not Found',
        description:
            'All ${working.length} elements were checked, but target $target was not found.',
        operation: 'Return -1',
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

    final parsedTarget = int.tryParse(targetController.text.trim());

    if (parsedTarget == null) {
      _showSnackBar('Please enter a valid target number.', red);
      return;
    }

    timer?.cancel();

    final generatedArray = [...values];

    setState(() {
      array = generatedArray;
      target = parsedTarget;

      executionHistory.clear();

      currentStep = 0;

      isRunning = false;
      isCompleted = false;

      currentIndex = -1;
      previousIndex = -1;
      foundIndex = -1;

      activeCodeLine = 0;

      executionMessage = 'Array loaded. Ready to start Linear Search.';
    });

    _generateEvents();

    _showSnackBar('Array loaded successfully.', green);
  }

  // ==========================================================================
  // GENERATE NUMBERS
  // ==========================================================================

  void _generateNumbers() {
    final random = Random();

    final generated = List.generate(8, (_) => random.nextInt(90) + 10);

    final generatedTarget = generated[random.nextInt(generated.length)];

    arrayController.text = generated.join(', ');

    targetController.text = generatedTarget.toString();

    timer?.cancel();

    setState(() {
      array = generated;
      target = generatedTarget;

      executionHistory.clear();

      currentStep = 0;

      isRunning = false;
      isCompleted = false;

      currentIndex = -1;
      previousIndex = -1;
      foundIndex = -1;

      activeCodeLine = 0;

      executionMessage = 'New numbers generated. Ready to search.';
    });

    _generateEvents();
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

    timer?.cancel();

    setState(() {
      isRunning = true;
    });

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

      setState(() {
        isRunning = false;
        isCompleted = true;
      });
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

    setState(() {
      isRunning = false;
      isCompleted = false;
    });
  }

  // ==========================================================================
  // REBUILD VISUAL STATE
  // ==========================================================================

  void _rebuildVisualState() {
    currentIndex = -1;
    previousIndex = -1;
    foundIndex = -1;

    activeCodeLine = 0;

    executionMessage = 'Ready to start Linear Search.';

    for (final event in executionHistory) {
      _applyEvent(event, updateState: false);
    }

    if (executionHistory.isEmpty) {
      currentIndex = -1;
      previousIndex = -1;
      foundIndex = -1;
      activeCodeLine = 0;

      executionMessage = 'Ready to start Linear Search.';
    }

    setState(() {});
  }

  // ==========================================================================
  // APPLY EVENT
  // ==========================================================================

  void _applyEvent(LinearSearchEvent event, {bool updateState = true}) {
    currentIndex = event.currentIndex;

    previousIndex = event.previousIndex;

    executionMessage = '${event.title}: ${event.description}';

    activeCodeLine = _codeLineForEvent(event.type);

    if (event.type == LinearSearchEventType.found) {
      foundIndex = event.currentIndex;
    }

    if (event.type == LinearSearchEventType.complete) {
      if (event.currentIndex >= 0 && event.currentValue == event.target) {
        foundIndex = event.currentIndex;
      }
    }

    if (updateState) {
      setState(() {});
    }
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

      currentIndex = -1;
      previousIndex = -1;
      foundIndex = -1;

      activeCodeLine = 0;

      executionMessage = 'Ready to start Linear Search.';
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

  int _codeLineForEvent(LinearSearchEventType type) {
    switch (type) {
      case LinearSearchEventType.initialize:
        return 1;

      case LinearSearchEventType.check:
        return 4;

      case LinearSearchEventType.notMatch:
        return 4;

      case LinearSearchEventType.found:
        return 5;

      case LinearSearchEventType.complete:
        return 9;
    }
  }

  // ==========================================================================
  // EVENT COLOR
  // ==========================================================================

  Color _eventColor(LinearSearchEventType type) {
    switch (type) {
      case LinearSearchEventType.initialize:
        return blue;

      case LinearSearchEventType.check:
        return cyan;

      case LinearSearchEventType.notMatch:
        return orange;

      case LinearSearchEventType.found:
        return green;

      case LinearSearchEventType.complete:
        return green;
    }
  }

  // ==========================================================================
  // EVENT ICON
  // ==========================================================================

  IconData _eventIcon(LinearSearchEventType type) {
    switch (type) {
      case LinearSearchEventType.initialize:
        return Icons.play_arrow_rounded;

      case LinearSearchEventType.check:
        return Icons.search_rounded;

      case LinearSearchEventType.notMatch:
        return Icons.close_rounded;

      case LinearSearchEventType.found:
        return Icons.check_circle_rounded;

      case LinearSearchEventType.complete:
        return Icons.flag_rounded;
    }
  }

  // ==========================================================================
  // SNACKBAR
  // ==========================================================================

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
  // COPY CODE
  // ==========================================================================

  Future<void> _copyCode() async {
    await Clipboard.setData(ClipboardData(text: sourceCode));

    _showSnackBar('Source code copied.', cyan);
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
<<<<<<< HEAD
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
=======
      body: AlgorithmScreenShell(
        header: _buildHeader(),
        algorithmInfo: _buildAlgorithmInfo(),
        inputSection: _buildInputSection(),
        visualization: _buildVisualization(),
        controls: _buildControls(),
        sourceCode: _buildSourceCode(),
        executionSteps: _buildExecutionSteps(),
>>>>>>> origin/main
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
        border: Border.all(color: cyan.withValues(alpha: 0.16)),
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
              gradient: const LinearGradient(colors: [cyan, blue]),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.manage_search_rounded,
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
                  'Linear Search',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Sequentially search each element',
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
            'Linear Search checks elements one by one from '
            'the beginning of the array until the target is '
            'found or all elements have been checked. '
            'It works on both sorted and unsorted arrays.',
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
              _infoBox('Time', 'O(n)', cyan),
              _infoBox('Space', 'O(1)', blue),
              _infoBox('Type', 'Searching', purple),
              _infoBox('Best', 'O(1)', green),
              _infoBox('Worst', 'O(n)', orange),
              _infoBox('Sorted', 'Not Required', pink),
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
          _sectionTitle(Icons.input_rounded, 'Input', cyan),

          const SizedBox(height: 12),

          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 700) {
                return Column(
                  children: [
                    _inputField(
                      controller: arrayController,
                      label: 'Enter Numbers',
                      hint: '64, 25, 12, 22, 11...',
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
                  Expanded(
                    flex: 3,
                    child: _inputField(
                      controller: arrayController,
                      label: 'Enter Numbers',
                      hint: '64, 25, 12, 22, 11...',
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
                  'Linear Search does not require the array to be sorted.',
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

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      cursorColor: cyan,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.58),
          fontSize: 12,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.25),
          fontSize: 12,
        ),
        prefixIcon: Icon(icon, color: cyan.withValues(alpha: 0.8), size: 19),
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
  // GENERATE BUTTON
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
  // LOAD BUTTON
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
  // MAIN WORKSPACE
  // ==========================================================================

<<<<<<< HEAD
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

=======
>>>>>>> origin/main
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
                'INDEX',
                currentIndex >= 0 ? currentIndex.toString() : '-',
                cyan,
              ),

              const SizedBox(width: 8),

              _miniBadge(
                'ELEMENT',
                currentIndex >= 0 ? array[currentIndex].toString() : '-',
                blue,
              ),

              const SizedBox(width: 8),

              _miniBadge('TARGET', target.toString(), pink),

              const SizedBox(width: 8),

              _miniBadge(
                'CHECKED',
                executionHistory
                    .where((event) => event.type == LinearSearchEventType.check)
                    .length
                    .toString(),
                purple,
              ),
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

  // ==========================================================================
  // ARRAY ITEM
  // ==========================================================================

  Widget _buildArrayItem(int index) {
    final value = array[index];

    Color itemColor = Colors.white.withValues(alpha: 0.12);

    Color borderColor = Colors.white.withValues(alpha: 0.08);

    final bool isCurrent = index == currentIndex;

    final bool isFound = index == foundIndex;

    final bool wasChecked = previousIndex == index && !isCurrent;

    if (isFound) {
      itemColor = green.withValues(alpha: 0.20);

      borderColor = green;
    } else if (isCurrent) {
      itemColor = cyan.withValues(alpha: 0.20);

      borderColor = cyan;
    } else if (wasChecked) {
      itemColor = orange.withValues(alpha: 0.12);

      borderColor = orange.withValues(alpha: 0.50);
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
                isFound
                    ? 'FOUND'
                    : isCurrent
                    ? 'CHECKING'
                    : wasChecked
                    ? 'CHECKED'
                    : '',
                style: TextStyle(
                  color: isFound
                      ? green
                      : isCurrent
                      ? cyan
                      : orange,
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
                width: isCurrent || isFound ? 1.6 : 1,
              ),
              boxShadow: isCurrent || isFound
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
                  color: isFound
                      ? green
                      : isCurrent
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
        _legendItem('Checking', cyan),
        _legendItem('Checked', orange),
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
    String currentElement = '-';

    if (currentIndex >= 0 && currentIndex < array.length) {
      currentElement = array[currentIndex].toString();
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
            child: const Icon(Icons.search_rounded, color: cyan, size: 18),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Search',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.42),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  currentIndex >= 0
                      ? 'Index $currentIndex → Value $currentElement'
                      : 'Waiting for execution',
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
              color: pink.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              'Target: $target',
              style: const TextStyle(
                color: pink,
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

    if (foundIndex >= 0) {
      color = green;
      icon = Icons.check_circle_rounded;
    } else if (isCompleted) {
      color = red;
      icon = Icons.cancel_rounded;
    } else if (isRunning) {
      color = orange;
      icon = Icons.play_circle_rounded;
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
<<<<<<< HEAD
              color: const Color(0xFF050A14),
=======
              color: AppColors.codeBackground,
>>>>>>> origin/main
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(lines.length, (index) {
                  final lineNumber = index + 1;

                  final bool active = lineNumber == activeCodeLine;

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
  // EMPTY EXECUTION
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
            'Press Next Step or Play to start',
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
  // EXECUTION STEP ITEM
  // ==========================================================================

  Widget _executionStepItem(int index, LinearSearchEvent event) {
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
}
