import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PreorderTraversalScreen extends StatefulWidget {
  const PreorderTraversalScreen({super.key});

  @override
  State<PreorderTraversalScreen> createState() =>
      _PreorderTraversalScreenState();
}

enum PreorderMethod { recursive, iterative }

enum PreorderEventType {
  initialize,
  visit,
  goLeft,
  goRight,
  nullChild,
  backtrack,
  push,
  pop,
  complete,
}

class PreorderEvent {
  final PreorderEventType type;
  final int nodeIndex;
  final int childIndex;
  final int fromIndex;
  final List<int> result;
  final Set<int> visited;
  final List<int> stack;
  final String title;
  final String description;
  final String operation;

  const PreorderEvent({
    required this.type,
    required this.nodeIndex,
    this.childIndex = -1,
    this.fromIndex = -1,
    required this.result,
    required this.visited,
    this.stack = const [],
    required this.title,
    required this.description,
    required this.operation,
  });
}

class _PreorderTraversalScreenState extends State<PreorderTraversalScreen> {
  static const background = Color(0xFF030712);
  static const cardColor = Color(0xFF0B1428);
  static const visualizationColor = Color(0xFF081120);
  static const cyan = Color(0xFF00E5FF);
  static const blue = Color(0xFF2979FF);
  static const purple = Color(0xFF9C27FF);
  static const green = Color(0xFF00E676);
  static const orange = Color(0xFFFFB300);
  static const pink = Color(0xFFFF4081);

  final TextEditingController arrayController = TextEditingController(
    text: '1, 2, 3, 4, 5, 6, 7',
  );

  List<int> tree = [1, 2, 3, 4, 5, 6, 7];
  List<int> originalTree = [1, 2, 3, 4, 5, 6, 7];
  List<PreorderEvent> events = [];
  final List<PreorderEvent> history = [];

  Timer? timer;
  int currentStep = 0;
  int currentIndex = -1;
  int exploringIndex = -1;

  // These two indexes are used ONLY while returning from recursion.
  // This makes the visualizer show child -> immediate parent instead
  // of appearing to jump back to the root.
  int backtrackFrom = -1;
  int backtrackTo = -1;

  Set<int> visitedIndexes = {};
  List<int> traversalResult = [];
  List<int> stackSnapshot = [];
  PreorderMethod method = PreorderMethod.recursive;
  bool isRunning = false;
  bool isCompleted = false;
  double speed = 1.0;
  String executionMessage = 'Ready to start Preorder Traversal.';

  bool get _isRecursive => method == PreorderMethod.recursive;

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

  int _left(int i) => i * 2 + 1;
  int _right(int i) => i * 2 + 2;

  void _generateEvents() {
    if (_isRecursive) {
      _generateRecursiveEvents();
    } else {
      _generateIterativeEvents();
    }
  }

  void _setMethod(PreorderMethod value) {
    if (method == value) return;

    _stop();

    setState(() {
      method = value;
    });

    _generateEvents();
    _resetVisualOnly();
  }

  void _generateRecursiveEvents() {
    final generated = <PreorderEvent>[];
    final result = <int>[];
    final visited = <int>{};

    generated.add(
      const PreorderEvent(
        type: PreorderEventType.initialize,
        nodeIndex: 0,
        result: [],
        visited: {},
        title: 'Initialize',
        description: 'Start recursive preorder traversal from the root.',
        operation: 'preorder(root)',
      ),
    );

    if (tree.isNotEmpty) {
      _walkPreorder(0, generated, result, visited);
    }

    generated.add(
      PreorderEvent(
        type: PreorderEventType.complete,
        nodeIndex: -1,
        result: List<int>.from(result),
        visited: Set<int>.from(visited),
        title: 'Traversal Complete',
        description: 'All nodes have been visited in preorder.',
        operation: 'return result',
      ),
    );

    events = generated;
  }

  void _generateIterativeEvents() {
    final generated = <PreorderEvent>[];
    final result = <int>[];
    final visited = <int>{};
    final stack = <int>[];

    generated.add(
      const PreorderEvent(
        type: PreorderEventType.initialize,
        nodeIndex: 0,
        result: [],
        visited: {},
        stack: [],
        title: 'Initialize',
        description:
            'Start non-recursive preorder using an explicit stack instead of the call stack.',
        operation: 'Stack stack = []',
      ),
    );

    if (tree.isEmpty) {
      generated.add(
        const PreorderEvent(
          type: PreorderEventType.complete,
          nodeIndex: -1,
          result: [],
          visited: {},
          stack: [],
          title: 'Traversal Complete',
          description: 'The tree is empty.',
          operation: 'return result',
        ),
      );
      events = generated;
      return;
    }

    stack.add(0);
    generated.add(
      PreorderEvent(
        type: PreorderEventType.push,
        nodeIndex: 0,
        result: const [],
        visited: const {},
        stack: List<int>.from(stack),
        title: 'Push Root ${tree[0]}',
        description: 'Push the root onto the stack to begin iteration.',
        operation: 'stack.push(root)',
      ),
    );

    while (stack.isNotEmpty) {
      final index = stack.removeLast();
      final value = tree[index];

      generated.add(
        PreorderEvent(
          type: PreorderEventType.pop,
          nodeIndex: index,
          result: List<int>.from(result),
          visited: Set<int>.from(visited),
          stack: List<int>.from(stack),
          title: 'Pop Node $value',
          description:
              'Stack is not empty. Pop $value and process it as the current node.',
          operation: 'node = stack.pop()',
        ),
      );

      result.add(value);
      visited.add(index);

      generated.add(
        PreorderEvent(
          type: PreorderEventType.visit,
          nodeIndex: index,
          result: List<int>.from(result),
          visited: Set<int>.from(visited),
          stack: List<int>.from(stack),
          title: 'Visit Node $value',
          description: 'Visit $value and add it to the preorder result.',
          operation: 'visit(node)',
        ),
      );

      final right = _right(index);
      final left = _left(index);

      if (right < tree.length) {
        stack.add(right);
        generated.add(
          PreorderEvent(
            type: PreorderEventType.push,
            nodeIndex: index,
            childIndex: right,
            result: List<int>.from(result),
            visited: Set<int>.from(visited),
            stack: List<int>.from(stack),
            title: 'Push Right ${tree[right]}',
            description:
                'Push the right child first so the left child is processed next (LIFO).',
            operation: 'stack.push(node.right)',
          ),
        );
      } else {
        generated.add(
          PreorderEvent(
            type: PreorderEventType.nullChild,
            nodeIndex: index,
            result: List<int>.from(result),
            visited: Set<int>.from(visited),
            stack: List<int>.from(stack),
            title: 'Right Child is Null',
            description: 'Node $value has no right child to push.',
            operation: 'node.right == null',
          ),
        );
      }

      if (left < tree.length) {
        stack.add(left);
        generated.add(
          PreorderEvent(
            type: PreorderEventType.push,
            nodeIndex: index,
            childIndex: left,
            result: List<int>.from(result),
            visited: Set<int>.from(visited),
            stack: List<int>.from(stack),
            title: 'Push Left ${tree[left]}',
            description:
                'Push the left child last so it is popped first and visited next.',
            operation: 'stack.push(node.left)',
          ),
        );
      } else {
        generated.add(
          PreorderEvent(
            type: PreorderEventType.nullChild,
            nodeIndex: index,
            result: List<int>.from(result),
            visited: Set<int>.from(visited),
            stack: List<int>.from(stack),
            title: 'Left Child is Null',
            description: 'Node $value has no left child to push.',
            operation: 'node.left == null',
          ),
        );
      }
    }

    generated.add(
      PreorderEvent(
        type: PreorderEventType.complete,
        nodeIndex: -1,
        result: List<int>.from(result),
        visited: Set<int>.from(visited),
        stack: const [],
        title: 'Traversal Complete',
        description:
            'The stack is empty, so every node has been visited in preorder.',
        operation: 'stack.isEmpty',
      ),
    );

    events = generated;
  }

  // Actual recursive DFS:
  // Root -> Left subtree -> Right subtree.
  void _walkPreorder(
    int index,
    List<PreorderEvent> generated,
    List<int> result,
    Set<int> visited,
  ) {
    final value = tree[index];

    result.add(value);
    visited.add(index);

    generated.add(
      PreorderEvent(
        type: PreorderEventType.visit,
        nodeIndex: index,
        result: List<int>.from(result),
        visited: Set<int>.from(visited),
        title: 'Visit Node $value',
        description: 'Visit $value and add it to the preorder result.',
        operation: 'visit(node)',
      ),
    );

    final left = _left(index);

    if (left < tree.length) {
      generated.add(
        PreorderEvent(
          type: PreorderEventType.goLeft,
          nodeIndex: index,
          childIndex: left,
          result: List<int>.from(result),
          visited: Set<int>.from(visited),
          title: 'Go Left: $value → ${tree[left]}',
          description: 'Recursively enter the left subtree of $value.',
          operation: 'preorder(node.left)',
        ),
      );

      _walkPreorder(left, generated, result, visited);

      // IMPORTANT:
      // Recursion returns to the immediate parent, not to root.
      generated.add(
        PreorderEvent(
          type: PreorderEventType.backtrack,
          nodeIndex: index,
          childIndex: index,
          fromIndex: left,
          result: List<int>.from(result),
          visited: Set<int>.from(visited),
          title: 'Backtrack: ${tree[left]} → $value',
          description:
              'Left subtree finished. Return from ${tree[left]} to parent $value.',
          operation: 'return to $value',
        ),
      );
    } else {
      generated.add(
        PreorderEvent(
          type: PreorderEventType.nullChild,
          nodeIndex: index,
          result: List<int>.from(result),
          visited: Set<int>.from(visited),
          title: 'Left Child is Null',
          description: 'Node $value has no left child.',
          operation: 'node.left == null',
        ),
      );
    }

    final right = _right(index);

    if (right < tree.length) {
      generated.add(
        PreorderEvent(
          type: PreorderEventType.goRight,
          nodeIndex: index,
          childIndex: right,
          result: List<int>.from(result),
          visited: Set<int>.from(visited),
          title: 'Go Right: $value → ${tree[right]}',
          description: 'Recursively enter the right subtree of $value.',
          operation: 'preorder(node.right)',
        ),
      );

      _walkPreorder(right, generated, result, visited);

      generated.add(
        PreorderEvent(
          type: PreorderEventType.backtrack,
          nodeIndex: index,
          childIndex: index,
          fromIndex: right,
          result: List<int>.from(result),
          visited: Set<int>.from(visited),
          title: 'Backtrack: ${tree[right]} → $value',
          description:
              'Right subtree finished. Return from ${tree[right]} to parent $value.',
          operation: 'return to $value',
        ),
      );
    } else {
      generated.add(
        PreorderEvent(
          type: PreorderEventType.nullChild,
          nodeIndex: index,
          result: List<int>.from(result),
          visited: Set<int>.from(visited),
          title: 'Right Child is Null',
          description: 'Node $value has no right child.',
          operation: 'node.right == null',
        ),
      );
    }
  }

  void _applyEvent(PreorderEvent event) {
    setState(() {
      currentIndex = event.nodeIndex;
      exploringIndex = event.childIndex;
      backtrackFrom = event.fromIndex;
      backtrackTo = event.type == PreorderEventType.backtrack
          ? event.nodeIndex
          : -1;
      traversalResult = List<int>.from(event.result);
      visitedIndexes = Set<int>.from(event.visited);
      stackSnapshot = List<int>.from(event.stack);
      executionMessage = '${event.title}: ${event.description}';

      if (event.type == PreorderEventType.initialize) {
        currentIndex = tree.isEmpty ? -1 : 0;
        exploringIndex = -1;
        backtrackFrom = -1;
        backtrackTo = -1;
      }

      if (event.type != PreorderEventType.backtrack) {
        // Do not keep the old return arrow visible on the next step.
        backtrackFrom = -1;
        backtrackTo = -1;
      }

      if (event.type == PreorderEventType.complete) {
        currentIndex = -1;
        exploringIndex = -1;
        backtrackFrom = -1;
        backtrackTo = -1;
        isRunning = false;
        isCompleted = true;
        executionMessage = 'Preorder Complete: ${event.result.join(' → ')}';
      }
    });
  }

  void _nextStep() {
    if (currentStep >= events.length) return;

    final event = events[currentStep];
    history.add(event);
    _applyEvent(event);
    currentStep++;

    if (event.type == PreorderEventType.complete) {
      _stop();
    }
  }

  void _previousStep() {
    if (currentStep <= 1) {
      _resetVisualOnly();
      return;
    }

    _stop();

    final target = currentStep - 2;
    history.clear();

    setState(() {
      currentStep = 0;
      currentIndex = -1;
      exploringIndex = -1;
      backtrackFrom = -1;
      backtrackTo = -1;
      visitedIndexes.clear();
      traversalResult.clear();
      stackSnapshot.clear();
      isCompleted = false;
    });

    for (int i = 0; i <= target; i++) {
      history.add(events[i]);
      _applyEvent(events[i]);
      currentStep = i + 1;
    }
  }

  void _play() {
    if (events.isEmpty) return;

    if (isRunning) {
      _stop();
      return;
    }

    if (isCompleted) {
      _resetVisualOnly();
    }

    setState(() => isRunning = true);

    timer?.cancel();
    timer = Timer.periodic(
      Duration(milliseconds: max(180, (850 / speed).round())),
      (_) {
        if (!mounted || !isRunning) return;

        if (currentStep >= events.length) {
          _stop();
          return;
        }

        _nextStep();
      },
    );
  }

  void _stop() {
    timer?.cancel();
    timer = null;
    if (mounted) {
      setState(() => isRunning = false);
    }
  }

  void _resetVisualOnly() {
    _stop();

    setState(() {
      currentStep = 0;
      history.clear();
      currentIndex = -1;
      exploringIndex = -1;
      backtrackFrom = -1;
      backtrackTo = -1;
      visitedIndexes.clear();
      traversalResult.clear();
      stackSnapshot.clear();
      isRunning = false;
      isCompleted = false;
      executionMessage = _isRecursive
          ? 'Ready to start recursive Preorder Traversal.'
          : 'Ready to start non-recursive Preorder Traversal.';
    });
  }

  void _reset() {
    _stop();

    setState(() {
      tree = List<int>.from(originalTree);
      events.clear();
    });

    _generateEvents();
    _resetVisualOnly();
  }

  void _loadTree() {
    final values = arrayController.text
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();

    if (values.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid tree nodes.')),
      );
      return;
    }

    _stop();

    setState(() {
      tree = values;
      originalTree = List<int>.from(values);
    });

    _generateEvents();
    _resetVisualOnly();
  }

  void _generateTree() {
    final random = Random();
    final values = List.generate(7, (_) => random.nextInt(90) + 10);

    arrayController.text = values.join(', ');

    setState(() {
      tree = values;
      originalTree = List<int>.from(values);
    });

    _generateEvents();
    _resetVisualOnly();
  }

  Color _eventColor(PreorderEventType type) {
    switch (type) {
      case PreorderEventType.visit:
        return green;
      case PreorderEventType.goLeft:
      case PreorderEventType.goRight:
        return orange;
      case PreorderEventType.backtrack:
        return blue;
      case PreorderEventType.nullChild:
        return pink;
      case PreorderEventType.complete:
        return purple;
      case PreorderEventType.initialize:
        return cyan;
      case PreorderEventType.push:
        return orange;
      case PreorderEventType.pop:
        return blue;
    }
  }

  IconData _eventIcon(PreorderEventType type) {
    switch (type) {
      case PreorderEventType.visit:
        return Icons.radio_button_checked_rounded;
      case PreorderEventType.goLeft:
        return Icons.subdirectory_arrow_left_rounded;
      case PreorderEventType.goRight:
        return Icons.subdirectory_arrow_right_rounded;
      case PreorderEventType.backtrack:
        return Icons.undo_rounded;
      case PreorderEventType.nullChild:
        return Icons.block_rounded;
      case PreorderEventType.complete:
        return Icons.check_circle_rounded;
      case PreorderEventType.initialize:
        return Icons.play_circle_outline_rounded;
      case PreorderEventType.push:
        return Icons.vertical_align_top_rounded;
      case PreorderEventType.pop:
        return Icons.vertical_align_bottom_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(),
                      const SizedBox(height: 14),
                      _algorithmInfo(),
                      const SizedBox(height: 14),
                      _inputSection(),
                      const SizedBox(height: 14),
                      _traversalMethodSection(),
                      const SizedBox(height: 14),
                      if (constraints.maxWidth < 950) ...[
                        _visualization(),
                        const SizedBox(height: 14),
                        _controls(),
                        const SizedBox(height: 14),
                        _sourceCode(),
                        const SizedBox(height: 14),
                        _executionSteps(),
                      ] else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                children: [
                                  _visualization(),
                                  const SizedBox(height: 14),
                                  _controls(),
                                ],
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  _sourceCode(),
                                  const SizedBox(height: 14),
                                  _executionSteps(),
                                ],
                              ),
                            ),
                          ],
                        ),
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

  Widget _header() {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: cyan.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cyan.withValues(alpha: .25)),
          ),
          child: const Icon(Icons.account_tree_rounded, color: cyan),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tree Preorder Traversal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Recursive DFS • Root → Left → Right',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
        _smallBadge(
          method == PreorderMethod.recursive ? 'RECURSIVE' : 'NON-RECURSIVE',
          cyan,
        ),
        const SizedBox(width: 7),
        _smallBadge('DFS', purple),
      ],
    );
  }

  Widget _smallBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: .22)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _algorithmInfo() {
    return _card(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _infoBox('ORDER', 'Root → Left → Right', cyan),
          _infoBox(
            'METHOD',
            method == PreorderMethod.recursive ? 'Recursive' : 'Non-recursive',
            purple,
          ),
          _infoBox('TYPE', 'DFS', orange),
          _infoBox('TIME', 'O(n)', green),
          _infoBox('SPACE', 'O(h)', blue),
        ],
      ),
    );
  }

  Widget _methodSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: visualizationColor,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white.withValues(alpha: .10)),
      ),
      child: Row(
        children: [
          Expanded(child: _methodButton(PreorderMethod.recursive, 'RECURSIVE')),
          Expanded(
            child: _methodButton(PreorderMethod.iterative, 'NON-RECURSIVE'),
          ),
        ],
      ),
    );
  }

  Widget _traversalMethodSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.alt_route_rounded, 'Traversal Method', purple),
          const SizedBox(height: 11),
          _methodSelector(),
        ],
      ),
    );
  }

  Widget _methodButton(PreorderMethod value, String label) {
    final selected = method == value;
    return InkWell(
      onTap: () => _setMethod(value),
      borderRadius: BorderRadius.circular(7),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? cyan.withValues(alpha: .16) : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? cyan : Colors.white54,
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _inputSection() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.input_rounded, 'Tree Input', cyan),
          const SizedBox(height: 11),
          LayoutBuilder(
            builder: (context, c) {
              final stacked = c.maxWidth < 700;

              final field = TextField(
                controller: arrayController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                cursorColor: cyan,
                decoration: InputDecoration(
                  labelText: 'Enter Tree Nodes',
                  hintText: '1, 2, 3, 4, 5, 6, 7',
                  labelStyle: const TextStyle(color: Colors.white54),
                  hintStyle: const TextStyle(color: Colors.white24),
                  prefixIcon: const Icon(
                    Icons.account_tree_rounded,
                    color: cyan,
                  ),
                  filled: true,
                  fillColor: visualizationColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: .08),
                    ),
                  ),
                ),
              );

              final buttons = Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _generateTree,
                      icon: const Icon(Icons.auto_awesome_rounded, size: 17),
                      label: const Text('GENERATE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _loadTree,
                      icon: const Icon(Icons.download_rounded, size: 17),
                      label: const Text('LOAD TREE'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cyan,
                        foregroundColor: background,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              );

              if (stacked) {
                return Column(
                  children: [field, const SizedBox(height: 9), buttons],
                );
              }

              return Row(
                children: [
                  Expanded(child: field),
                  const SizedBox(width: 9),
                  SizedBox(width: 270, child: buttons),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Array representation: left = 2i + 1, right = 2i + 2',
            style: TextStyle(
              color: Colors.white.withValues(alpha: .35),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _visualization() {
    final levels = tree.isEmpty ? 1 : (log(tree.length) / log(2)).floor() + 1;
    final height = max(300.0, levels * 105.0);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.account_tree_rounded, 'Visualization', cyan),
          const SizedBox(height: 11),
          Row(
            children: [
              _miniBadge(
                'CURRENT',
                currentIndex >= 0 && currentIndex < tree.length
                    ? '${tree[currentIndex]}'
                    : '-',
                cyan,
              ),
              const SizedBox(width: 7),
              _miniBadge('VISITED', '${visitedIndexes.length}', green),
              const SizedBox(width: 7),
              _miniBadge('RESULT', '${traversalResult.length}', purple),
              const SizedBox(width: 7),
              _miniBadge('STEP', '$currentStep/${events.length}', orange),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: height,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: visualizationColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: .06)),
            ),
            child: tree.isEmpty
                ? const Center(
                    child: Text(
                      'Load a tree to visualize.',
                      style: TextStyle(color: Colors.white38),
                    ),
                  )
                : CustomPaint(
                    painter: _PreorderTreePainter(
                      values: tree,
                      currentIndex: currentIndex,
                      exploringIndex: exploringIndex,
                      backtrackFrom: backtrackFrom,
                      backtrackTo: backtrackTo,
                      visitedIndexes: visitedIndexes,
                      cyan: cyan,
                      green: green,
                      orange: orange,
                      purple: purple,
                      blue: blue,
                    ),
                    child: const SizedBox.expand(),
                  ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .025),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: .06)),
            ),
            child: Text(
              executionMessage,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
          if (traversalResult.isNotEmpty) ...[
            const SizedBox(height: 9),
            Row(
              children: [
                const Text(
                  'PREORDER:',
                  style: TextStyle(
                    color: purple,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    traversalResult.join(' → '),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _controls() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.tune_rounded, 'Traversal Controls', orange),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: currentStep > 0 ? _previousStep : null,
                  icon: const Icon(Icons.skip_previous_rounded, size: 17),
                  label: const Text('PREVIOUS'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _play,
                  icon: Icon(
                    isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  ),
                  label: Text(isRunning ? 'PAUSE' : 'PLAY'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cyan,
                    foregroundColor: background,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: currentStep < events.length ? _nextStep : null,
                  icon: const Icon(Icons.skip_next_rounded, size: 17),
                  label: const Text('NEXT'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _reset,
                tooltip: 'Reset',
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Speed',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
              Expanded(
                child: Slider(
                  value: speed,
                  min: .5,
                  max: 2.5,
                  divisions: 8,
                  activeColor: cyan,
                  onChanged: (v) {
                    setState(() => speed = v);
                  },
                ),
              ),
              Text(
                '${speed.toStringAsFixed(1)}x',
                style: const TextStyle(color: cyan, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sourceCode() {
    final code = _isRecursive
        ? '''void preorder(Node node) {
  if (node == null) return;

  visit(node);           // Root
  preorder(node.left);   // Left
  preorder(node.right);  // Right
}'''
        : '''List<int> preorder(Node root) {
  if (root == null) return [];

  final stack = <Node>[root];
  final result = <int>[];

  while (stack.isNotEmpty) {
    final node = stack.removeLast();
    result.add(node.value);       // Root

    // Push right first; the left child is processed first (LIFO).
    if (node.right != null) stack.add(node.right!);
    if (node.left != null) stack.add(node.left!);
  }

  return result;                  // Root → Left → Right
}''';

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _sectionTitle(
                  Icons.code_rounded,
                  _isRecursive
                      ? 'Recursive Source Code'
                      : 'Iterative Source Code',
                  purple,
                ),
              ),
              IconButton(
                tooltip: 'Copy code',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Source code copied.')),
                  );
                },
                icon: const Icon(
                  Icons.copy_rounded,
                  color: Colors.white54,
                  size: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF050A14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                code,
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                  fontSize: 10.5,
                  height: 1.55,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _executionSteps() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.timeline_rounded, 'Execution Steps', green),
          const SizedBox(height: 9),
          if (history.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: visualizationColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Press PLAY or NEXT to start',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 560),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final event = history[index];
                  final color = _eventColor(event.type);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .045),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: color.withValues(alpha: .14)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(_eventIcon(event.type), color: color, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#${index + 1}  ${event.title}',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                event.description,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 9.5,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                event.operation,
                                style: const TextStyle(
                                  color: Colors.white30,
                                  fontFamily: 'monospace',
                                  fontSize: 8.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
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
        border: Border.all(color: Colors.white.withValues(alpha: .065)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 7),
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
          width: 29,
          height: 29,
          decoration: BoxDecoration(
            color: color.withValues(alpha: .09),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 8),
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
        color: color.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: .15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color.withValues(alpha: .8),
              fontSize: 8,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
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
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .06),
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: color.withValues(alpha: .16)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                letterSpacing: .5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreorderTreePainter extends CustomPainter {
  final List<int> values;
  final int currentIndex;
  final int exploringIndex;
  final int backtrackFrom;
  final int backtrackTo;
  final Set<int> visitedIndexes;
  final Color cyan;
  final Color green;
  final Color orange;
  final Color purple;
  final Color blue;

  const _PreorderTreePainter({
    required this.values,
    required this.currentIndex,
    required this.exploringIndex,
    required this.backtrackFrom,
    required this.backtrackTo,
    required this.visitedIndexes,
    required this.cyan,
    required this.green,
    required this.orange,
    required this.purple,
    required this.blue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final n = values.length;
    final levels = (log(n) / log(2)).floor() + 1;
    final radius = n > 15 ? 15.0 : 20.0;
    final positions = <Offset>[];

    for (int i = 0; i < n; i++) {
      final level = (log(i + 1) / log(2)).floor();
      final first = (1 << level) - 1;
      final positionInLevel = i - first;
      final countInLevel = 1 << level;

      final x = size.width * (positionInLevel + 1) / (countInLevel + 1);

      final y = levels == 1
          ? size.height / 2
          : 28 + level * ((size.height - 56) / (levels - 1));

      positions.add(Offset(x, y));
    }

    final normalEdge = Paint()
      ..color = Colors.white.withValues(alpha: .15)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final activeEdge = Paint()
      ..color = orange.withValues(alpha: .95)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final returnEdge = Paint()
      ..color = blue.withValues(alpha: .98)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < n; i++) {
      final left = i * 2 + 1;
      final right = i * 2 + 2;

      if (left < n) {
        final isReturn = backtrackFrom == left && backtrackTo == i;
        final isActive = exploringIndex == left;

        canvas.drawLine(
          positions[i],
          positions[left],
          isReturn ? returnEdge : (isActive ? activeEdge : normalEdge),
        );
      }

      if (right < n) {
        final isReturn = backtrackFrom == right && backtrackTo == i;
        final isActive = exploringIndex == right;

        canvas.drawLine(
          positions[i],
          positions[right],
          isReturn ? returnEdge : (isActive ? activeEdge : normalEdge),
        );
      }
    }

    // During a backtrack event, draw the arrow from the child
    // back to the immediate parent.
    if (backtrackFrom >= 0 &&
        backtrackTo >= 0 &&
        backtrackFrom < positions.length &&
        backtrackTo < positions.length) {
      _drawArrow(
        canvas,
        positions[backtrackFrom],
        positions[backtrackTo],
        returnEdge,
        radius,
      );
    }

    for (int i = 0; i < n; i++) {
      Color fill = const Color(0xFF111827);
      Color border = Colors.white.withValues(alpha: .18);
      Color textColor = Colors.white;

      if (visitedIndexes.contains(i)) {
        fill = green.withValues(alpha: .16);
        border = green;
        textColor = green;
      }

      if (i == exploringIndex) {
        fill = orange.withValues(alpha: .18);
        border = orange;
        textColor = orange;
      }

      if (i == currentIndex) {
        fill = cyan.withValues(alpha: .22);
        border = cyan;
        textColor = cyan;
      }

      if (i == backtrackFrom) {
        fill = blue.withValues(alpha: .18);
        border = blue;
        textColor = blue;
      }

      final glow = Paint()
        ..color = border.withValues(alpha: .24)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11);

      if (i == currentIndex ||
          i == exploringIndex ||
          i == backtrackFrom ||
          visitedIndexes.contains(i)) {
        canvas.drawCircle(positions[i], radius + 6, glow);
      }

      canvas.drawCircle(positions[i], radius, Paint()..color = fill);

      canvas.drawCircle(
        positions[i],
        radius,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );

      final text = TextPainter(
        text: TextSpan(
          text: '${values[i]}',
          style: TextStyle(
            color: textColor,
            fontSize: n > 15 ? 10 : 13,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      text.paint(
        canvas,
        positions[i] - Offset(text.width / 2, text.height / 2),
      );

      final indexText = TextPainter(
        text: TextSpan(
          text: '[$i]',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .28),
            fontSize: 7.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      indexText.paint(
        canvas,
        positions[i] + Offset(-indexText.width / 2, radius + 4),
      );
    }
  }

  void _drawArrow(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint,
    double radius,
  ) {
    final direction = to - from;
    final length = direction.distance;
    if (length < 1) return;

    final unit = direction / length;
    final start = from + unit * radius;
    final end = to - unit * radius;

    canvas.drawLine(start, end, paint);

    final angle = atan2(unit.dy, unit.dx);
    const arrowSize = 9.0;

    final p1 =
        end -
        Offset(
          cos(angle - pi / 6) * arrowSize,
          sin(angle - pi / 6) * arrowSize,
        );

    final p2 =
        end -
        Offset(
          cos(angle + pi / 6) * arrowSize,
          sin(angle + pi / 6) * arrowSize,
        );

    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();

    canvas.drawPath(path, paint..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant _PreorderTreePainter oldDelegate) {
    return oldDelegate.currentIndex != currentIndex ||
        oldDelegate.exploringIndex != exploringIndex ||
        oldDelegate.backtrackFrom != backtrackFrom ||
        oldDelegate.backtrackTo != backtrackTo ||
        oldDelegate.values != values ||
        oldDelegate.visitedIndexes != visitedIndexes;
  }
}
