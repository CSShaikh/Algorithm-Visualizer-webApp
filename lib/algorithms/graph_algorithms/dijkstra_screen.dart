import 'dart:async';

import 'package:flutter/material.dart';

class DijkstraScreen extends StatefulWidget {
  const DijkstraScreen({super.key});

  @override
  State<DijkstraScreen> createState() => _DijkstraScreenState();
}

// ============================================================
// GRAPH MODELS
// ============================================================

class GraphNode {
  final String id;
  final Offset position;

  const GraphNode({required this.id, required this.position});
}

class GraphEdge {
  final String from;
  final String to;
  final int weight;

  const GraphEdge({required this.from, required this.to, required this.weight});
}

// ============================================================
// EVENT TYPES
// ============================================================

enum DijkstraEventType {
  initialize,
  selectSource,
  extractMin,
  visitNode,
  inspectEdge,
  relax,
  noRelax,
  finalize,
  complete,
}

// ============================================================
// DIJKSTRA EVENT
// ============================================================

class DijkstraEvent {
  final DijkstraEventType type;

  final Map<String, int> distances;
  final Map<String, String?> previous;
  final Set<String> visited;

  final String? currentNode;
  final String? edgeFrom;
  final String? edgeTo;
  final int? edgeWeight;

  final List<String> priorityQueue;

  final int codeLine;

  final String title;
  final String description;
  final String operation;

  const DijkstraEvent({
    required this.type,
    required this.distances,
    required this.previous,
    required this.visited,
    required this.currentNode,
    required this.edgeFrom,
    required this.edgeTo,
    required this.edgeWeight,
    required this.priorityQueue,
    required this.codeLine,
    required this.title,
    required this.description,
    required this.operation,
  });
}

// ============================================================
// STATE
// ============================================================

class _DijkstraScreenState extends State<DijkstraScreen> {
  // ============================================================
  // COLORS
  // ============================================================

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

  // ============================================================
  // GRAPH
  // ============================================================

  final List<GraphNode> nodes = const [
    GraphNode(id: 'A', position: Offset(0.15, 0.50)),
    GraphNode(id: 'B', position: Offset(0.36, 0.22)),
    GraphNode(id: 'C', position: Offset(0.36, 0.78)),
    GraphNode(id: 'D', position: Offset(0.62, 0.22)),
    GraphNode(id: 'E', position: Offset(0.62, 0.78)),
    GraphNode(id: 'F', position: Offset(0.85, 0.50)),
  ];

  final List<GraphEdge> edges = const [
    GraphEdge(from: 'A', to: 'B', weight: 4),
    GraphEdge(from: 'A', to: 'C', weight: 2),
    GraphEdge(from: 'B', to: 'C', weight: 1),
    GraphEdge(from: 'B', to: 'D', weight: 5),
    GraphEdge(from: 'B', to: 'E', weight: 7),
    GraphEdge(from: 'C', to: 'D', weight: 8),
    GraphEdge(from: 'C', to: 'E', weight: 10),
    GraphEdge(from: 'D', to: 'E', weight: 2),
    GraphEdge(from: 'D', to: 'F', weight: 6),
    GraphEdge(from: 'E', to: 'F', weight: 3),
  ];

  // ============================================================
  // INPUT
  // ============================================================

  String sourceNode = 'A';

  // ============================================================
  // ORIGINAL / CURRENT STATE
  // ============================================================

  Map<String, int> distances = {};
  Map<String, String?> previous = {};
  Set<String> visited = {};

  String? currentNode;
  String? edgeFrom;
  String? edgeTo;
  int? edgeWeight;

  List<String> priorityQueue = [];

  // ============================================================
  // EVENTS
  // ============================================================

  List<DijkstraEvent> events = [];
  List<DijkstraEvent> executionHistory = [];

  int currentStep = 0;
  int activeCodeLine = 0;

  // ============================================================
  // PLAYBACK
  // ============================================================

  bool isRunning = false;
  bool isCompleted = false;

  double speed = 1.0;

  Timer? timer;

  String executionMessage = 'Ready to start Dijkstra Algorithm';

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final ScrollController stepsScrollController = ScrollController();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _initializeGraph();
    _generateEvents();
  }

  @override
  void dispose() {
    timer?.cancel();
    stepsScrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // INITIAL GRAPH
  // ============================================================

  void _initializeGraph() {
    distances = {
      for (final node in nodes) node.id: node.id == sourceNode ? 0 : 999999,
    };

    previous = {for (final node in nodes) node.id: null};

    visited = {};

    currentNode = null;
    edgeFrom = null;
    edgeTo = null;
    edgeWeight = null;

    priorityQueue = [sourceNode];

    currentStep = 0;
    activeCodeLine = 0;

    executionMessage = 'Ready to start Dijkstra Algorithm';
  }

  // ============================================================
  // ADJACENCY
  // ============================================================

  Map<String, List<_Neighbor>> _buildAdjacency() {
    final Map<String, List<_Neighbor>> graph = {
      for (final node in nodes) node.id: [],
    };

    for (final edge in edges) {
      graph[edge.from]!.add(_Neighbor(node: edge.to, weight: edge.weight));

      graph[edge.to]!.add(_Neighbor(node: edge.from, weight: edge.weight));
    }

    return graph;
  }

  // ============================================================
  // EVENT CREATOR
  // ============================================================

  DijkstraEvent _event({
    required DijkstraEventType type,
    required Map<String, int> distances,
    required Map<String, String?> previous,
    required Set<String> visited,
    required String? currentNode,
    required String? edgeFrom,
    required String? edgeTo,
    required int? edgeWeight,
    required List<String> priorityQueue,
    required int codeLine,
    required String title,
    required String description,
    required String operation,
  }) {
    return DijkstraEvent(
      type: type,
      distances: Map<String, int>.from(distances),
      previous: Map<String, String?>.from(previous),
      visited: Set<String>.from(visited),
      currentNode: currentNode,
      edgeFrom: edgeFrom,
      edgeTo: edgeTo,
      edgeWeight: edgeWeight,
      priorityQueue: List<String>.from(priorityQueue),
      codeLine: codeLine,
      title: title,
      description: description,
      operation: operation,
    );
  }

  // ============================================================
  // GENERATE DIJKSTRA EVENTS
  // ============================================================

  void _generateEvents() {
    final generated = <DijkstraEvent>[];

    final graph = _buildAdjacency();

    final localDistances = <String, int>{
      for (final node in nodes) node.id: node.id == sourceNode ? 0 : 999999,
    };

    final localPrevious = <String, String?>{
      for (final node in nodes) node.id: null,
    };

    final localVisited = <String>{};

    final queue = <_QueueItem>[_QueueItem(node: sourceNode, distance: 0)];

    generated.add(
      _event(
        type: DijkstraEventType.initialize,
        distances: localDistances,
        previous: localPrevious,
        visited: localVisited,
        currentNode: null,
        edgeFrom: null,
        edgeTo: null,
        edgeWeight: null,
        priorityQueue: [sourceNode],
        codeLine: 2,
        title: 'Initialize',
        description:
            'All distances are initialized to infinity except source $sourceNode = 0.',
        operation: 'Initialize distances',
      ),
    );

    generated.add(
      _event(
        type: DijkstraEventType.selectSource,
        distances: localDistances,
        previous: localPrevious,
        visited: localVisited,
        currentNode: sourceNode,
        edgeFrom: null,
        edgeTo: null,
        edgeWeight: null,
        priorityQueue: [sourceNode],
        codeLine: 3,
        title: 'Source Selected',
        description: 'Starting Dijkstra from source node $sourceNode.',
        operation: 'Select source',
      ),
    );

    while (queue.isNotEmpty) {
      queue.sort((a, b) => a.distance.compareTo(b.distance));

      final item = queue.removeAt(0);

      if (localVisited.contains(item.node)) {
        continue;
      }

      generated.add(
        _event(
          type: DijkstraEventType.extractMin,
          distances: localDistances,
          previous: localPrevious,
          visited: localVisited,
          currentNode: item.node,
          edgeFrom: null,
          edgeTo: null,
          edgeWeight: null,
          priorityQueue: queue.map((e) => e.node).toList(),
          codeLine: 5,
          title: 'Extract Minimum',
          description:
              'Node ${item.node} has the smallest tentative distance: ${item.distance}.',
          operation: 'Extract minimum distance',
        ),
      );

      localVisited.add(item.node);

      generated.add(
        _event(
          type: DijkstraEventType.visitNode,
          distances: localDistances,
          previous: localPrevious,
          visited: localVisited,
          currentNode: item.node,
          edgeFrom: null,
          edgeTo: null,
          edgeWeight: null,
          priorityQueue: queue.map((e) => e.node).toList(),
          codeLine: 6,
          title: 'Visit Node',
          description:
              'Node ${item.node} is now finalized with distance ${localDistances[item.node]}.',
          operation: 'Mark node visited',
        ),
      );

      for (final neighbor in graph[item.node]!) {
        if (localVisited.contains(neighbor.node)) {
          continue;
        }

        final candidate = localDistances[item.node]! + neighbor.weight;

        generated.add(
          _event(
            type: DijkstraEventType.inspectEdge,
            distances: localDistances,
            previous: localPrevious,
            visited: localVisited,
            currentNode: item.node,
            edgeFrom: item.node,
            edgeTo: neighbor.node,
            edgeWeight: neighbor.weight,
            priorityQueue: queue.map((e) => e.node).toList(),
            codeLine: 8,
            title: 'Inspect Edge',
            description:
                'Checking edge ${item.node} → ${neighbor.node} with weight ${neighbor.weight}.',
            operation: 'Inspect edge',
          ),
        );

        if (candidate < localDistances[neighbor.node]!) {
          localDistances[neighbor.node] = candidate;
          localPrevious[neighbor.node] = item.node;

          queue.add(_QueueItem(node: neighbor.node, distance: candidate));

          generated.add(
            _event(
              type: DijkstraEventType.relax,
              distances: localDistances,
              previous: localPrevious,
              visited: localVisited,
              currentNode: item.node,
              edgeFrom: item.node,
              edgeTo: neighbor.node,
              edgeWeight: neighbor.weight,
              priorityQueue: queue.map((e) => e.node).toList(),
              codeLine: 10,
              title: 'Relax Edge',
              description:
                  'New shorter distance for ${neighbor.node}: $candidate.',
              operation: 'Relax ${item.node} → ${neighbor.node}',
            ),
          );
        } else {
          generated.add(
            _event(
              type: DijkstraEventType.noRelax,
              distances: localDistances,
              previous: localPrevious,
              visited: localVisited,
              currentNode: item.node,
              edgeFrom: item.node,
              edgeTo: neighbor.node,
              edgeWeight: neighbor.weight,
              priorityQueue: queue.map((e) => e.node).toList(),
              codeLine: 12,
              title: 'No Relaxation',
              description:
                  'Current distance for ${neighbor.node} is already shorter. No update required.',
              operation: 'Keep existing distance',
            ),
          );
        }
      }

      generated.add(
        _event(
          type: DijkstraEventType.finalize,
          distances: localDistances,
          previous: localPrevious,
          visited: localVisited,
          currentNode: item.node,
          edgeFrom: null,
          edgeTo: null,
          edgeWeight: null,
          priorityQueue: queue.map((e) => e.node).toList(),
          codeLine: 14,
          title: 'Finalize Node',
          description:
              'All useful outgoing edges from ${item.node} have been processed.',
          operation: 'Finalize node',
        ),
      );
    }

    generated.add(
      _event(
        type: DijkstraEventType.complete,
        distances: localDistances,
        previous: localPrevious,
        visited: localVisited,
        currentNode: null,
        edgeFrom: null,
        edgeTo: null,
        edgeWeight: null,
        priorityQueue: [],
        codeLine: 17,
        title: 'Completed',
        description:
            'Dijkstra completed. Shortest distances from $sourceNode are available.',
        operation: 'Algorithm completed',
      ),
    );

    setState(() {
      events = generated;
      executionHistory = [];
      currentStep = 0;
      isCompleted = false;
      isRunning = false;
    });

    _initializeGraph();
  }

  // ============================================================
  // APPLY EVENT
  // ============================================================

  void _applyEvent(DijkstraEvent event) {
    setState(() {
      distances = Map<String, int>.from(event.distances);
      previous = Map<String, String?>.from(event.previous);
      visited = Set<String>.from(event.visited);

      currentNode = event.currentNode;
      edgeFrom = event.edgeFrom;
      edgeTo = event.edgeTo;
      edgeWeight = event.edgeWeight;

      priorityQueue = List<String>.from(event.priorityQueue);

      activeCodeLine = event.codeLine;

      executionMessage = event.description;

      isCompleted = event.type == DijkstraEventType.complete;

      if (event.type == DijkstraEventType.complete) {
        isRunning = false;
      }
    });

    _scrollStepsToBottom();
  }

  // ============================================================
  // NEXT
  // ============================================================

  void _nextStep() {
    if (events.isEmpty) {
      return;
    }

    if (currentStep >= events.length) {
      return;
    }

    final event = events[currentStep];

    executionHistory.add(event);

    _applyEvent(event);

    setState(() {
      currentStep++;
    });

    if (currentStep >= events.length) {
      _stopTimer();

      setState(() {
        isRunning = false;
        isCompleted = true;
      });
    }
  }

  // ============================================================
  // PREVIOUS
  // ============================================================

  void _previousStep() {
    _stopTimer();

    if (currentStep <= 0) {
      _initializeGraph();

      setState(() {
        isRunning = false;
        isCompleted = false;
        executionHistory.clear();
      });

      return;
    }

    final targetIndex = currentStep - 2;

    if (targetIndex < 0) {
      _initializeGraph();

      setState(() {
        currentStep = 0;
        executionHistory.clear();
        isCompleted = false;
        isRunning = false;
      });

      return;
    }

    final event = events[targetIndex];

    setState(() {
      currentStep = targetIndex + 1;
      executionHistory = events.take(targetIndex + 1).toList();
    });

    _applyEvent(event);

    setState(() {
      isCompleted = false;
      isRunning = false;
    });
  }

  // ============================================================
  // PLAY
  // ============================================================

  void _play() {
    if (events.isEmpty) {
      return;
    }

    if (currentStep >= events.length) {
      _reset();
    }

    _stopTimer();

    setState(() {
      isRunning = true;
      isCompleted = false;
    });

    timer = Timer.periodic(
      Duration(milliseconds: (900 / speed).round().clamp(100, 2000).toInt()),
      (_) {
        if (!mounted) {
          return;
        }

        if (currentStep >= events.length) {
          _stopTimer();

          setState(() {
            isRunning = false;
            isCompleted = true;
          });

          return;
        }

        _nextStep();
      },
    );
  }

  // ============================================================
  // PAUSE
  // ============================================================

  void _pause() {
    _stopTimer();

    setState(() {
      isRunning = false;
    });
  }

  // ============================================================
  // TOGGLE
  // ============================================================

  void _togglePlayPause() {
    if (isRunning) {
      _pause();
    } else {
      _play();
    }
  }

  // ============================================================
  // STOP TIMER
  // ============================================================

  void _stopTimer() {
    timer?.cancel();
    timer = null;
  }

  // ============================================================
  // RESET
  // ============================================================

  void _reset() {
    _stopTimer();

    _initializeGraph();

    setState(() {
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
    });
  }

  // ============================================================
  // CHANGE SOURCE
  // ============================================================

  void _changeSource(String value) {
    if (isRunning) {
      _stopTimer();
    }

    setState(() {
      sourceNode = value;
      isRunning = false;
      isCompleted = false;
    });

    _generateEvents();
  }

  // ============================================================
  // SPEED
  // ============================================================

  void _setSpeed(double value) {
    setState(() {
      speed = value;
    });

    if (isRunning) {
      _play();
    }
  }

  // ============================================================
  // SCROLL EXECUTION
  // ============================================================

  void _scrollStepsToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!stepsScrollController.hasClients) {
        return;
      }

      stepsScrollController.animateTo(
        stepsScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  // ============================================================
  // DISTANCE TEXT
  // ============================================================

  String _distanceText(String node) {
    final value = distances[node] ?? 999999;

    if (value >= 999999) {
      return '∞';
    }

    return '$value';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            if (width < 700) {
              return _buildMobileLayout();
            }

            return _buildDesktopLayout();
          },
        ),
      ),
    );
  }

  // ============================================================
  // DESKTOP
  // ============================================================

  Widget _buildDesktopLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 14),
          _buildAlgorithmInfo(),
          const SizedBox(height: 14),
          _buildInputSection(),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    _buildVisualizationPanel(),
                    const SizedBox(height: 14),
                    _buildControls(),
                    const SizedBox(height: 14),
                    _buildDistancePanel(),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    _buildSourceCodePanel(),
                    const SizedBox(height: 14),
                    _buildExecutionSteps(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MOBILE
  // ============================================================

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildAlgorithmInfo(),
          const SizedBox(height: 12),
          _buildInputSection(),
          const SizedBox(height: 12),
          _buildVisualizationPanel(),
          const SizedBox(height: 12),
          _buildControls(),
          const SizedBox(height: 12),
          _buildDistancePanel(),
          const SizedBox(height: 12),
          _buildSourceCodePanel(),
          const SizedBox(height: 12),
          _buildExecutionSteps(),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cyan.withValues(alpha: .18)),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white70,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [cyan, blue]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.route_rounded, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dijkstra Algorithm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Shortest Path • Weighted Graph',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .45),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        _statusBadge(),
      ],
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge() {
    final Color color;

    if (isCompleted) {
      color = green;
    } else if (isRunning) {
      color = cyan;
    } else {
      color = orange;
    }

    final String text;

    if (isCompleted) {
      text = 'COMPLETED';
    } else if (isRunning) {
      text = 'RUNNING';
    } else {
      text = 'READY';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: .7), blurRadius: 7),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ALGORITHM INFO
  // ============================================================

  Widget _buildAlgorithmInfo() {
    return _panel(
      borderColor: purple.withValues(alpha: .15),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _iconBox(Icons.info_outline_rounded, purple),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ALGORITHM OVERVIEW',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .7,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Finds the shortest paths from one source node to every reachable node.',
                        style: TextStyle(color: Colors.white54, fontSize: 9),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _infoBox('TIME', 'O((V+E) log V)', cyan),
                _infoBox('SPACE', 'O(V)', blue),
                _infoBox('TYPE', 'Graph', purple),
                _infoBox('STRATEGY', 'Greedy', orange),
                _infoBox('WEIGHTS', 'Non-negative', green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .05),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: color.withValues(alpha: .14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label  ',
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INPUT SECTION
  // ============================================================

  Widget _buildInputSection() {
    return _panel(
      borderColor: cyan.withValues(alpha: .14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sourceSelector(),
                  const SizedBox(height: 10),
                  _generateButton(),
                ],
              );
            }

            return Row(
              children: [
                Expanded(child: _sourceSelector()),
                const SizedBox(width: 10),
                _generateButton(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _sourceSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      height: 50,
      decoration: BoxDecoration(
        color: background2,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: cyan.withValues(alpha: .16)),
      ),
      child: Row(
        children: [
          const Icon(Icons.trip_origin_rounded, color: cyan, size: 18),
          const SizedBox(width: 9),
          const Text(
            'SOURCE NODE',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: .7,
            ),
          ),
          const Spacer(),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: sourceNode,
              dropdownColor: cardColor,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: cyan,
                size: 18,
              ),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
              items: nodes
                  .map(
                    (node) => DropdownMenuItem<String>(
                      value: node.id,
                      child: Text(node.id),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  _changeSource(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _generateButton() {
    return InkWell(
      onTap: isRunning ? null : _generateEvents,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [cyan.withValues(alpha: .15), blue.withValues(alpha: .12)],
          ),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: cyan.withValues(alpha: .25)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, color: cyan, size: 18),
            SizedBox(width: 8),
            Text(
              'REGENERATE',
              style: TextStyle(
                color: cyan,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: .6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // VISUALIZATION
  // ============================================================

  Widget _buildVisualizationPanel() {
    return _panel(
      borderColor: cyan.withValues(alpha: .18),
      child: Column(
        children: [
          _panelHeader(
            Icons.account_tree_rounded,
            cyan,
            'GRAPH VISUALIZATION',
            'LIVE DIJKSTRA EXECUTION',
            activeCodeLine == 0 ? 'READY' : 'LINE $activeCodeLine',
            cyan,
          ),
          Container(height: 1, color: Colors.white.withValues(alpha: .05)),
          SizedBox(
            height: 430,
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: visualizationColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cyan.withValues(alpha: .08)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CustomPaint(
                  painter: _DijkstraGraphPainter(
                    nodes: nodes,
                    edges: edges,
                    distances: distances,
                    previous: previous,
                    visited: visited,
                    currentNode: currentNode,
                    edgeFrom: edgeFrom,
                    edgeTo: edgeTo,
                    edgeWeight: edgeWeight,
                    sourceNode: sourceNode,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          _buildLegend(),
        ],
      ),
    );
  }

  // ============================================================
  // LEGEND
  // ============================================================

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 2, 14, 14),
      child: Wrap(
        spacing: 14,
        runSpacing: 8,
        children: [
          _legendItem('Source', cyan),
          _legendItem('Current', orange),
          _legendItem('Visited', green),
          _legendItem('Shortest Path', pink),
          _legendItem('Checking', purple),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withValues(alpha: .4), blurRadius: 5),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 8,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CONTROLS
  // ============================================================

  Widget _buildControls() {
    return _panel(
      borderColor: blue.withValues(alpha: .15),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  'EXECUTION',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                  ),
                ),
                const Spacer(),
                Text(
                  events.isEmpty ? '0 / 0' : '$currentStep / ${events.length}',
                  style: const TextStyle(
                    color: cyan,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: events.isEmpty ? 0 : currentStep / events.length,
                minHeight: 6,
                backgroundColor: Colors.white.withValues(alpha: .05),
                valueColor: const AlwaysStoppedAnimation(cyan),
              ),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 480) {
                  return Column(
                    children: [
                      _controlRow(),
                      const SizedBox(height: 12),
                      _speedControl(),
                    ],
                  );
                }

                return Row(
                  children: [_controlRow(), const Spacer(), _speedControl()],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _controlRow() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _controlButton(
          Icons.skip_previous_rounded,
          currentStep > 0 ? _previousStep : () {},
        ),
        const SizedBox(width: 7),
        _playButton(),
        const SizedBox(width: 7),
        _controlButton(
          Icons.skip_next_rounded,
          currentStep < events.length ? _nextStep : () {},
        ),
        const SizedBox(width: 7),
        _controlButton(Icons.restart_alt_rounded, _reset),
      ],
    );
  }

  Widget _playButton() {
    return InkWell(
      onTap: _togglePlayPause,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        width: 56,
        height: 48,
        decoration: BoxDecoration(
          color: cyan.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: cyan.withValues(alpha: .30)),
          boxShadow: [
            BoxShadow(color: cyan.withValues(alpha: .06), blurRadius: 12),
          ],
        ),
        child: Icon(
          isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: cyan,
          size: 23,
        ),
      ),
    );
  }

  Widget _controlButton(IconData icon, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(11),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: background2,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: blue.withValues(alpha: .18)),
        ),
        child: Icon(icon, color: Colors.white60, size: 20),
      ),
    );
  }

  Widget _speedControl() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.speed_rounded, color: Colors.white38, size: 17),
        const SizedBox(width: 7),
        const Text(
          'SPEED',
          style: TextStyle(
            color: Colors.white38,
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(
          width: 120,
          child: Slider(
            value: speed,
            min: .5,
            max: 3,
            divisions: 5,
            activeColor: cyan,
            inactiveColor: Colors.white.withValues(alpha: .08),
            onChanged: _setSpeed,
          ),
        ),
        Text(
          '${speed.toStringAsFixed(1)}x',
          style: const TextStyle(
            color: cyan,
            fontSize: 9,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DISTANCE PANEL
  // ============================================================

  Widget _buildDistancePanel() {
    return _panel(
      borderColor: green.withValues(alpha: .14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _iconBox(Icons.straighten_rounded, green),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SHORTEST DISTANCES',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: .7,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Current shortest known distance from source',
                        style: TextStyle(color: Colors.white38, fontSize: 8),
                      ),
                    ],
                  ),
                ),
                Text(
                  'SOURCE: $sourceNode',
                  style: const TextStyle(
                    color: cyan,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: nodes.map((node) {
                final isVisited = visited.contains(node.id);

                final color = isVisited ? green : cyan;

                return Container(
                  width: 85,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withValues(alpha: .16)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        node.id,
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _distanceText(node.id),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SOURCE CODE
  // ============================================================

  Widget _buildSourceCodePanel() {
    return _panel(
      borderColor: purple.withValues(alpha: .18),
      child: Column(
        children: [
          _panelHeader(
            Icons.code_rounded,
            purple,
            'DIJKSTRA SOURCE CODE',
            'LIVE CODE EXECUTION',
            activeCodeLine == 0 ? 'READY' : 'LINE $activeCodeLine',
            cyan,
          ),
          Container(height: 1, color: Colors.white.withValues(alpha: .05)),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Column(
              children: [
                _codeLine(
                  1,
                  'void dijkstra(Graph graph, String source) {',
                  purple,
                ),
                _codeLine(2, '  distance[source] = 0;', cyan),
                _codeLine(3, '  priorityQueue.add(source);', blue),
                _codeLine(4, '  while (priorityQueue.isNotEmpty) {', orange),
                _codeLine(5, '    u = extractMin();', orange),
                _codeLine(6, '    visited.add(u);', green),
                _codeLine(7, '    for (edge in graph[u]) {', cyan),
                _codeLine(8, '      inspect(edge);', purple),
                _codeLine(9, '      newDist = distance[u] + weight;', blue),
                _codeLine(10, '      if (newDist < distance[v]) {', green),
                _codeLine(11, '        distance[v] = newDist;', green),
                _codeLine(12, '      } else {', pink),
                _codeLine(13, '        keep current distance;', pink),
                _codeLine(14, '    }', cyan),
                _codeLine(15, '  }', cyan),
                _codeLine(16, '  return distance;', purple),
                _codeLine(17, '}', purple),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: activeCodeLine == 10 || activeCodeLine == 11
                    ? green.withValues(alpha: .06)
                    : cyan.withValues(alpha: .04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: activeCodeLine == 10 || activeCodeLine == 11
                      ? green.withValues(alpha: .25)
                      : cyan.withValues(alpha: .12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    activeCodeLine == 17
                        ? Icons.check_circle_rounded
                        : Icons.play_circle_outline_rounded,
                    color: activeCodeLine == 17 ? green : cyan,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      executionMessage,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 9,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _codeLine(int number, String code, Color color) {
    final active = activeCodeLine == number;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: .10) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: active ? Border.all(color: color.withValues(alpha: .25)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25,
            child: Text(
              '$number',
              style: TextStyle(
                color: active ? color : Colors.white24,
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: Text(
              code,
              style: TextStyle(
                color: active ? Colors.white : Colors.white54,
                fontSize: 9,
                fontFamily: 'monospace',
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EXECUTION STEPS
  // ============================================================

  Widget _buildExecutionSteps() {
    return _panel(
      borderColor: cyan.withValues(alpha: .15),
      child: SizedBox(
        height: 500,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _iconBox(Icons.history_rounded, cyan),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EXECUTION STEPS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .7,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Step-by-step algorithm process',
                          style: TextStyle(color: Colors.white38, fontSize: 8),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${executionHistory.length}',
                    style: const TextStyle(
                      color: cyan,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: executionHistory.isEmpty
                    ? _emptySteps()
                    : ListView.builder(
                        controller: stepsScrollController,
                        itemCount: executionHistory.length,
                        itemBuilder: (context, index) {
                          final event = executionHistory[index];

                          return _stepItem(index + 1, event);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptySteps() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.play_circle_outline_rounded,
            color: cyan.withValues(alpha: .25),
            size: 40,
          ),
          const SizedBox(height: 10),
          const Text(
            'Press Play or Next',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Execution steps will appear here',
            style: TextStyle(color: Colors.white24, fontSize: 8),
          ),
        ],
      ),
    );
  }

  Widget _stepItem(int number, DijkstraEvent event) {
    final color = _eventColor(event.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .045),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: .12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 27,
            height: 27,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$number',
              style: TextStyle(
                color: color,
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
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
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (event.edgeFrom != null && event.edgeTo != null)
                      Text(
                        '${event.edgeFrom} → ${event.edgeTo}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  event.description,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 8,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _eventColor(DijkstraEventType type) {
    switch (type) {
      case DijkstraEventType.initialize:
        return blue;
      case DijkstraEventType.selectSource:
        return cyan;
      case DijkstraEventType.extractMin:
        return orange;
      case DijkstraEventType.visitNode:
        return green;
      case DijkstraEventType.inspectEdge:
        return purple;
      case DijkstraEventType.relax:
        return green;
      case DijkstraEventType.noRelax:
        return pink;
      case DijkstraEventType.finalize:
        return cyan;
      case DijkstraEventType.complete:
        return green;
    }
  }

  // ============================================================
  // COMMON PANEL
  // ============================================================

  Widget _panel({required Color borderColor, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .15),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _iconBox(IconData icon, Color color) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: .15)),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _panelHeader(
    IconData icon,
    Color color,
    String title,
    String subtitle,
    String badge,
    Color badgeColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _iconBox(icon, color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white30,
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .6,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: badgeColor.withValues(alpha: .18)),
            ),
            child: Text(
              badge,
              style: TextStyle(
                color: badgeColor,
                fontSize: 7,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// NEIGHBOR MODEL
// ============================================================

class _Neighbor {
  final String node;
  final int weight;

  const _Neighbor({required this.node, required this.weight});
}

// ============================================================
// QUEUE ITEM
// ============================================================

class _QueueItem {
  final String node;
  final int distance;

  const _QueueItem({required this.node, required this.distance});
}

// ============================================================
// GRAPH PAINTER
// ============================================================

class _DijkstraGraphPainter extends CustomPainter {
  // ============================================================
  // IMPORTANT:
  // Colors are defined INSIDE the painter.
  // This fixes cyan/background2/green/pink/purple errors.
  // ============================================================

  static const Color background2 = Color(0xFF07101F);

  static const Color cyan = Color(0xFF00E5FF);
  static const Color blue = Color(0xFF2979FF);
  static const Color purple = Color(0xFF9C27FF);
  static const Color green = Color(0xFF00E676);
  static const Color orange = Color(0xFFFFB300);
  static const Color pink = Color(0xFFFF4081);

  final List<GraphNode> nodes;
  final List<GraphEdge> edges;

  final Map<String, int> distances;
  final Map<String, String?> previous;
  final Set<String> visited;

  final String? currentNode;

  final String? edgeFrom;
  final String? edgeTo;
  final int? edgeWeight;

  final String sourceNode;

  _DijkstraGraphPainter({
    required this.nodes,
    required this.edges,
    required this.distances,
    required this.previous,
    required this.visited,
    required this.currentNode,
    required this.edgeFrom,
    required this.edgeTo,
    required this.edgeWeight,
    required this.sourceNode,
  });

  // ============================================================
  // NODE POSITION
  // ============================================================

  Offset _nodeOffset(GraphNode node, Size size) {
    return Offset(
      node.position.dx * size.width,
      node.position.dy * size.height,
    );
  }

  // ============================================================
  // PAINT
  // ============================================================

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawGrid(canvas, size);
    _drawEdges(canvas, size);
    _drawNodes(canvas, size);
  }

  // ============================================================
  // BACKGROUND
  // ============================================================

  void _drawBackground(Canvas canvas, Size size) {
    final paint = Paint()..color = background2;

    canvas.drawRect(Offset.zero & size, paint);
  }

  // ============================================================
  // GRID
  // ============================================================

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: .025)
      ..strokeWidth = 1;

    const spacing = 35.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  // ============================================================
  // EDGES
  // ============================================================

  void _drawEdges(Canvas canvas, Size size) {
    for (final edge in edges) {
      final fromNode = nodes.firstWhere((node) => node.id == edge.from);

      final toNode = nodes.firstWhere((node) => node.id == edge.to);

      final p1 = _nodeOffset(fromNode, size);

      final p2 = _nodeOffset(toNode, size);

      final isCurrentEdge =
          (edge.from == edgeFrom && edge.to == edgeTo) ||
          (edge.from == edgeTo && edge.to == edgeFrom);

      final isShortestPath = _isShortestPathEdge(edge.from, edge.to);

      Color edgeColor;
      double width;

      if (isCurrentEdge) {
        edgeColor = purple;
        width = 4;
      } else if (isShortestPath) {
        edgeColor = pink;
        width = 4;
      } else {
        edgeColor = Colors.white.withValues(alpha: .15);
        width = 2;
      }

      final paint = Paint()
        ..color = edgeColor
        ..strokeWidth = width
        ..style = PaintingStyle.stroke;

      if (isCurrentEdge) {
        paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);

        canvas.drawLine(p1, p2, paint);

        paint.maskFilter = null;
      }

      canvas.drawLine(p1, p2, paint);

      _drawWeight(canvas, p1, p2, edge.weight, edgeColor);
    }
  }

  // ============================================================
  // SHORTEST PATH EDGE
  // ============================================================

  bool _isShortestPathEdge(String from, String to) {
    final fromPrevious = previous[from];
    final toPrevious = previous[to];

    return fromPrevious == to || toPrevious == from;
  }

  // ============================================================
  // WEIGHT
  // ============================================================

  void _drawWeight(
    Canvas canvas,
    Offset p1,
    Offset p2,
    int weight,
    Color color,
  ) {
    final midpoint = Offset((p1.dx + p2.dx) / 2, (p1.dy + p2.dy) / 2);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$weight',
        style: TextStyle(
          color: color == Colors.white ? Colors.white70 : color,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: midpoint,
        width: textPainter.width + 14,
        height: textPainter.height + 9,
      ),
      const Radius.circular(7),
    );

    final bgPaint = Paint()
      ..color = background2
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rect, bgPaint);

    final borderPaint = Paint()
      ..color = color.withValues(alpha: .35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(rect, borderPaint);

    textPainter.paint(
      canvas,
      Offset(
        midpoint.dx - textPainter.width / 2,
        midpoint.dy - textPainter.height / 2,
      ),
    );
  }

  // ============================================================
  // NODES
  // ============================================================

  void _drawNodes(Canvas canvas, Size size) {
    for (final node in nodes) {
      final position = _nodeOffset(node, size);

      final isSource = node.id == sourceNode;

      final isCurrent = node.id == currentNode;

      final isVisited = visited.contains(node.id);

      Color nodeColor;

      if (isCurrent) {
        nodeColor = orange;
      } else if (isSource) {
        nodeColor = cyan;
      } else if (isVisited) {
        nodeColor = green;
      } else {
        nodeColor = blue;
      }

      // Glow
      final glowPaint = Paint()
        ..color = nodeColor.withValues(alpha: .18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawCircle(position, 30, glowPaint);

      // Outer ring
      final outerPaint = Paint()
        ..color = nodeColor.withValues(alpha: .25)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(position, 28, outerPaint);

      // Main circle
      final mainPaint = Paint()
        ..color = background2
        ..style = PaintingStyle.fill;

      canvas.drawCircle(position, 24, mainPaint);

      // Border
      final borderPaint = Paint()
        ..color = nodeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isCurrent ? 3 : 2;

      canvas.drawCircle(position, 24, borderPaint);

      // Node label
      final labelPainter = TextPainter(
        text: TextSpan(
          text: node.id,
          style: TextStyle(
            color: nodeColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      labelPainter.layout();

      labelPainter.paint(
        canvas,
        Offset(position.dx - labelPainter.width / 2, position.dy - 14),
      );

      // Distance
      final distance = distances[node.id] ?? 999999;

      final distanceText = distance >= 999999 ? '∞' : '$distance';

      final distancePainter = TextPainter(
        text: TextSpan(
          text: distanceText,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      distancePainter.layout();

      distancePainter.paint(
        canvas,
        Offset(position.dx - distancePainter.width / 2, position.dy + 7),
      );

      // Source marker
      if (isSource) {
        _drawSourceMarker(canvas, position);
      }

      // Current marker
      if (isCurrent) {
        _drawCurrentMarker(canvas, position);
      }
    }
  }

  // ============================================================
  // SOURCE MARKER
  // ============================================================

  void _drawSourceMarker(Canvas canvas, Offset position) {
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'SOURCE',
        style: TextStyle(
          color: cyan,
          fontSize: 7,
          fontWeight: FontWeight.w900,
          letterSpacing: .5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy - 40),
    );
  }

  // ============================================================
  // CURRENT MARKER
  // ============================================================

  void _drawCurrentMarker(Canvas canvas, Offset position) {
    final paint = Paint()
      ..color = orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(position, 33, paint);
  }

  @override
  bool shouldRepaint(covariant _DijkstraGraphPainter oldDelegate) {
    return oldDelegate.distances != distances ||
        oldDelegate.previous != previous ||
        oldDelegate.visited != visited ||
        oldDelegate.currentNode != currentNode ||
        oldDelegate.edgeFrom != edgeFrom ||
        oldDelegate.edgeTo != edgeTo ||
        oldDelegate.sourceNode != sourceNode;
  }
}
