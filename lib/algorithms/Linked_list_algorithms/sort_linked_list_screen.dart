import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SortLinkedListScreen extends StatefulWidget {
  const SortLinkedListScreen({super.key});

  @override
  State<SortLinkedListScreen> createState() =>
      _SortLinkedListScreenState();
}

enum SortEventType {
  initialize,
  split,
  compare,
  takeLeft,
  takeRight,
  mergeComplete,
  resultFound,
  invalid,
}

class SortEvent {
  final SortEventType type;
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

  const SortEvent({
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

class _SortLinkedListScreenState extends State<SortLinkedListScreen> {
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

  List<int> linkedList = [38, 12, 45, 7, 29, 18, 50];
  List<int> originalList = [38, 12, 45, 7, 29, 18, 50];

  final TextEditingController listController = TextEditingController(
    text: '38, 12, 45, 7, 29, 18, 50',
  );

  List<SortEvent> events = [];
  List<SortEvent> executionHistory = [];

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

  String executionMessage =
      'Ready to sort the linked list using bottom-up Merge Sort.';

  final String sourceCode = '''
class Node {
  int data;
  Node? next;

  Node(this.data);
}

Node? sortLinkedList(Node? head) {
  if (head == null || head.next == null) return head;

  Node? slow = head;
  Node? fast = head.next;

  // Split the list into two halves.
  while (fast != null && fast.next != null) {
    slow = slow!.next;
    fast = fast.next!.next;
  }

  Node? right = slow!.next;
  slow.next = null;

  // Sort both halves recursively.
  final left = sortLinkedList(head);
  right = sortLinkedList(right);

  // Merge two sorted halves.
  return merge(left, right);
}

Node? merge(Node? left, Node? right) {
  final dummy = Node(0);
  Node tail = dummy;

  while (left != null && right != null) {
    if (left.data <= right.data) {
      tail.next = left;
      left = left.next;
    } else {
      tail.next = right;
      right = right.next;
    }
    tail = tail.next!;
  }

  tail.next = left ?? right;
  return dummy.next;
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
    final generated = <SortEvent>[];
    var step = 0;

    if (working.length <= 1) {
      generated.add(SortEvent(
        type: SortEventType.resultFound,
        list: [...working],
        leftIndex: -1,
        rightIndex: -1,
        activeIndex: working.isEmpty ? -1 : 0,
        rangeStart: 0,
        rangeEnd: working.isEmpty ? -1 : working.length - 1,
        title: 'List Already Sorted',
        description: 'A linked list with zero or one node is already sorted.',
        operation: 'if (head == null || head.next == null) return head;',
      ));
      events = generated;
      return;
    }

    generated.add(SortEvent(
      type: SortEventType.initialize,
      list: [...working],
      leftIndex: -1,
      rightIndex: -1,
      activeIndex: -1,
      rangeStart: 0,
      rangeEnd: working.length - 1,
      title: 'Linked List Initialized',
      description:
          'Merge Sort starts by recursively splitting the linked list into smaller halves.',
      operation: 'sortLinkedList(head)',
      iteration: step,
    ));

    void addEvent({
      required SortEventType type,
      required List<int> list,
      int left = -1,
      int right = -1,
      int active = -1,
      int start = -1,
      int end = -1,
      required String title,
      required String description,
      required String operation,
    }) {
      step++;
      generated.add(SortEvent(
        type: type,
        list: [...list],
        leftIndex: left,
        rightIndex: right,
        activeIndex: active,
        rangeStart: start,
        rangeEnd: end,
        title: title,
        description: description,
        operation: operation,
        iteration: step,
      ));
    }

    void mergeSort(List<int> arr, int start, int end) {
      if (start >= end) return;

      final mid = (start + end) ~/ 2;
      addEvent(
        type: SortEventType.split,
        list: arr,
        start: start,
        end: end,
        active: mid,
        title: 'Split Current Range',
        description:
            'Divide indexes $start–$end at midpoint $mid into two smaller sorted ranges.',
        operation: 'mid = (start + end) ~/ 2',
      );

      mergeSort(arr, start, mid);
      mergeSort(arr, mid + 1, end);

      final left = arr.sublist(start, mid + 1);
      final right = arr.sublist(mid + 1, end + 1);
      var i = 0;
      var j = 0;
      var k = start;

      while (i < left.length && j < right.length) {
        final leftPos = start + i;
        final rightPos = mid + 1 + j;

        addEvent(
          type: SortEventType.compare,
          list: arr,
          left: leftPos,
          right: rightPos,
          active: k,
          start: start,
          end: end,
          title: 'Compare Two Nodes',
          description:
              'Compare ${left[i]} from the left half with ${right[j]} from the right half.',
          operation: 'if (left.data <= right.data)',
        );

        if (left[i] <= right[j]) {
          arr[k] = left[i];
          addEvent(
            type: SortEventType.takeLeft,
            list: arr,
            left: leftPos,
            right: rightPos,
            active: k,
            start: start,
            end: end,
            title: 'Take Left Node',
            description:
                '${left[i]} is smaller or equal, so it is placed at sorted index $k.',
            operation: 'tail.next = left',
          );
          i++;
        } else {
          arr[k] = right[j];
          addEvent(
            type: SortEventType.takeRight,
            list: arr,
            left: leftPos,
            right: rightPos,
            active: k,
            start: start,
            end: end,
            title: 'Take Right Node',
            description:
                '${right[j]} is smaller, so it is placed at sorted index $k.',
            operation: 'tail.next = right',
          );
          j++;
        }
        k++;
      }

      while (i < left.length) {
        arr[k] = left[i];
        addEvent(
          type: SortEventType.takeLeft,
          list: arr,
          left: start + i,
          right: -1,
          active: k,
          start: start,
          end: end,
          title: 'Append Remaining Left',
          description:
              '${left[i]} remains in the left half and is copied into position $k.',
          operation: 'tail.next = left',
        );
        i++;
        k++;
      }

      while (j < right.length) {
        arr[k] = right[j];
        addEvent(
          type: SortEventType.takeRight,
          list: arr,
          left: -1,
          right: mid + 1 + j,
          active: k,
          start: start,
          end: end,
          title: 'Append Remaining Right',
          description:
              '${right[j]} remains in the right half and is copied into position $k.',
          operation: 'tail.next = right',
        );
        j++;
        k++;
      }

      addEvent(
        type: SortEventType.mergeComplete,
        list: arr,
        active: -1,
        start: start,
        end: end,
        title: 'Range Merged',
        description:
            'Indexes $start–$end are now sorted. Merge Sort continues with the next range.',
        operation: 'tail.next = left ?? right',
      );
    }

    mergeSort(working, 0, working.length - 1);

    addEvent(
      type: SortEventType.resultFound,
      list: working,
      active: -1,
      start: 0,
      end: working.length - 1,
      title: 'Linked List Sorted',
      description:
          'All merge ranges are complete. The linked list is now sorted in ascending order.',
      operation: 'return dummy.next',
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

    timer?.cancel();

    setState(() {
      linkedList = [...values];
      originalList = [...values];
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
      executionMessage =
          'Linked list loaded. Ready to sort using Merge Sort.';
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
      leftIndex = -1;
      rightIndex = -1;
      activeIndex = -1;
      rangeStart = -1;
      rangeEnd = -1;
      activeCodeLine = 0;
      iteration = 0;
      executionMessage =
          'New linked list generated. Ready to sort using Merge Sort.';
    });

    _generateEvents();
    _showSnackBar('New linked list generated.', purple);
  }

  void _play() {
    if (events.isEmpty || isCompleted) return;

    timer?.cancel();
    setState(() => isRunning = true);

    final milliseconds =
        (900 / speed).round().clamp(100, 2000).toInt();

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
    leftIndex = -1;
    rightIndex = -1;
    activeIndex = -1;
    rangeStart = -1;
    rangeEnd = -1;
    activeCodeLine = 0;
    iteration = 0;
    executionMessage =
        'Ready to sort the linked list using bottom-up Merge Sort.';

    for (final event in executionHistory) {
      _applyEvent(event, updateState: false);
    }
  }

  void _applyEvent(SortEvent event, {bool updateState = true}) {
    linkedList = [...event.list];
    leftIndex = event.leftIndex;
    rightIndex = event.rightIndex;
    activeIndex = event.activeIndex;
    rangeStart = event.rangeStart;
    rangeEnd = event.rangeEnd;
    iteration = event.iteration;
    executionMessage = '${event.title}: ${event.description}';
    activeCodeLine = _codeLineForEvent(event.type);

    if (event.type == SortEventType.resultFound) {
      executionMessage =
          'Linked List Sorted → ${linkedList.join(', ')}';
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
      leftIndex = -1;
      rightIndex = -1;
      activeIndex = -1;
      rangeStart = -1;
      rangeEnd = -1;
      activeCodeLine = 0;
      iteration = 0;
      executionMessage =
          'Ready to sort the linked list using Merge Sort.';
    });

    _generateEvents();
  }

  void _setSpeed(double value) {
    setState(() => speed = value);
    if (isRunning) _play();
  }

  String _currentPhase() {
    if (activeIndex >= 0 && executionHistory.any(
      (e) => e.type == SortEventType.compare ||
          e.type == SortEventType.takeLeft ||
          e.type == SortEventType.takeRight,
    )) {
      return 'PHASE 2 • MERGE';
    }

    if (executionHistory.any((e) => e.type == SortEventType.mergeComplete)) {
      return 'PHASE 2 • MERGE';
    }

    if (executionHistory.any((e) => e.type == SortEventType.split)) {
      return 'PHASE 1 • SPLIT';
    }

    if (executionHistory.any((e) => e.type == SortEventType.resultFound)) {
      return 'RESULT • SORTED';
    }

    return 'PHASE 1 • SPLIT';
  }

  Color _phaseColor() {
    if (_currentPhase().contains('RESULT')) return green;
    if (_currentPhase().contains('MERGE')) return purple;
    return cyan;
  }

  int _codeLineForEvent(SortEventType type) {
    switch (type) {
      case SortEventType.initialize:
        return 8;
      case SortEventType.split:
        return 14;
      case SortEventType.compare:
        return 36;
      case SortEventType.takeLeft:
        return 37;
      case SortEventType.takeRight:
        return 40;
      case SortEventType.mergeComplete:
        return 46;
      case SortEventType.resultFound:
        return 47;
      case SortEventType.invalid:
        return 8;
    }
  }

  Color _eventColor(SortEventType type) {
    switch (type) {
      case SortEventType.initialize:
        return blue;
      case SortEventType.split:
        return cyan;
      case SortEventType.compare:
        return pink;
      case SortEventType.takeLeft:
        return green;
      case SortEventType.takeRight:
        return orange;
      case SortEventType.mergeComplete:
        return purple;
      case SortEventType.resultFound:
        return green;
      case SortEventType.invalid:
        return red;
    }
  }

  IconData _eventIcon(SortEventType type) {
    switch (type) {
      case SortEventType.initialize:
        return Icons.play_arrow_rounded;
      case SortEventType.split:
        return Icons.call_split_rounded;
      case SortEventType.compare:
        return Icons.compare_arrows_rounded;
      case SortEventType.takeLeft:
        return Icons.arrow_back_rounded;
      case SortEventType.takeRight:
        return Icons.arrow_forward_rounded;
      case SortEventType.mergeComplete:
        return Icons.merge_type_rounded;
      case SortEventType.resultFound:
        return Icons.check_circle_rounded;
      case SortEventType.invalid:
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
        backgroundColor: color.withOpacity(0.85),
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
          colors: [background2, const Color(0xFF0A1326), phaseColor.withOpacity(0.055)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: phaseColor.withOpacity(0.20)),
        boxShadow: [
          BoxShadow(color: phaseColor.withOpacity(0.055), blurRadius: 28, spreadRadius: 2),
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
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [orange, pink]),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [BoxShadow(color: pink.withOpacity(0.22), blurRadius: 18)],
                ),
                child: const Icon(Icons.low_priority_rounded, color: Colors.white, size: 25),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Sort a Linked List',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('Merge Sort • split → compare → merge',
                      style: TextStyle(color: Colors.white.withOpacity(0.50), fontSize: 11.5)),
                  ],
                ),
              ),
              _statusBadge(),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _headerStat(Icons.alt_route_rounded, 'ALGORITHM', 'Merge Sort • O(n log n)', cyan)),
              const SizedBox(width: 8),
              Expanded(child: _headerStat(Icons.layers_rounded, 'PHASE', phase, phaseColor)),
              const SizedBox(width: 8),
              Expanded(child: _headerStat(Icons.flag_rounded, 'WRITE', isCompleted ? 'SORTED' : 'ASCENDING', green)),
              const SizedBox(width: 8),
              Expanded(child: _headerStat(Icons.timeline_rounded, 'PROGRESS', '${currentStep}/${events.length}', purple)),
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
        color: color.withOpacity(0.055),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: color.withOpacity(0.13)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 7),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(color: Colors.white.withOpacity(0.34), fontSize: 7.5, fontWeight: FontWeight.w800, letterSpacing: 0.7)),
            const SizedBox(height: 2),
            Text(value, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.78), fontSize: 9.5, fontWeight: FontWeight.w800)),
          ])),
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
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 7),
          Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
        ],
      ),
    );
  }

  Widget _buildAlgorithmInfo() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.auto_awesome_rounded, 'Sort a Linked List', cyan),
          const SizedBox(height: 12),
          Text(
            'Merge Sort recursively divides the linked list into smaller halves, sorts each half, and merges the sorted halves. During execution, the visualization shows the active range, compared nodes, and the position being written.',
            style: TextStyle(color: Colors.white.withOpacity(0.64), height: 1.55, fontSize: 12.2),
          ),
          const SizedBox(height: 15),
          _buildPhaseRail(),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              _infoBox('Time', 'O(n log n)', orange),
              _infoBox('Space', 'O(log n)', blue),
              _infoBox('Phase 1', 'Split Halves', purple),
              _infoBox('Phase 2', 'Merge Sorted', green),
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
    final p1 = phase.contains('SPLIT');
    final p2 = phase.contains('MERGE');
    final p3 = phase.contains('RESULT');
    return Row(
      children: [
        Expanded(child: _phaseBox('01', 'SPLIT', 'Divide into halves', p1, cyan)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Icon(Icons.arrow_forward_rounded, color: Colors.white.withOpacity(0.18), size: 16)),
        Expanded(child: _phaseBox('02', 'MERGE', 'Compare + place', p2, purple)),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 5), child: Icon(Icons.arrow_forward_rounded, color: Colors.white.withOpacity(0.18), size: 16)),
        Expanded(child: _phaseBox('03', 'SORTED', 'All ranges merged', p3, green)),
      ],
    );
  }

  Widget _phaseBox(String number, String title, String subtitle, bool active, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: active ? color.withOpacity(0.10) : Colors.white.withOpacity(0.025),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: active ? color.withOpacity(0.42) : Colors.white.withOpacity(0.06)),
      ),
      child: Row(children: [
        Container(width: 26, height: 26, alignment: Alignment.center,
          decoration: BoxDecoration(color: color.withOpacity(active ? 0.18 : 0.07), shape: BoxShape.circle),
          child: Text(number, style: TextStyle(color: active ? color : Colors.white.withOpacity(0.35), fontSize: 8, fontWeight: FontWeight.w900))),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(color: active ? color : Colors.white.withOpacity(0.38), fontSize: 8.5, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.36), fontSize: 7.5)),
        ])),
      ]),
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
              Icon(Icons.lightbulb_outline_rounded, color: orange.withOpacity(0.85), size: 15),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Enter numbers to sort. Example: 38, 12, 45, 7, 29, 18, 50',
                  style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 11),
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
        hintText: '38, 12, 45, 7, 29, 18, 50',
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.58), fontSize: 12),
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 12),
        prefixIcon: Icon(Icons.link_rounded, color: cyan.withOpacity(0.8), size: 19),
        filled: true,
        fillColor: visualizationColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cyan.withOpacity(0.55)),
        ),
      ),
    );
  }

  Widget _buildVisualization() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.account_tree_rounded, 'Live Sorting Visualization', cyan),
          const SizedBox(height: 10),
          _buildLivePhaseBanner(),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniBadge('LEFT', leftIndex >= 0 ? '$leftIndex' : 'NULL', cyan),
              const SizedBox(width: 8),
              _miniBadge('RIGHT', rightIndex >= 0 ? '$rightIndex' : 'NULL', orange),
              const SizedBox(width: 8),
              _miniBadge('RANGE', rangeStart >= 0 ? '$rangeStart-$rangeEnd' : 'ALL', purple),
              const SizedBox(width: 8),
              _miniBadge('WRITE', activeIndex >= 0 ? 'INDEX $activeIndex' : '—', green),
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
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(linkedList.length, (index) => _buildListNode(index)),
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
    final isMove = phase.contains('MERGE');
    final text = isResult
        ? 'All ranges are merged. The linked list is now sorted in ascending order.'
        : isMove
            ? 'The two sorted halves are compared and written back in ascending order.'
            : 'The current range is divided into smaller halves before merging.';
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.10), Colors.transparent]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(9)),
          child: Icon(isResult ? Icons.flag_rounded : Icons.radar_rounded, color: color, size: 18)),
        const SizedBox(width: 9),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(phase, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.7)),
          const SizedBox(height: 3),
          Text(text, style: TextStyle(color: Colors.white.withOpacity(0.58), fontSize: 10, height: 1.35)),
        ])),
      ]),
    );
  }

  Widget _buildListNode(int index) {
    final value = linkedList[index];
    final bool isSlow = index == leftIndex;
    final bool isFast = index == rightIndex;
    final bool isTarget = index == activeIndex;
    final bool isBoth = isSlow && isFast;

    Color itemColor = Colors.white.withOpacity(0.08);
    Color borderColor = Colors.white.withOpacity(0.08);
    Color textColor = Colors.white;
    String label = '';

    if (isTarget) {
      itemColor = green.withOpacity(0.18);
      borderColor = green;
      textColor = green;
      label = 'WRITE';
    }
    if (isSlow) {
      itemColor = cyan.withOpacity(0.18);
      borderColor = cyan;
      textColor = cyan;
      label = 'LEFT';
    }
    if (isFast) {
      itemColor = orange.withOpacity(0.18);
      borderColor = orange;
      textColor = orange;
      label = 'RIGHT';
    }
    if (isBoth) {
      itemColor = purple.withOpacity(0.20);
      borderColor = purple;
      textColor = Colors.white;
      label = 'LEFT + RIGHT';
    }
    if (isTarget && isSlow) label = 'WRITE';

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
                      color: isBoth ? purple : isTarget ? green : isFast ? orange : isSlow ? cyan : Colors.white.withOpacity(0.25),
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
                      ? [BoxShadow(color: borderColor.withOpacity(0.18), blurRadius: 12, spreadRadius: 1)]
                      : null,
                ),
                child: Center(
                  child: Text(
                    value.toString(),
                    style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text('[$index]', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        if (index < linkedList.length - 1)
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 1, right: 1),
            child: Column(
              children: [
                Icon(Icons.arrow_forward_rounded, color: Colors.white.withOpacity(0.35), size: 19),
                Text('next', style: TextStyle(color: Colors.white.withOpacity(0.22), fontSize: 7)),
              ],
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 3),
            child: Column(
              children: [
                Icon(Icons.stop_rounded, color: green.withOpacity(0.80), size: 19),
                Text('TAIL', style: TextStyle(color: green.withOpacity(0.65), fontSize: 7, fontWeight: FontWeight.w700)),
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
        _legendItem('Left Pointer', cyan),
        _legendItem('Right Pointer', orange),
        _legendItem('Sorted', green),
      ],
    );
  }

  Widget _legendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 9, height: 9,
            decoration: BoxDecoration(color: color,
                borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(title, style: TextStyle(color: Colors.white.withOpacity(0.58),
            fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildCurrentInfo() {
    String message = 'Waiting for execution';

    if (activeIndex >= 0 && activeIndex < linkedList.length) {
      message = 'Sorted List → ${linkedList.join(', ')}';
    } else if (leftIndex >= 0 && leftIndex < linkedList.length && rightIndex >= 0 && rightIndex < linkedList.length) {
      message = 'Left → ${linkedList[leftIndex]}    •    Right → ${linkedList[rightIndex]}';
    } else if (leftIndex >= 0 && leftIndex < linkedList.length) {
      message = 'Left → ${linkedList[leftIndex]}    •    Right → NULL';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background2,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cyan.withOpacity(0.14)),
      ),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(color: cyan.withOpacity(0.09), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.compare_arrows_rounded, color: cyan, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Operation', style: TextStyle(color: Colors.white.withOpacity(0.42), fontSize: 9, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(message, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          if (activeIndex >= 0 && activeIndex < linkedList.length)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(color: green.withOpacity(0.08), borderRadius: BorderRadius.circular(7)),
              child: Text('Sorted → ${linkedList.join(', ')}', style: const TextStyle(color: green, fontSize: 10, fontWeight: FontWeight.w800)),
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
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 9),
          Expanded(child: Text(executionMessage, style: TextStyle(color: Colors.white.withOpacity(0.72), fontSize: 11, height: 1.45))),
        ],
      ),
    );
  }

  Widget _generateButton() {
    return ElevatedButton.icon(
      onPressed: _generateNumbers,
      icon: const Icon(
        Icons.auto_awesome_rounded,
        size: 17,
      ),
      label: const Text(
        'Generate List',
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

  Widget _loadButton() {
    return ElevatedButton.icon(
      onPressed: _loadList,
      icon: const Icon(
        Icons.download_rounded,
        size: 17,
      ),
      label: const Text(
        'LOAD LIST',
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
              const Text('Execution Controls', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
              const Spacer(),
              Text(_currentPhase(), style: TextStyle(color: _phaseColor(), fontSize: 8.5, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 10),
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
                onPressed: currentStep >= events.length
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
                  color: Colors.white.withOpacity( 0.55),
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
                      Colors.white.withOpacity( 0.08),
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
                  : currentStep / events.length,
              minHeight: 4,
              backgroundColor:
                  Colors.white.withOpacity( 0.06),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(cyan),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Step $currentStep / ${events.length}',
                style: TextStyle(
                  color: Colors.white.withOpacity( 0.45),
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
                          : Colors.white.withOpacity( 0.4),
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
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary ? cyan : cardColor,
          foregroundColor: primary ? background : Colors.white,
          disabledBackgroundColor:
              Colors.white.withOpacity( 0.04),
          disabledForegroundColor:
              Colors.white.withOpacity( 0.20),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
            side: BorderSide(
              color: primary
                  ? cyan
                  : Colors.white.withOpacity( 0.08),
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
                    color: purple.withOpacity( 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: purple.withOpacity( 0.20),
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
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF050A14),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: Colors.white.withOpacity( 0.06),
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(
                  lines.length,
                  (index) {
                    final lineNumber = index + 1;
                    final active = lineNumber == activeCodeLine;

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      color: active
                          ? cyan.withOpacity( 0.09)
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
                                    : Colors.white.withOpacity(0.20),
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
                                    : Colors.white.withOpacity(0.65),
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
                  color: cyan.withOpacity( 0.07),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: cyan.withOpacity( 0.14),
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
              constraints: const BoxConstraints(maxHeight: 460),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: executionHistory.length,
                itemBuilder: (context, index) {
                  return _executionStepItem(
                    index,
                    executionHistory[index],
                  );
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
      padding: const EdgeInsets.symmetric(
        vertical: 35,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        color: visualizationColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white.withOpacity( 0.06),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.timeline_rounded,
            color: Colors.white.withOpacity( 0.20),
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            'No steps executed yet',
            style: TextStyle(
              color: Colors.white.withOpacity( 0.55),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Press Next Step or Play to start',
            style: TextStyle(
              color: Colors.white.withOpacity( 0.30),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _executionStepItem(
  int index,
  SortEvent event,
) {
  final color = _eventColor(event.type);

  return Container(
    margin: const EdgeInsets.only(bottom: 7),
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

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity( 0.065),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.18),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: child,
    );
  }

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
            color: color.withOpacity( 0.09),
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
        color: color.withOpacity( 0.055),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: color.withOpacity( 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity( 0.8),
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
          color: color.withOpacity( 0.07),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: color.withOpacity( 0.18),
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
