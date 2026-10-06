import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ConvertLinkedListToBinaryTreeScreen extends StatefulWidget {
  const ConvertLinkedListToBinaryTreeScreen({super.key});

  @override
  State<ConvertLinkedListToBinaryTreeScreen> createState() =>
      _ConvertLinkedListToBinaryTreeScreenState();
}

enum TreeEventType {
  initialize,
  createRoot,
  createLeft,
  createRight,
  completeNode,
  resultFound,
  invalid,
}

class TreeEvent {
  final TreeEventType type;
  final List<int> list;
  final List<int> tree;
  final int listIndex;
  final int parentIndex;
  final int activeIndex;
  final String title;
  final String description;
  final String operation;
  final int iteration;

  const TreeEvent({
    required this.type,
    required this.list,
    required this.tree,
    required this.listIndex,
    required this.parentIndex,
    required this.activeIndex,
    required this.title,
    required this.description,
    required this.operation,
    this.iteration = 0,
  });
}

class _ConvertLinkedListToBinaryTreeScreenState
    extends State<ConvertLinkedListToBinaryTreeScreen> {
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

  List<int> linkedList = [1, 2, 3, 4, 5, 6, 7];
  List<int> originalList = [1, 2, 3, 4, 5, 6, 7];
  List<int> treeValues = [];

  final TextEditingController listController = TextEditingController(
    text: '1, 2, 3, 4, 5, 6, 7',
  );

  List<TreeEvent> events = [];
  List<TreeEvent> executionHistory = [];

  int currentStep = 0;
  bool isRunning = false;
  bool isCompleted = false;
  double speed = 1.0;
  Timer? timer;

  int listIndex = -1;
  int parentIndex = -1;
  int activeIndex = -1;
  int activeCodeLine = 0;
  int iteration = 0;

  String executionMessage =
      'Ready to convert the linked list into a binary tree.';

  final String sourceCode = '''
class Node {
  int data;
  Node? next;

  Node(this.data);
}

class TreeNode {
  int data;
  TreeNode? left;
  TreeNode? right;

  TreeNode(this.data);
}

TreeNode? convertListToTree(Node? head) {
  if (head == null) return null;

  final root = TreeNode(head.data);
  final queue = <TreeNode>[root];
  var queueIndex = 0;
  Node? current = head.next;

  while (current != null) {
    final parent = queue[queueIndex++];

    parent.left = TreeNode(current.data);
    queue.add(parent.left!);
    current = current.next;

    if (current != null) {
      parent.right = TreeNode(current.data);
      queue.add(parent.right!);
      current = current.next;
    }
  }

  return root;
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
    final values = [...linkedList];
    final generated = <TreeEvent>[];
    final tree = <int>[];
    var step = 0;

    void addEvent({
      required TreeEventType type,
      required String title,
      required String description,
      required String operation,
      int source = -1,
      int parent = -1,
      int active = -1,
    }) {
      step++;
      generated.add(
        TreeEvent(
          type: type,
          list: [...values],
          tree: [...tree],
          listIndex: source,
          parentIndex: parent,
          activeIndex: active,
          title: title,
          description: description,
          operation: operation,
          iteration: step,
        ),
      );
    }

    if (values.isEmpty) {
      addEvent(
        type: TreeEventType.invalid,
        title: 'Empty Linked List',
        description: 'At least one node is required to create the binary tree.',
        operation: 'if (head == null) return null;',
      );
      events = generated;
      return;
    }

    addEvent(
      type: TreeEventType.initialize,
      title: 'Linked List Initialized',
      description:
          'The linked list is ready. Nodes will be consumed from left to right in level order.',
      operation: 'head = linkedList.head',
    );

    tree.add(values[0]);
    addEvent(
      type: TreeEventType.createRoot,
      title: 'Create Root',
      description:
          'The first linked-list node becomes the root of the binary tree.',
      operation: 'root = TreeNode(head.data)',
      source: 0,
      active: 0,
    );

    var source = 1;
    var queueIndex = 0;

    while (source < values.length) {
      final parent = queueIndex;
      final leftChild = tree.length;
      final rightChild = tree.length + 1;

      // The linked-list nodes are consumed in level order, so the next
      // two tree positions are always the next available positions.
      // Using add() avoids growing List<int> with temporary null values.
      tree.add(values[source]);
      addEvent(
        type: TreeEventType.createLeft,
        title: 'Create Left Child',
        description:
            'Node ${values[source]} becomes the left child of tree node ${tree[parent]}.',
        operation: 'parent.left = TreeNode(current.data)',
        source: source,
        parent: parent,
        active: leftChild,
      );
      source++;

      if (source < values.length) {
        final rightChildIndex = rightChild;
        tree.add(values[source]);
        addEvent(
          type: TreeEventType.createRight,
          title: 'Create Right Child',
          description:
              'Node ${values[source]} becomes the right child of tree node ${tree[parent]}.',
          operation: 'parent.right = TreeNode(current.data)',
          source: source,
          parent: parent,
          active: rightChildIndex,
        );
        source++;
      }

      addEvent(
        type: TreeEventType.completeNode,
        title: 'Parent Completed',
        description:
            'Both available child positions for node ${tree[parent]} have been processed.',
        operation: 'queueIndex++',
        source: source - 1,
        parent: parent,
        active: parent,
      );

      queueIndex++;
    }

    addEvent(
      type: TreeEventType.resultFound,
      title: 'Binary Tree Created',
      description:
          'All linked-list nodes have been placed into the binary tree in level-order.',
      operation: 'return root',
      source: values.length - 1,
      active: 0,
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
      treeValues.clear();
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      listIndex = -1;
      parentIndex = -1;
      activeIndex = -1;
      activeCodeLine = 0;
      iteration = 0;
      executionMessage = 'Linked list loaded. Ready to build the binary tree.';
    });

    _generateEvents();
    _showSnackBar('Linked list loaded successfully.', green);
  }

  void _generateNumbers() {
    final random = Random();
    final count = 7 + random.nextInt(2);
    final generated = List.generate(count, (_) => random.nextInt(90) + 10);

    listController.text = generated.join(', ');
    timer?.cancel();

    setState(() {
      linkedList = [...generated];
      originalList = [...generated];
      treeValues.clear();
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      listIndex = -1;
      parentIndex = -1;
      activeIndex = -1;
      activeCodeLine = 0;
      iteration = 0;
      executionMessage =
          'New linked list generated. Ready to build the binary tree.';
    });

    _generateEvents();
    _showSnackBar('New linked list generated.', purple);
  }

  void _applyEvent(TreeEvent event, {bool updateState = true}) {
    void apply() {
      listIndex = event.listIndex;
      parentIndex = event.parentIndex;
      activeIndex = event.activeIndex;
      treeValues = [...event.tree];
      activeCodeLine = _codeLineForEvent(event.type);
      iteration = event.iteration;
      executionMessage = '${event.title}: ${event.description}';
      if (event.type == TreeEventType.resultFound) {
        isCompleted = true;
      }
    }

    if (updateState) {
      setState(apply);
    } else {
      apply();
    }
  }

  void _reset() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      isCompleted = false;
      currentStep = 0;
      executionHistory.clear();
      treeValues.clear();
      listIndex = -1;
      parentIndex = -1;
      activeIndex = -1;
      activeCodeLine = 0;
      iteration = 0;
      executionMessage = 'Ready to convert the linked list into a binary tree.';
    });
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
        setState(() => isRunning = false);
        return;
      }

      _nextStepInternal();
    });
  }

  void _pause() {
    timer?.cancel();
    if (mounted) setState(() => isRunning = false);
  }

  void _togglePlayPause() {
    if (isRunning) {
      _pause();
    } else {
      _play();
    }
  }

  void _nextStep() {
    _pause();
    _nextStepInternal();
  }

  void _nextStepInternal() {
    if (currentStep >= events.length) return;

    final event = events[currentStep];
    executionHistory.add(event);
    currentStep++;
    _applyEvent(event);

    if (currentStep >= events.length) {
      setState(() => isCompleted = true);
      timer?.cancel();
      if (mounted) setState(() => isRunning = false);
    }
  }

  void _previousStep() {
    _pause();
    if (currentStep <= 0) return;

    setState(() {
      currentStep--;
      executionHistory = [...events.take(currentStep)];
      treeValues.clear();
      listIndex = -1;
      parentIndex = -1;
      activeIndex = -1;
      activeCodeLine = 0;
      iteration = 0;
      isCompleted = false;
    });

    if (currentStep > 0) {
      _applyEvent(events[currentStep - 1], updateState: true);
    } else {
      setState(() {
        executionMessage =
            'Ready to convert the linked list into a binary tree.';
      });
    }
  }

  void _setSpeed(double value) {
    setState(() => speed = value);
    if (isRunning) _play();
  }

  String _currentPhase() {
    final type = _currentStepType();
    if (type == TreeEventType.resultFound) return 'RESULT • TREE READY';
    if (type == TreeEventType.createLeft || type == TreeEventType.createRight) {
      return 'PHASE 2 • BUILD TREE';
    }
    if (type == TreeEventType.completeNode) return 'PHASE 2 • BUILD TREE';
    return 'PHASE 1 • INITIALIZE';
  }

  TreeEventType? _currentStepType() {
    if (executionHistory.isEmpty) return null;
    return executionHistory.last.type;
  }

  Color _phaseColor() {
    if (_currentPhase().contains('RESULT')) return green;
    if (_currentPhase().contains('BUILD')) return purple;
    return cyan;
  }

  int _codeLineForEvent(TreeEventType type) {
    switch (type) {
      case TreeEventType.initialize:
        return 18;
      case TreeEventType.createRoot:
        return 20;
      case TreeEventType.createLeft:
        return 28;
      case TreeEventType.createRight:
        return 33;
      case TreeEventType.completeNode:
        return 26;
      case TreeEventType.resultFound:
        return 39;
      case TreeEventType.invalid:
        return 18;
    }
  }

  Color _eventColor(TreeEventType type) {
    switch (type) {
      case TreeEventType.initialize:
        return blue;
      case TreeEventType.createRoot:
        return cyan;
      case TreeEventType.createLeft:
        return green;
      case TreeEventType.createRight:
        return orange;
      case TreeEventType.completeNode:
        return purple;
      case TreeEventType.resultFound:
        return green;
      case TreeEventType.invalid:
        return red;
    }
  }

  IconData _eventIcon(TreeEventType type) {
    switch (type) {
      case TreeEventType.initialize:
        return Icons.play_arrow_rounded;
      case TreeEventType.createRoot:
        return Icons.account_tree_rounded;
      case TreeEventType.createLeft:
        return Icons.subdirectory_arrow_left_rounded;
      case TreeEventType.createRight:
        return Icons.subdirectory_arrow_right_rounded;
      case TreeEventType.completeNode:
        return Icons.task_alt_rounded;
      case TreeEventType.resultFound:
        return Icons.check_circle_rounded;
      case TreeEventType.invalid:
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
                  Icons.account_tree_rounded,
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
                      'Convert Linked List to Binary Tree',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Level-order conversion • consume nodes → attach children',
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
                  'Level Order • O(n)',
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
                  Icons.account_tree_rounded,
                  'NODES',
                  '${treeValues.length}/${linkedList.length}',
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
      text = 'TREE READY';
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
            'Convert Linked List to Binary Tree',
            cyan,
          ),
          const SizedBox(height: 12),
          Text(
            'This algorithm reads the linked list from left to right and places the values into a binary tree level by level. The first value becomes the root, then the next values become the left and right children of each parent in queue order.',
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
              _infoBox('Space', 'O(n)', blue),
              _infoBox('Phase 1', 'Initialize Root', cyan),
              _infoBox('Phase 2', 'Build Levels', purple),
              _infoBox('Input', 'Linked List', green),
              _infoBox('Output', 'Binary Tree', pink),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseRail() {
    final phase = _currentPhase();
    final p1 = phase.contains('INITIALIZE');
    final p2 = phase.contains('BUILD');
    final p3 = phase.contains('RESULT');
    return Row(
      children: [
        Expanded(
          child: _phaseBox('01', 'INITIALIZE', 'First node → root', p1, cyan),
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
            'BUILD TREE',
            'Attach left + right',
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
          child: _phaseBox('03', 'TREE READY', 'Return root', p3, green),
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
              final field = _inputField(
                controller: listController,
                label: 'Linked List Values',
                hint: '1, 2, 3, 4, 5, 6, 7',
                color: cyan,
              );
              if (constraints.maxWidth < 650) {
                return Column(
                  children: [
                    field,
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _loadButton()),
                        const SizedBox(width: 8),
                        Expanded(child: _generateButton()),
                      ],
                    ),
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: field),
                  const SizedBox(width: 10),
                  _loadButton(),
                  const SizedBox(width: 8),
                  _generateButton(),
                ],
              );
            },
          ),
          const SizedBox(height: 9),
          Text(
            'Enter values separated by commas or spaces. The values are placed into the binary tree in level-order.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.34),
              fontSize: 9.5,
            ),
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
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: color.withValues(alpha: 0.75),
          fontSize: 10,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.20),
          fontSize: 11,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.025),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color.withValues(alpha: 0.65)),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
      ),
    );
  }

  Widget _buildLivePhaseBanner() {
    final type = _currentStepType();
    final color = type == null ? cyan : _eventColor(type);
    final title = executionHistory.isEmpty
        ? 'READY'
        : executionHistory.last.title;
    final description = executionHistory.isEmpty
        ? 'Press Play or Next Step to start building the tree.'
        : executionHistory.last.description;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            type == null ? Icons.play_circle_outline_rounded : _eventIcon(type),
            color: color,
            size: 18,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.58),
                    fontSize: 9.5,
                    height: 1.4,
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
            'Live Binary Tree Visualization',
            cyan,
          ),
          const SizedBox(height: 10),
          _buildLivePhaseBanner(),
          const SizedBox(height: 12),
          Row(
            children: [
              _miniBadge('LIST', listIndex >= 0 ? '$listIndex' : 'NULL', cyan),
              const SizedBox(width: 8),
              _miniBadge(
                'PARENT',
                parentIndex >= 0 ? '$parentIndex' : '—',
                purple,
              ),
              const SizedBox(width: 8),
              _miniBadge(
                'ACTIVE',
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
            height: _treeCanvasHeight(),
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
            decoration: BoxDecoration(
              color: visualizationColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: _buildTreeCanvas(),
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

  double _treeCanvasHeight() {
    final count = treeValues.length;
    if (count <= 1) return 150;
    final depth = (log(count) / log(2)).floor();
    return max(150, 105 + depth * 78).toDouble();
  }

  Widget _buildTreeCanvas() {
    if (treeValues.isEmpty) {
      return Center(
        child: Text(
          'Binary tree will appear here',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.25),
            fontSize: 11,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        final positions = <int, Offset>{};

        for (var index = 0; index < treeValues.length; index++) {
          if (index >= treeValues.length) continue;
          final depth = (log(index + 1) / log(2)).floor();
          final firstAtDepth = pow(2, depth).toInt() - 1;
          final column = index - firstAtDepth;
          final slots = pow(2, depth).toInt();
          final x = width * ((column + 0.5) / slots);
          final y = 28 + depth * 78.0;
          positions[index] = Offset(x, min(y, height - 26));
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _TreeEdgePainter(
                  positions: positions,
                  count: treeValues.length,
                ),
              ),
            ),
            ...positions.entries.map((entry) {
              final index = entry.key;
              final position = entry.value;
              final isActive = index == activeIndex;
              final isParent = index == parentIndex;
              final color = isActive
                  ? green
                  : isParent
                  ? purple
                  : cyan;

              return Positioned(
                left: position.dx - 26,
                top: position.dy - 24,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 52,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(
                      alpha: isActive || isParent ? 0.18 : 0.06,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isActive || isParent
                          ? color
                          : Colors.white.withValues(alpha: 0.10),
                      width: isActive || isParent ? 1.8 : 1,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.22),
                              blurRadius: 14,
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '${treeValues[index]}',
                      style: TextStyle(
                        color: isActive || isParent ? color : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        _legendItem('Linked List Node', cyan),
        _legendItem('Parent', purple),
        _legendItem('New Child', green),
        _legendItem('Right Child', orange),
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

    if (activeIndex >= 0 && activeIndex < treeValues.length) {
      message =
          'Tree node → index $activeIndex • value ${treeValues[activeIndex]}';
    }

    if (parentIndex >= 0 && parentIndex < treeValues.length) {
      message += ' • parent index $parentIndex';
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
          Icon(Icons.account_tree_rounded, color: purple, size: 17),
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
          if (treeValues.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
              decoration: BoxDecoration(
                color: green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                '${treeValues.length} nodes',
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
                'Speed ${speed.toStringAsFixed(1)}×',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _controlButton(
                icon: isRunning
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                label: isRunning ? 'PAUSE' : 'PLAY',
                onPressed: events.isEmpty || isCompleted
                    ? null
                    : _togglePlayPause,
                primary: true,
              ),
              _controlButton(
                icon: Icons.chevron_left_rounded,
                label: 'PREVIOUS',
                onPressed: currentStep <= 0 ? null : _previousStep,
              ),
              _controlButton(
                icon: Icons.chevron_right_rounded,
                label: 'NEXT',
                onPressed: currentStep >= events.length ? null : _nextStep,
              ),
              _controlButton(
                icon: Icons.refresh_rounded,
                label: 'RESET',
                onPressed: _reset,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.speed_rounded, color: purple, size: 16),
              const SizedBox(width: 7),
              Expanded(
                child: Slider(
                  value: speed,
                  min: 0.5,
                  max: 3.0,
                  divisions: 5,
                  activeColor: purple,
                  inactiveColor: Colors.white.withValues(alpha: 0.10),
                  onChanged: _setSpeed,
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
                  final isActive = lineNumber == activeCodeLine;
                  return Container(
                    width: double.infinity,
                    color: isActive
                        ? purple.withValues(alpha: 0.08)
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2.5,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 30,
                          child: Text(
                            '$lineNumber',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: isActive
                                  ? purple
                                  : Colors.white.withValues(alpha: 0.18),
                              fontSize: 9,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            lines[index].isEmpty ? ' ' : lines[index],
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.62),
                              fontSize: 9.5,
                              height: 1.35,
                              fontFamily: 'monospace',
                              fontWeight: isActive
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
              _sectionTitle(Icons.history_rounded, 'Execution History', pink),
              const Spacer(),
              Text(
                '${executionHistory.length} steps',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.34),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (executionHistory.isEmpty)
            _emptyExecutionState()
          else
            Container(
              constraints: const BoxConstraints(maxHeight: 460),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: executionHistory.length,
                separatorBuilder: (_, _) => const SizedBox(height: 7),
                itemBuilder: (context, index) =>
                    _executionStepItem(index, executionHistory[index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _emptyExecutionState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 34, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.account_tree_outlined,
            color: Colors.white.withValues(alpha: 0.18),
            size: 30,
          ),
          const SizedBox(height: 9),
          Text(
            'No steps executed yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.38),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Use Play or Next Step to start the visualization.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.22),
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _executionStepItem(int index, TreeEvent event) {
    final color = _eventColor(event.type);
    final isCurrent = index == executionHistory.length - 1;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isCurrent
            ? color.withValues(alpha: 0.075)
            : Colors.white.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrent
              ? color.withValues(alpha: 0.24)
              : Colors.white.withValues(alpha: 0.055),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 27,
            height: 27,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_eventIcon(event.type), color: color, size: 14),
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
                          color: Colors.white.withValues(alpha: 0.82),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '#${index + 1}',
                      style: TextStyle(
                        color: color,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  event.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.48),
                    fontSize: 9,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    event.operation,
                    style: TextStyle(
                      color: color.withValues(alpha: 0.82),
                      fontSize: 8.5,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                    ),
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
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _infoBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: color.withValues(alpha: 0.72),
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            value,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 9.5,
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
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.13)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: color.withValues(alpha: 0.70),
                fontSize: 7.2,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TreeEdgePainter extends CustomPainter {
  final Map<int, Offset> positions;
  final int count;

  const _TreeEdgePainter({required this.positions, required this.count});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.13)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (var index = 0; index < count; index++) {
      final parent = positions[index];
      if (parent == null) continue;

      final left = 2 * index + 1;
      final right = 2 * index + 2;

      if (left < count && positions[left] != null) {
        canvas.drawLine(parent, positions[left]!, paint);
      }
      if (right < count && positions[right] != null) {
        canvas.drawLine(parent, positions[right]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _TreeEdgePainter oldDelegate) {
    return oldDelegate.count != count || oldDelegate.positions != positions;
  }
}
