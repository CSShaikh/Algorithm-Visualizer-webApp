import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/algorithm_screen_shell.dart';

class LevelOrderTraversalEvent {
  final int value;
  final String description;
  final int codeLine;
  const LevelOrderTraversalEvent({
    required this.value,
    required this.description,
    required this.codeLine,
  });
}

class LevelOrderTraversalScreen extends StatefulWidget {
  const LevelOrderTraversalScreen({super.key});
  @override
  State<LevelOrderTraversalScreen> createState() =>
      _LevelOrderTraversalScreenState();
}

class _LevelOrderTraversalScreenState extends State<LevelOrderTraversalScreen> {
  final String sourceCode = '''List<int> levelOrder(Node root) {
  final queue = <Node>[root];
  final result = <int>[];
  while (queue.isNotEmpty) {
    final node = queue.removeAt(0);
    result.add(node.value);
    if (node.left != null) queue.add(node.left!);
    if (node.right != null) queue.add(node.right!);
  }
  return result;
}''';
  final List<int> values = [8, 4, 12, 2, 6, 10, 14];
  List<LevelOrderTraversalEvent> events = [];
  final List<LevelOrderTraversalEvent> history = [];
  final Set<int> visited = {};
  int currentStep = 0;
  int activeCodeLine = 0;
  int currentValue = -1;
  bool isRunning = false;
  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _generateEvents() {
    events = values
        .map(
          (v) => LevelOrderTraversalEvent(
            value: v,
            description: 'Process node $v',
            codeLine: 5,
          ),
        )
        .toList();
    events.add(
      const LevelOrderTraversalEvent(
        value: -1,
        description: 'Operation complete',
        codeLine: 10,
      ),
    );
  }

  void _apply(LevelOrderTraversalEvent e) {
    setState(() {
      currentValue = e.value;
      activeCodeLine = e.codeLine;
      if (e.value >= 0) visited.add(e.value);
    });
  }

  void _nextStep() {
    if (currentStep >= events.length) return;
    final e = events[currentStep];
    history.add(e);
    _apply(e);
    currentStep++;
    if (currentStep >= events.length) isRunning = false;
  }

  void _previousStep() {
    if (currentStep <= 1) {
      _reset();
      return;
    }
    final target = currentStep - 2;
    _reset();
    for (var i = 0; i <= target; i++) {
      history.add(events[i]);
      _apply(events[i]);
      currentStep = i + 1;
    }
  }

  void _togglePlay() {
    if (events.isEmpty) _generateEvents();
    if (isRunning) {
      timer?.cancel();
      setState(() => isRunning = false);
      return;
    }
    setState(() => isRunning = true);
    timer = Timer.periodic(const Duration(milliseconds: 650), (_) {
      if (currentStep >= events.length) {
        timer?.cancel();
        setState(() => isRunning = false);
      } else {
        _nextStep();
      }
    });
  }

  void _reset() {
    timer?.cancel();
    setState(() {
      currentStep = 0;
      activeCodeLine = 0;
      currentValue = -1;
      isRunning = false;
      visited.clear();
      history.clear();
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: AlgorithmScreenShell(
      header: _header(),
      algorithmInfo: _algorithmInfo(),
      inputSection: _input(),
      visualization: _visualization(),
      controls: _controls(),
      sourceCode: _sourceCode(),
      executionSteps: _executionSteps(),
    ),
  );
  Widget _header() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.background2,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.cyan.withValues(alpha: .16)),
    ),
    child: Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.cyan.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.account_tree_rounded, color: AppColors.cyan),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Level Order Traversal',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    ),
  );
  Widget _algorithmInfo() => _card(
    child: Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        const Text(
          'Level Order Traversal',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        _badge('O(n)', AppColors.cyan),
        _badge('Medium', AppColors.orange),
      ],
    ),
  );
  Widget _badge(String text, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .08),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withValues(alpha: .18)),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w800),
    ),
  );
  Widget _input() => _card(
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 8,
      children: [
        const Text(
          'Values: 8, 4, 12, 2, 6, 10, 14',
          style: TextStyle(color: Colors.white70, fontSize: 10.5),
        ),
        ElevatedButton(
          onPressed: () => setState(_generateEvents),
          child: const Text('Generate'),
        ),
      ],
    ),
  );
  Widget _visualization() => _card(
    child: SizedBox(
      height: 280,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_node(values[0])],
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _node(values[1]),
                const SizedBox(width: 48),
                _node(values[2]),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: values
                  .skip(3)
                  .map(
                    (v) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: _node(v),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    ),
  );
  Widget _node(int v) => Container(
    width: 48,
    height: 48,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: v == currentValue
          ? AppColors.cyan.withValues(alpha: .25)
          : visited.contains(v)
          ? AppColors.green.withValues(alpha: .15)
          : AppColors.background2,
      border: Border.all(
        color: v == currentValue
            ? AppColors.cyan
            : visited.contains(v)
            ? AppColors.green
            : Colors.white24,
        width: 2,
      ),
    ),
    child: Text(
      '$v',
      style: TextStyle(
        color: v == currentValue ? AppColors.cyan : Colors.white,
        fontWeight: FontWeight.w900,
      ),
    ),
  );
  Widget _controls() => _card(
    child: Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _button(
          Icons.skip_previous_rounded,
          'Previous',
          _previousStep,
          currentStep > 0,
        ),
        _button(
          isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          isRunning ? 'Pause' : 'Play',
          _togglePlay,
          true,
        ),
        _button(
          Icons.skip_next_rounded,
          'Next',
          _nextStep,
          currentStep < events.length,
        ),
        _button(Icons.restart_alt_rounded, 'Reset', _reset, true),
      ],
    ),
  );
  Widget _button(
    IconData icon,
    String label,
    VoidCallback action,
    bool enabled,
  ) => ElevatedButton.icon(
    onPressed: enabled ? action : null,
    icon: Icon(icon, size: 16),
    label: Text(label),
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.card,
      foregroundColor: Colors.white,
      disabledForegroundColor: Colors.white24,
    ),
  );
  Widget _sourceCode() {
    final lines = sourceCode.split('\n');
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Source Code',
            style: TextStyle(
              color: AppColors.purple,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxHeight: 430),
            decoration: BoxDecoration(
              color: AppColors.codeBackground,
              borderRadius: BorderRadius.circular(10),
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
                        ? AppColors.cyan.withValues(alpha: .10)
                        : Colors.transparent,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 26,
                          child: Text(
                            '$lineNumber',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: active ? AppColors.cyan : Colors.white24,
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
                              color: active ? Colors.white : Colors.white70,
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

  Widget _executionSteps() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Execution Steps',
                style: TextStyle(
                  color: AppColors.green,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              '${history.length}',
              style: const TextStyle(color: AppColors.green, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (history.isEmpty)
          const Padding(
            padding: EdgeInsets.all(28),
            child: Center(
              child: Text(
                'Press PLAY or NEXT to start',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 460),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: history.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text(
                  history[index].description,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
              ),
            ),
          ),
      ],
    ),
  );
  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: .06)),
    ),
    child: child,
  );
}
