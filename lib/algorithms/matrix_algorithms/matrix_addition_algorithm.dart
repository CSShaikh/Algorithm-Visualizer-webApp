import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MatrixAdditionAlgorithmScreen extends StatefulWidget {
  const MatrixAdditionAlgorithmScreen({super.key});

  @override
  State<MatrixAdditionAlgorithmScreen> createState() =>
      _MatrixAdditionAlgorithmScreenState();
}

// ============================================================================
// EVENT TYPES
// ============================================================================

enum MatrixAdditionEventType { initialize, calculate, add, complete }

// ============================================================================
// EVENT MODEL
// ============================================================================

class MatrixAdditionEvent {
  final MatrixAdditionEventType type;
  final List<int> array;
  final int index;
  final int secondIndex;
  final int firstValue;
  final int secondValue;
  final int sortedCount;
  final int row;
  final int column;
  final List<List<int>> matrixA;
  final List<List<int>> matrixB;
  final List<List<int>> result;
  final String title;
  final String description;
  final String operation;

  const MatrixAdditionEvent({
    required this.type,
    required this.array,
    required this.index,
    required this.secondIndex,
    required this.firstValue,
    required this.secondValue,
    required this.sortedCount,
    required this.row,
    required this.column,
    required this.matrixA,
    required this.matrixB,
    required this.result,
    required this.title,
    required this.description,
    required this.operation,
  });
}

// ============================================================================
// STATE

// ============================================================================

class _MatrixAdditionAlgorithmScreenState
    extends State<MatrixAdditionAlgorithmScreen> {
  // ==========================================================================
  // COLORS
  // ==========================================================================

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

  // ============================================================================
  // DATA
  // ============================================================================

  List<List<int>> matrixA = [
    [1, 2],
    [3, 4],
  ];

  List<List<int>> matrixB = [
    [5, 6],
    [7, 8],
  ];

  List<List<int>> resultMatrix = [
    [0, 0],
    [0, 0],
  ];

  List<List<int>> originalA = [
    [1, 2],
    [3, 4],
  ];

  List<List<int>> originalB = [
    [5, 6],
    [7, 8],
  ];

  final TextEditingController arrayController = TextEditingController(
    text: '1, 2; 3, 4 | 5, 6; 7, 8',
  );

  List<MatrixAdditionEvent> events = [];
  List<MatrixAdditionEvent> executionHistory = [];

  int currentStep = 0;
  bool isRunning = false;
  bool isCompleted = false;
  double speed = 1.0;
  Timer? timer;

  int currentRow = -1;
  int currentColumn = -1;
  int activeCell = -1;
  int sortedCount = 0;
  Set<int> sortedIndexes = {};
  int activeCodeLine = 0;
  int matrixResultValue = 0;
  String executionMessage = 'Ready to start the Matrix Addition Algorithm.';

  final String sourceCode = '''
List<List<int>> addMatrices(
  List<List<int>> a,
  List<List<int>> b,
) {
  final result = List.generate(
    a.length,
    (_) => List.filled(b[0].length, 0),
  );

  for (int i = 0; i < a.length; i++) {
    for (int j = 0; j < a[0].length; j++) {
      result[i][j] = a[i][j] + b[i][j];
    }
  }

  return result;
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
    arrayController.dispose();
    super.dispose();
  }

  List<int> _flatten(List<List<int>> matrix) =>
      matrix.expand((row) => row).toList();

  List<List<int>> _copyMatrix(List<List<int>> matrix) =>
      matrix.map((row) => [...row]).toList();

  void _generateEvents() {
    final generated = <MatrixAdditionEvent>[];
    resultMatrix = List.generate(2, (_) => List.filled(2, 0));

    generated.add(
      MatrixAdditionEvent(
        type: MatrixAdditionEventType.initialize,
        array: _flatten(resultMatrix),
        index: -1,
        secondIndex: -1,
        firstValue: 0,
        secondValue: 0,
        sortedCount: 0,
        row: -1,
        column: -1,
        matrixA: _copyMatrix(matrixA),
        matrixB: _copyMatrix(matrixB),
        result: _copyMatrix(resultMatrix),
        title: 'Matrix Addition Initialized',
        description:
            'Start with two 2 × 2 matrices and an empty result matrix.',
        operation: 'C = A + B',
      ),
    );

    int step = 0;
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 2; j++) {
        final a = matrixA[i][j];
        final b = matrixB[i][j];
        step++;
        generated.add(
          MatrixAdditionEvent(
            type: MatrixAdditionEventType.calculate,
            array: _flatten(resultMatrix),
            index: i * 2 + j,
            secondIndex: -1,
            firstValue: a,
            secondValue: b,
            sortedCount: step - 1,
            row: i,
            column: j,
            matrixA: _copyMatrix(matrixA),
            matrixB: _copyMatrix(matrixB),
            result: _copyMatrix(resultMatrix),
            title: 'Select Matrix Elements',
            description:
                'Select A[$i][$j] = $a and B[$i][$j] = $b for addition.',
            operation: 'C[$i][$j] = $a + $b',
          ),
        );

        resultMatrix[i][j] = a + b;
        generated.add(
          MatrixAdditionEvent(
            type: MatrixAdditionEventType.add,
            array: _flatten(resultMatrix),
            index: i * 2 + j,
            secondIndex: -1,
            firstValue: a,
            secondValue: b,
            sortedCount: step,
            row: i,
            column: j,
            matrixA: _copyMatrix(matrixA),
            matrixB: _copyMatrix(matrixB),
            result: _copyMatrix(resultMatrix),
            title: 'Add Matrix Elements',
            description:
                '$a + $b = ${resultMatrix[i][j]}. Store the sum in C[$i][$j].',
            operation: 'C[$i][$j] = ${resultMatrix[i][j]}',
          ),
        );
      }
    }

    generated.add(
      MatrixAdditionEvent(
        type: MatrixAdditionEventType.complete,
        array: _flatten(resultMatrix),
        index: -1,
        secondIndex: -1,
        firstValue: 0,
        secondValue: 0,
        sortedCount: 4,
        row: -1,
        column: -1,
        matrixA: _copyMatrix(matrixA),
        matrixB: _copyMatrix(matrixB),
        result: _copyMatrix(resultMatrix),
        title: 'Matrix Addition Complete',
        description:
            'Every corresponding pair has been added to form the result matrix.',
        operation: 'C = A + B',
      ),
    );
    events = generated;
    resultMatrix = List.generate(2, (_) => List.filled(2, 0));
  }

  void _applyEvent(MatrixAdditionEvent event, {bool updateState = true}) {
    matrixA = _copyMatrix(event.matrixA);
    matrixB = _copyMatrix(event.matrixB);
    resultMatrix = _copyMatrix(event.result);
    currentRow = event.row;
    currentColumn = event.column;
    activeCell = event.index;
    sortedCount = event.sortedCount;
    executionMessage = '${event.title}: ${event.description}';
    activeCodeLine = _codeLineForEvent(event.type);

    if (event.type == MatrixAdditionEventType.add) {
      sortedIndexes = Set<int>.from(List.generate(event.sortedCount, (i) => i));
      matrixResultValue = event.result[event.row][event.column];
    }
    if (event.type == MatrixAdditionEventType.complete) {
      sortedIndexes = {0, 1, 2, 3};
      activeCell = -1;
      currentRow = -1;
      currentColumn = -1;
      executionMessage = 'Matrix Addition Complete: C = A + B';
    }
    if (updateState) setState(() {});
  }

  void _rebuildVisualState() {
    resultMatrix = List.generate(2, (_) => List.filled(2, 0));
    currentRow = -1;
    currentColumn = -1;
    activeCell = -1;
    sortedCount = 0;
    sortedIndexes.clear();
    activeCodeLine = 0;
    matrixResultValue = 0;
    executionMessage = 'Ready to start the Matrix Addition Algorithm.';
    matrixA = _copyMatrix(originalA);
    matrixB = _copyMatrix(originalB);
    for (final event in executionHistory) {
      _applyEvent(event, updateState: false);
    }
  }

  void _reset() {
    timer?.cancel();
    setState(() {
      matrixA = _copyMatrix(originalA);
      matrixB = _copyMatrix(originalB);
      resultMatrix = List.generate(2, (_) => List.filled(2, 0));
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      currentRow = -1;
      currentColumn = -1;
      activeCell = -1;
      sortedCount = 0;
      sortedIndexes.clear();
      activeCodeLine = 0;
      matrixResultValue = 0;
      executionMessage = 'Ready to start the Matrix Addition Algorithm.';
    });
    _generateEvents();
  }

  void _setSpeed(double value) {
    setState(() => speed = value);
    if (isRunning) _play();
  }

  int _codeLineForEvent(MatrixAdditionEventType type) {
    switch (type) {
      case MatrixAdditionEventType.initialize:
        return 1;
      case MatrixAdditionEventType.calculate:
        return 7;
      case MatrixAdditionEventType.add:
        return 8;
      case MatrixAdditionEventType.complete:
        return 12;
    }
  }

  Color _eventColor(MatrixAdditionEventType type) {
    switch (type) {
      case MatrixAdditionEventType.initialize:
        return blue;
      case MatrixAdditionEventType.calculate:
        return cyan;
      case MatrixAdditionEventType.add:
        return orange;
      case MatrixAdditionEventType.complete:
        return green;
    }
  }

  IconData _eventIcon(MatrixAdditionEventType type) {
    switch (type) {
      case MatrixAdditionEventType.initialize:
        return Icons.play_arrow_rounded;
      case MatrixAdditionEventType.calculate:
        return Icons.grid_view_rounded;
      case MatrixAdditionEventType.add:
        return Icons.add_circle_outline_rounded;
      case MatrixAdditionEventType.complete:
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
        backgroundColor: color.withValues(alpha: 0.85),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<List<int>>? _parseMatrix(String value) {
    final rows = value
        .split(';')
        .map((row) => row.trim())
        .where((row) => row.isNotEmpty)
        .toList();
    if (rows.length != 2) return null;
    final matrix = <List<int>>[];
    for (final row in rows) {
      final values = row
          .split(RegExp(r'[,\s]+'))
          .where((v) => v.isNotEmpty)
          .map(int.tryParse)
          .toList();
      if (values.length != 2 || values.any((v) => v == null)) return null;
      matrix.add(values.cast<int>());
    }
    return matrix;
  }

  void _loadArray() {
    final parts = arrayController.text.split('|');
    if (parts.length != 2) {
      _showSnackBar('Enter two 2 × 2 matrices separated by |.', red);
      return;
    }
    final a = _parseMatrix(parts[0]);
    final b = _parseMatrix(parts[1]);
    if (a == null || b == null) {
      _showSnackBar('Use format: 1,2;3,4 | 5,6;7,8', red);
      return;
    }
    timer?.cancel();
    setState(() {
      matrixA = _copyMatrix(a);
      matrixB = _copyMatrix(b);
      originalA = _copyMatrix(a);
      originalB = _copyMatrix(b);
      resultMatrix = List.generate(2, (_) => List.filled(2, 0));
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      currentRow = -1;
      currentColumn = -1;
      activeCell = -1;
      sortedCount = 0;
      sortedIndexes.clear();
      activeCodeLine = 0;
      matrixResultValue = 0;
      executionMessage = 'Matrices loaded. Ready to add them.';
    });
    _generateEvents();
    _showSnackBar('Matrices loaded successfully.', green);
  }

  void _generateNumbers() {
    final random = Random();
    List<List<int>> randomMatrix() =>
        List.generate(2, (_) => List.generate(2, (_) => random.nextInt(9) + 1));
    final a = randomMatrix();
    final b = randomMatrix();
    arrayController.text =
        '${a[0].join(',')};${a[1].join(',')} | ${b[0].join(',')};${b[1].join(',')}';
    timer?.cancel();
    setState(() {
      matrixA = _copyMatrix(a);
      matrixB = _copyMatrix(b);
      originalA = _copyMatrix(a);
      originalB = _copyMatrix(b);
      resultMatrix = List.generate(2, (_) => List.filled(2, 0));
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      currentRow = -1;
      currentColumn = -1;
      activeCell = -1;
      sortedCount = 0;
      sortedIndexes.clear();
      activeCodeLine = 0;
      matrixResultValue = 0;
      executionMessage = 'New matrices generated. Ready to add them.';
    });
    _generateEvents();
    _showSnackBar('New matrices generated.', purple);
  }

  // ==========================================================================
  // PLAY
  // ==========================================================================

  void _play() {
    if (events.isEmpty || isCompleted) {
      return;
    }

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

  // ==========================================================================
  // PAUSE
  // ==========================================================================

  void _pause() {
    timer?.cancel();

    if (!mounted) return;

    setState(() {
      isRunning = false;
    });
  }

  // ==========================================================================
  // TOGGLE
  // ==========================================================================

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
    if (currentStep >= events.length) {
      return;
    }

    _nextStepInternal();
  }

  void _nextStepInternal() {
    if (currentStep >= events.length) {
      return;
    }

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

  // ==========================================================================
  // PREVIOUS
  // ==========================================================================

  void _previousStep() {
    if (executionHistory.isEmpty) {
      return;
    }

    timer?.cancel();

    executionHistory.removeLast();

    currentStep = executionHistory.length;

    _rebuildVisualState();

    setState(() {
      isRunning = false;
      isCompleted = false;
    });
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

  // ==========================================================================
  // HEADER
  // ==========================================================================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cyan.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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
              Icons.calculate_rounded,
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
                  'Matrix Addition Algorithm',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Add corresponding elements of two matrices step by step',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
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

  // ==========================================================================
  // STATUS
  // ==========================================================================

  Widget _statusBadge() {
    Color color = cyan;

    String text = 'READY';

    if (isRunning) {
      color = orange;
      text = 'RUNNING';
    } else if (isCompleted) {
      color = green;
      text = 'Matrix Addition READY';
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

  // ==========================================================================
  // ALGORITHM INFO
  // ==========================================================================

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
            'The Matrix Addition Algorithm adds corresponding elements of two matrices to produce a result matrix.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.64),
              height: 1.5,
              fontSize: 12.5,
            ),
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _infoBox('Time', 'O(n × m)', orange),
              _infoBox('Space', 'O(n × m)', blue),
              _infoBox('Type', 'Mathematical', purple),
              _infoBox('Method', 'Element-wise Addition', green),
              _infoBox('Matrices', '2 × 2', red),
              _infoBox('Result', 'C = A + B', cyan),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // INPUT
  // ==========================================================================

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
                  'Enter two 2 × 2 matrices: A | B, using ; between rows.',
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

  // ==========================================================================
  // INPUT FIELD
  // ==========================================================================

  Widget _inputField() {
    return TextField(
      controller: arrayController,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      cursorColor: cyan,
      decoration: InputDecoration(
        labelText: 'Enter Matrices',
        hintText: '1,2;3,4 | 5,6;7,8',
        labelStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.58),
          fontSize: 12,
        ),
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.25),
          fontSize: 12,
        ),
        prefixIcon: Icon(
          Icons.grid_view_rounded,
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

  // ==========================================================================
  // GENERATE
  // ==========================================================================

  Widget _generateButton() {
    return ElevatedButton.icon(
      onPressed: _generateNumbers,
      icon: const Icon(Icons.auto_awesome_rounded, size: 17),
      label: const Text(
        'Generate Numbers',
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

  // ==========================================================================
  // LOAD
  // ==========================================================================

  Widget _loadButton() {
    return ElevatedButton.icon(
      onPressed: _loadArray,
      icon: const Icon(Icons.download_rounded, size: 17),
      label: const Text(
        'LOAD ARRAY',
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

  // ==========================================================================
  // WORKSPACE
  // ==========================================================================

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

  // ==========================================================================
  // VISUALIZATION
  // ==========================================================================

  Widget _buildVisualization() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.grid_view_rounded, 'Matrix Visualization', cyan),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _matrixPanel('Matrix A', matrixA, blue),
                _operator('+', orange),
                _matrixPanel('Matrix B', matrixB, purple),
                _operator('=', green),
                _matrixPanel('Result C', resultMatrix, green, result: true),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
          const SizedBox(height: 12),
          _buildCurrentInfo(),
          const SizedBox(height: 12),
          _buildStatusCard(),
        ],
      ),
    );
  }

  Widget _operator(String text, Color color) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w800),
    ),
  );

  Widget _matrixPanel(
    String title,
    List<List<int>> matrix,
    Color color, {
    bool result = false,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: visualizationColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: .25)),
          ),
          child: Column(
            children: List.generate(
              2,
              (r) => Row(
                children: List.generate(2, (c) {
                  final idx = r * 2 + c;
                  final active = result && idx == activeCell;
                  final done = result && sortedIndexes.contains(idx);
                  return Container(
                    width: 64,
                    height: 64,
                    margin: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: active
                          ? cyan.withValues(alpha: .18)
                          : done
                          ? green.withValues(alpha: .10)
                          : cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: active
                            ? cyan
                            : done
                            ? green.withValues(alpha: .45)
                            : Colors.white.withValues(alpha: .08),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${matrix[r][c]}',
                        style: TextStyle(
                          color: active ? cyan : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _legendItem('Current Cell', cyan),
        _legendItem('Completed Cell', green),
        _legendItem('Matrix A', blue),
        _legendItem('Matrix B', purple),
      ],
    );
  }

  Widget _buildCurrentInfo() {
    final message = currentRow >= 0 && currentColumn >= 0
        ? 'C[$currentRow][$currentColumn] = ${matrixA[currentRow][currentColumn]} + ${matrixB[currentRow][currentColumn]}'
        : isCompleted
        ? 'All corresponding matrix elements have been added.'
        : 'Select a matrix cell to begin.';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: visualizationColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cyan.withValues(alpha: .12)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: cyan, size: 17),
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

  // ==========================================================================
  // CONTROLS
  // ==========================================================================

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
  // LEGEND ITEM
  // ==========================================================================

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

  Widget _executionStepItem(int index, MatrixAdditionEvent event) {
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

  // ==========================================================================
  // SECTION TITLE
  // ==========================================================================

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

  // ==========================================================================
  // INFO BOX
  // ==========================================================================

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

  // ==========================================================================
  // MINI BADGE
  // ==========================================================================
}
