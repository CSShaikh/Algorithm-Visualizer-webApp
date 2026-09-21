import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';

class CountingSortScreen extends StatefulWidget {
  const CountingSortScreen({super.key});

  @override
  State<CountingSortScreen> createState() => _CountingSortScreenState();
}

enum CountingSortEventType { initialize, count, buildOutput, complete }

class CountingSortEvent {
  final CountingSortEventType type;
  final List<int> input;
  final List<int> counts;
  final List<int> output;
  final int currentValue;
  final int currentIndex;
  final String title;
  final String description;
  final String operation;
  final int codeLine;

  const CountingSortEvent({
    required this.type,
    required this.input,
    required this.counts,
    required this.output,
    this.currentValue = -1,
    this.currentIndex = -1,
    required this.title,
    required this.description,
    required this.operation,
    required this.codeLine,
  });
}

class _CountingSortScreenState extends State<CountingSortScreen> {
  static const Color background = AppColors.background;
  static const Color background2 = AppColors.background2;
  static const Color cardColor = AppColors.card;
  static const Color visualizationColor = background2;

  static const Color cyan = AppColors.cyan;
  static const Color blue = AppColors.blue;
  static const Color purple = AppColors.purple;
  static const Color green = AppColors.green;
  static const Color orange = AppColors.orange;
  static const Color pink = AppColors.pink;
  static const Color red = AppColors.error;

  static const String sourceCode = r'''List<int> countingSort(List<int> arr) {
  final maxValue = arr.reduce(max);
  final count = List.filled(maxValue + 1, 0);

  for (final value in arr) {
    count[value]++;
  }

  final output = <int>[];

  for (var value = 0; value <= maxValue; value++) {
    while (count[value] > 0) {
      output.add(value);
      count[value]--;
    }
  }

  return output;
}''';

  final TextEditingController arrayController = TextEditingController(
    text: '4, 2, 2, 8, 3, 3, 1',
  );

  List<int> array = [4, 2, 2, 8, 3, 3, 1];
  List<int> originalArray = [4, 2, 2, 8, 3, 3, 1];

  final List<CountingSortEvent> events = [];
  final List<CountingSortEvent> executionHistory = [];

  Timer? timer;
  int currentStep = 0;
  int activeCodeLine = 0;
  bool isRunning = false;
  bool isCompleted = false;
  double speed = 1.0;

  List<int> countArray = [];
  List<int> outputArray = [];
  int currentIndex = -1;
  int currentValue = -1;
  String executionMessage = 'Ready to start Counting Sort';

  @override
  void initState() {
    super.initState();
    _generateEvents();
  }

  @override
  void dispose() {
    timer?.cancel();
    arrayController.dispose();
    super.dispose();
  }

  List<int> _parseInput(String value) {
    return value
        .split(RegExp(r'[,;\s]+'))
        .where((e) => e.trim().isNotEmpty)
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();
  }

  void _generateEvents() {
    timer?.cancel();

    final parsed = _parseInput(arrayController.text);

    events.clear();
    executionHistory.clear();
    currentStep = 0;
    activeCodeLine = 0;
    isRunning = false;
    isCompleted = false;
    currentIndex = -1;
    currentValue = -1;
    outputArray = [];

    if (parsed.isEmpty || parsed.any((value) => value < 0)) {
      array = List<int>.from(parsed);
      originalArray = List<int>.from(parsed);
      countArray = [];
      executionMessage = 'Enter non-negative integers separated by commas.';
      setState(() {});
      return;
    }

    final maxValue = parsed.reduce(max);

    if (maxValue > 100) {
      array = List<int>.from(parsed);
      originalArray = List<int>.from(parsed);
      countArray = [];
      executionMessage = 'For visualization, use values from 0 to 100.';
      setState(() {});
      return;
    }

    array = List<int>.from(parsed);
    originalArray = List<int>.from(parsed);

    final counts = List<int>.filled(maxValue + 1, 0);

    events.add(
      CountingSortEvent(
        type: CountingSortEventType.initialize,
        input: List<int>.from(parsed),
        counts: List<int>.from(counts),
        output: const [],
        title: 'Initialize',
        description: 'Create a counting array from 0 to the maximum value.',
        operation: 'count = [0] * (${maxValue + 1})',
        codeLine: 3,
      ),
    );

    for (var index = 0; index < parsed.length; index++) {
      final value = parsed[index];
      counts[value]++;

      events.add(
        CountingSortEvent(
          type: CountingSortEventType.count,
          input: List<int>.from(parsed),
          counts: List<int>.from(counts),
          output: const [],
          currentValue: value,
          currentIndex: index,
          title: 'Count $value',
          description:
              'Read $value and increase its frequency to ${counts[value]}.',
          operation: 'count[$value]++  →  ${counts[value]}',
          codeLine: 6,
        ),
      );
    }

    final output = <int>[];

    for (var value = 0; value < counts.length; value++) {
      while (counts[value] > 0) {
        output.add(value);
        counts[value]--;

        events.add(
          CountingSortEvent(
            type: CountingSortEventType.buildOutput,
            input: List<int>.from(parsed),
            counts: List<int>.from(counts),
            output: List<int>.from(output),
            currentValue: value,
            currentIndex: value,
            title: 'Place $value',
            description:
                'Take one occurrence of $value and place it into the sorted output.',
            operation: 'output.add($value)',
            codeLine: 11,
          ),
        );
      }
    }

    events.add(
      CountingSortEvent(
        type: CountingSortEventType.complete,
        input: List<int>.from(parsed),
        counts: List<int>.from(counts),
        output: List<int>.from(output),
        title: 'Sorting Complete',
        description: 'All counted values have been written in ascending order.',
        operation: 'return output',
        codeLine: 15,
      ),
    );

    countArray = List<int>.filled(maxValue + 1, 0);
    outputArray = [];
    executionMessage = 'Ready to start Counting Sort';
    setState(() {});
  }

  void _applyEvent(CountingSortEvent event) {
    setState(() {
      countArray = List<int>.from(event.counts);
      outputArray = List<int>.from(event.output);
      currentIndex = event.currentIndex;
      currentValue = event.currentValue;
      activeCodeLine = event.codeLine;
      executionMessage = event.description;

      array = event.type == CountingSortEventType.complete
          ? List<int>.from(event.output)
          : List<int>.from(event.input);
    });
  }

  void _nextStep() {
    if (currentStep >= events.length) return;

    final event = events[currentStep];
    currentStep++;
    executionHistory.add(event);
    _applyEvent(event);

    if (currentStep >= events.length) {
      timer?.cancel();
      setState(() {
        isRunning = false;
        isCompleted = true;
      });
    }
  }

  void _rebuildPreviousState() {
    countArray = [];
    outputArray = [];
    array = List<int>.from(originalArray);
    currentIndex = -1;
    currentValue = -1;
    activeCodeLine = 0;
    executionMessage = 'Ready to start Counting Sort';

    for (final event in executionHistory) {
      countArray = List<int>.from(event.counts);
      outputArray = List<int>.from(event.output);
      currentIndex = event.currentIndex;
      currentValue = event.currentValue;
      activeCodeLine = event.codeLine;
      executionMessage = event.description;

      if (event.type == CountingSortEventType.complete) {
        array = List<int>.from(event.output);
      }
    }
  }

  void _previousStep() {
    timer?.cancel();
    if (executionHistory.isEmpty) return;

    executionHistory.removeLast();
    currentStep = executionHistory.length;
    isRunning = false;
    isCompleted = false;
    setState(_rebuildPreviousState);
  }

  void _togglePlay() {
    if (isRunning) {
      timer?.cancel();
      setState(() => isRunning = false);
      return;
    }

    if (events.isEmpty) {
      _generateEvents();
      return;
    }

    if (currentStep >= events.length) {
      _generateEvents();
    }

    setState(() => isRunning = true);

    timer = Timer.periodic(
      Duration(milliseconds: (900 / speed).round().clamp(120, 1800)),
      (_) {
        if (currentStep >= events.length) {
          timer?.cancel();
          setState(() => isRunning = false);
          return;
        }
        _nextStep();
      },
    );
  }

  void _reset() {
    timer?.cancel();
    executionHistory.clear();
    currentStep = 0;
    activeCodeLine = 0;
    isRunning = false;
    isCompleted = false;
    array = List<int>.from(originalArray);
    countArray = [];
    outputArray = [];
    currentIndex = -1;
    currentValue = -1;
    executionMessage = 'Ready to start Counting Sort';
    setState(() {});
  }

  void _loadInput() {
    final parsed = _parseInput(arrayController.text);

    if (parsed.isEmpty || parsed.any((value) => value < 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid non-negative integers.'),
        ),
      );
      return;
    }

    if (parsed.reduce(max) > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('For visualization, maximum value is 100.'),
        ),
      );
      return;
    }

    _generateEvents();
  }

  void _generateNumbers() {
    final random = Random();
    final values = List.generate(8, (_) => random.nextInt(31));
    arrayController.text = values.join(', ');
    _generateEvents();
  }

  Future<void> _copyCode() async {
    await Clipboard.setData(const ClipboardData(text: sourceCode));

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Counting Sort source code copied.')),
    );
  }

  Color _eventColor(CountingSortEventType type) {
    switch (type) {
      case CountingSortEventType.initialize:
        return cyan;
      case CountingSortEventType.count:
        return blue;
      case CountingSortEventType.buildOutput:
        return pink;
      case CountingSortEventType.complete:
        return green;
    }
  }

  IconData _eventIcon(CountingSortEventType type) {
    switch (type) {
      case CountingSortEventType.initialize:
        return Icons.settings_rounded;
      case CountingSortEventType.count:
        return Icons.numbers_rounded;
      case CountingSortEventType.buildOutput:
        return Icons.output_rounded;
      case CountingSortEventType.complete:
        return Icons.check_circle_rounded;
    }
  }

  Widget _card({required Widget child}) => Container(
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

  Widget _sectionTitle(IconData icon, String title, Color color) => Row(
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

  Widget _statusBadge() {
    final color = isCompleted
        ? green
        : isRunning
        ? orange
        : cyan;
    final text = isCompleted
        ? 'SORTED'
        : isRunning
        ? 'RUNNING'
        : 'READY';

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

  Widget _buildHeader() => _card(
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cyan.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.bar_chart_rounded, color: cyan),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Counting Sort',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Sort non-negative integers by counting frequencies and rebuilding the sorted output.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        _statusBadge(),
      ],
    ),
  );

  Widget _buildAlgorithmInfo() => _card(
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
          'Counting Sort counts how many times each integer occurs. '
          'It then visits the count array in ascending order and '
          'reconstructs the sorted output.',
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
            _infoBox('Time', 'O(n + k)', orange),
            _infoBox('Space', 'O(k)', blue),
            _infoBox('Type', 'Sorting', purple),
            _infoBox('Best', 'O(n + k)', green),
            _infoBox('Worst', 'O(n + k)', red),
            _infoBox('Input', 'Non-negative', cyan),
          ],
        ),
      ],
    ),
  );

  Widget _buildInputSection() => _card(
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
                'Use non-negative integers. Example: 4, 2, 2, 8, 3, 3, 1',
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

  Widget _inputField() => TextField(
    controller: arrayController,
    style: const TextStyle(color: Colors.white, fontSize: 13),
    cursorColor: cyan,
    decoration: InputDecoration(
      labelText: 'Enter Numbers',
      hintText: '4, 2, 2, 8, 3, 3, 1',
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
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

  Widget _generateButton() => ElevatedButton.icon(
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

  Widget _loadButton() => ElevatedButton.icon(
    onPressed: _loadInput,
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

  Widget _buildVisualization() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(Icons.bar_chart_rounded, 'Visualization', cyan),
        const SizedBox(height: 12),
        Row(
          children: [
            _miniBadge(
              'CURRENT',
              currentValue >= 0 ? '$currentValue' : '-',
              cyan,
            ),
            const SizedBox(width: 8),
            _miniBadge('OUTPUT', '${outputArray.length}', green),
            const SizedBox(width: 8),
            _miniBadge('STEPS', '${executionHistory.length}', purple),
          ],
        ),
        const SizedBox(height: 16),
        _visualSection('Input Array', array, currentIndex, currentValue),
        const SizedBox(height: 14),
        _buildCountArray(),
        const SizedBox(height: 14),
        _visualSection('Sorted Output', outputArray, -1, -1),
        const SizedBox(height: 14),
        _buildCurrentInfo(),
        const SizedBox(height: 12),
        _buildStatusCard(),
      ],
    ),
  );

  Widget _visualSection(
    String title,
    List<int> values,
    int activeIndex,
    int activeValue,
  ) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: visualizationColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.58),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        if (values.isEmpty)
          Text(
            'Waiting for execution...',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.30),
              fontSize: 10,
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(values.length, (index) {
                final active =
                    index == activeIndex && values[index] == activeValue;

                return Container(
                  width: 58,
                  height: 58,
                  margin: const EdgeInsets.only(right: 7),
                  decoration: BoxDecoration(
                    color: active
                        ? cyan.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: active
                          ? cyan
                          : Colors.white.withValues(alpha: 0.08),
                      width: active ? 1.6 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${values[index]}',
                      style: TextStyle(
                        color: active ? cyan : Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    ),
  );

  Widget _buildCountArray() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: visualizationColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: blue.withValues(alpha: 0.14)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Count Array / Frequency Table',
          style: TextStyle(
            color: blue.withValues(alpha: 0.85),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        if (countArray.isEmpty)
          Text(
            'Count array will appear after initialization.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.30),
              fontSize: 10,
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(countArray.length, (index) {
                final active = index == currentValue;

                return Container(
                  width: 48,
                  margin: const EdgeInsets.only(right: 5),
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: active
                        ? blue.withValues(alpha: 0.18)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: active
                          ? blue
                          : Colors.white.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$index',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.38),
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${countArray[index]}',
                        style: TextStyle(
                          color: active ? blue : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
      ],
    ),
  );

  Widget _buildCurrentInfo() => Container(
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
          child: const Icon(Icons.swap_horiz_rounded, color: cyan, size: 18),
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
                executionMessage,
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
            '${outputArray.length} output',
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

  Widget _buildStatusCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: isCompleted
          ? green.withValues(alpha: 0.06)
          : cyan.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(
        color: isCompleted
            ? green.withValues(alpha: 0.18)
            : cyan.withValues(alpha: 0.12),
      ),
    ),
    child: Row(
      children: [
        Icon(
          isCompleted
              ? Icons.check_circle_outline_rounded
              : Icons.timeline_rounded,
          color: isCompleted ? green : cyan,
          size: 17,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            isCompleted
                ? 'Counting Sort completed successfully.'
                : isRunning
                ? 'Algorithm is running step by step.'
                : 'Press Next Step or Play to start.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 10,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildControls() => _card(
    child: Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _controlButton(
                icon: Icons.skip_previous_rounded,
                label: 'Previous',
                onPressed: executionHistory.isEmpty ? null : _previousStep,
              ),
              const SizedBox(width: 8),
              _controlButton(
                icon: isRunning
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                label: isRunning ? 'Pause' : 'Play',
                onPressed: _togglePlay,
                primary: true,
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
                onChanged: (value) => setState(() => speed = value),
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

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool primary = false,
  }) => SizedBox(
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

  Widget _buildSourceCode() {
    final lines = sourceCode.split('\n');

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

  Widget _buildExecutionSteps() => _card(
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

  Widget _emptyExecutionState() => Container(
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

  Widget _executionStepItem(int index, CountingSortEvent event) {
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

  Widget _infoBox(String title, String value, Color color) => Container(
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

  Widget _miniBadge(String title, String value, Color color) => Expanded(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.all(constraints.maxWidth < 600 ? 10 : 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 14),
                      _buildAlgorithmInfo(),
                      const SizedBox(height: 14),
                      _buildInputSection(),
                      const SizedBox(height: 14),
                      _buildMainWorkspace(constraints.maxWidth),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
