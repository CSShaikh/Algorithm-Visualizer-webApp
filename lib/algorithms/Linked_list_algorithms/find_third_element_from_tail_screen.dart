import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FindThirdElementFromTailScreen extends StatefulWidget {
  const FindThirdElementFromTailScreen({super.key});

  @override
  State<FindThirdElementFromTailScreen> createState() =>
      _FindThirdElementFromTailScreenState();
}

enum TailEventType {
  initialize,
  pointersSet,
  fastAdvance,
  compare,
  moveSlow,
  moveFast,
  resultFound,
  invalid,
}

class TailEvent {
  final TailEventType type;
  final List<int> list;
  final int slowIndex;
  final int fastIndex;
  final int targetIndex;
  final String title;
  final String description;
  final String operation;
  final int iteration;

  const TailEvent({
    required this.type,
    required this.list,
    required this.slowIndex,
    required this.fastIndex,
    required this.targetIndex,
    required this.title,
    required this.description,
    required this.operation,
    this.iteration = 0,
  });
}

class _FindThirdElementFromTailScreenState
    extends State<FindThirdElementFromTailScreen> {
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

  static const int targetFromTail = 3;

  List<int> linkedList = [10, 20, 30, 40, 50, 60, 70];
  List<int> originalList = [10, 20, 30, 40, 50, 60, 70];

  final TextEditingController listController = TextEditingController(
    text: '10, 20, 30, 40, 50, 60, 70',
  );

  List<TailEvent> events = [];
  List<TailEvent> executionHistory = [];

  int currentStep = 0;
  bool isRunning = false;
  bool isCompleted = false;
  double speed = 1.0;
  Timer? timer;

  int slowIndex = -1;
  int fastIndex = -1;
  int targetIndex = -1;
  int activeCodeLine = 0;
  int iteration = 0;

  String executionMessage =
      'Ready to find the 3rd element from the tail using two pointers.';

  final String sourceCode = '''
class Node {
  int data;
  Node? next;

  Node(this.data);
}

Node? findThirdFromTail(Node? head) {
  if (head == null) return null;

  Node? slow = head;
  Node? fast = head;

  // Create a gap of 3 nodes.
  for (int i = 0; i < 3; i++) {
    if (fast == null) return null;
    fast = fast.next;
  }

  // Move both pointers until fast reaches NULL.
  while (fast != null) {
    slow = slow!.next;
    fast = fast.next;
  }

  return slow;
}
''';

  @override
  void initState() {
    super.initState();
    originalList = [...linkedList];
    _generateEvents();
  }

  @override
  void dispose() {
    timer?.cancel();
    listController.dispose();
    super.dispose();
  }

  void _generateEvents() {
    final working = [...linkedList];
    final generated = <TailEvent>[];

    if (working.length < targetFromTail) {
      generated.add(
        TailEvent(
          type: TailEventType.invalid,
          list: [...working],
          slowIndex: -1,
          fastIndex: -1,
          targetIndex: -1,
          title: 'List Too Short',
          description:
              'At least 3 nodes are required to find the 3rd element from the tail.',
          operation: 'if (head == null || length < 3)',
        ),
      );
      events = generated;
      return;
    }

    generated.add(
      TailEvent(
        type: TailEventType.initialize,
        list: [...working],
        slowIndex: -1,
        fastIndex: -1,
        targetIndex: -1,
        title: 'Linked List Initialized',
        description:
            'The linked list is ready. The target is the 3rd node counted from the tail.',
        operation: 'slow = head, fast = head',
      ),
    );

    var slow = 0;
    var fast = 0;
    var step = 0;

    generated.add(
      TailEvent(
        type: TailEventType.pointersSet,
        list: [...working],
        slowIndex: slow,
        fastIndex: fast,
        targetIndex: -1,
        title: 'Slow and Fast Initialized',
        description:
            'Both pointers start at the head. Fast will move 3 nodes ahead to create the required gap.',
        operation: 'slow = head, fast = head',
        iteration: step,
      ),
    );

    // Phase 1: create a gap of exactly 3 nodes.
    for (var gap = 1; gap <= targetFromTail; gap++) {
      step++;
      fast++;
      final visualFast = fast >= working.length ? -1 : fast;

      generated.add(
        TailEvent(
          type: TailEventType.fastAdvance,
          list: [...working],
          slowIndex: slow,
          fastIndex: visualFast,
          targetIndex: -1,
          title: 'Fast Moves Ahead',
          description: visualFast == -1
              ? 'Fast moves past the tail and becomes NULL. The 3-node gap is now established.'
              : 'Fast moves one node ahead. Gap progress: $gap of $targetFromTail.',
          operation: 'fast = fast.next',
          iteration: step,
        ),
      );
    }

    if (fast >= working.length) {
      generated.add(
        TailEvent(
          type: TailEventType.compare,
          list: [...working],
          slowIndex: slow,
          fastIndex: -1,
          targetIndex: slow,
          title: '3-Node Gap Reaches NULL',
          description:
              'The list has exactly 3 nodes. Slow is already the 3rd element from the tail.',
          operation: 'fast == null',
          iteration: step,
        ),
      );

      generated.add(
        TailEvent(
          type: TailEventType.resultFound,
          list: [...working],
          slowIndex: slow,
          fastIndex: -1,
          targetIndex: slow,
          title: '3rd Element from Tail Found',
          description:
              'Slow points to index $slow with value ${working[slow]}. This is the 3rd element from the tail.',
          operation: 'return slow',
          iteration: step,
        ),
      );
      events = generated;
      return;
    }

    generated.add(
      TailEvent(
        type: TailEventType.compare,
        list: [...working],
        slowIndex: slow,
        fastIndex: fast,
        targetIndex: -1,
        title: '3-Node Gap Established',
        description:
            'Fast is exactly 3 nodes ahead of slow. Now both pointers move together.',
        operation: 'fast is 3 nodes ahead of slow',
        iteration: step,
      ),
    );

    // Phase 2: move both pointers until fast reaches the tail.
    while (fast < working.length - 1) {
      final oldSlow = slow;
      final oldFast = fast;
      step++;

      slow++;
      generated.add(
        TailEvent(
          type: TailEventType.moveSlow,
          list: [...working],
          slowIndex: slow,
          fastIndex: oldFast,
          targetIndex: -1,
          title: 'Slow Pointer Moves',
          description:
              'Slow moves from index $oldSlow to index $slow while keeping a 3-node gap.',
          operation: 'slow = slow.next',
          iteration: step,
        ),
      );

      fast++;
      generated.add(
        TailEvent(
          type: TailEventType.moveFast,
          list: [...working],
          slowIndex: slow,
          fastIndex: fast,
          targetIndex: -1,
          title: 'Fast Pointer Moves',
          description: 'Fast moves from index $oldFast to index $fast.',
          operation: 'fast = fast.next',
          iteration: step,
        ),
      );

      generated.add(
        TailEvent(
          type: TailEventType.compare,
          list: [...working],
          slowIndex: slow,
          fastIndex: fast,
          targetIndex: -1,
          title: 'Check Fast Pointer',
          description: fast == working.length - 1
              ? 'Fast reached the tail. Slow is now the 3rd element from the tail.'
              : 'Fast has not reached the tail yet, so both pointers continue.',
          operation: 'while (fast != null)',
          iteration: step,
        ),
      );
    }

    generated.add(
      TailEvent(
        type: TailEventType.resultFound,
        list: [...working],
        slowIndex: slow,
        fastIndex: fast,
        targetIndex: slow,
        title: '3rd Element from Tail Found',
        description:
            'Slow points to index $slow with value ${working[slow]}. This is the 3rd element from the tail.',
        operation: 'return slow',
        iteration: step,
      ),
    );

    events = generated;
  }

  void _loadList() {
    final text = listController.text.trim();

    if (text.isEmpty) {
      _showSnackBar('Please enter numbers.', red);
      return;
    }

    final parts = text.split(RegExp(r'[\s,]+'));
    final values = <int>[];

    for (final part in parts) {
      final value = int.tryParse(part);
      if (value != null) values.add(value);
    }

    if (values.isEmpty) {
      _showSnackBar('No valid numbers found.', red);
      return;
    }

    if (values.length < targetFromTail) {
      _showSnackBar('At least $targetFromTail elements are required.', red);
      return;
    }

    timer?.cancel();

    setState(() {
      linkedList = [...values];
      originalList = [...values];
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      slowIndex = -1;
      fastIndex = -1;
      targetIndex = -1;
      activeCodeLine = 0;
      iteration = 0;
      executionMessage =
          'Linked list loaded. Ready to find the 3rd element from the tail.';
    });

    _generateEvents();
    _showSnackBar('Linked list loaded successfully.', green);
  }

  void _generateNumbers() {
    final random = Random();
    final generated = List.generate(7, (_) => random.nextInt(90) + 10);

    listController.text = generated.join(', ');
    timer?.cancel();

    setState(() {
      linkedList = [...generated];
      originalList = [...generated];
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      slowIndex = -1;
      fastIndex = -1;
      targetIndex = -1;
      activeCodeLine = 0;
      iteration = 0;
      executionMessage =
          'New linked list generated. Ready to find the 3rd element from the tail.';
    });

    _generateEvents();
    _showSnackBar('New linked list generated.', purple);
  }

  void _play() {
    if (events.isEmpty || isCompleted) return;

    timer?.cancel();
    setState(() => isRunning = true);

    final milliseconds = (900 / speed).round().clamp(100, 2000).toInt();

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
    linkedList = [...originalList];
    slowIndex = -1;
    fastIndex = -1;
    targetIndex = -1;
    activeCodeLine = 0;
    iteration = 0;
    executionMessage =
        'Ready to find the 3rd element from the tail using two pointers.';

    for (final event in executionHistory) {
      _applyEvent(event, updateState: false);
    }
  }

  void _applyEvent(TailEvent event, {bool updateState = true}) {
    linkedList = [...event.list];
    slowIndex = event.slowIndex;
    fastIndex = event.fastIndex;
    targetIndex = event.targetIndex;
    iteration = event.iteration;
    executionMessage = '${event.title}: ${event.description}';
    activeCodeLine = _codeLineForEvent(event.type);

    if (event.type == TailEventType.resultFound) {
      executionMessage =
          '3rd Element from Tail: ${linkedList[event.targetIndex]} at index ${event.targetIndex}.';
    }

    if (event.type == TailEventType.invalid) {
      executionMessage =
          'Unable to find the 3rd element from the tail. At least 3 nodes are required.';
    }

    if (updateState) setState(() {});
  }

  void _reset() {
    timer?.cancel();

    setState(() {
      linkedList = [...originalList];
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      slowIndex = -1;
      fastIndex = -1;
      targetIndex = -1;
      activeCodeLine = 0;
      iteration = 0;
      executionMessage =
          'Ready to find the 3rd element from the tail using two pointers.';
    });

    _generateEvents();
  }

  void _setSpeed(double value) {
    setState(() => speed = value);
    if (isRunning) _play();
  }

  String _currentPhase() {
    if (targetIndex >= 0) return 'RESULT • 3RD FROM TAIL';
    final hasGap = executionHistory.any(
      (e) =>
          e.type == TailEventType.compare &&
          e.description.contains('Fast is exactly 3 nodes ahead'),
    );
    if (hasGap) return 'PHASE 2 • MOVE TO TAIL';
    return 'PHASE 1 • CREATE 3-NODE GAP';
  }

  Color _phaseColor() {
    if (_currentPhase().contains('RESULT')) return green;
    if (_currentPhase().contains('MOVE')) return purple;
    return cyan;
  }

  int _codeLineForEvent(TailEventType type) {
    switch (type) {
      case TailEventType.initialize:
        return 7;
      case TailEventType.pointersSet:
        return 10;
      case TailEventType.fastAdvance:
        return 14;
      case TailEventType.compare:
        return 18;
      case TailEventType.moveSlow:
        return 19;
      case TailEventType.moveFast:
        return 20;
      case TailEventType.resultFound:
        return 23;
      case TailEventType.invalid:
        return 8;
    }
  }

  Color _eventColor(TailEventType type) {
    switch (type) {
      case TailEventType.initialize:
        return blue;
      case TailEventType.pointersSet:
        return purple;
      case TailEventType.fastAdvance:
        return orange;
      case TailEventType.compare:
        return pink;
      case TailEventType.moveSlow:
        return cyan;
      case TailEventType.moveFast:
        return orange;
      case TailEventType.resultFound:
        return green;
      case TailEventType.invalid:
        return red;
    }
  }

  IconData _eventIcon(TailEventType type) {
    switch (type) {
      case TailEventType.initialize:
        return Icons.play_arrow_rounded;
      case TailEventType.pointersSet:
        return Icons.my_location_rounded;
      case TailEventType.fastAdvance:
        return Icons.bolt_rounded;
      case TailEventType.compare:
        return Icons.compare_arrows_rounded;
      case TailEventType.moveSlow:
        return Icons.directions_walk_rounded;
      case TailEventType.moveFast:
        return Icons.bolt_rounded;
      case TailEventType.resultFound:
        return Icons.flag_rounded;
      case TailEventType.invalid:
        return Icons.block_rounded;
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

  Widget _buildHeader() {
    final phase = _currentPhase();
    final phaseColor = _phaseColor();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            background2,
            const Color(0xFF0A1326),
            phaseColor.withValues(alpha: 0.055),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: phaseColor.withValues(alpha: 0.20)),
        boxShadow: [
          BoxShadow(
            color: phaseColor.withValues(alpha: 0.055),
            blurRadius: 28,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                borderRadius: BorderRadius.circular(11),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
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
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [orange, pink]),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: pink.withValues(alpha: 0.22),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.low_priority_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find 3rd Element from Tail',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Two pointers • fixed 3-node gap → tail-relative position',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.50),
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ),
              _statusBadge(),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _headerStat(
                  Icons.alt_route_rounded,
                  'ALGORITHM',
                  'Two Pointers • O(1)',
                  cyan,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _headerStat(
                  Icons.layers_rounded,
                  'PHASE',
                  phase,
                  phaseColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _headerStat(
                  Icons.flag_rounded,
                  'TARGET',
                  targetIndex >= 0 ? 'Index $targetIndex' : '3rd from Tail',
                  green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _headerStat(
                  Icons.timeline_rounded,
                  'PROGRESS',
                  '$currentStep/${events.length}',
                  purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerStat(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withValues(alpha: 0.13)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.34),
                    fontSize: 7.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    Color color = cyan;
    String text = 'READY';
    if (isRunning) {
      color = orange;
      text = 'RUNNING';
    } else if (isCompleted) {
      final found = executionHistory.any(
        (event) => event.type == TailEventType.resultFound,
      );
      color = found ? green : red;
      text = found ? 'FOUND' : 'NOT FOUND';
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

  Widget _buildAlgorithmInfo() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.auto_awesome_rounded,
            'Find 3rd Element from Tail',
            cyan,
          ),
          const SizedBox(height: 12),
          Text(
            'The algorithm uses two pointers. First, fast is moved 3 nodes ahead of slow. Then both pointers move one node at a time. When fast reaches the tail, slow is exactly the 3rd element from the tail.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.64),
              height: 1.55,
              fontSize: 12.2,
            ),
          ),
          const SizedBox(height: 15),
          _buildPhaseRail(),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoBox('Time', 'O(n)', orange),
              _infoBox('Space', 'O(1)', blue),
              _infoBox('Phase 1', 'Gap = 3', purple),
              _infoBox('Phase 2', 'Move Together', green),
              _infoBox('Slow', '1 step', cyan),
              _infoBox('Fast', '1 step', orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseRail() {
    final phase = _currentPhase();
    final p1 = phase.contains('CREATE');
    final p2 = phase.contains('MOVE');
    final p3 = phase.contains('RESULT');
    return Row(
      children: [
        Expanded(
          child: _phaseBox(
            '01',
            'CREATE GAP',
            'Fast → 3 nodes ahead',
            p1,
            cyan,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white.withValues(alpha: 0.18),
            size: 16,
          ),
        ),
        Expanded(
          child: _phaseBox(
            '02',
            'MOVE TO TAIL',
            'Slow + Fast → 1 step',
            p2,
            purple,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white.withValues(alpha: 0.18),
            size: 16,
          ),
        ),
        Expanded(
          child: _phaseBox('03', 'FOUND', 'Slow = 3rd from tail', p3, green),
        ),
      ],
    );
  }

  Widget _phaseBox(
    String number,
    String title,
    String subtitle,
    bool active,
    Color color,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: active
            ? color.withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: active
              ? color.withValues(alpha: 0.42)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: active ? 0.18 : 0.07),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: TextStyle(
                color: active ? color : Colors.white.withValues(alpha: 0.35),
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: active
                        ? color
                        : Colors.white.withValues(alpha: 0.38),
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.36),
                    fontSize: 7.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
                  'Enter at least 3 values. Example: 10, 20, 30, 40, 50, 60, 70',
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

  Widget _inputField() {
    return TextField(
      controller: listController,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      cursorColor: cyan,
      decoration: InputDecoration(
        labelText: 'Enter Linked List Values',
        hintText: '10, 20, 30, 40, 50, 60, 70',
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.58),
          fontSize: 12,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.25),
          fontSize: 12,
        ),
        prefixIcon: Icon(
          Icons.link_rounded,
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

  Widget _buildVisualization() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.account_tree_rounded,
            'Live Pointer Visualization',
            cyan,
          ),
          const SizedBox(height: 10),
          _buildLivePhaseBanner(),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniBadge('SLOW', slowIndex >= 0 ? '$slowIndex' : 'NULL', cyan),
              const SizedBox(width: 8),
              _miniBadge(
                'FAST',
                fastIndex >= 0 ? '$fastIndex' : 'NULL',
                orange,
              ),
              const SizedBox(width: 8),
              _miniBadge('GAP', '3 NODES', purple),
              const SizedBox(width: 8),
              _miniBadge(
                'TARGET',
                targetIndex >= 0 ? 'INDEX $targetIndex' : '3RD',
                green,
              ),
              const SizedBox(width: 8),
              _miniBadge('STEPS', executionHistory.length.toString(), pink),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 10),
            decoration: BoxDecoration(
              color: visualizationColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(
                  linkedList.length,
                  (index) => _buildListNode(index),
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

  Widget _buildLivePhaseBanner() {
    final phase = _currentPhase();
    final color = _phaseColor();
    final isResult = phase.contains('RESULT');
    final isMove = phase.contains('MOVE');
    final text = isResult
        ? 'Slow is exactly the 3rd element from the tail. The target has been found.'
        : isMove
        ? 'The 3-node gap is maintained while Slow and Fast move one node at a time.'
        : 'Fast moves 3 nodes ahead first. This creates the fixed gap needed to locate the tail-relative node.';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.10), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              isResult ? Icons.flag_rounded : Icons.radar_rounded,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  phase,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
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

  Widget _buildListNode(int index) {
    final value = linkedList[index];
    final bool isSlow = index == slowIndex;
    final bool isFast = index == fastIndex;
    final bool isTarget = index == targetIndex;
    final bool isBoth = isSlow && isFast;

    Color itemColor = Colors.white.withValues(alpha: 0.08);
    Color borderColor = Colors.white.withValues(alpha: 0.08);
    Color textColor = Colors.white;
    String label = '';

    if (isTarget) {
      itemColor = green.withValues(alpha: 0.18);
      borderColor = green;
      textColor = green;
      label = '3RD FROM TAIL';
    }
    if (isSlow) {
      itemColor = cyan.withValues(alpha: 0.18);
      borderColor = cyan;
      textColor = cyan;
      label = 'SLOW';
    }
    if (isFast) {
      itemColor = orange.withValues(alpha: 0.18);
      borderColor = orange;
      textColor = orange;
      label = 'FAST';
    }
    if (isBoth) {
      itemColor = purple.withValues(alpha: 0.20);
      borderColor = purple;
      textColor = Colors.white;
      label = 'SLOW + FAST';
    }
    if (isTarget && isSlow) label = '3RD FROM TAIL';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 92,
          child: Column(
            children: [
              SizedBox(
                height: 20,
                child: Center(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isBoth
                          ? purple
                          : isTarget
                          ? green
                          : isFast
                          ? orange
                          : isSlow
                          ? cyan
                          : Colors.white.withValues(alpha: 0.25),
                      fontSize: 7.0,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Container(
                height: 58,
                width: 64,
                decoration: BoxDecoration(
                  color: itemColor,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: borderColor,
                    width: isSlow || isFast || isTarget || isBoth ? 1.7 : 1,
                  ),
                  boxShadow: isSlow || isFast || isTarget || isBoth
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
        ),
        if (index < linkedList.length - 1)
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 1, right: 1),
            child: Column(
              children: [
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white.withValues(alpha: 0.35),
                  size: 19,
                ),
                Text(
                  'next',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.22),
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 3),
            child: Column(
              children: [
                Icon(
                  Icons.stop_rounded,
                  color: green.withValues(alpha: 0.80),
                  size: 19,
                ),
                Text(
                  'TAIL',
                  style: TextStyle(
                    color: green.withValues(alpha: 0.65),
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        _legendItem('Ready', Colors.white),
        _legendItem('Slow Pointer', cyan),
        _legendItem('Fast Pointer', orange),
        _legendItem('3rd from Tail', green),
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

  Widget _buildCurrentInfo() {
    String message = 'Waiting for execution';

    if (targetIndex >= 0 && targetIndex < linkedList.length) {
      message =
          'Answer → ${linkedList[targetIndex]}    •    Index → [$targetIndex]';
    } else if (slowIndex >= 0 &&
        slowIndex < linkedList.length &&
        fastIndex >= 0 &&
        fastIndex < linkedList.length) {
      message =
          'Slow → ${linkedList[slowIndex]}    •    Fast → ${linkedList[fastIndex]}';
    } else if (slowIndex >= 0 && slowIndex < linkedList.length) {
      message = 'Slow → ${linkedList[slowIndex]}    •    Fast → NULL';
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
          if (targetIndex >= 0 && targetIndex < linkedList.length)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                '3rd from Tail → ${linkedList[targetIndex]}',
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

  Widget _buildStatusCard() {
    Color color = cyan;
    IconData icon = Icons.info_outline_rounded;

    if (isRunning) {
      color = orange;
      icon = Icons.play_circle_rounded;
    } else if (isCompleted) {
      final found = executionHistory.any(
        (event) => event.type == TailEventType.resultFound,
      );
      color = found ? green : red;
      icon = found ? Icons.check_circle_rounded : Icons.block_rounded;
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

  Widget _generateButton() {
    return ElevatedButton.icon(
      onPressed: _generateNumbers,
      icon: const Icon(Icons.auto_awesome_rounded, size: 17),
      label: const Text(
        'Generate List',
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

  Widget _loadButton() {
    return ElevatedButton.icon(
      onPressed: _loadList,
      icon: const Icon(Icons.download_rounded, size: 17),
      label: const Text(
        'LOAD LIST',
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

  Widget _buildControls() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: cyan, size: 16),
              const SizedBox(width: 7),
              const Text(
                'Execution Controls',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                _currentPhase(),
                style: TextStyle(
                  color: _phaseColor(),
                  fontSize: 8.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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
                  return _executionStepItem(index, executionHistory[index]);
                },
              ),
            ),
        ],
      ),
    );
  }

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

  Widget _executionStepItem(int index, TailEvent event) {
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
