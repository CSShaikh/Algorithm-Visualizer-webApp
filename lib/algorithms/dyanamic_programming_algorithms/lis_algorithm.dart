import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LisAlgorithmScreen extends StatefulWidget {
  const LisAlgorithmScreen({super.key});
  @override
  State<LisAlgorithmScreen> createState() => _LisAlgorithmScreenState();
}

enum LisEventType { initialize, compare, update, skip, backtrack, complete }

class LisEvent {
  final LisEventType type;
  final List<int> values;
  final List<int> dp;
  final List<int> parent;
  final int currentIndex;
  final int compareIndex;
  final Set<int> lisIndexes;
  final String lis;
  final String title;
  final String description;
  final String operation;
  const LisEvent({
    required this.type,
    required this.values,
    required this.dp,
    required this.parent,
    required this.currentIndex,
    required this.compareIndex,
    required this.lisIndexes,
    required this.lis,
    required this.title,
    required this.description,
    required this.operation,
  });
}

class _LisAlgorithmScreenState extends State<LisAlgorithmScreen> {
  static const Color background = Color(0xFF030712),
      background2 = Color(0xFF07101F),
      cardColor = Color(0xFF0B1428),
      visualizationColor = Color(0xFF0A1020),
      cyan = Color(0xFF00E5FF),
      blue = Color(0xFF2979FF),
      purple = Color(0xFF9C27FF),
      green = Color(0xFF00E676),
      orange = Color(0xFFFFB300),
      red = Color(0xFFFF5252);
  List<int> values = [10, 22, 9, 33, 21, 50, 41, 60];
  List<int> dp = [];
  List<int> parent = [];
  final inputController = TextEditingController(
    text: '10, 22, 9, 33, 21, 50, 41, 60',
  );
  List<LisEvent> events = [];
  List<LisEvent> executionHistory = [];
  int currentStep = 0;
  bool isRunning = false;
  bool isCompleted = false;
  double speed = 1.0;
  Timer? timer;
  int currentIndex = -1, compareIndex = -1, activeCodeLine = 0;
  Set<int> lisIndexes = {};
  String lisResult = '';
  String executionMessage =
      'Ready to start the Longest Increasing Subsequence Algorithm.';
  final String sourceCode = '''
List<int> lis(List<int> values) {
  final n = values.length;
  final dp = List.filled(n, 1);
  final parent = List.filled(n, -1);

  for (int i = 0; i < n; i++) {
    for (int j = 0; j < i; j++) {
      if (values[j] < values[i] && dp[j] + 1 > dp[i]) {
        dp[i] = dp[j] + 1;
        parent[i] = j;
      }
    }
  }

  int best = 0;
  for (int i = 1; i < n; i++) {
    if (dp[i] > dp[best]) best = i;
  }

  final result = <int>[];
  while (best != -1) {
    result.add(values[best]);
    best = parent[best];
  }
  return result.reversed.toList();
}
''';
  @override
  void initState() {
    super.initState();
    _generateEvents();
  }

  @override
  void dispose() {
    timer?.cancel();
    inputController.dispose();
    super.dispose();
  }

  List<int> _copy(List<int> v) => [...v];
  void _generateEvents() {
    final generated = <LisEvent>[];
    final n = values.length;
    var workDp = List.filled(n, 1);
    var workParent = List.filled(n, -1);
    var path = <int>{};
    var built = '';
    generated.add(
      LisEvent(
        type: LisEventType.initialize,
        values: _copy(values),
        dp: _copy(workDp),
        parent: _copy(workParent),
        currentIndex: -1,
        compareIndex: -1,
        lisIndexes: {},
        lis: '',
        title: 'LIS DP Initialized',
        description:
            'Create a DP array where every element initially forms an increasing subsequence of length 1.',
        operation: 'dp = [1, 1, ..., 1]',
      ),
    );
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < i; j++) {
        generated.add(
          LisEvent(
            type: LisEventType.compare,
            values: _copy(values),
            dp: _copy(workDp),
            parent: _copy(workParent),
            currentIndex: i,
            compareIndex: j,
            lisIndexes: {...path},
            lis: built,
            title: 'Compare Pair',
            description:
                'Compare ${values[j]} with ${values[i]} to check whether the increasing subsequence can be extended.',
            operation: 'values[$j] < values[$i] ?',
          ),
        );
        if (values[j] < values[i] && workDp[j] + 1 > workDp[i]) {
          workDp[i] = workDp[j] + 1;
          workParent[i] = j;
          generated.add(
            LisEvent(
              type: LisEventType.update,
              values: _copy(values),
              dp: _copy(workDp),
              parent: _copy(workParent),
              currentIndex: i,
              compareIndex: j,
              lisIndexes: {...path},
              lis: built,
              title: 'Update DP Value',
              description:
                  'A longer increasing subsequence is found through index $j.',
              operation: 'dp[$i] = dp[$j] + 1 = ${workDp[i]}',
            ),
          );
        } else {
          generated.add(
            LisEvent(
              type: LisEventType.skip,
              values: _copy(values),
              dp: _copy(workDp),
              parent: _copy(workParent),
              currentIndex: i,
              compareIndex: j,
              lisIndexes: {...path},
              lis: built,
              title: 'Keep Current Best',
              description:
                  'This pair does not improve the best subsequence ending at index $i.',
              operation: 'no update',
            ),
          );
        }
      }
    }
    int best = 0;
    for (int i = 1; i < n; i++) {
      if (workDp[i] > workDp[best]) best = i;
    }
    final reversed = <int>[];
    while (best != -1) {
      reversed.add(values[best]);
      path = {...path, best};
      built = reversed.reversed.join(' → ');
      generated.add(
        LisEvent(
          type: LisEventType.backtrack,
          values: _copy(values),
          dp: _copy(workDp),
          parent: _copy(workParent),
          currentIndex: best,
          compareIndex: workParent[best],
          lisIndexes: {...path},
          lis: built,
          title: 'Backtrack LIS',
          description:
              'Follow the parent index to reconstruct the increasing subsequence.',
          operation: 'result += values[$best]; index = parent[$best]',
        ),
      );
      best = workParent[best];
    }
    final finalLis = reversed.reversed.join(' → ');
    generated.add(
      LisEvent(
        type: LisEventType.complete,
        values: _copy(values),
        dp: _copy(workDp),
        parent: _copy(workParent),
        currentIndex: -1,
        compareIndex: -1,
        lisIndexes: {...path},
        lis: finalLis,
        title: 'LIS Complete',
        description:
            'The DP array is complete and the longest increasing subsequence has been reconstructed.',
        operation: 'LIS = [$finalLis] (length ${reversed.length})',
      ),
    );
    events = generated;
    dp = List.filled(n, 0);
    parent = List.filled(n, -1);
    lisIndexes.clear();
    lisResult = '';
  }

  void _applyEvent(LisEvent event, {bool updateState = true}) {
    dp = _copy(event.dp);
    parent = _copy(event.parent);
    currentIndex = event.currentIndex;
    compareIndex = event.compareIndex;
    lisIndexes = {...event.lisIndexes};
    lisResult = event.lis;
    executionMessage = '${event.title}: ${event.description}';
    activeCodeLine = _codeLineForEvent(event.type);
    if (event.type == LisEventType.complete) {
      currentIndex = -1;
      compareIndex = -1;
      executionMessage =
          'LIS Complete: "$lisResult"  •  Length = ${_lisLength(event)}.';
    }
    if (updateState) setState(() {});
  }

  int _lisLength(LisEvent e) => e.lis.isEmpty ? 0 : e.lis.split(' → ').length;
  void _rebuildVisualState() {
    dp = List.filled(values.length, 0);
    parent = List.filled(values.length, -1);
    currentIndex = -1;
    compareIndex = -1;
    activeCodeLine = 0;
    lisIndexes.clear();
    lisResult = '';
    executionMessage =
        'Ready to start the Longest Increasing Subsequence Algorithm.';
    for (final event in executionHistory) {
      _applyEvent(event, updateState: false);
    }
  }

  void _reset() {
    timer?.cancel();
    setState(() {
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      currentIndex = -1;
      compareIndex = -1;
      activeCodeLine = 0;
      lisIndexes.clear();
      lisResult = '';
      dp = List.filled(values.length, 0);
      parent = List.filled(values.length, -1);
      executionMessage =
          'Ready to start the Longest Increasing Subsequence Algorithm.';
    });
    _generateEvents();
  }

  void _setSpeed(double value) {
    setState(() => speed = value);
    if (isRunning) _play();
  }

  int _codeLineForEvent(LisEventType type) {
    switch (type) {
      case LisEventType.initialize:
        return 3;
      case LisEventType.compare:
        return 8;
      case LisEventType.update:
        return 9;
      case LisEventType.skip:
        return 11;
      case LisEventType.backtrack:
        return 21;
      case LisEventType.complete:
        return 30;
    }
  }

  Color _eventColor(LisEventType type) {
    switch (type) {
      case LisEventType.initialize:
        return blue;
      case LisEventType.compare:
        return orange;
      case LisEventType.update:
        return green;
      case LisEventType.skip:
        return purple;
      case LisEventType.backtrack:
        return cyan;
      case LisEventType.complete:
        return green;
    }
  }

  IconData _eventIcon(LisEventType type) {
    switch (type) {
      case LisEventType.initialize:
        return Icons.play_arrow_rounded;
      case LisEventType.compare:
        return Icons.compare_arrows_rounded;
      case LisEventType.update:
        return Icons.trending_up_rounded;
      case LisEventType.skip:
        return Icons.remove_rounded;
      case LisEventType.backtrack:
        return Icons.route_rounded;
      case LisEventType.complete:
        return Icons.check_circle_rounded;
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
        backgroundColor: color.withValues(alpha: .85),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<int>? _parseInput(String text) {
    final parts = text.trim().split(RegExp(r'[\s,]+'));
    if (parts.length < 2 || parts.length > 12) return null;
    final parsed = <int>[];
    for (final p in parts) {
      final v = int.tryParse(p);
      if (v == null || v < -99 || v > 999) return null;
      parsed.add(v);
    }
    return parsed;
  }

  void _loadArray() {
    final parsed = _parseInput(inputController.text);
    if (parsed == null) {
      _showSnackBar(
        'Enter 2 to 12 valid integers separated by commas or spaces.',
        red,
      );
      return;
    }
    timer?.cancel();
    setState(() {
      values = parsed;
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      currentIndex = -1;
      compareIndex = -1;
      activeCodeLine = 0;
      lisIndexes.clear();
      lisResult = '';
      dp = List.filled(values.length, 0);
      parent = List.filled(values.length, -1);
      executionMessage = 'Array loaded. Ready to find the LIS.';
    });
    _generateEvents();
    _showSnackBar('Input loaded successfully.', green);
  }

  void _generateNumbers() {
    const samples = [
      [10, 22, 9, 33, 21, 50, 41, 60],
      [3, 10, 2, 1, 20, 4, 6],
      [0, 8, 4, 12, 2, 10, 6, 14],
      [5, 4, 11, 1, 16, 7, 12],
      [10, 9, 2, 5, 3, 7, 101, 18],
    ];
    final sample = samples[Random().nextInt(samples.length)];
    inputController.text = sample.join(', ');
    timer?.cancel();
    setState(() {
      values = [...sample];
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      currentIndex = -1;
      compareIndex = -1;
      activeCodeLine = 0;
      lisIndexes.clear();
      lisResult = '';
      dp = List.filled(values.length, 0);
      parent = List.filled(values.length, -1);
      executionMessage = 'New sequence generated. Ready to find the LIS.';
    });
    _generateEvents();
    _showSnackBar('New sequence generated.', purple);
  }

  void _play() {
    if (events.isEmpty || isCompleted) return;
    timer?.cancel();
    setState(() => isRunning = true);
    final ms = (900 / speed).round().clamp(100, 2000);
    timer = Timer.periodic(Duration(milliseconds: ms), (_) {
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
    if (currentStep < events.length) _nextStepInternal();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
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
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: background2,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: cyan.withValues(alpha: .16)),
    ),
    child: Row(
      children: [
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(10),
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
            gradient: const LinearGradient(colors: [purple, cyan]),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.trending_up_rounded,
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
                'Longest Increasing Subsequence (LIS) Algorithm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Dynamic programming + parent tracking visualization',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .55),
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
  Widget _statusBadge() {
    final color = isRunning
        ? orange
        : isCompleted
        ? green
        : cyan;
    final text = isRunning
        ? 'RUNNING'
        : isCompleted
        ? 'LIS COMPLETE'
        : 'READY';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .35)),
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
              letterSpacing: .6,
            ),
          ),
        ],
      ),
    );
  }

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
          'LIS finds the longest subsequence of an array whose elements are strictly increasing, using dynamic programming and parent tracking.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .64),
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
            _infoBox('Space', 'O(n)', blue),
            _infoBox('Type', 'Dynamic Programming', purple),
            _infoBox('Method', 'DP + Parents', green),
            _infoBox('Input', 'Integer Array', red),
            _infoBox('Result', 'LIS Sequence', cyan),
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
                  _inputField(
                    'Integer Sequence',
                    inputController,
                    Icons.format_list_numbered_rounded,
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
                  child: _inputField(
                    'Integer Sequence',
                    inputController,
                    Icons.format_list_numbered_rounded,
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
            Icon(Icons.lightbulb_outline_rounded, color: orange, size: 15),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                'Use 2 to 12 integers separated by commas or spaces for a clear DP visualization.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .45),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  Widget _inputField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) => TextField(
    controller: controller,
    style: const TextStyle(color: Colors.white, fontSize: 13),
    cursorColor: cyan,
    decoration: InputDecoration(
      labelText: label,
      hintText: '10, 22, 9, 33, 21, 50, 41, 60',
      labelStyle: TextStyle(
        color: Colors.white.withValues(alpha: .58),
        fontSize: 12,
      ),
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: .25),
        fontSize: 12,
      ),
      prefixIcon: Icon(icon, color: cyan.withValues(alpha: .8), size: 19),
      filled: true,
      fillColor: visualizationColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: cyan.withValues(alpha: .55)),
      ),
    ),
  );
  Widget _generateButton() => ElevatedButton.icon(
    onPressed: _generateNumbers,
    icon: const Icon(Icons.auto_awesome_rounded, size: 17),
    label: const Text(
      'Generate Sequence',
      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: purple,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    ),
  );
  Widget _loadButton() => ElevatedButton.icon(
    onPressed: _loadArray,
    icon: const Icon(Icons.download_rounded, size: 17),
    label: const Text(
      'Load Input',
      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: cyan.withValues(alpha: .14),
      foregroundColor: cyan,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
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
        _sectionTitle(
          Icons.show_chart_rounded,
          'LIS Dynamic Programming Array',
          cyan,
        ),
        const SizedBox(height: 8),
        Text(
          'Each DP cell stores the longest increasing subsequence length ending at that index. Parent links reconstruct the final LIS.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .48),
            fontSize: 10.5,
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildDpArray(),
        ),
        const SizedBox(height: 14),
        _buildLegend(),
        const SizedBox(height: 12),
        _buildCurrentInfo(),
        const SizedBox(height: 12),
        _buildStatusCard(),
      ],
    ),
  );
  Widget _buildDpArray() => Column(
    children: [
      Row(children: [for (int i = 0; i < values.length; i++) _valueCell(i)]),
      const SizedBox(height: 5),
      Row(children: [for (int i = 0; i < dp.length; i++) _dpCell(i)]),
      const SizedBox(height: 5),
      Row(children: [for (int i = 0; i < parent.length; i++) _parentCell(i)]),
    ],
  );
  Widget _valueCell(int index) {
    final active = index == currentIndex;
    final compared = index == compareIndex;
    final inLis = lisIndexes.contains(index);
    final color = active
        ? cyan
        : compared
        ? orange
        : inLis
        ? green
        : Colors.white;
    return Container(
      width: 68,
      height: 48,
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: active
            ? cyan.withValues(alpha: .16)
            : compared
            ? orange.withValues(alpha: .10)
            : inLis
            ? green.withValues(alpha: .10)
            : background2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active
              ? cyan
              : compared
              ? orange
              : inLis
              ? green.withValues(alpha: .55)
              : Colors.white.withValues(alpha: .08),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '[$index]',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .4),
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '${values[index]}',
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dpCell(int index) {
    final active = index == currentIndex;
    final inLis = lisIndexes.contains(index);
    final color = active
        ? cyan
        : inLis
        ? green
        : Colors.white;
    return Container(
      width: 68,
      height: 44,
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: active
            ? cyan.withValues(alpha: .14)
            : inLis
            ? green.withValues(alpha: .08)
            : cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active
              ? cyan
              : inLis
              ? green.withValues(alpha: .45)
              : Colors.white.withValues(alpha: .07),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'DP',
            style: TextStyle(
              color: color.withValues(alpha: .55),
              fontSize: 8,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '${dp[index]}',
            style: TextStyle(
              color: color.withValues(alpha: .9),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _parentCell(int index) {
    final p = parent[index];
    final color = lisIndexes.contains(index)
        ? green
        : Colors.white.withValues(alpha: .55);
    return Container(
      width: 68,
      height: 34,
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: visualizationColor,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: Center(
        child: Text(
          p < 0 ? 'parent: —' : 'parent: $p',
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() => Wrap(
    spacing: 12,
    runSpacing: 8,
    children: [
      _legendItem('Current Index', cyan),
      _legendItem('Compared Index', orange),
      _legendItem('LIS Path', green),
      _legendItem('DP Value', blue),
      _legendItem('Parent Link', purple),
    ],
  );
  Widget _legendItem(String title, Color color) => Row(
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
          color: Colors.white.withValues(alpha: .58),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
  Widget _buildCurrentInfo() {
    final message = currentIndex >= 0 && compareIndex >= 0
        ? 'Compare ${values[compareIndex]} (index $compareIndex) with ${values[currentIndex]} (index $currentIndex) → DP[$currentIndex] = ${dp[currentIndex]}'
        : isCompleted
        ? 'LIS = [$lisResult]  •  Length = ${lisResult.isEmpty ? 0 : lisResult.split(' → ').length}'
        : 'Press Next Step or Play to build the LIS DP array.';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: visualizationColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cyan.withValues(alpha: .12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: cyan, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .72),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    final color = isRunning
        ? orange
        : isCompleted
        ? green
        : cyan;
    final icon = isRunning
        ? Icons.play_circle_rounded
        : isCompleted
        ? Icons.check_circle_rounded
        : Icons.info_outline_rounded;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: .18)),
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
                color: Colors.white.withValues(alpha: .72),
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: .065)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .18),
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
          color: color.withValues(alpha: .09),
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
  Widget _infoBox(String title, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .055),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: color.withValues(alpha: .16)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color.withValues(alpha: .8),
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
  // EXECUTION ITEM
  // ==========================================================================

  Widget _executionStepItem(int index, LisEvent event) {
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
}
