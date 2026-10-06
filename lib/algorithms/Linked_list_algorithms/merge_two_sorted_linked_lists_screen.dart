import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MergeTwoSortedLinkedListsScreen extends StatefulWidget {
  const MergeTwoSortedLinkedListsScreen({super.key});

  @override
  State<MergeTwoSortedLinkedListsScreen> createState() =>
      _MergeTwoSortedLinkedListsScreenState();
}

enum MergeEventType {
  initialize,
  split,
  compare,
  takeLeft,
  takeRight,
  mergeComplete,
  resultFound,
  invalid,
}

class MergeEvent {
  final MergeEventType type;
  final List<int> list;
  final int leftIndex;
  final int rightIndex;
  final int activeIndex;
  final int rangeStart;
  final int rangeEnd;
  final String title;
  final String description;
  final String operation;
  final int iteration;

  const MergeEvent({
    required this.type,
    required this.list,
    required this.leftIndex,
    required this.rightIndex,
    required this.activeIndex,
    required this.rangeStart,
    required this.rangeEnd,
    required this.title,
    required this.description,
    required this.operation,
    this.iteration = 0,
  });
}

class _MergeTwoSortedLinkedListsScreenState
    extends State<MergeTwoSortedLinkedListsScreen> {
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

  List<int> linkedList = [1, 3, 5, 8];
  List<int> secondList = [2, 4, 6, 9];
  List<int> originalList = [1, 3, 5, 8];
  List<int> originalSecondList = [2, 4, 6, 9];
  List<int> mergedList = [];

  final TextEditingController listController = TextEditingController(
    text: '1, 3, 5, 8',
  );
  final TextEditingController secondListController = TextEditingController(
    text: '2, 4, 6, 9',
  );

  List<MergeEvent> events = [];
  List<MergeEvent> executionHistory = [];

  int currentStep = 0;
  bool isRunning = false;
  bool isCompleted = false;
  double speed = 1.0;
  Timer? timer;

  int leftIndex = -1;
  int rightIndex = -1;
  int activeIndex = -1;
  int rangeStart = -1;
  int rangeEnd = -1;
  int activeCodeLine = 0;
  int iteration = 0;

  String executionMessage = 'Ready to merge two sorted linked lists.';

  final String sourceCode = '''
class Node {
  int data;
  Node? next;

  Node(this.data);
}

Node? mergeTwoLists(Node? list1, Node? list2) {
  final dummy = Node(0);
  Node tail = dummy;

  while (list1 != null && list2 != null) {
    if (list1.data <= list2.data) {
      tail.next = list1;
      list1 = list1.next;
    } else {
      tail.next = list2;
      list2 = list2.next;
    }

    tail = tail.next!;
  }

  tail.next = list1 ?? list2;
  return dummy.next;
}
''';

  @override
  void initState() {
    super.initState();
    originalList = [...linkedList];
    originalSecondList = [...secondList];
    _generateEvents();
  }

  @override
  void dispose() {
    timer?.cancel();
    listController.dispose();
    secondListController.dispose();
    super.dispose();
  }

  void _generateEvents() {
    final left = [...linkedList];
    final right = [...secondList];
    final generated = <MergeEvent>[];
    var step = 0;
    var i = 0;
    var j = 0;
    final result = <int>[];

    void addEvent({
      required MergeEventType type,
      required String title,
      required String description,
      required String operation,
      int leftPos = -1,
      int rightPos = -1,
      int active = -1,
    }) {
      step++;
      generated.add(
        MergeEvent(
          type: type,
          list: [...result],
          leftIndex: leftPos,
          rightIndex: rightPos,
          activeIndex: active,
          rangeStart: 0,
          rangeEnd: result.isEmpty ? -1 : result.length - 1,
          title: title,
          description: description,
          operation: operation,
          iteration: step,
        ),
      );
    }

    addEvent(
      type: MergeEventType.initialize,
      title: 'Two Sorted Lists Initialized',
      description:
          'Both linked lists are already sorted and ready to be merged.',
      operation: 'mergeTwoLists(list1, list2)',
      leftPos: left.isEmpty ? -1 : 0,
      rightPos: right.isEmpty ? -1 : 0,
    );

    while (i < left.length && j < right.length) {
      addEvent(
        type: MergeEventType.compare,
        title: 'Compare Front Nodes',
        description:
            'Compare the current node from List 1 with the current node from List 2.',
        operation: 'if (list1.data <= list2.data)',
        leftPos: i,
        rightPos: j,
      );

      if (left[i] <= right[j]) {
        result.add(left[i]);
        addEvent(
          type: MergeEventType.takeLeft,
          title: 'Take From List 1',
          description:
              '${left[i]} is smaller or equal, so it is appended to the merged list.',
          operation: 'tail.next = list1; list1 = list1.next;',
          leftPos: i,
          rightPos: j,
          active: result.length - 1,
        );
        i++;
      } else {
        result.add(right[j]);
        addEvent(
          type: MergeEventType.takeRight,
          title: 'Take From List 2',
          description:
              '${right[j]} is smaller, so it is appended to the merged list.',
          operation: 'tail.next = list2; list2 = list2.next;',
          leftPos: i,
          rightPos: j,
          active: result.length - 1,
        );
        j++;
      }
    }

    while (i < left.length) {
      result.add(left[i]);
      addEvent(
        type: MergeEventType.takeLeft,
        title: 'Append Remaining List 1',
        description: '${left[i]} remains in List 1 and is appended directly.',
        operation: 'tail.next = list1 ?? list2',
        leftPos: i,
        rightPos: -1,
        active: result.length - 1,
      );
      i++;
    }

    while (j < right.length) {
      result.add(right[j]);
      addEvent(
        type: MergeEventType.takeRight,
        title: 'Append Remaining List 2',
        description: '${right[j]} remains in List 2 and is appended directly.',
        operation: 'tail.next = list1 ?? list2',
        leftPos: -1,
        rightPos: j,
        active: result.length - 1,
      );
      j++;
    }

    generated.add(
      MergeEvent(
        type: MergeEventType.mergeComplete,
        list: [...result],
        leftIndex: -1,
        rightIndex: -1,
        activeIndex: -1,
        rangeStart: 0,
        rangeEnd: result.isEmpty ? -1 : result.length - 1,
        title: 'Lists Merged',
        description:
            'Both sorted linked lists are now combined into one sorted linked list.',
        operation: 'return dummy.next',
        iteration: ++step,
      ),
    );

    generated.add(
      MergeEvent(
        type: MergeEventType.resultFound,
        list: [...result],
        leftIndex: -1,
        rightIndex: -1,
        activeIndex: -1,
        rangeStart: 0,
        rangeEnd: result.isEmpty ? -1 : result.length - 1,
        title: 'Merged List Ready',
        description:
            'The final linked list contains all nodes in ascending order.',
        operation: 'return dummy.next',
        iteration: ++step,
      ),
    );

    mergedList = [...result];
    events = generated;
  }

  void _loadList() {
    final firstText = listController.text.trim();
    final secondText = secondListController.text.trim();

    List<int>? parse(String value) {
      if (value.isEmpty) return null;
      final values = <int>[];
      for (final part in value.split(RegExp(r'[\s,]+'))) {
        final number = int.tryParse(part);
        if (number != null) values.add(number);
      }
      return values.isEmpty ? null : values;
    }

    final first = parse(firstText);
    final second = parse(secondText);

    if (first == null || second == null) {
      _showSnackBar('Please enter valid numbers in both sorted lists.', red);
      return;
    }

    if (!_isSorted(first) || !_isSorted(second)) {
      _showSnackBar('Both input lists must already be sorted.', orange);
      return;
    }

    timer?.cancel();

    setState(() {
      linkedList = [...first];
      secondList = [...second];
      originalList = [...first];
      originalSecondList = [...second];
      mergedList = [];
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      leftIndex = -1;
      rightIndex = -1;
      activeIndex = -1;
      rangeStart = -1;
      rangeEnd = -1;
      activeCodeLine = 0;
      iteration = 0;
      executionMessage = 'Two sorted linked lists loaded. Ready to merge.';
    });

    _generateEvents();
    _showSnackBar('Both sorted linked lists loaded successfully.', green);
  }

  bool _isSorted(List<int> values) {
    for (var i = 1; i < values.length; i++) {
      if (values[i - 1] > values[i]) return false;
    }
    return true;
  }

  void _generateNumbers() {
    final random = Random();
    final first = List.generate(5, (_) => random.nextInt(80) + 10)..sort();
    final second = List.generate(5, (_) => random.nextInt(80) + 10)..sort();

    listController.text = first.join(', ');
    secondListController.text = second.join(', ');
    timer?.cancel();

    setState(() {
      linkedList = [...first];
      secondList = [...second];
      originalList = [...first];
      originalSecondList = [...second];
      mergedList = [];
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      leftIndex = -1;
      rightIndex = -1;
      activeIndex = -1;
      rangeStart = -1;
      rangeEnd = -1;
      activeCodeLine = 0;
      iteration = 0;
      executionMessage = 'Generated two sorted linked lists. Ready to merge.';
    });

    _generateEvents();
  }

  void _applyEvent(MergeEvent event, {bool updateState = true}) {
    leftIndex = event.leftIndex;
    rightIndex = event.rightIndex;
    activeIndex = event.activeIndex;
    rangeStart = event.rangeStart;
    rangeEnd = event.rangeEnd;
    iteration = event.iteration;
    mergedList = [...event.list];
    executionMessage = '${event.title}: ${event.description}';
    activeCodeLine = _codeLineForEvent(event.type);

    if (event.type == MergeEventType.resultFound) {
      mergedList = [...event.list];
      executionMessage = 'Merged List → ${mergedList.join(', ')}';
    }

    if (updateState) setState(() {});
  }

  void _reset() {
    timer?.cancel();

    setState(() {
      linkedList = [...originalList];
      secondList = [...originalSecondList];
      mergedList = [];
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      leftIndex = -1;
      rightIndex = -1;
      activeIndex = -1;
      rangeStart = -1;
      rangeEnd = -1;
      activeCodeLine = 0;
      iteration = 0;
      executionMessage = 'Ready to merge two sorted linked lists.';
    });

    _generateEvents();
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
    secondList = [...originalSecondList];
    mergedList = [];
    leftIndex = -1;
    rightIndex = -1;
    activeIndex = -1;
    rangeStart = -1;
    rangeEnd = -1;
    activeCodeLine = 0;
    iteration = 0;
    executionMessage = 'Ready to merge two sorted linked lists.';

    for (final event in executionHistory) {
      _applyEvent(event, updateState: false);
    }
  }

  void _setSpeed(double value) {
    setState(() => speed = value);
    if (isRunning) _play();
  }

  String _currentPhase() {
    if (_currentStepType() == MergeEventType.resultFound ||
        _currentStepType() == MergeEventType.mergeComplete) {
      return 'RESULT • MERGED';
    }
    if (_currentStepType() == MergeEventType.compare ||
        _currentStepType() == MergeEventType.takeLeft ||
        _currentStepType() == MergeEventType.takeRight) {
      return 'PHASE 2 • MERGE';
    }
    return 'PHASE 1 • COMPARE & MERGE';
  }

  MergeEventType? _currentStepType() {
    if (executionHistory.isEmpty) return null;
    return executionHistory.last.type;
  }

  Color _phaseColor() {
    if (_currentPhase().contains('RESULT')) return green;
    if (_currentPhase().contains('MERGE')) return purple;
    return cyan;
  }

  int _codeLineForEvent(MergeEventType type) {
    switch (type) {
      case MergeEventType.initialize:
        return 8;
      case MergeEventType.split:
        return 10;
      case MergeEventType.compare:
        return 13;
      case MergeEventType.takeLeft:
        return 14;
      case MergeEventType.takeRight:
        return 17;
      case MergeEventType.mergeComplete:
      case MergeEventType.resultFound:
        return 24;
      case MergeEventType.invalid:
        return 7;
    }
  }

  Color _eventColor(MergeEventType type) {
    switch (type) {
      case MergeEventType.initialize:
        return blue;
      case MergeEventType.split:
        return cyan;
      case MergeEventType.compare:
        return pink;
      case MergeEventType.takeLeft:
        return green;
      case MergeEventType.takeRight:
        return orange;
      case MergeEventType.mergeComplete:
        return purple;
      case MergeEventType.resultFound:
        return green;
      case MergeEventType.invalid:
        return red;
    }
  }

  IconData _eventIcon(MergeEventType type) {
    switch (type) {
      case MergeEventType.initialize:
        return Icons.play_arrow_rounded;
      case MergeEventType.split:
        return Icons.call_split_rounded;
      case MergeEventType.compare:
        return Icons.compare_arrows_rounded;
      case MergeEventType.takeLeft:
        return Icons.arrow_back_rounded;
      case MergeEventType.takeRight:
        return Icons.arrow_forward_rounded;
      case MergeEventType.mergeComplete:
        return Icons.merge_type_rounded;
      case MergeEventType.resultFound:
        return Icons.check_circle_rounded;
      case MergeEventType.invalid:
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
                      'Merge Two Sorted Linked Lists',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Two-pointer merge • compare → select → append',
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
                  'Merge Two Sorted Lists • O(n + m)',
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
                  'WRITE',
                  isCompleted ? 'MERGED' : 'ASCENDING',
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
      color = green;
      text = 'SORTED';
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
            'Merge Two Sorted Linked Lists',
            cyan,
          ),
          const SizedBox(height: 12),
          Text(
            'Merge Two Sorted Linked Lists compares the front nodes of two already sorted linked lists and repeatedly appends the smaller node to the merged list. When one list is exhausted, the remaining nodes are appended directly.',
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
              _infoBox('Time', 'O(n + m)', orange),
              _infoBox('Space', 'O(1)', blue),
              _infoBox('Phase 1', 'Compare Nodes', purple),
              _infoBox('Phase 2', 'Append in Order', green),
              _infoBox('Compare', '2 nodes', cyan),
              _infoBox('Merge', 'Ascending', orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseRail() {
    final phase = _currentPhase();
    final p1 = phase.contains('COMPARE');
    final p2 = phase.contains('MERGE');
    final p3 = phase.contains('RESULT');
    return Row(
      children: [
        Expanded(
          child: _phaseBox('01', 'COMPARE', 'Compare front nodes', p1, cyan),
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
          child: _phaseBox('02', 'MERGE', 'Compare + place', p2, purple),
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
          child: _phaseBox('03', 'MERGED', 'Final list ready', p3, green),
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
              final fields = Column(
                children: [
                  _inputField(
                    controller: listController,
                    label: 'Sorted Linked List 1',
                    hint: '1, 3, 5, 8',
                    color: cyan,
                  ),
                  const SizedBox(height: 10),
                  _inputField(
                    controller: secondListController,
                    label: 'Sorted Linked List 2',
                    hint: '2, 4, 6, 9',
                    color: orange,
                  ),
                ],
              );

              if (constraints.maxWidth < 700) {
                return Column(
                  children: [
                    fields,
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
                  Expanded(child: fields),
                  const SizedBox(width: 10),
                  SizedBox(width: 150, child: _generateButton()),
                  const SizedBox(width: 10),
                  SizedBox(width: 150, child: _loadButton()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required Color color,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      cursorColor: color,
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
        prefixIcon: Icon(
          Icons.link_rounded,
          color: color.withValues(alpha: 0.8),
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
          borderSide: BorderSide(color: color.withValues(alpha: 0.55)),
        ),
      ),
    );
  }

  Widget _buildLivePhaseBanner() {
    final phase = _currentPhase();
    final color = _phaseColor();
    final isResult = phase.contains('RESULT');
    final isMerge = phase.contains('MERGE');

    final text = isResult
        ? 'Both sorted linked lists have been completely merged into one sorted list.'
        : isMerge
        ? 'Compare the current nodes from List 1 and List 2, then append the smaller value.'
        : 'The two sorted linked lists are ready. Start the merge to compare their current nodes.';

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
              isResult
                  ? Icons.check_circle_rounded
                  : isMerge
                  ? Icons.compare_arrows_rounded
                  : Icons.play_arrow_rounded,
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

  Widget _buildVisualization() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.account_tree_rounded,
            'Live Merge Visualization',
            cyan,
          ),
          const SizedBox(height: 10),
          _buildLivePhaseBanner(),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniBadge(
                'LIST 1',
                leftIndex >= 0 ? '$leftIndex' : 'NULL',
                cyan,
              ),
              const SizedBox(width: 8),
              _miniBadge(
                'LIST 2',
                rightIndex >= 0 ? '$rightIndex' : 'NULL',
                orange,
              ),
              const SizedBox(width: 8),
              _miniBadge(
                'WRITE',
                activeIndex >= 0 ? 'INDEX $activeIndex' : '—',
                green,
              ),
              const SizedBox(width: 8),
              _miniBadge('STEPS', executionHistory.length.toString(), pink),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSourceRow('LIST 1', linkedList, cyan, leftIndex),
                  const SizedBox(height: 12),
                  _buildSourceRow('LIST 2', secondList, orange, rightIndex),
                  const SizedBox(height: 16),
                  _buildMergedRow(),
                ],
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

  Widget _buildSourceRow(
    String title,
    List<int> values,
    Color color,
    int active,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 74,
          child: Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        ...List.generate(
          values.length,
          (index) =>
              _buildMergeNode(values[index], index, index == active, color),
        ),
      ],
    );
  }

  Widget _buildMergedRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 74),
        ...List.generate(
          mergedList.length,
          (index) => _buildMergeNode(
            mergedList[index],
            index,
            index == activeIndex,
            green,
          ),
        ),
      ],
    );
  }

  Widget _buildMergeNode(int value, int index, bool active, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 52,
          margin: const EdgeInsets.only(right: 5),
          decoration: BoxDecoration(
            color: active
                ? color.withValues(alpha: 0.18)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: active ? color : Colors.white.withValues(alpha: 0.08),
              width: active ? 1.7 : 1,
            ),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.18),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '$value',
              style: TextStyle(
                color: active ? color : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
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
        _legendItem('List 1 Pointer', cyan),
        _legendItem('List 2 Pointer', orange),
        _legendItem('Merged', green),
        _legendItem('Compare / Merge', purple),
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

    if (activeIndex >= 0 && activeIndex < mergedList.length) {
      message = 'Merged → ${mergedList.join(', ')}';
    } else if (leftIndex >= 0 &&
        rightIndex >= 0 &&
        leftIndex < linkedList.length &&
        rightIndex < secondList.length) {
      message =
          'List 1 → ${linkedList[leftIndex]}    •    List 2 → ${secondList[rightIndex]}';
    } else if (leftIndex >= 0 && leftIndex < linkedList.length) {
      message = 'List 1 → ${linkedList[leftIndex]}    •    List 2 → remaining';
    } else if (rightIndex >= 0 && rightIndex < secondList.length) {
      message = 'List 1 → remaining    •    List 2 → ${secondList[rightIndex]}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Icon(Icons.compare_arrows_rounded, color: purple, size: 17),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (mergedList.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                'Merged → ${mergedList.join(', ')}',
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

  Widget _executionStepItem(int index, MergeEvent event) {
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
