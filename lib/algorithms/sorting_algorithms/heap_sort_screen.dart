import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HeapSortScreen extends StatefulWidget {
  const HeapSortScreen({super.key});

  @override
  State<HeapSortScreen> createState() => _HeapSortScreenState();
}

// ================================================================
// HEAP SORT EVENT TYPES
// ================================================================

enum HeapSortEventType {
  buildHeap,
  heapify,
  compare,
  swap,
  extract,
  sorted,
  complete,
}

// ================================================================
// HEAP SORT EVENT
// ================================================================

class HeapSortEvent {
  final HeapSortEventType type;
  final List<int> array;

  final int activeIndex;
  final int compareIndex;
  final int swapIndex;
  final int heapSize;

  final String title;
  final String description;
  final String operation;

  const HeapSortEvent({
    required this.type,
    required this.array,
    this.activeIndex = -1,
    this.compareIndex = -1,
    this.swapIndex = -1,
    this.heapSize = 0,
    required this.title,
    required this.description,
    required this.operation,
  });
}

// ================================================================
// STATE
// ================================================================

class _HeapSortScreenState extends State<HeapSortScreen> {
  // ==============================================================
  // COLORS
  // ==============================================================

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

  // ==============================================================
  // ARRAY
  // ==============================================================

  List<int> array = [64, 25, 12, 22, 11, 90, 34];

  // Original array
  List<int> originalArray = [64, 25, 12, 22, 11, 90, 34];

  // ==============================================================
  // CONTROLLERS
  // ==============================================================

  late final TextEditingController arrayController;

  // ==============================================================
  // EVENTS
  // ==============================================================

  List<HeapSortEvent> events = [];
  List<HeapSortEvent> executionHistory = [];

  int currentStep = 0;

  // ==============================================================
  // EXECUTION STATE
  // ==============================================================

  bool isRunning = false;
  bool isCompleted = false;

  double speed = 1.0;

  Timer? timer;

  // ==============================================================
  // VISUALIZATION STATE
  // ==============================================================

  int activeIndex = -1;
  int compareIndex = -1;
  int swapIndex = -1;

  int heapSize = 0;

  Set<int> sortedIndices = {};

  String executionMessage = 'Ready to start Heap Sort';

  int activeCodeLine = 0;

  // ==============================================================
  // SOURCE CODE
  // ==============================================================

  static const String sourceCode = '''
void heapSort(int[] arr) {
  int n = arr.length;

  // Build max heap
  for (int i = n / 2 - 1; i >= 0; i--) {
    heapify(arr, n, i);
  }

  // Extract elements
  for (int i = n - 1; i > 0; i--) {
    swap(arr, 0, i);
    heapify(arr, i, 0);
  }
}

void heapify(int[] arr, int n, int i) {
  int largest = i;
  int left = 2 * i + 1;
  int right = 2 * i + 2;

  if (left < n && arr[left] > arr[largest]) {
    largest = left;
  }

  if (right < n && arr[right] > arr[largest]) {
    largest = right;
  }

  if (largest != i) {
    swap(arr, i, largest);
    heapify(arr, n, largest);
  }
}''';

  late final List<String> sourceLines;

  // ==============================================================
  // INIT
  // ==============================================================

  @override
  void initState() {
    super.initState();

    arrayController = TextEditingController(
      text: array.join(', '),
    );

    sourceLines = sourceCode.split('\n');

    _generateEvents();
  }

  // ==============================================================
  // DISPOSE
  // ==============================================================

  @override
  void dispose() {
    timer?.cancel();
    arrayController.dispose();
    super.dispose();
  }

  // ==============================================================
  // GENERATE EVENTS
  // ==============================================================

  void _generateEvents() {
    events.clear();

    final working = List<int>.from(array);

    final n = working.length;

    // --------------------------------------------------------------
    // BUILD MAX HEAP
    // --------------------------------------------------------------

    events.add(
      HeapSortEvent(
        type: HeapSortEventType.buildHeap,
        array: List<int>.from(working),
        heapSize: n,
        title: 'Build Max Heap',
        description:
            'Start building a Max Heap from the input array.',
        operation: 'BUILD HEAP',
      ),
    );

    for (int i = (n ~/ 2) - 1; i >= 0; i--) {
      _recordHeapifyEvents(
        working,
        n,
        i,
      );
    }

    // --------------------------------------------------------------
    // EXTRACT MAX ELEMENTS
    // --------------------------------------------------------------

    for (int i = n - 1; i > 0; i--) {
      events.add(
        HeapSortEvent(
          type: HeapSortEventType.extract,
          array: List<int>.from(working),
          activeIndex: 0,
          swapIndex: i,
          heapSize: i + 1,
          title: 'Extract Maximum',
          description:
              'The root contains the largest element. Move it to position $i.',
          operation: 'EXTRACT MAX',
        ),
      );

      // Swap root with last heap element.
      final temp = working[0];
      working[0] = working[i];
      working[i] = temp;

      events.add(
        HeapSortEvent(
          type: HeapSortEventType.swap,
          array: List<int>.from(working),
          activeIndex: 0,
          swapIndex: i,
          heapSize: i,
          title: 'Swap Root',
          description:
              'Swap the maximum element at the root with index $i.',
          operation: 'SWAP',
        ),
      );

      _recordHeapifyEvents(
        working,
        i,
        0,
      );
    }

    // --------------------------------------------------------------
    // COMPLETE
    // --------------------------------------------------------------

    events.add(
      HeapSortEvent(
        type: HeapSortEventType.complete,
        array: List<int>.from(working),
        heapSize: 1,
        title: 'Sorting Complete',
        description:
            'All elements have been extracted from the heap.',
        operation: 'COMPLETE',
      ),
    );
  }

  // ==============================================================
  // RECORD HEAPIFY EVENTS
  // ==============================================================

  void _recordHeapifyEvents(
    List<int> working,
    int size,
    int root,
  ) {
    if (size <= 0 || root >= size) {
      return;
    }

    int largest = root;

    final left = 2 * root + 1;
    final right = 2 * root + 2;

    events.add(
      HeapSortEvent(
        type: HeapSortEventType.heapify,
        array: List<int>.from(working),
        activeIndex: root,
        heapSize: size,
        title: 'Heapify',
        description:
            'Heapify subtree rooted at index $root.',
        operation: 'HEAPIFY',
      ),
    );

    // --------------------------------------------------------------
    // LEFT COMPARISON
    // --------------------------------------------------------------

    if (left < size) {
      events.add(
        HeapSortEvent(
          type: HeapSortEventType.compare,
          array: List<int>.from(working),
          activeIndex: root,
          compareIndex: left,
          heapSize: size,
          title: 'Compare Left Child',
          description:
              'Compare parent ${working[root]} with left child ${working[left]}.',
          operation: 'COMPARE',
        ),
      );

      if (working[left] > working[largest]) {
        largest = left;
      }
    }

    // --------------------------------------------------------------
    // RIGHT COMPARISON
    // --------------------------------------------------------------

    if (right < size) {
      events.add(
        HeapSortEvent(
          type: HeapSortEventType.compare,
          array: List<int>.from(working),
          activeIndex: largest,
          compareIndex: right,
          heapSize: size,
          title: 'Compare Right Child',
          description:
              'Compare current largest ${working[largest]} with right child ${working[right]}.',
          operation: 'COMPARE',
        ),
      );

      if (working[right] > working[largest]) {
        largest = right;
      }
    }

    // --------------------------------------------------------------
    // SWAP
    // --------------------------------------------------------------

    if (largest != root) {
      events.add(
        HeapSortEvent(
          type: HeapSortEventType.swap,
          array: List<int>.from(working),
          activeIndex: root,
          swapIndex: largest,
          heapSize: size,
          title: 'Swap Heap Nodes',
          description:
              'Move the larger child to the parent position.',
          operation: 'SWAP',
        ),
      );

      final temp = working[root];
      working[root] = working[largest];
      working[largest] = temp;

      _recordHeapifyEvents(
        working,
        size,
        largest,
      );
    }
  }

  // ==============================================================
  // HEADER
  // ==============================================================

  Widget _buildHeader() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: background2,
        border: Border(
          bottom: BorderSide(
            color: cyan.withOpacity(0.10),
          ),
        ),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  purple,
                  blue,
                ],
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.account_tree_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Heap Sort',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Sorting Algorithm Visualizer',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: green.withOpacity(0.20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                const Text(
                  'HEAP',
                  style: TextStyle(
                    color: green,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // ALGORITHM INFORMATION
  // ==============================================================

  Widget _buildAlgorithmInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.info_outline_rounded,
            'Algorithm Information',
            cyan,
          ),
          const SizedBox(height: 14),
          const Text(
            'Heap Sort builds a Max Heap and repeatedly extracts '
            'the largest element to produce a sorted array.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              int count = 2;

              if (width >= 1000) {
                count = 6;
              } else if (width >= 650) {
                count = 3;
              }

              final itemWidth =
                  (width - ((count - 1) * 10)) / count;

              return Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _infoBox(
                    'TIME',
                    'O(n log n)',
                    cyan,
                    itemWidth,
                  ),
                  _infoBox(
                    'SPACE',
                    'O(1)',
                    blue,
                    itemWidth,
                  ),
                  _infoBox(
                    'TYPE',
                    'Sorting',
                    purple,
                    itemWidth,
                  ),
                  _infoBox(
                    'BEST',
                    'O(n log n)',
                    green,
                    itemWidth,
                  ),
                  _infoBox(
                    'WORST',
                    'O(n log n)',
                    orange,
                    itemWidth,
                  ),
                  _infoBox(
                    'STABLE',
                    'No',
                    pink,
                    itemWidth,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _infoBox(
    String title,
    String value,
    Color color,
    double width,
  ) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // INPUT SECTION
  // ==============================================================

  Widget _buildInputSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 700;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _generateButton(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _loadButton(),
                    ),
                  ],
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _buildInputField(),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 160,
                child: _generateButton(),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 140,
                child: _loadButton(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInputField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Enter Numbers',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: arrayController,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
          ),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '64, 25, 12, 22, 11',
            hintStyle: const TextStyle(
              color: Colors.white30,
              fontSize: 12,
            ),
            prefixIcon: const Icon(
              Icons.format_list_numbered_rounded,
              color: cyan,
              size: 19,
            ),
            filled: true,
            fillColor: visualizationColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.06),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: cyan,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _generateButton() {
    return SizedBox(
      height: 45,
      child: OutlinedButton.icon(
        onPressed: isRunning ? null : _generateNumbers,
        icon: const Icon(
          Icons.auto_awesome_rounded,
          size: 17,
        ),
        label: const Text(
          'GENERATE NUMBERS',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: .4,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: cyan,
          side: BorderSide(
            color: cyan.withOpacity(0.30),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: cyan.withOpacity(0.04),
        ),
      ),
    );
  }

  Widget _loadButton() {
    return SizedBox(
      height: 45,
      child: ElevatedButton.icon(
        onPressed: isRunning ? null : _loadArray,
        icon: const Icon(
          Icons.download_rounded,
          size: 17,
        ),
        label: const Text(
          'LOAD ARRAY',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: .4,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: blue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // MAIN WORKSPACE
  // ==============================================================

  Widget _buildMainWorkspace(double width) {
    final bool mobile = width < 900;

    if (mobile) {
      return Column(
        children: [
          _buildVisualizationPanel(),
          const SizedBox(height: 16),
          _buildSourceAndStepsPanel(),
          const SizedBox(height: 16),
          _buildControls(),
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
              _buildVisualizationPanel(),
              const SizedBox(height: 16),
              _buildControls(),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: _buildSourceAndStepsPanel(),
        ),
      ],
    );
  }

  // ==============================================================
  // VISUALIZATION PANEL
  // ==============================================================

  Widget _buildVisualizationPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: visualizationColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.account_tree_rounded,
            'Heap Visualization',
            purple,
          ),
          const SizedBox(height: 12),
          _buildLegend(),
          const SizedBox(height: 18),
          _buildHeapVisualization(),
          const SizedBox(height: 18),
          _buildOperationCard(),
        ],
      ),
    );
  }

  // ==============================================================
  // LEGEND
  // ==============================================================

  Widget _buildLegend() {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        _legendItem(
          'Heap Root',
          orange,
        ),
        _legendItem(
          'Comparing',
          cyan,
        ),
        _legendItem(
          'Swap',
          pink,
        ),
        _legendItem(
          'Sorted',
          green,
        ),
        _legendItem(
          'Heap',
          blue,
        ),
      ],
    );
  }

  Widget _legendItem(
    String title,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // HEAP VISUALIZATION
  // ==============================================================

  Widget _buildHeapVisualization() {
    if (array.isEmpty) {
      return const SizedBox(
        height: 250,
        child: Center(
          child: Text(
            'No array loaded',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 350,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = max(
            constraints.maxWidth,
            array.length * 78.0,
          );

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              height: 350,
              child: Stack(
                children: [
                  _buildHeapLines(width),
                  _buildHeapNodes(width),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==============================================================
  // HEAP LINES
  // ==============================================================

  Widget _buildHeapLines(double width) {
    if (array.length <= 1) {
      return const SizedBox();
    }

    final List<Widget> lines = [];

    final double nodeWidth = 58;
    final double levelGap = 78;

    for (int i = 0; i < array.length; i++) {
      final int left = 2 * i + 1;
      final int right = 2 * i + 2;

      final Offset parent = _nodePosition(
        i,
        width,
        nodeWidth,
        levelGap,
      );

      if (left < array.length) {
        final Offset child = _nodePosition(
          left,
          width,
          nodeWidth,
          levelGap,
        );

        lines.add(
          _connectionLine(
            parent,
            child,
          ),
        );
      }

      if (right < array.length) {
        final Offset child = _nodePosition(
          right,
          width,
          nodeWidth,
          levelGap,
        );

        lines.add(
          _connectionLine(
            parent,
            child,
          ),
        );
      }
    }

    return Stack(
      children: lines,
    );
  }

  Offset _nodePosition(
    int index,
    double width,
    double nodeWidth,
    double levelGap,
  ) {
    final int level = (log(index + 1) / log(2)).floor();

    final int firstIndexAtLevel = pow(2, level).toInt() - 1;

    final int positionAtLevel =
        index - firstIndexAtLevel;

    final int nodesAtLevel =
        pow(2, level).toInt();

    final double levelWidth =
        width / nodesAtLevel;

    final double x =
        (positionAtLevel + .5) * levelWidth -
            nodeWidth / 2;

    final double y =
        20 + level * levelGap;

    return Offset(
      x + nodeWidth / 2,
      y + nodeWidth / 2,
    );
  }

  Widget _connectionLine(
    Offset start,
    Offset end,
  ) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;

    final length = sqrt(
      dx * dx + dy * dy,
    );

    final angle = atan2(dy, dx);

    return Positioned(
      left: start.dx,
      top: start.dy,
      child: Transform.rotate(
        angle: angle,
        alignment: Alignment.centerLeft,
        child: Container(
          width: length,
          height: 1,
          color: Colors.white.withOpacity(0.10),
        ),
      ),
    );
  }

  // ==============================================================
  // HEAP NODES
  // ==============================================================

  Widget _buildHeapNodes(double width) {
    final List<Widget> nodes = [];

    const double nodeSize = 58;
    const double levelGap = 78;

    for (int i = 0; i < array.length; i++) {
      final position = _nodePosition(
        i,
        width,
        nodeSize,
        levelGap,
      );

      final bool isRoot = i == 0;

      final bool isActive =
          i == activeIndex;

      final bool isComparing =
          i == compareIndex;

      final bool isSwapping =
          i == swapIndex;

      final bool isSorted =
          sortedIndices.contains(i);

      Color nodeColor = blue;

      if (isSorted) {
        nodeColor = green;
      } else if (isSwapping) {
        nodeColor = pink;
      } else if (isComparing) {
        nodeColor = cyan;
      } else if (isActive) {
        nodeColor = orange;
      } else if (isRoot) {
        nodeColor = purple;
      }

      nodes.add(
        Positioned(
          left: position.dx - nodeSize / 2,
          top: position.dy - nodeSize / 2,
          child: Column(
            children: [
              Container(
                width: nodeSize,
                height: nodeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: nodeColor.withOpacity(0.10),
                  border: Border.all(
                    color: nodeColor,
                    width:
                        isActive ||
                                isComparing ||
                                isSwapping ||
                                isSorted
                            ? 2
                            : 1.2,
                  ),
                  boxShadow:
                      isActive ||
                              isComparing ||
                              isSwapping
                          ? [
                              BoxShadow(
                                color:
                                    nodeColor.withOpacity(
                                  0.28,
                                ),
                                blurRadius: 14,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                ),
                child: Center(
                  child: Text(
                    '${array[i]}',
                    style: TextStyle(
                      color: isSorted
                          ? green
                          : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '[$i]',
                style: TextStyle(
                  color: nodeColor.withOpacity(.75),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: nodes,
    );
  }

  // ==============================================================
  // OPERATION CARD
  // ==============================================================

  Widget _buildOperationCard() {
    Color operationColor = cyan;

    if (executionHistory.isNotEmpty) {
      final event =
          executionHistory.last;

      switch (event.type) {
        case HeapSortEventType.swap:
          operationColor = pink;
          break;

        case HeapSortEventType.compare:
          operationColor = cyan;
          break;

        case HeapSortEventType.extract:
          operationColor = orange;
          break;

        case HeapSortEventType.complete:
          operationColor = green;
          break;

        case HeapSortEventType.buildHeap:
        case HeapSortEventType.heapify:
        case HeapSortEventType.sorted:
          operationColor = purple;
          break;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: operationColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: operationColor.withOpacity(0.16),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: operationColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              _operationIcon(),
              color: operationColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  executionHistory.isEmpty
                      ? 'READY'
                      : executionHistory.last.title
                          .toUpperCase(),
                  style: TextStyle(
                    color: operationColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  executionMessage,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
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

  IconData _operationIcon() {
    if (executionHistory.isEmpty) {
      return Icons.play_arrow_rounded;
    }

    switch (executionHistory.last.type) {
      case HeapSortEventType.buildHeap:
        return Icons.account_tree_rounded;

      case HeapSortEventType.heapify:
        return Icons.settings_rounded;

      case HeapSortEventType.compare:
        return Icons.compare_arrows_rounded;

      case HeapSortEventType.swap:
        return Icons.swap_vert_rounded;

      case HeapSortEventType.extract:
        return Icons.vertical_align_top_rounded;

      case HeapSortEventType.sorted:
        return Icons.check_circle_outline_rounded;

      case HeapSortEventType.complete:
        return Icons.done_all_rounded;
    }
  }

  // ==============================================================
  // CONTROLS
  // ==============================================================

  Widget _buildControls() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.07),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _controlButton(
                icon: Icons.skip_previous_rounded,
                label: 'Previous',
                onPressed:
                    currentStep > 0 && !isRunning
                        ? _previousStep
                        : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed:
                        isCompleted
                            ? null
                            : isRunning
                                ? _pause
                                : _play,
                    icon: Icon(
                      isRunning
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 18,
                    ),
                    label: Text(
                      isRunning
                          ? 'PAUSE'
                          : isCompleted
                              ? 'COMPLETED'
                              : 'PLAY',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .6,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRunning
                          ? orange
                          : green,
                      foregroundColor: background,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(9),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _controlButton(
                icon: Icons.skip_next_rounded,
                label: 'Next',
                onPressed:
                    !isCompleted && !isRunning
                        ? _nextStep
                        : null,
              ),
              const SizedBox(width: 8),
              _controlButton(
                icon: Icons.restart_alt_rounded,
                label: 'Reset',
                onPressed:
                    isRunning ? null : _reset,
              ),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              const Icon(
                Icons.speed_rounded,
                color: cyan,
                size: 17,
              ),
              const SizedBox(width: 8),
              const Text(
                'Speed',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: Slider(
                  value: speed,
                  min: 0.5,
                  max: 2.5,
                  divisions: 4,
                  activeColor: cyan,
                  inactiveColor:
                      Colors.white.withOpacity(.10),
                  onChanged: _setSpeed,
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '${speed.toStringAsFixed(1)}x',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    color: cyan,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
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
  }) {
    return SizedBox(
      height: 42,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 16,
        ),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white70,
          side: BorderSide(
            color: Colors.white.withOpacity(.09),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // SOURCE + STEPS
  // ==============================================================

  Widget _buildSourceAndStepsPanel() {
    return Column(
      children: [
        _buildSourceCode(),
        const SizedBox(height: 16),
        _buildExecutionSteps(),
      ],
    );
  }

  // ==============================================================
  // SOURCE CODE
  // ==============================================================

  Widget _buildSourceCode() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 400,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(.07),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              15,
              13,
              10,
              13,
            ),
            child: Row(
              children: [
                _sectionTitle(
                  Icons.code_rounded,
                  'Source Code',
                  cyan,
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
                      color: cyan.withOpacity(.06),
                      borderRadius:
                          BorderRadius.circular(8),
                      border: Border.all(
                        color: cyan.withOpacity(.15),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.copy_rounded,
                          color: cyan,
                          size: 13,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'COPY',
                          style: TextStyle(
                            color: cyan,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: Colors.white.withOpacity(.06),
          ),
          SizedBox(
            height: 390,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              itemCount: sourceLines.length,
              itemBuilder: (context, index) {
                final bool active =
                    index + 1 == activeCodeLine;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  color: active
                      ? cyan.withOpacity(.08)
                      : Colors.transparent,
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 28,
                        child: Text(
                          '${index + 1}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: active
                                ? cyan
                                : Colors.white24,
                            fontSize: 10,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          sourceLines[index],
                          style: TextStyle(
                            color: active
                                ? Colors.white
                                : Colors.white60,
                            fontSize: 10.5,
                            height: 1.45,
                            fontFamily: 'monospace',
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
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

  // ==============================================================
  // EXECUTION STEPS
  // ==============================================================

  Widget _buildExecutionSteps() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 260,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(.07),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.timeline_rounded,
            'Execution Steps',
            orange,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: executionHistory.isEmpty
                ? _emptySteps()
                : ListView.builder(
                    itemCount:
                        executionHistory.length,
                    itemBuilder: (
                      context,
                      index,
                    ) {
                      final event =
                          executionHistory[index];

                      return _stepTile(
                        index,
                        event,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptySteps() {
    return Center(
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline_outlined,
            color: Colors.white.withOpacity(.16),
            size: 34,
          ),
          const SizedBox(height: 8),
          const Text(
            'No steps executed yet',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Press Next Step or Play',
            style: TextStyle(
              color: Colors.white24,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepTile(
    int index,
    HeapSortEvent event,
  ) {
    final Color color =
        _eventColor(event.type);

    return Container(
      margin: const EdgeInsets.only(
        bottom: 7,
      ),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: color.withOpacity(.045),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: color.withOpacity(.10),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 25,
            height: 25,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _eventColor(
    HeapSortEventType type,
  ) {
    switch (type) {
      case HeapSortEventType.buildHeap:
        return purple;

      case HeapSortEventType.heapify:
        return blue;

      case HeapSortEventType.compare:
        return cyan;

      case HeapSortEventType.swap:
        return pink;

      case HeapSortEventType.extract:
        return orange;

      case HeapSortEventType.sorted:
        return green;

      case HeapSortEventType.complete:
        return green;
    }
  }

  // ==============================================================
  // SECTION TITLE
  // ==============================================================

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
            color: color.withOpacity(.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
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

  // ==============================================================
  // NEXT STEP
  // ==============================================================

  void _nextStep() {
    if (events.isEmpty) {
      return;
    }

    if (currentStep >= events.length) {
      return;
    }

    final event = events[currentStep];

    setState(() {
      executionHistory.add(event);
      currentStep++;

      array = List<int>.from(event.array);

      activeIndex = event.activeIndex;
      compareIndex = event.compareIndex;
      swapIndex = event.swapIndex;

      heapSize = event.heapSize;

      executionMessage =
          event.description;

      activeCodeLine =
          _codeLineForEvent(event);

      if (event.type ==
          HeapSortEventType.extract) {
        if (event.swapIndex >= 0) {
          sortedIndices.add(
            event.swapIndex,
          );
        }
      }

      if (event.type ==
          HeapSortEventType.complete) {
        isCompleted = true;

        sortedIndices =
            Set<int>.from(
          List.generate(
            array.length,
            (index) => index,
          ),
        );

        activeIndex = -1;
        compareIndex = -1;
        swapIndex = -1;
        heapSize = 0;

        executionMessage =
            'Heap Sort completed successfully.';
      }
    });
  }

  // ==============================================================
  // PREVIOUS STEP
  // ==============================================================

  void _previousStep() {
    if (executionHistory.isEmpty) {
      return;
    }

    executionHistory.removeLast();

    final int newStep =
        executionHistory.length;

    setState(() {
      currentStep = newStep;

      sortedIndices.clear();

      if (executionHistory.isEmpty) {
        array = List<int>.from(
          originalArray,
        );

        activeIndex = -1;
        compareIndex = -1;
        swapIndex = -1;
        heapSize = 0;
        activeCodeLine = 0;
        executionMessage =
            'Ready to start Heap Sort';
        isCompleted = false;
        return;
      }

      final event =
          executionHistory.last;

      array = List<int>.from(
        event.array,
      );

      activeIndex = event.activeIndex;
      compareIndex = event.compareIndex;
      swapIndex = event.swapIndex;
      heapSize = event.heapSize;

      activeCodeLine =
          _codeLineForEvent(event);

      executionMessage =
          event.description;

      for (final e in executionHistory) {
        if (e.type ==
            HeapSortEventType.extract) {
          if (e.swapIndex >= 0) {
            sortedIndices.add(
              e.swapIndex,
            );
          }
        }
      }

      isCompleted = false;

      if (event.type ==
          HeapSortEventType.complete) {
        isCompleted = true;
      }
    });
  }

  // ==============================================================
  // PLAY
  // ==============================================================

  void _play() {
    if (isCompleted) {
      return;
    }

    setState(() {
      isRunning = true;
    });

    _startTimer();
  }

  // ==============================================================
  // PAUSE
  // ==============================================================

  void _pause() {
    _stopTimer();

    setState(() {
      isRunning = false;
    });
  }

  // ==============================================================
  // TIMER
  // ==============================================================

  void _startTimer() {
    _stopTimer();

    final int milliseconds =
        max(
          120,
          (850 / speed).round(),
        );

    timer = Timer.periodic(
      Duration(
        milliseconds: milliseconds,
      ),
      (_) {
        if (currentStep >=
            events.length) {
          _stopTimer();

          if (mounted) {
            setState(() {
              isRunning = false;
              isCompleted = true;
            });
          }

          return;
        }

        _nextStep();

        if (isCompleted) {
          _stopTimer();

          if (mounted) {
            setState(() {
              isRunning = false;
            });
          }
        }
      },
    );
  }

  void _stopTimer() {
    timer?.cancel();
    timer = null;
  }

  // ==============================================================
  // RESET
  // ==============================================================

  void _reset() {
    _stopTimer();

    setState(() {
      isRunning = false;
      isCompleted = false;

      currentStep = 0;

      executionHistory.clear();

      array = List<int>.from(
        originalArray,
      );

      activeIndex = -1;
      compareIndex = -1;
      swapIndex = -1;

      heapSize = 0;

      sortedIndices.clear();

      activeCodeLine = 0;

      executionMessage =
          'Ready to start Heap Sort';
    });
  }

  // ==============================================================
  // LOAD ARRAY
  // ==============================================================

  void _loadArray() {
    final text =
        arrayController.text.trim();

    if (text.isEmpty) {
      _showMessage(
        'Please enter some numbers.',
        red,
      );
      return;
    }

    try {
      final values = text
          .split(RegExp(r'[,;\s]+'))
          .where(
            (value) => value.isNotEmpty,
          )
          .map(
            (value) => int.parse(value),
          )
          .toList();

      if (values.isEmpty) {
        throw const FormatException();
      }

      if (values.length > 31) {
        _showMessage(
          'Please use 31 numbers or fewer for clear heap visualization.',
          orange,
        );
        return;
      }

      _stopTimer();

      setState(() {
        array = List<int>.from(values);
        originalArray =
            List<int>.from(values);

        events.clear();
        executionHistory.clear();

        currentStep = 0;

        isRunning = false;
        isCompleted = false;

        activeIndex = -1;
        compareIndex = -1;
        swapIndex = -1;

        heapSize = 0;

        sortedIndices.clear();

        activeCodeLine = 0;

        executionMessage =
            'Array loaded. Ready to start Heap Sort.';

        _generateEvents();
      });
    } catch (_) {
      _showMessage(
        'Invalid input. Use numbers like: 64, 25, 12, 22',
        red,
      );
    }
  }

  // ==============================================================
  // GENERATE NUMBERS
  // ==============================================================

  void _generateNumbers() {
    final random = Random();

    final generated = List.generate(
      8,
      (_) => 10 + random.nextInt(90),
    );

    arrayController.text =
        generated.join(', ');

    _loadArray();
  }

  // ==============================================================
  // SPEED
  // ==============================================================

  void _setSpeed(double value) {
    setState(() {
      speed = value;
    });

    if (isRunning) {
      _startTimer();
    }
  }

  // ==============================================================
  // CODE LINE
  // ==============================================================

  int _codeLineForEvent(
    HeapSortEvent event,
  ) {
    switch (event.type) {
      case HeapSortEventType.buildHeap:
        return 5;

      case HeapSortEventType.heapify:
        return 14;

      case HeapSortEventType.compare:
        return 19;

      case HeapSortEventType.swap:
        return 29;

      case HeapSortEventType.extract:
        return 9;

      case HeapSortEventType.sorted:
        return 10;

      case HeapSortEventType.complete:
        return 11;
    }
  }

  // ==============================================================
  // COPY CODE
  // ==============================================================

  Future<void> _copyCode() async {
    await Clipboard.setData(
      const ClipboardData(
        text: sourceCode,
      ),
    );

    if (!mounted) {
      return;
    }

    _showMessage(
      'Source code copied to clipboard.',
      green,
    );
  }

  // ==============================================================
  // SNACKBAR
  // ==============================================================

  void _showMessage(
    String message,
    Color color,
  ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
          backgroundColor: cardColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10),
          ),
          duration:
              const Duration(seconds: 2),
        ),
      );
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: LayoutBuilder(
                builder: (
                  context,
                  constraints,
                ) {
                  return SingleChildScrollView(
                    padding:
                        const EdgeInsets.all(18),
                    child: Center(
                      child: ConstrainedBox(
                        constraints:
                            const BoxConstraints(
                          maxWidth: 1450,
                        ),
                        child: Column(
                          children: [
                            _buildAlgorithmInfo(),
                            const SizedBox(
                              height: 16,
                            ),
                            _buildInputSection(),
                            const SizedBox(
                              height: 16,
                            ),
                            _buildMainWorkspace(
                              constraints.maxWidth,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}