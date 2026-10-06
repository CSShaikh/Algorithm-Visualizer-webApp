import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FindMiddleElementScreen extends StatefulWidget {
  const FindMiddleElementScreen({super.key});

  @override
  State<FindMiddleElementScreen> createState() =>
      _FindingMiddleElementScreenState();
}

enum MiddleEventType {
  initialize,
  pointersSet,
  moveSlow,
  moveFast,
  middleFound,
  complete,
}

class MiddleEvent {
  final MiddleEventType type;
  final List<int> list;
  final int slowIndex;
  final int fastIndex;
  final int middleIndex;
  final String title;
  final String description;
  final String operation;

  const MiddleEvent({
    required this.type,
    required this.list,
    required this.slowIndex,
    required this.fastIndex,
    required this.middleIndex,
    required this.title,
    required this.description,
    required this.operation,
  });
}

class _FindingMiddleElementScreenState extends State<FindMiddleElementScreen> {
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

  List<int> linkedList = [10, 20, 30, 40, 50];
  List<int> originalList = [10, 20, 30, 40, 50];

  final TextEditingController listController = TextEditingController(
    text: '10, 20, 30, 40, 50',
  );

  List<MiddleEvent> events = [];
  List<MiddleEvent> executionHistory = [];

  int currentStep = 0;
  bool isRunning = false;
  bool isCompleted = false;
  double speed = 1.0;
  Timer? timer;

  int slowIndex = -1;
  int fastIndex = -1;
  int middleIndex = -1;
  int activeCodeLine = 0;

  String executionMessage =
      'Ready to find the middle element of the linked list.';

  final String sourceCode = '''
class Node {
  int data;
  Node? next;

  Node(this.data);
}

Node? findMiddle(Node? head) {
  Node? slow = head;
  Node? fast = head;

  while (fast != null && fast.next != null) {
    slow = slow!.next;
    fast = fast.next!.next;
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
    final generated = <MiddleEvent>[];

    if (working.isEmpty) {
      events = generated;
      return;
    }

    generated.add(
      MiddleEvent(
        type: MiddleEventType.initialize,
        list: [...working],
        slowIndex: -1,
        fastIndex: -1,
        middleIndex: -1,
        title: 'Linked List Initialized',
        description:
            'The linked list is ready. We will use slow and fast pointers to find its middle element.',
        operation: 'Start Finding Middle',
      ),
    );

    int slow = 0;
    int fast = 0;

    generated.add(
      MiddleEvent(
        type: MiddleEventType.pointersSet,
        list: [...working],
        slowIndex: slow,
        fastIndex: fast,
        middleIndex: -1,
        title: 'Pointers Initialized',
        description:
            'Both slow and fast pointers start at the head of the linked list.',
        operation: 'slow = head, fast = head',
      ),
    );

    while (fast >= 0 && fast < working.length && fast + 1 < working.length) {
      slow++;

      generated.add(
        MiddleEvent(
          type: MiddleEventType.moveSlow,
          list: [...working],
          slowIndex: slow,
          fastIndex: fast,
          middleIndex: -1,
          title: 'Slow Pointer Moves',
          description:
              'Slow moves one node forward to index $slow (value ${working[slow]}).',
          operation: 'slow = slow.next',
        ),
      );

      fast += 2;

      generated.add(
        MiddleEvent(
          type: MiddleEventType.moveFast,
          list: [...working],
          slowIndex: slow,
          fastIndex: fast < working.length ? fast : -1,
          middleIndex: -1,
          title: 'Fast Pointer Moves',
          description: fast < working.length
              ? 'Fast moves two nodes forward to index $fast (value ${working[fast]}).'
              : 'Fast moves two nodes and reaches the end of the linked list.',
          operation: 'fast = fast.next.next',
        ),
      );
    }

    final foundMiddle = slow.clamp(0, working.length - 1);

    generated.add(
      MiddleEvent(
        type: MiddleEventType.middleFound,
        list: [...working],
        slowIndex: foundMiddle,
        fastIndex: -1,
        middleIndex: foundMiddle,
        title: 'Middle Element Found',
        description:
            'Fast has reached the end, so slow is pointing to the middle element ${working[foundMiddle]}.',
        operation: 'return slow',
      ),
    );

    generated.add(
      MiddleEvent(
        type: MiddleEventType.complete,
        list: [...working],
        slowIndex: foundMiddle,
        fastIndex: -1,
        middleIndex: foundMiddle,
        title: 'Finding Middle Complete',
        description:
            'The middle element of the linked list has been found successfully.',
        operation: 'Middle = ${working[foundMiddle]}',
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
      if (value != null) {
        values.add(value);
      }
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
      slowIndex = -1;
      fastIndex = -1;
      middleIndex = -1;
      activeCodeLine = 0;
      executionMessage =
          'Linked list loaded. Ready to find its middle element.';
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
      middleIndex = -1;
      activeCodeLine = 0;
      executionMessage = 'New linked list generated. Ready to find the middle.';
    });

    _generateEvents();
    _showSnackBar('New linked list generated.', purple);
  }

  void _play() {
    if (events.isEmpty || isCompleted) return;

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

  void _pause() {
    timer?.cancel();

    if (!mounted) return;

    setState(() {
      isRunning = false;
    });
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
    middleIndex = -1;
    activeCodeLine = 0;
    executionMessage = 'Ready to find the middle element of the linked list.';

    for (final event in executionHistory) {
      _applyEvent(event, updateState: false);
    }
  }

  void _applyEvent(MiddleEvent event, {bool updateState = true}) {
    linkedList = [...event.list];
    slowIndex = event.slowIndex;
    fastIndex = event.fastIndex;
    middleIndex = event.middleIndex;
    executionMessage = '${event.title}: ${event.description}';
    activeCodeLine = _codeLineForEvent(event.type);

    if (event.type == MiddleEventType.complete) {
      slowIndex = event.middleIndex;
      fastIndex = -1;
      middleIndex = event.middleIndex;

      executionMessage =
          'Finding Middle Complete: Middle element is ${event.list[event.middleIndex]}.';
    }

    if (updateState) {
      setState(() {});
    }
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
      middleIndex = -1;
      activeCodeLine = 0;
      executionMessage = 'Ready to find the middle element of the linked list.';
    });

    _generateEvents();
  }

  void _setSpeed(double value) {
    setState(() {
      speed = value;
    });

    if (isRunning) {
      _play();
    }
  }

  int _codeLineForEvent(MiddleEventType type) {
    switch (type) {
      case MiddleEventType.initialize:
        return 1;
      case MiddleEventType.pointersSet:
        return 7;
      case MiddleEventType.moveSlow:
        return 9;
      case MiddleEventType.moveFast:
        return 10;
      case MiddleEventType.middleFound:
        return 13;
      case MiddleEventType.complete:
        return 13;
    }
  }

  Color _eventColor(MiddleEventType type) {
    switch (type) {
      case MiddleEventType.initialize:
        return blue;
      case MiddleEventType.pointersSet:
        return purple;
      case MiddleEventType.moveSlow:
        return cyan;
      case MiddleEventType.moveFast:
        return orange;
      case MiddleEventType.middleFound:
        return green;
      case MiddleEventType.complete:
        return green;
    }
  }

  IconData _eventIcon(MiddleEventType type) {
    switch (type) {
      case MiddleEventType.initialize:
        return Icons.play_arrow_rounded;
      case MiddleEventType.pointersSet:
        return Icons.my_location_rounded;
      case MiddleEventType.moveSlow:
        return Icons.arrow_forward_rounded;
      case MiddleEventType.moveFast:
        return Icons.double_arrow_rounded;
      case MiddleEventType.middleFound:
        return Icons.center_focus_strong_rounded;
      case MiddleEventType.complete:
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: orange.withOpacity(0.16)),
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
                border: Border.all(color: Colors.white.withOpacity(0.08)),
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
              Icons.account_tree_rounded,
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
                  'Finding Middle Element',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Find the middle node using slow and fast pointers',
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
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
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
            Icons.info_outline_rounded,
            'Algorithm Information',
            cyan,
          ),
          const SizedBox(height: 14),
          Text(
            'The middle element is found using two pointers. '
            'The slow pointer moves one node at a time while the '
            'fast pointer moves two nodes at a time. When fast '
            'reaches the end, slow is at the middle.',
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
              _infoBox('Time', 'O(n)', orange),
              _infoBox('Space', 'O(1)', blue),
              _infoBox('Type', 'Linked List', purple),
              _infoBox('Method', 'Two Pointers', green),
              _infoBox('Slow', '1 step', cyan),
              _infoBox('Fast', '2 steps', red),
            ],
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
                color: orange.withOpacity(0.85),
                size: 15,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  'Try an odd or even number of nodes to see how the slow and fast pointers move.',
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

  Widget _inputField() {
    return TextField(
      controller: listController,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      cursorColor: cyan,
      decoration: InputDecoration(
        labelText: 'Enter Linked List Values',
        hintText: '10, 20, 30, 40, 50...',
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.58),
          fontSize: 12,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withOpacity(0.25),
          fontSize: 12,
        ),
        prefixIcon: Icon(
          Icons.link_rounded,
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
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: cyan.withOpacity(0.55)),
        ),
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

  Widget _buildVisualization() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.account_tree_rounded, 'Visualization', cyan),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniBadge('SLOW', slowIndex >= 0 ? '$slowIndex' : '-', cyan),
              const SizedBox(width: 8),
              _miniBadge(
                'FAST',
                fastIndex >= 0 ? '$fastIndex' : 'NULL',
                orange,
              ),
              const SizedBox(width: 8),
              _miniBadge(
                'MIDDLE',
                middleIndex >= 0 ? '$middleIndex' : '-',
                green,
              ),
              const SizedBox(width: 8),
              _miniBadge('STEPS', executionHistory.length.toString(), purple),
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

  Widget _buildListNode(int index) {
    final value = linkedList[index];
    final bool isSlow = index == slowIndex;
    final bool isFast = index == fastIndex;
    final bool isMiddle = index == middleIndex;

    Color itemColor = Colors.white.withOpacity(0.08);
    Color borderColor = Colors.white.withOpacity(0.08);
    Color textColor = Colors.white;
    String label = '';

    if (isMiddle) {
      itemColor = green.withOpacity(0.18);
      borderColor = green;
      textColor = green;
      label = 'MIDDLE';
    }

    if (isSlow) {
      itemColor = cyan.withOpacity(0.18);
      borderColor = cyan;
      textColor = cyan;
      label = isFast ? 'SLOW + FAST' : 'SLOW';
    }

    if (isFast) {
      itemColor = orange.withOpacity(0.18);
      borderColor = orange;
      textColor = orange;
      label = isSlow ? 'SLOW + FAST' : 'FAST';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 88,
          child: Column(
            children: [
              SizedBox(
                height: 20,
                child: Center(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isMiddle
                          ? green
                          : isFast
                          ? orange
                          : isSlow
                          ? cyan
                          : Colors.white.withOpacity(0.25),
                      fontSize: 7.2,
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
                    width: isSlow || isFast || isMiddle ? 1.7 : 1,
                  ),
                  boxShadow: isSlow || isFast || isMiddle
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
        ),
        if (index < linkedList.length - 1)
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 1, right: 1),
            child: Column(
              children: [
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white.withOpacity(0.35),
                  size: 19,
                ),
                Text(
                  'next',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.22),
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
                  Icons.arrow_forward_rounded,
                  color: Colors.white.withOpacity(0.20),
                  size: 19,
                ),
                Text(
                  'null',
                  style: TextStyle(
                    color: red.withOpacity(0.55),
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
        _legendItem('Middle', green),
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
            color: Colors.white.withOpacity(0.58),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentInfo() {
    String message = 'Waiting for execution';

    if (slowIndex >= 0 &&
        slowIndex < linkedList.length &&
        fastIndex >= 0 &&
        fastIndex < linkedList.length) {
      message =
          'Slow → ${linkedList[slowIndex]}    •    Fast → ${linkedList[fastIndex]}';
    } else if (slowIndex >= 0 &&
        slowIndex < linkedList.length &&
        fastIndex == -1) {
      message = 'Slow → ${linkedList[slowIndex]}    •    Fast → NULL';
    }

    if (middleIndex >= 0 && middleIndex < linkedList.length) {
      message = 'Middle element → ${linkedList[middleIndex]}';
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
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cyan.withOpacity(0.09),
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
                    color: Colors.white.withOpacity(0.42),
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
          if (middleIndex >= 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: green.withOpacity(0.08),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Text(
                'Found',
                style: TextStyle(
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
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.18)),
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
              backgroundColor: Colors.white.withOpacity(0.06),
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
          disabledBackgroundColor: Colors.white.withOpacity(0.04),
          disabledForegroundColor: Colors.white.withOpacity(0.20),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
            side: BorderSide(
              color: primary ? cyan : Colors.white.withOpacity(0.08),
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
                    color: purple.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: purple.withOpacity(0.20)),
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
              border: Border.all(color: Colors.white.withOpacity(0.06)),
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
                    color: active ? cyan.withOpacity(0.09) : Colors.transparent,
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
                  color: cyan.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(color: cyan.withOpacity(0.14)),
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
        border: Border.all(color: Colors.white.withOpacity(0.06)),
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

  Widget _executionStepItem(int index, MiddleEvent event) {
    final color = _eventColor(event.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.045),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(0.14)),
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
        border: Border.all(color: Colors.white.withOpacity(0.065)),
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

  Widget _sectionTitle(IconData icon, String title, Color color) {
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
        color: color.withOpacity(0.055),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withOpacity(0.16)),
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

  Widget _miniBadge(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: color.withOpacity(0.18)),
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
