import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InorderTraversalScreen extends StatefulWidget {
  const InorderTraversalScreen({super.key});

  @override
  State<InorderTraversalScreen> createState() => _InorderTraversalScreenState();
}

// ============================================================================
// METHOD
// ============================================================================

enum InorderMethod { recursive, iterative }

// ============================================================================
// EVENT TYPE
// ============================================================================

enum InorderEventType {
  initialize,
  goLeft,
  visit,
  goRight,
  nullChild,
  backtrack,
  push,
  pop,
  complete,
}

// ============================================================================
// EVENT MODEL
// ============================================================================

class InorderEvent {
  final InorderEventType type;

  final int nodeIndex;
  final int childIndex;
  final int fromIndex;

  final List<int> result;
  final Set<int> visited;
  final List<int> stack;

  final String title;
  final String description;
  final String operation;

  const InorderEvent({
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

// ============================================================================
// SCREEN
// ============================================================================

class _InorderTraversalScreenState extends State<InorderTraversalScreen> {
  // ==========================================================================
  // COLORS
  // ==========================================================================

  static const background = Color(0xFF030712);
  static const cardColor = Color(0xFF0B1428);
  static const visualizationColor = Color(0xFF081120);

  static const cyan = Color(0xFF00E5FF);
  static const blue = Color(0xFF2979FF);
  static const purple = Color(0xFF9C27FF);
  static const green = Color(0xFF00E676);
  static const orange = Color(0xFFFFB300);
  static const pink = Color(0xFFFF4081);

  // ==========================================================================
  // INPUT
  // ==========================================================================

  final TextEditingController arrayController = TextEditingController(
    text: '1, 2, 3, 4, 5, 6, 7',
  );

  List<int> tree = [1, 2, 3, 4, 5, 6, 7];

  List<int> originalTree = [1, 2, 3, 4, 5, 6, 7];

  // ==========================================================================
  // EVENTS
  // ==========================================================================

  List<InorderEvent> events = [];

  final List<InorderEvent> history = [];

  Timer? timer;

  // ==========================================================================
  // VISUAL STATE
  // ==========================================================================

  int currentStep = 0;

  int currentIndex = -1;

  int exploringIndex = -1;

  int backtrackFrom = -1;

  int backtrackTo = -1;

  Set<int> visitedIndexes = {};

  List<int> traversalResult = [];

  List<int> stackSnapshot = [];

  // ==========================================================================
  // EXECUTION
  // ==========================================================================

  InorderMethod method = InorderMethod.recursive;

  bool isRunning = false;

  bool isCompleted = false;

  double speed = 1.0;

  String executionMessage = 'Ready to start recursive Inorder Traversal.';

  bool get _isRecursive => method == InorderMethod.recursive;

  // ==========================================================================
  // LIFECYCLE
  // ==========================================================================

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

  // ==========================================================================
  // TREE HELPERS
  // ==========================================================================

  int _left(int index) => index * 2 + 1;

  int _right(int index) => index * 2 + 2;

  // ==========================================================================
  // EVENT GENERATION
  // ==========================================================================

  void _generateEvents() {
    if (_isRecursive) {
      _generateRecursiveEvents();
    } else {
      _generateIterativeEvents();
    }
  }

  // ==========================================================================
  // METHOD SWITCH
  // ==========================================================================

  void _setMethod(InorderMethod value) {
    if (method == value) return;

    _stop();

    setState(() {
      method = value;
    });

    _generateEvents();
    _resetVisualOnly();
  }

  // ==========================================================================
  // RECURSIVE EVENTS
  // ==========================================================================
  //
  // INORDER:
  // LEFT -> ROOT -> RIGHT
  //
  // ==========================================================================

  void _generateRecursiveEvents() {
    final generated = <InorderEvent>[];
    final result = <int>[];
    final visited = <int>{};

    generated.add(
      const InorderEvent(
        type: InorderEventType.initialize,
        nodeIndex: 0,
        result: [],
        visited: {},
        title: 'Initialize',
        description:
            'Start recursive inorder traversal from the root. Inorder follows Left → Root → Right.',
        operation: 'inorder(root)',
      ),
    );

    if (tree.isNotEmpty) {
      _walkInorder(0, generated, result, visited);
    }

    generated.add(
      InorderEvent(
        type: InorderEventType.complete,
        nodeIndex: -1,
        result: List<int>.from(result),
        visited: Set<int>.from(visited),
        title: 'Traversal Complete',
        description:
            'All nodes have been visited in inorder: Left → Root → Right.',
        operation: 'return result',
      ),
    );

    events = generated;
  }

  void _walkInorder(
    int index,
    List<InorderEvent> generated,
    List<int> result,
    Set<int> visited,
  ) {
    final value = tree[index];

    // ------------------------------------------------------------------------
    // GO LEFT
    // ------------------------------------------------------------------------

    final left = _left(index);

    if (left < tree.length) {
      generated.add(
        InorderEvent(
          type: InorderEventType.goLeft,
          nodeIndex: index,
          childIndex: left,
          result: List<int>.from(result),
          visited: Set<int>.from(visited),
          title: 'Go Left: $value → ${tree[left]}',
          description:
              'In inorder, visit the complete left subtree before visiting the current node.',
          operation: 'inorder(node.left)',
        ),
      );

      _walkInorder(left, generated, result, visited);

      // Return from immediate child to parent.
      generated.add(
        InorderEvent(
          type: InorderEventType.backtrack,
          nodeIndex: index,
          childIndex: index,
          fromIndex: left,
          result: List<int>.from(result),
          visited: Set<int>.from(visited),
          title: 'Backtrack: ${tree[left]} → $value',
          description:
              'Left subtree of $value is complete. Return to the parent node.',
          operation: 'return to $value',
        ),
      );
    } else {
      generated.add(
        InorderEvent(
          type: InorderEventType.nullChild,
          nodeIndex: index,
          result: List<int>.from(result),
          visited: Set<int>.from(visited),
          title: 'Left Child is Null',
          description: 'Node $value has no left child. Now it can be visited.',
          operation: 'node.left == null',
        ),
      );
    }

    // ------------------------------------------------------------------------
    // VISIT ROOT
    // ------------------------------------------------------------------------

    result.add(value);
    visited.add(index);

    generated.add(
      InorderEvent(
        type: InorderEventType.visit,
        nodeIndex: index,
        result: List<int>.from(result),
        visited: Set<int>.from(visited),
        title: 'Visit Node $value',
        description:
            'Left subtree is complete, so visit the current node $value.',
        operation: 'visit(node)',
      ),
    );

    // ------------------------------------------------------------------------
    // GO RIGHT
    // ------------------------------------------------------------------------

    final right = _right(index);

    if (right < tree.length) {
      generated.add(
        InorderEvent(
          type: InorderEventType.goRight,
          nodeIndex: index,
          childIndex: right,
          result: List<int>.from(result),
          visited: Set<int>.from(visited),
          title: 'Go Right: $value → ${tree[right]}',
          description:
              'After visiting the current node, recursively visit the right subtree.',
          operation: 'inorder(node.right)',
        ),
      );

      _walkInorder(right, generated, result, visited);

      generated.add(
        InorderEvent(
          type: InorderEventType.backtrack,
          nodeIndex: index,
          childIndex: index,
          fromIndex: right,
          result: List<int>.from(result),
          visited: Set<int>.from(visited),
          title: 'Backtrack: ${tree[right]} → $value',
          description:
              'Right subtree of $value is complete. Return to the parent node.',
          operation: 'return to $value',
        ),
      );
    } else {
      generated.add(
        InorderEvent(
          type: InorderEventType.nullChild,
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

  // ==========================================================================
  // ITERATIVE EVENTS
  // ==========================================================================
  //
  // INORDER ITERATIVE:
  //
  // while (current != null || stack.isNotEmpty)
  // {
  //   while (current != null)
  //   {
  //     stack.push(current);
  //     current = current.left;
  //   }
  //
  //   current = stack.pop();
  //   visit(current);
  //   current = current.right;
  // }
  //
  // ==========================================================================

  void _generateIterativeEvents() {
    final generated = <InorderEvent>[];

    final result = <int>[];

    final visited = <int>{};

    final stack = <int>[];

    generated.add(
      const InorderEvent(
        type: InorderEventType.initialize,
        nodeIndex: 0,
        result: [],
        visited: {},
        stack: [],
        title: 'Initialize',
        description: 'Start non-recursive inorder using an explicit stack.',
        operation: 'Stack stack = []',
      ),
    );

    if (tree.isEmpty) {
      generated.add(
        const InorderEvent(
          type: InorderEventType.complete,
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

    int current = 0;

    while (current >= 0 || stack.isNotEmpty) {
      // ----------------------------------------------------------------------
      // PUSH ALL LEFT NODES
      // ----------------------------------------------------------------------

      while (current >= 0 && current < tree.length) {
        stack.add(current);

        generated.add(
          InorderEvent(
            type: InorderEventType.push,
            nodeIndex: current,
            result: List<int>.from(result),
            visited: Set<int>.from(visited),
            stack: List<int>.from(stack),
            title: 'Push ${tree[current]}',
            description:
                'Push ${tree[current]} onto the stack and continue to its left child.',
            operation: 'stack.push(current)',
          ),
        );

        final left = _left(current);

        if (left < tree.length) {
          generated.add(
            InorderEvent(
              type: InorderEventType.goLeft,
              nodeIndex: current,
              childIndex: left,
              result: List<int>.from(result),
              visited: Set<int>.from(visited),
              stack: List<int>.from(stack),
              title: 'Go Left: ${tree[current]} → ${tree[left]}',
              description:
                  'Move to the left child because inorder visits Left first.',
              operation: 'current = current.left',
            ),
          );

          current = left;
        } else {
          generated.add(
            InorderEvent(
              type: InorderEventType.nullChild,
              nodeIndex: current,
              result: List<int>.from(result),
              visited: Set<int>.from(visited),
              stack: List<int>.from(stack),
              title: 'Left Child is Null',
              description:
                  'Node ${tree[current]} has no left child. Stop moving left.',
              operation: 'current.left == null',
            ),
          );

          current = -1;
        }
      }

      // ----------------------------------------------------------------------
      // STACK EMPTY
      // ----------------------------------------------------------------------

      if (stack.isEmpty) {
        break;
      }

      // ----------------------------------------------------------------------
      // POP
      // ----------------------------------------------------------------------

      final index = stack.removeLast();

      generated.add(
        InorderEvent(
          type: InorderEventType.pop,
          nodeIndex: index,
          result: List<int>.from(result),
          visited: Set<int>.from(visited),
          stack: List<int>.from(stack),
          title: 'Pop Node ${tree[index]}',
          description:
              'Pop ${tree[index]} from the stack because its left subtree is complete.',
          operation: 'current = stack.pop()',
        ),
      );

      // ----------------------------------------------------------------------
      // VISIT
      // ----------------------------------------------------------------------

      result.add(tree[index]);
      visited.add(index);

      generated.add(
        InorderEvent(
          type: InorderEventType.visit,
          nodeIndex: index,
          result: List<int>.from(result),
          visited: Set<int>.from(visited),
          stack: List<int>.from(stack),
          title: 'Visit Node ${tree[index]}',
          description:
              'Visit ${tree[index]} after completing its left subtree.',
          operation: 'visit(current)',
        ),
      );

      // ----------------------------------------------------------------------
      // MOVE RIGHT
      // ----------------------------------------------------------------------

      final right = _right(index);

      if (right < tree.length) {
        generated.add(
          InorderEvent(
            type: InorderEventType.goRight,
            nodeIndex: index,
            childIndex: right,
            result: List<int>.from(result),
            visited: Set<int>.from(visited),
            stack: List<int>.from(stack),
            title: 'Go Right: ${tree[index]} → ${tree[right]}',
            description:
                'After visiting ${tree[index]}, move to its right subtree.',
            operation: 'current = current.right',
          ),
        );

        current = right;
      } else {
        generated.add(
          InorderEvent(
            type: InorderEventType.nullChild,
            nodeIndex: index,
            result: List<int>.from(result),
            visited: Set<int>.from(visited),
            stack: List<int>.from(stack),
            title: 'Right Child is Null',
            description:
                'Node ${tree[index]} has no right child. Continue with the stack.',
            operation: 'current.right == null',
          ),
        );

        current = -1;
      }
    }

    generated.add(
      InorderEvent(
        type: InorderEventType.complete,
        nodeIndex: -1,
        result: List<int>.from(result),
        visited: Set<int>.from(visited),
        stack: const [],
        title: 'Traversal Complete',
        description:
            'The stack is empty and all nodes have been visited in inorder.',
        operation: 'stack.isEmpty',
      ),
    );

    events = generated;
  }

  // ==========================================================================
  // APPLY EVENT
  // ==========================================================================

  void _applyEvent(InorderEvent event) {
    setState(() {
      currentIndex = event.nodeIndex;

      exploringIndex = event.childIndex;

      backtrackFrom = event.fromIndex;

      backtrackTo = event.type == InorderEventType.backtrack
          ? event.nodeIndex
          : -1;

      traversalResult = List<int>.from(event.result);

      visitedIndexes = Set<int>.from(event.visited);

      stackSnapshot = List<int>.from(event.stack);

      executionMessage = '${event.title}: ${event.description}';

      if (event.type == InorderEventType.initialize) {
        currentIndex = tree.isEmpty ? -1 : 0;
        exploringIndex = -1;
        backtrackFrom = -1;
        backtrackTo = -1;
      }

      if (event.type != InorderEventType.backtrack) {
        backtrackFrom = -1;
        backtrackTo = -1;
      }

      if (event.type == InorderEventType.complete) {
        currentIndex = -1;
        exploringIndex = -1;
        backtrackFrom = -1;
        backtrackTo = -1;

        isRunning = false;
        isCompleted = true;

        executionMessage = 'Inorder Complete: ${event.result.join(' → ')}';
      }
    });
  }

  // ==========================================================================
  // NEXT
  // ==========================================================================

  void _nextStep() {
    if (currentStep >= events.length) return;

    final event = events[currentStep];

    history.add(event);

    _applyEvent(event);

    currentStep++;

    if (event.type == InorderEventType.complete) {
      _stop();
    }
  }

  // ==========================================================================
  // PREVIOUS
  // ==========================================================================

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

  // ==========================================================================
  // PLAY / PAUSE
  // ==========================================================================

  void _play() {
    if (events.isEmpty) return;

    if (isRunning) {
      _stop();
      return;
    }

    if (isCompleted) {
      _resetVisualOnly();
    }

    setState(() {
      isRunning = true;
    });

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

  // ==========================================================================
  // STOP
  // ==========================================================================

  void _stop() {
    timer?.cancel();
    timer = null;

    if (mounted) {
      setState(() {
        isRunning = false;
      });
    }
  }

  // ==========================================================================
  // RESET VISUAL
  // ==========================================================================

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
          ? 'Ready to start recursive Inorder Traversal.'
          : 'Ready to start non-recursive Inorder Traversal.';
    });
  }

  // ==========================================================================
  // RESET
  // ==========================================================================

  void _reset() {
    _stop();

    setState(() {
      tree = List<int>.from(originalTree);
      events.clear();
    });

    _generateEvents();

    _resetVisualOnly();
  }

  // ==========================================================================
  // LOAD TREE
  // ==========================================================================

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

  // ==========================================================================
  // GENERATE TREE
  // ==========================================================================

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

  // ==========================================================================
  // EVENT COLOR
  // ==========================================================================

  Color _eventColor(InorderEventType type) {
    switch (type) {
      case InorderEventType.visit:
        return green;

      case InorderEventType.goLeft:
      case InorderEventType.goRight:
        return orange;

      case InorderEventType.backtrack:
        return blue;

      case InorderEventType.nullChild:
        return pink;

      case InorderEventType.complete:
        return purple;

      case InorderEventType.initialize:
        return cyan;

      case InorderEventType.push:
        return orange;

      case InorderEventType.pop:
        return blue;
    }
  }

  // ==========================================================================
  // EVENT ICON
  // ==========================================================================

  IconData _eventIcon(InorderEventType type) {
    switch (type) {
      case InorderEventType.visit:
        return Icons.radio_button_checked_rounded;

      case InorderEventType.goLeft:
        return Icons.subdirectory_arrow_left_rounded;

      case InorderEventType.goRight:
        return Icons.subdirectory_arrow_right_rounded;

      case InorderEventType.backtrack:
        return Icons.undo_rounded;

      case InorderEventType.nullChild:
        return Icons.block_rounded;

      case InorderEventType.complete:
        return Icons.check_circle_rounded;

      case InorderEventType.initialize:
        return Icons.play_circle_outline_rounded;

      case InorderEventType.push:
        return Icons.vertical_align_top_rounded;

      case InorderEventType.pop:
        return Icons.vertical_align_bottom_rounded;
    }
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

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

  // ==========================================================================
  // HEADER
  // ==========================================================================

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
                'Tree Inorder Traversal',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),

              SizedBox(height: 2),

              Text(
                'Recursive / Non-Recursive DFS • Left → Root → Right',
                style: TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),

        _smallBadge(
          _isRecursive ? 'RECURSIVE' : 'ITERATIVE',
          _isRecursive ? cyan : purple,
        ),

        const SizedBox(width: 7),

        _smallBadge(
          _isRecursive ? 'DFS' : 'STACK',
          _isRecursive ? purple : orange,
        ),
      ],
    );
  }

  // ==========================================================================
  // SMALL BADGE
  // ==========================================================================

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

  // ==========================================================================
  // ALGORITHM INFO
  // ==========================================================================

  Widget _algorithmInfo() {
    return _card(
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _infoBox('ORDER', 'Left → Root → Right', cyan),

          _infoBox(
            'METHOD',
            _isRecursive ? 'Recursive' : 'Non-Recursive',
            _isRecursive ? purple : orange,
          ),

          _infoBox('TYPE', 'DFS', orange),

          _infoBox('TIME', 'O(n)', green),

          _infoBox('SPACE', _isRecursive ? 'O(h)' : 'O(h)', blue),
        ],
      ),
    );
  }

  // ==========================================================================
  // INPUT SECTION
  // ==========================================================================

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

  // ==========================================================================
  // VISUALIZATION
  // ==========================================================================

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
                    painter: _InorderTreePainter(
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
                  'INORDER:',
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

          if (!_isRecursive && stackSnapshot.isNotEmpty) ...[
            const SizedBox(height: 9),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STACK:',
                  style: TextStyle(
                    color: orange,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    stackSnapshot.map((i) => tree[i].toString()).join(' → '),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
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

  // ==========================================================================
  // CONTROLS
  // ==========================================================================

  Widget _controls() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.tune_rounded, 'Traversal Controls', orange),

          const SizedBox(height: 10),

          // ------------------------------------------------------------------
          // METHOD
          // ------------------------------------------------------------------
          Row(
            children: [
              Expanded(
                child: _methodButton(
                  title: 'RECURSIVE',
                  subtitle: 'Call Stack',
                  icon: Icons.account_tree_rounded,
                  color: cyan,
                  selected: method == InorderMethod.recursive,
                  onTap: () {
                    _setMethod(InorderMethod.recursive);
                  },
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: _methodButton(
                  title: 'NON-RECURSIVE',
                  subtitle: 'Explicit Stack',
                  icon: Icons.layers_rounded,
                  color: purple,
                  selected: method == InorderMethod.iterative,
                  onTap: () {
                    _setMethod(InorderMethod.iterative);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ------------------------------------------------------------------
          // MAIN BUTTONS
          // ------------------------------------------------------------------
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

          // ------------------------------------------------------------------
          // SPEED
          // ------------------------------------------------------------------
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
                    setState(() {
                      speed = v;
                    });
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

  // ==========================================================================
  // METHOD BUTTON
  // ==========================================================================

  Widget _methodButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: .10)
              : Colors.white.withValues(alpha: .025),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: .45)
                : Colors.white.withValues(alpha: .07),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? color : Colors.white38, size: 19),

            const SizedBox(width: 8),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? color : Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),
            ),

            if (selected)
              Icon(Icons.check_circle_rounded, color: color, size: 16),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // SOURCE CODE
  // ==========================================================================

  Widget _sourceCode() {
    const recursiveCode = '''void inorder(Node node) {
  if (node == null) {
    return;
  }

  // visit left subtree
  inorder(node.left);

  // visit current node
  visit(node);

  // visit right subtree
  inorder(node.right);
}''';

    const iterativeCode = '''List<int> inorder(Node root) {
  final stack = <Node>[];
  final result = <int>[];
  Node? current = root;

  while (current != null ||
      stack.isNotEmpty) {

    while (current != null) {
      stack.add(current);
      current = current.left;
    }

    current = stack.removeLast();
    result.add(current.value);

    current = current.right;
  }

  return result;
}''';

    final code = _isRecursive ? recursiveCode : iterativeCode;

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
                  Clipboard.setData(const ClipboardData(text: recursiveCode));

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

  // ==========================================================================
  // EXECUTION STEPS
  // ==========================================================================

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

                              if (event.stack.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Stack: ${event.stack.map((i) => tree[i]).join(' → ')}',
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontFamily: 'monospace',
                                    fontSize: 8.5,
                                  ),
                                ),
                              ],
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

  // ==========================================================================
  // SECTION TITLE
  // ==========================================================================

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

  // ==========================================================================
  // INFO BOX
  // ==========================================================================

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

  // ==========================================================================
  // MINI BADGE
  // ==========================================================================

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

// ============================================================================
// TREE PAINTER
// ============================================================================

class _InorderTreePainter extends CustomPainter {
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

  const _InorderTreePainter({
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

    // ------------------------------------------------------------------------
    // NODE POSITIONS
    // ------------------------------------------------------------------------

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

    // ------------------------------------------------------------------------
    // EDGES
    // ------------------------------------------------------------------------

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

    // ------------------------------------------------------------------------
    // BACKTRACK ARROW
    // ------------------------------------------------------------------------

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

    // ------------------------------------------------------------------------
    // NODES
    // ------------------------------------------------------------------------

    for (int i = 0; i < n; i++) {
      Color fill = const Color(0xFF111827);

      Color border = Colors.white.withValues(alpha: .18);

      Color textColor = Colors.white;

      // Visited
      if (visitedIndexes.contains(i)) {
        fill = green.withValues(alpha: .16);
        border = green;
        textColor = green;
      }

      // Exploring
      if (i == exploringIndex) {
        fill = orange.withValues(alpha: .18);
        border = orange;
        textColor = orange;
      }

      // Current
      if (i == currentIndex) {
        fill = cyan.withValues(alpha: .22);
        border = cyan;
        textColor = cyan;
      }

      // Backtracking
      if (i == backtrackFrom) {
        fill = blue.withValues(alpha: .18);
        border = blue;
        textColor = blue;
      }

      // Glow
      final glow = Paint()
        ..color = border.withValues(alpha: .24)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 11);

      if (i == currentIndex ||
          i == exploringIndex ||
          i == backtrackFrom ||
          visitedIndexes.contains(i)) {
        canvas.drawCircle(positions[i], radius + 6, glow);
      }

      // Fill
      canvas.drawCircle(positions[i], radius, Paint()..color = fill);

      // Border
      canvas.drawCircle(
        positions[i],
        radius,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.8,
      );

      // Text
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
    }
  }

  // ==========================================================================
  // ARROW
  // ==========================================================================

  void _drawArrow(
    Canvas canvas,
    Offset from,
    Offset to,
    Paint paint,
    double radius,
  ) {
    final direction = to - from;

    if (direction.distance == 0) {
      return;
    }

    final unit = direction / direction.distance;

    final start = from + unit * (radius + 2);

    final end = to - unit * (radius + 4);

    canvas.drawLine(start, end, paint);

    final angle = atan2(unit.dy, unit.dx);

    const arrowSize = 8.0;

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

    canvas.drawPath(path, Paint()..color = paint.color);
  }

  @override
  bool shouldRepaint(covariant _InorderTreePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.currentIndex != currentIndex ||
        oldDelegate.exploringIndex != exploringIndex ||
        oldDelegate.backtrackFrom != backtrackFrom ||
        oldDelegate.backtrackTo != backtrackTo ||
        oldDelegate.visitedIndexes != visitedIndexes;
  }
}
