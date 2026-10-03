import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/algorithm_screen_shell.dart';
import 'package:flutter/services.dart';

// ============================================================================
// POSTORDER TRAVERSAL
// Left -> Right -> Root
// ============================================================================

enum PostorderMethod { recursive, iterative }

enum PostorderEventType {
  initialize,
  goLeft,
  goRight,
  visit,
  nullChild,
  backtrack,
  push,
  pop,
  complete,
}

// ============================================================================
// EVENT MODEL
// ============================================================================

class PostorderEvent {
  final PostorderEventType type;
  final int? index;
  final int? value;
  final String message;
  final int codeLine;

  const PostorderEvent({
    required this.type,
    this.index,
    this.value,
    required this.message,
    required this.codeLine,
  });
}

// ============================================================================
// SCREEN
// ============================================================================

class PostorderTraversalScreen extends StatefulWidget {
  const PostorderTraversalScreen({super.key});

  @override
  State<PostorderTraversalScreen> createState() =>
      _PostorderTraversalScreenState();
}

class _PostorderTraversalScreenState extends State<PostorderTraversalScreen> {
  // --------------------------------------------------------------------------
  // COLORS
  // --------------------------------------------------------------------------

  static const Color background = AppColors.background;
  static const Color background2 = AppColors.background2;
  static const Color cardColor = AppColors.card;

  static const Color cyan = AppColors.cyan;
  static const Color blue = AppColors.blue;
  static const Color purple = AppColors.purple;
  static const Color green = AppColors.green;
  static const Color orange = AppColors.orange;
  static const Color pink = AppColors.pink;

  // --------------------------------------------------------------------------
  // CONTROLLERS
  // --------------------------------------------------------------------------

  final TextEditingController inputController = TextEditingController(
    text: '1, 2, 3, 4, 5, 6, 7',
  );

  // --------------------------------------------------------------------------
  // DATA
  // --------------------------------------------------------------------------

  List<int> values = [1, 2, 3, 4, 5, 6, 7];

  List<PostorderEvent> events = [];

  List<int> traversalResult = [];

  PostorderMethod method = PostorderMethod.recursive;

  int currentStep = 0;
  int currentNode = -1;
  int visitedNode = -1;
  int activeCodeLine = 0;

  bool isRunning = false;
  bool isPaused = false;
  bool isCompleted = false;

  double speed = 1.0;

  Timer? timer;

  String status = 'Ready';
  String operation = 'Waiting to start';
  String description =
      'Postorder Traversal visits nodes in Left → Right → Root order.';

  // --------------------------------------------------------------------------
  // SOURCE CODE
  // --------------------------------------------------------------------------

  final String recursiveCode = '''
void postorder(Node? node) {
  if (node == null) {
    return;
  }

  postorder(node.left);
  postorder(node.right);
  visit(node);
}''';

  final String iterativeCode = '''
void postorder(Node? root) {
  if (root == null) {
    return;
  }

  final stack = <Node>[root];

  while (stack.isNotEmpty) {
    final node = stack.removeLast();
    visit(node);

    if (node.left != null) {
      stack.add(node.left!);
    }

    if (node.right != null) {
      stack.add(node.right!);
    }
  }
}''';

  String get code {
    return method == PostorderMethod.recursive ? recursiveCode : iterativeCode;
  }

  // --------------------------------------------------------------------------
  // LOG
  // --------------------------------------------------------------------------

  final List<String> executionLog = [];

  // ==========================================================================
  // INIT
  // ==========================================================================

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

  // ==========================================================================
  // INPUT
  // ==========================================================================

  List<int> _parseInput() {
    final text = inputController.text.trim();

    if (text.isEmpty) {
      return [];
    }

    try {
      return text
          .split(RegExp(r'[,\s]+'))
          .where((e) => e.trim().isNotEmpty)
          .map(int.parse)
          .toList();
    } catch (_) {
      return [];
    }
  }

  void _loadInput() {
    final parsed = _parseInput();

    if (parsed.isEmpty) {
      _showMessage('Please enter valid numbers.');
      return;
    }

    if (parsed.length > 15) {
      _showMessage('Please enter maximum 15 numbers.');
      return;
    }

    setState(() {
      values = parsed;
      currentStep = 0;
      currentNode = -1;
      visitedNode = -1;
      activeCodeLine = 0;
      isRunning = false;
      isPaused = false;
      isCompleted = false;
      status = 'Ready';
      operation = 'Input loaded';
      description =
          'Binary tree created. Press Play or Next to start traversal.';
      traversalResult.clear();
      executionLog.clear();
    });

    _generateEvents();
  }

  // ==========================================================================
  // EVENT GENERATION
  // ==========================================================================

  void _generateEvents() {
    events.clear();

    if (values.isEmpty) {
      return;
    }

    events.add(
      const PostorderEvent(
        type: PostorderEventType.initialize,
        message: 'Initialize Postorder Traversal.',
        codeLine: 1,
      ),
    );

    if (method == PostorderMethod.recursive) {
      _generateRecursiveEvents(0);
    } else {
      _generateIterativeEvents();
    }

    events.add(
      const PostorderEvent(
        type: PostorderEventType.complete,
        message: 'Traversal completed successfully.',
        codeLine: 8,
      ),
    );
  }

  void _generateRecursiveEvents(int index) {
    if (index >= values.length) {
      events.add(
        PostorderEvent(
          type: PostorderEventType.nullChild,
          index: index,
          message: 'Reached a null child. Return.',
          codeLine: 3,
        ),
      );
      return;
    }

    events.add(
      PostorderEvent(
        type: PostorderEventType.goLeft,
        index: index,
        value: values[index],
        message: 'Move to LEFT child of ${values[index]}.',
        codeLine: 6,
      ),
    );

    _generateRecursiveEvents(_leftChild(index));

    events.add(
      PostorderEvent(
        type: PostorderEventType.goRight,
        index: index,
        value: values[index],
        message: 'Move to RIGHT child of ${values[index]}.',
        codeLine: 7,
      ),
    );

    _generateRecursiveEvents(_rightChild(index));

    events.add(
      PostorderEvent(
        type: PostorderEventType.visit,
        index: index,
        value: values[index],
        message: 'Visit node ${values[index]}. Add it to result.',
        codeLine: 8,
      ),
    );

    events.add(
      PostorderEvent(
        type: PostorderEventType.backtrack,
        index: index,
        value: values[index],
        message: 'Backtrack from node ${values[index]}.',
        codeLine: 6,
      ),
    );
  }

  void _generateIterativeEvents() {
    if (values.isEmpty) return;

    final stack = <int>[0];

    events.add(
      const PostorderEvent(
        type: PostorderEventType.push,
        index: 0,
        message: 'Push root node onto stack.',
        codeLine: 7,
      ),
    );

    final tempResult = <int>[];

    while (stack.isNotEmpty) {
      final index = stack.removeLast();

      events.add(
        PostorderEvent(
          type: PostorderEventType.pop,
          index: index,
          value: values[index],
          message: 'Pop node ${values[index]} from stack.',
          codeLine: 10,
        ),
      );

      tempResult.add(values[index]);

      final left = _leftChild(index);
      final right = _rightChild(index);

      if (left < values.length) {
        stack.add(left);

        events.add(
          PostorderEvent(
            type: PostorderEventType.push,
            index: left,
            value: values[left],
            message: 'Push LEFT child ${values[left]} onto stack.',
            codeLine: 13,
          ),
        );
      }

      if (right < values.length) {
        stack.add(right);

        events.add(
          PostorderEvent(
            type: PostorderEventType.push,
            index: right,
            value: values[right],
            message: 'Push RIGHT child ${values[right]} onto stack.',
            codeLine: 17,
          ),
        );
      }
    }

    // The simple stack approach above produces Root-Right-Left.
    // Reverse it to obtain Left-Right-Root.
    for (int i = tempResult.length - 1; i >= 0; i--) {
      final value = tempResult[i];

      final index = values.indexOf(value);

      events.add(
        PostorderEvent(
          type: PostorderEventType.visit,
          index: index >= 0 ? index : null,
          value: value,
          message: 'Visit node $value in final Postorder result.',
          codeLine: 10,
        ),
      );
    }
  }

  // ==========================================================================
  // TREE INDEX
  // ==========================================================================

  int _leftChild(int index) {
    return (2 * index) + 1;
  }

  int _rightChild(int index) {
    return (2 * index) + 2;
  }

  // ==========================================================================
  // PLAY / PAUSE
  // ==========================================================================

  void _play() {
    if (events.isEmpty) {
      _generateEvents();
    }

    if (isCompleted) {
      _reset();
    }

    setState(() {
      isRunning = true;
      isPaused = false;
      status = 'Running';
    });

    _startTimer();
  }

  void _startTimer() {
    timer?.cancel();

    final milliseconds = (900 / speed).round();

    timer = Timer.periodic(Duration(milliseconds: milliseconds), (_) {
      if (!isRunning || isPaused) return;

      _nextStep();
    });
  }

  void _pause() {
    timer?.cancel();

    setState(() {
      isPaused = true;
      isRunning = false;
      status = 'Paused';
    });
  }

  void _togglePlayPause() {
    if (isRunning) {
      _pause();
    } else {
      _play();
    }
  }

  // ==========================================================================
  // NEXT
  // ==========================================================================

  void _nextStep() {
    if (events.isEmpty) return;

    if (currentStep >= events.length) {
      _finish();
      return;
    }

    final event = events[currentStep];

    setState(() {
      _applyEvent(event);
      currentStep++;

      if (event.type == PostorderEventType.complete) {
        _finish();
      }
    });
  }

  // ==========================================================================
  // PREVIOUS
  // ==========================================================================

  void _previousStep() {
    if (currentStep <= 0) return;

    timer?.cancel();

    setState(() {
      currentStep--;

      traversalResult.clear();
      currentNode = -1;
      visitedNode = -1;
      activeCodeLine = 0;
      executionLog.clear();
      status = 'Ready';

      for (int i = 0; i < currentStep; i++) {
        _applyEvent(events[i]);
      }

      if (currentStep == 0) {
        operation = 'Waiting to start';
        description =
            'Postorder Traversal visits nodes in Left → Right → Root order.';
      }

      isRunning = false;
      isPaused = false;
      isCompleted = false;
    });
  }

  // ==========================================================================
  // APPLY EVENT
  // ==========================================================================

  void _applyEvent(PostorderEvent event) {
    activeCodeLine = event.codeLine;

    if (event.index != null) {
      currentNode = event.index!;
    }

    operation = _eventTitle(event.type);
    description = event.message;

    executionLog.insert(0, event.message);

    if (executionLog.length > 8) {
      executionLog.removeLast();
    }

    switch (event.type) {
      case PostorderEventType.initialize:
        status = 'Initialized';
        break;

      case PostorderEventType.goLeft:
        status = 'Moving Left';
        break;

      case PostorderEventType.goRight:
        status = 'Moving Right';
        break;

      case PostorderEventType.visit:
        status = 'Visited';

        if (event.value != null) {
          if (!traversalResult.contains(event.value)) {
            traversalResult.add(event.value!);
          }

          visitedNode = event.index ?? -1;
        }
        break;

      case PostorderEventType.nullChild:
        status = 'Null Child';
        break;

      case PostorderEventType.backtrack:
        status = 'Backtracking';
        break;

      case PostorderEventType.push:
        status = 'Push';
        break;

      case PostorderEventType.pop:
        status = 'Pop';
        break;

      case PostorderEventType.complete:
        status = 'Completed';
        break;
    }
  }

  String _eventTitle(PostorderEventType type) {
    switch (type) {
      case PostorderEventType.initialize:
        return 'Initialize';

      case PostorderEventType.goLeft:
        return 'Go Left';

      case PostorderEventType.goRight:
        return 'Go Right';

      case PostorderEventType.visit:
        return 'Visit Node';

      case PostorderEventType.nullChild:
        return 'Null Child';

      case PostorderEventType.backtrack:
        return 'Backtrack';

      case PostorderEventType.push:
        return 'Push';

      case PostorderEventType.pop:
        return 'Pop';

      case PostorderEventType.complete:
        return 'Complete';
    }
  }

  // ==========================================================================
  // FINISH
  // ==========================================================================

  void _finish() {
    timer?.cancel();

    setState(() {
      isRunning = false;
      isPaused = false;
      isCompleted = true;
      status = 'Completed';
      operation = 'Traversal Complete';
      description = 'Postorder Traversal finished: Left → Right → Root.';
    });
  }

  // ==========================================================================
  // RESET
  // ==========================================================================

  void _reset() {
    timer?.cancel();

    setState(() {
      currentStep = 0;
      currentNode = -1;
      visitedNode = -1;
      activeCodeLine = 0;

      isRunning = false;
      isPaused = false;
      isCompleted = false;

      status = 'Ready';
      operation = 'Waiting to start';
      description =
          'Postorder Traversal visits nodes in Left → Right → Root order.';

      traversalResult.clear();
      executionLog.clear();
    });
  }

  // ==========================================================================
  // SPEED
  // ==========================================================================

  void _changeSpeed(double value) {
    setState(() {
      speed = value;
    });

    if (isRunning) {
      _startTimer();
    }
  }

  // ==========================================================================
  // METHOD
  // ==========================================================================

  void _changeMethod(PostorderMethod newMethod) {
    if (method == newMethod) return;

    timer?.cancel();

    setState(() {
      method = newMethod;

      currentStep = 0;
      currentNode = -1;
      visitedNode = -1;
      activeCodeLine = 0;

      isRunning = false;
      isPaused = false;
      isCompleted = false;

      traversalResult.clear();
      executionLog.clear();

      status = 'Ready';
      operation = 'Method changed';
      description = newMethod == PostorderMethod.recursive
          ? 'Recursive Postorder: Left → Right → Root.'
          : 'Iterative Postorder using an explicit stack.';
    });

    _generateEvents();
  }

  // ==========================================================================
  // RANDOMIZE
  // ==========================================================================

  void _randomize() {
    final random = math.Random();

    final generated = List.generate(7, (_) => 10 + random.nextInt(90));

    inputController.text = generated.join(', ');
    _loadInput();
  }

  // ==========================================================================
  // MESSAGE
  // ==========================================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: cardColor),
    );
  }

  // ==========================================================================
  // BUILD
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      backgroundColor: background,
      body: AlgorithmScreenShell(
        header: _buildHeader(width),
        algorithmInfo: _buildAlgorithmInfo(width),
        inputSection: _buildInputSection(width),
        additionalContent: _buildMethodSelector(width),
        visualization: _buildVisualizationPanel(width),
        controls: _buildControls(),
        sourceCode: _buildCodePanel(),
        executionSteps: _buildExecutionPanel(),
      ),
    );
  }

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _buildHeader(double width) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width < 600 ? 14 : 24,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: background2,
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: orange.withValues(alpha: 0.35)),
            ),
            child: const Icon(Icons.account_tree_rounded, color: orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Postorder Traversal',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Binary Tree • Left → Right → Root',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (width >= 600) _statusBadge(),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _statusColor().withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _statusColor().withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _statusColor(),
            ),
          ),
          const SizedBox(width: 7),
          Text(
            status,
            style: TextStyle(
              color: _statusColor(),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor() {
    if (isCompleted) return green;
    if (isRunning) return cyan;
    if (isPaused) return orange;
    return Colors.white70;
  }

  // ==========================================================================
  // ALGORITHM INFO
  // ==========================================================================

  Widget _buildAlgorithmInfo(double width) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: orange.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.info_outline_rounded,
                  color: orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Algorithm Information',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Postorder Traversal visits the left subtree first, '
            'then the right subtree, and finally the root node.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.70),
              height: 1.5,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoBox('Order', 'Left → Right → Root', orange),
              _infoBox('Time', 'O(n)', cyan),
              _infoBox('Space', 'O(h)', purple),
              _infoBox('Type', 'Tree / DFS', green),
              _infoBox('Difficulty', 'Easy', pink),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBox(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // INPUT
  // ==========================================================================

  Widget _buildInputSection(double width) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tree Input',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Enter values in level-order format.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.48),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          if (width < 700)
            Column(
              children: [
                _inputField(),
                const SizedBox(height: 10),
                _inputButtons(),
              ],
            )
          else
            Row(
              children: [
                Expanded(child: _inputField()),
                const SizedBox(width: 10),
                _inputButtons(),
              ],
            ),
        ],
      ),
    );
  }

  Widget _inputField() {
    return TextField(
      controller: inputController,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: 'Enter Number',
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.50)),
        hintText: '1, 2, 3, 4, 5, 6, 7',
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.25)),
        prefixIcon: const Icon(Icons.account_tree_rounded, color: orange),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.035),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: orange, width: 1.2),
        ),
      ),
      onSubmitted: (_) => _loadInput(),
    );
  }

  Widget _inputButtons() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _smallButton(
          icon: Icons.auto_awesome_rounded,
          label: 'Generate',
          color: purple,
          onTap: _randomize,
        ),
        _smallButton(
          icon: Icons.upload_rounded,
          label: 'Load Input',
          color: cyan,
          onTap: _loadInput,
        ),
      ],
    );
  }

  // ==========================================================================
  // METHOD SELECTOR
  // ==========================================================================

  Widget _buildMethodSelector(double width) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Traversal Method',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _methodButton(
                  title: 'Recursive',
                  subtitle: 'Uses call stack',
                  icon: Icons.replay_rounded,
                  color: purple,
                  selected: method == PostorderMethod.recursive,
                  onTap: () {
                    _changeMethod(PostorderMethod.recursive);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _methodButton(
                  title: 'Iterative',
                  subtitle: 'Uses explicit stack',
                  icon: Icons.layers_rounded,
                  color: cyan,
                  selected: method == PostorderMethod.iterative,
                  onTap: () {
                    _changeMethod(PostorderMethod.iterative);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.11)
              : Colors.white.withValues(alpha: 0.025),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? color.withValues(alpha: 0.45)
                : Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? color : Colors.white54, size: 21),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? color : Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.40),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(Icons.check_circle_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // WORKSPACE
  // ==========================================================================

<<<<<<< HEAD
  Widget _buildWorkspace(double width) {
    if (width < 950) {
      return Column(
        children: [
          _buildVisualizationPanel(width),
          const SizedBox(height: 16),
          _buildCodePanel(),
          const SizedBox(height: 16),
          _buildExecutionPanel(),
        ],
      );
    }

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: _buildVisualizationPanel(width)),
            const SizedBox(width: 16),
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  _buildCodePanel(),
                  const SizedBox(height: 16),
                  _buildExecutionPanel(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

=======
>>>>>>> origin/main
  // ==========================================================================
  // VISUALIZATION
  // ==========================================================================

  Widget _buildVisualizationPanel(double width) {
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.account_tree_rounded, color: orange, size: 20),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Tree Visualization',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _legendDot('Ready', Colors.white54),
                const SizedBox(width: 10),
                _legendDot('Current', cyan),
                const SizedBox(width: 10),
                _legendDot('Visited', green),
              ],
            ),
          ),
          Container(
            height: width < 600 ? 350 : 420,
            margin: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CustomPaint(
                painter: _TreePainter(
                  values: values,
                  currentNode: currentNode,
                  visitedNode: visitedNode,
                  traversalResult: traversalResult,
                  leftColor: blue,
                  rightColor: purple,
                  currentColor: cyan,
                  visitedColor: green,
                  defaultColor: Colors.white24,
                  textColor: Colors.white,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildResult(),
          const SizedBox(height: 14),
          _buildControls(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _legendDot(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        const SizedBox(width: 5),
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.42),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // RESULT
  // ==========================================================================

  Widget _buildResult() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: green.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: green.withValues(alpha: 0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.route_rounded, color: green, size: 17),
                const SizedBox(width: 7),
                const Text(
                  'Postorder Result',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (traversalResult.isEmpty)
                    Text(
                      'Waiting...',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 13,
                      ),
                    ),
                  for (int i = 0; i < traversalResult.length; i++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _resultChip(
                          traversalResult[i].toString(),
                          i == traversalResult.length - 1,
                        ),
                        if (i != traversalResult.length - 1)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              color: green,
                              size: 14,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultChip(String value, bool last) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: last
            ? green.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: last
              ? green.withValues(alpha: 0.40)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Text(
        value,
        style: TextStyle(
          color: last ? green : Colors.white70,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ==========================================================================
  // CONTROLS
  // ==========================================================================

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              _controlButton(
                icon: Icons.skip_previous_rounded,
                tooltip: 'Previous',
                onTap: _previousStep,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: _togglePlayPause,
                  borderRadius: BorderRadius.circular(11),
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: isRunning
                          ? orange.withValues(alpha: 0.12)
                          : cyan.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: isRunning
                            ? orange.withValues(alpha: 0.35)
                            : cyan.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Icon(
                      isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: isRunning ? orange : cyan,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _controlButton(
                icon: Icons.skip_next_rounded,
                tooltip: 'Next',
                onTap: _nextStep,
              ),
              const SizedBox(width: 8),
              _controlButton(
                icon: Icons.restart_alt_rounded,
                tooltip: 'Reset',
                onTap: _reset,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.speed_rounded, color: Colors.white54, size: 17),
              const SizedBox(width: 8),
              Text(
                'Speed',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.50),
                  fontSize: 11,
                ),
              ),
              Expanded(
                child: Slider(
                  value: speed,
                  min: 0.25,
                  max: 2.5,
                  divisions: 9,
                  activeColor: cyan,
                  inactiveColor: Colors.white12,
                  onChanged: _changeSpeed,
                ),
              ),
              Text(
                '${speed.toStringAsFixed(2)}x',
                style: const TextStyle(
                  color: cyan,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Step ${currentStep.clamp(0, events.length)} / ${events.length}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.35),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Icon(icon, color: Colors.white70, size: 20),
        ),
      ),
    );
  }

  // ==========================================================================
  // CODE PANEL
  // ==========================================================================

  Widget _buildCodePanel() {
    return _card(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.code_rounded, color: cyan, size: 20),
                const SizedBox(width: 9),
                const Expanded(
                  child: Text(
                    'Source Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: code));

                    if (!mounted) return;

                    _showMessage('Code copied to clipboard.');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: cyan.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: cyan.withValues(alpha: 0.20)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.copy_rounded, color: cyan, size: 14),
                        SizedBox(width: 5),
                        Text(
                          'Copy',
                          style: TextStyle(
                            color: cyan,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 390,
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(child: _buildCodeText()),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeText() {
    final lines = code.split('\n');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < lines.length; i++)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 5),
            decoration: activeCodeLine == i + 1
                ? BoxDecoration(
                    color: cyan.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 25,
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.20),
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    lines[i],
                    style: TextStyle(
                      color: activeCodeLine == i + 1
                          ? cyan
                          : Colors.white.withValues(alpha: 0.72),
                      fontSize: 12,
                      height: 1.5,
                      fontFamily: 'monospace',
                      fontWeight: activeCodeLine == i + 1
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ==========================================================================
  // EXECUTION PANEL
  // ==========================================================================

  Widget _buildExecutionPanel() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: orange.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  color: orange,
                  size: 18,
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Execution Process',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                operation,
                style: TextStyle(
                  color: _statusColor(),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _statusColor().withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _statusColor().withValues(alpha: 0.16)),
            ),
            child: Text(
              description,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.68),
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (executionLog.isEmpty)
            Text(
              'Execution steps will appear here...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.30),
                fontSize: 12,
              ),
            )
          else
            Column(
              children: [
                for (int i = 0; i < executionLog.length; i++)
                  _logItem(executionLog[i], i),
              ],
            ),
        ],
      ),
    );
  }

  Widget _logItem(String text, int index) {
    final isLatest = index == 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: isLatest
            ? cyan.withValues(alpha: 0.055)
            : Colors.white.withValues(alpha: 0.018),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: isLatest
              ? cyan.withValues(alpha: 0.16)
              : Colors.white.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isLatest
                  ? cyan.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: isLatest ? cyan : Colors.white38,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isLatest ? Colors.white : Colors.white54,
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // COMMON CARD
  // ==========================================================================

  Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _smallButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
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

class _TreePainter extends CustomPainter {
  final List<int> values;
  final int currentNode;
  final int visitedNode;
  final List<int> traversalResult;

  final Color leftColor;
  final Color rightColor;
  final Color currentColor;
  final Color visitedColor;
  final Color defaultColor;
  final Color textColor;

  _TreePainter({
    required this.values,
    required this.currentNode,
    required this.visitedNode,
    required this.traversalResult,
    required this.leftColor,
    required this.rightColor,
    required this.currentColor,
    required this.visitedColor,
    required this.defaultColor,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final positions = <int, Offset>{};

    _calculatePositions(0, 0, size.width / 2, 45, size.width * 0.22, positions);

    final edgePaint = Paint()
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw edges first.
    for (int i = 0; i < values.length; i++) {
      final parent = positions[i];

      if (parent == null) continue;

      final left = 2 * i + 1;
      final right = 2 * i + 2;

      if (left < values.length && positions[left] != null) {
        edgePaint.color = leftColor.withValues(alpha: 0.35);

        canvas.drawLine(parent, positions[left]!, edgePaint);
      }

      if (right < values.length && positions[right] != null) {
        edgePaint.color = rightColor.withValues(alpha: 0.35);

        canvas.drawLine(parent, positions[right]!, edgePaint);
      }
    }

    // Draw nodes.
    for (int i = 0; i < values.length; i++) {
      final position = positions[i];

      if (position == null) continue;

      Color nodeColor = defaultColor;

      if (traversalResult.contains(values[i])) {
        nodeColor = visitedColor;
      }

      if (i == currentNode) {
        nodeColor = currentColor;
      }

      if (i == visitedNode) {
        nodeColor = visitedColor;
      }

      final glowPaint = Paint()
        ..color = nodeColor.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawCircle(position, 25, glowPaint);

      final fillPaint = Paint()
        ..color = const Color(0xFF0F1B31)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(position, 22, fillPaint);

      final borderPaint = Paint()
        ..color = nodeColor
        ..strokeWidth = i == currentNode ? 3 : 1.8
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(position, 22, borderPaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${values[i]}',
          style: TextStyle(
            color: i == currentNode || traversalResult.contains(values[i])
                ? nodeColor
                : textColor,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          position.dx - textPainter.width / 2,
          position.dy - textPainter.height / 2,
        ),
      );

      final indexPainter = TextPainter(
        text: TextSpan(
          text: '[$i]',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.28),
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      indexPainter.layout();

      indexPainter.paint(
        canvas,
        Offset(position.dx - indexPainter.width / 2, position.dy + 28),
      );
    }
  }

  void _calculatePositions(
    int index,
    int depth,
    double x,
    double y,
    double horizontalGap,
    Map<int, Offset> positions,
  ) {
    if (index >= values.length) return;

    positions[index] = Offset(x, y);

    final left = 2 * index + 1;
    final right = 2 * index + 2;

    final nextGap = math.max(horizontalGap * 0.52, 35.0);

    if (left < values.length) {
      _calculatePositions(
        left,
        depth + 1,
        x - horizontalGap,
        y + 82,
        nextGap,
        positions,
      );
    }

    if (right < values.length) {
      _calculatePositions(
        right,
        depth + 1,
        x + horizontalGap,
        y + 82,
        nextGap,
        positions,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TreePainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.currentNode != currentNode ||
        oldDelegate.visitedNode != visitedNode ||
        oldDelegate.traversalResult != traversalResult;
  }
}
