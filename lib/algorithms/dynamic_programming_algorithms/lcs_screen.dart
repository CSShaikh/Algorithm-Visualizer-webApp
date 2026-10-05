import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LcsAlgorithmScreen extends StatefulWidget {
  const LcsAlgorithmScreen({super.key});
  @override
  State<LcsAlgorithmScreen> createState() => _LcsAlgorithmScreenState();
}

enum LcsEventType { initialize, compare, match, choose, backtrack, complete }

class LcsEvent {
  final LcsEventType type;
  final List<List<int>> dp;
  final int row;
  final int column;
  final String firstString;
  final String secondString;
  final String lcs;
  final Set<String> pathCells;
  final String title;
  final String description;
  final String operation;
  const LcsEvent({
    required this.type,
    required this.dp,
    required this.row,
    required this.column,
    required this.firstString,
    required this.secondString,
    required this.lcs,
    required this.pathCells,
    required this.title,
    required this.description,
    required this.operation,
  });
}

class _LcsAlgorithmScreenState extends State<LcsAlgorithmScreen> {
  static const Color background = Color(0xFF030712);
  static const Color background2 = Color(0xFF07101F);
  static const Color cardColor = Color(0xFF0B1428);
  static const Color visualizationColor = Color(0xFF0A1020);
  static const Color cyan = Color(0xFF00E5FF);
  static const Color blue = Color(0xFF2979FF);
  static const Color purple = Color(0xFF9C27FF);
  static const Color green = Color(0xFF00E676);
  static const Color orange = Color(0xFFFFB300);
  static const Color red = Color(0xFFFF5252);

  String firstString = 'ABCBDAB';
  String secondString = 'BDCABA';
  String originalFirst = 'ABCBDAB';
  String originalSecond = 'BDCABA';
  List<List<int>> dpTable = [];
  String lcsResult = '';
  final firstStringController = TextEditingController(text: 'ABCBDAB');
  final secondStringController = TextEditingController(text: 'BDCABA');
  List<LcsEvent> events = [];
  List<LcsEvent> executionHistory = [];
  int currentStep = 0;
  bool isRunning = false;
  bool isCompleted = false;
  double speed = 1.0;
  Timer? timer;
  int currentRow = -1;
  int currentColumn = -1;
  int activeCodeLine = 0;
  Set<String> pathCells = {};
  String executionMessage =
      'Ready to start the Longest Common Subsequence Algorithm.';

  final String sourceCode = '''
int lcs(String a, String b) {
  final dp = List.generate(
    a.length + 1,
    (_) => List.filled(b.length + 1, 0),
  );

  for (int i = 1; i <= a.length; i++) {
    for (int j = 1; j <= b.length; j++) {
      if (a[i - 1] == b[j - 1]) {
        dp[i][j] = dp[i - 1][j - 1] + 1;
      } else {
        dp[i][j] = max(dp[i - 1][j], dp[i][j - 1]);
      }
    }
  }

  final result = <String>[];
  int i = a.length;
  int j = b.length;
  while (i > 0 && j > 0) {
    if (a[i - 1] == b[j - 1]) {
      result.add(a[i - 1]);
      i--;
      j--;
    } else if (dp[i - 1][j] >= dp[i][j - 1]) {
      i--;
    } else {
      j--;
    }
  }

  return result.reversed.join();
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
    firstStringController.dispose();
    secondStringController.dispose();
    super.dispose();
  }

  List<List<int>> _copyDp(List<List<int>> v) => v.map((r) => [...r]).toList();

  void _generateEvents() {
    final generated = <LcsEvent>[];
    final m = firstString.length, n = secondString.length;
    var dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
    var path = <String>{};
    var built = '';
    generated.add(
      LcsEvent(
        type: LcsEventType.initialize,
        dp: _copyDp(dp),
        row: -1,
        column: -1,
        firstString: firstString,
        secondString: secondString,
        lcs: '',
        pathCells: {},
        title: 'LCS Table Initialized',
        description:
            'Create an empty DP table for all prefixes of both strings.',
        operation: 'dp = zeros(${m + 1} × ${n + 1})',
      ),
    );
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        final a = firstString[i - 1], b = secondString[j - 1];
        generated.add(
          LcsEvent(
            type: LcsEventType.compare,
            dp: _copyDp(dp),
            row: i,
            column: j,
            firstString: firstString,
            secondString: secondString,
            lcs: built,
            pathCells: {...path},
            title: 'Compare Characters',
            description: 'Compare "$a" with "$b".',
            operation: 'a[${i - 1}] == b[${j - 1}] ?',
          ),
        );
        if (a == b) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
          generated.add(
            LcsEvent(
              type: LcsEventType.match,
              dp: _copyDp(dp),
              row: i,
              column: j,
              firstString: firstString,
              secondString: secondString,
              lcs: built,
              pathCells: {...path},
              title: 'Characters Match',
              description:
                  '"$a" matches "$b". Use the diagonal value plus one.',
              operation:
                  'dp[$i][$j] = dp[${i - 1}][${j - 1}] + 1 = ${dp[i][j]}',
            ),
          );
        } else {
          dp[i][j] = max(dp[i - 1][j], dp[i][j - 1]);
          final source = dp[i - 1][j] >= dp[i][j - 1] ? 'top' : 'left';
          generated.add(
            LcsEvent(
              type: LcsEventType.choose,
              dp: _copyDp(dp),
              row: i,
              column: j,
              firstString: firstString,
              secondString: secondString,
              lcs: built,
              pathCells: {...path},
              title: 'Choose Larger Subproblem',
              description:
                  'Characters differ. Keep the larger value from the $source cell.',
              operation:
                  'dp[$i][$j] = max(${dp[i - 1][j]}, ${dp[i][j - 1]}) = ${dp[i][j]}',
            ),
          );
        }
      }
    }
    int i = m, j = n;
    final reversed = <String>[];
    while (i > 0 && j > 0) {
      if (firstString[i - 1] == secondString[j - 1]) {
        reversed.add(firstString[i - 1]);
        path = {...path, '$i:$j'};
        built = reversed.reversed.join();
        generated.add(
          LcsEvent(
            type: LcsEventType.backtrack,
            dp: _copyDp(dp),
            row: i,
            column: j,
            firstString: firstString,
            secondString: secondString,
            lcs: built,
            pathCells: {...path},
            title: 'Backtrack Match',
            description: 'Take "${firstString[i - 1]}" and move diagonally.',
            operation: 'result += ${firstString[i - 1]}; i--; j--;',
          ),
        );
        i--;
        j--;
      } else if (dp[i - 1][j] >= dp[i][j - 1]) {
        generated.add(
          LcsEvent(
            type: LcsEventType.backtrack,
            dp: _copyDp(dp),
            row: i,
            column: j,
            firstString: firstString,
            secondString: secondString,
            lcs: built,
            pathCells: {...path},
            title: 'Backtrack Up',
            description: 'Move up because the top cell is larger or equal.',
            operation: 'i--',
          ),
        );
        i--;
      } else {
        generated.add(
          LcsEvent(
            type: LcsEventType.backtrack,
            dp: _copyDp(dp),
            row: i,
            column: j,
            firstString: firstString,
            secondString: secondString,
            lcs: built,
            pathCells: {...path},
            title: 'Backtrack Left',
            description: 'Move left because the left cell is larger.',
            operation: 'j--',
          ),
        );
        j--;
      }
    }
    final finalLcs = reversed.reversed.join();
    generated.add(
      LcsEvent(
        type: LcsEventType.complete,
        dp: _copyDp(dp),
        row: -1,
        column: -1,
        firstString: firstString,
        secondString: secondString,
        lcs: finalLcs,
        pathCells: {...path},
        title: 'LCS Complete',
        description:
            'The table is complete and the subsequence has been reconstructed.',
        operation: 'LCS = "$finalLcs" (length ${finalLcs.length})',
      ),
    );
    events = generated;
    dpTable = List.generate(m + 1, (_) => List.filled(n + 1, 0));
    lcsResult = '';
    pathCells.clear();
  }

  void _applyEvent(LcsEvent event, {bool updateState = true}) {
    dpTable = _copyDp(event.dp);
    currentRow = event.row;
    currentColumn = event.column;
    lcsResult = event.lcs;
    pathCells = {...event.pathCells};
    executionMessage = '${event.title}: ${event.description}';
    activeCodeLine = _codeLineForEvent(event.type);
    if (event.type == LcsEventType.complete) {
      currentRow = -1;
      currentColumn = -1;
      executionMessage =
          'LCS Complete: "$lcsResult" with length ${lcsResult.length}.';
    }
    if (updateState) setState(() {});
  }

  void _rebuildVisualState() {
    dpTable = List.generate(
      firstString.length + 1,
      (_) => List.filled(secondString.length + 1, 0),
    );
    currentRow = -1;
    currentColumn = -1;
    activeCodeLine = 0;
    pathCells.clear();
    lcsResult = '';
    executionMessage =
        'Ready to start the Longest Common Subsequence Algorithm.';
    for (final event in executionHistory) {
      _applyEvent(event, updateState: false);
    }
  }

  void _reset() {
    timer?.cancel();
    setState(() {
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      currentRow = -1;
      currentColumn = -1;
      activeCodeLine = 0;
      pathCells.clear();
      lcsResult = '';
      dpTable = List.generate(
        firstString.length + 1,
        (_) => List.filled(secondString.length + 1, 0),
      );
      executionMessage =
          'Ready to start the Longest Common Subsequence Algorithm.';
    });
    _generateEvents();
  }

  void _setSpeed(double value) {
    setState(() => speed = value);
    if (isRunning) _play();
  }

  int _codeLineForEvent(LcsEventType type) {
    switch (type) {
      case LcsEventType.initialize:
        return 2;
      case LcsEventType.compare:
        return 7;
      case LcsEventType.match:
        return 8;
      case LcsEventType.choose:
        return 10;
      case LcsEventType.backtrack:
        return 16;
      case LcsEventType.complete:
        return 31;
    }
  }

  Color _eventColor(LcsEventType type) {
    switch (type) {
      case LcsEventType.initialize:
        return blue;
      case LcsEventType.compare:
        return orange;
      case LcsEventType.match:
        return green;
      case LcsEventType.choose:
        return purple;
      case LcsEventType.backtrack:
        return cyan;
      case LcsEventType.complete:
        return green;
    }
  }

  IconData _eventIcon(LcsEventType type) {
    switch (type) {
      case LcsEventType.initialize:
        return Icons.play_arrow_rounded;
      case LcsEventType.compare:
        return Icons.compare_arrows_rounded;
      case LcsEventType.match:
        return Icons.check_rounded;
      case LcsEventType.choose:
        return Icons.call_split_rounded;
      case LcsEventType.backtrack:
        return Icons.route_rounded;
      case LcsEventType.complete:
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
        backgroundColor: color.withValues(alpha: .85),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _validString(String value) =>
      value.trim().isNotEmpty && value.trim().length <= 12;
  void _loadArray() {
    final a = firstStringController.text.trim(),
        b = secondStringController.text.trim();
    if (!_validString(a) || !_validString(b)) {
      _showSnackBar('Enter two non-empty strings of up to 12 characters.', red);
      return;
    }
    timer?.cancel();
    setState(() {
      firstString = a;
      secondString = b;
      originalFirst = a;
      originalSecond = b;
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      currentRow = -1;
      currentColumn = -1;
      activeCodeLine = 0;
      pathCells.clear();
      lcsResult = '';
      dpTable = List.generate(
        a.length + 1,
        (_) => List.filled(b.length + 1, 0),
      );
      executionMessage = 'Strings loaded. Ready to build the LCS table.';
    });
    _generateEvents();
    _showSnackBar('Strings loaded successfully.', green);
  }

  void _generateNumbers() {
    const samples = [
      ['ABCBDAB', 'BDCABA'],
      ['AGGTAB', 'GXTXAYB'],
      ['XMJYAUZ', 'MZJAWXU'],
      ['BANANA', 'ATANA'],
      ['HELLO', 'YELLOW'],
    ];
    final pair = samples[Random().nextInt(samples.length)];
    firstStringController.text = pair[0];
    secondStringController.text = pair[1];
    timer?.cancel();
    setState(() {
      firstString = pair[0];
      secondString = pair[1];
      originalFirst = pair[0];
      originalSecond = pair[1];
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      currentRow = -1;
      currentColumn = -1;
      activeCodeLine = 0;
      pathCells.clear();
      lcsResult = '';
      dpTable = List.generate(
        firstString.length + 1,
        (_) => List.filled(secondString.length + 1, 0),
      );
      executionMessage = 'New string pair generated. Ready to find the LCS.';
    });
    _generateEvents();
    _showSnackBar('New string pair generated.', purple);
  }

  void _play() {
    if (events.isEmpty || isCompleted) return;
    timer?.cancel();
    setState(() => isRunning = true);
    final ms = (900 / speed).round().clamp(100, 2000);
    timer = Timer.periodic(Duration(milliseconds: ms), (_) {
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
    if (currentStep < events.length) _nextStepInternal();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
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
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: background2,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: cyan.withValues(alpha: .16)),
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
            gradient: const LinearGradient(colors: [purple, cyan]),
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
                'Longest Common Subsequence (LCS) Algorithm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Dynamic programming table + backtracking visualization',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .55),
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

  Widget _statusBadge() {
    final color = isRunning
        ? orange
        : isCompleted
        ? green
        : cyan;
    final text = isRunning
        ? 'RUNNING'
        : isCompleted
        ? 'LCS COMPLETE'
        : 'READY';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .35)),
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
              letterSpacing: .6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlgorithmInfo() => _card(
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
          'LCS finds the longest sequence that appears in both strings in the same order, using dynamic programming.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .64),
            height: 1.5,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _infoBox('Time', 'O(m × n)', orange),
            _infoBox('Space', 'O(m × n)', blue),
            _infoBox('Type', 'Dynamic Programming', purple),
            _infoBox('Method', 'DP + Backtracking', green),
            _infoBox('Input', 'Two Strings', red),
            _infoBox('Result', 'LCS String', cyan),
          ],
        ),
      ],
    ),
  );

  Widget _buildInputSection() => _card(
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
                  _inputField(
                    'First String',
                    firstStringController,
                    Icons.text_fields_rounded,
                  ),
                  const SizedBox(height: 10),
                  _inputField(
                    'Second String',
                    secondStringController,
                    Icons.text_format_rounded,
                  ),
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
                Expanded(
                  child: _inputField(
                    'First String',
                    firstStringController,
                    Icons.text_fields_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _inputField(
                    'Second String',
                    secondStringController,
                    Icons.text_format_rounded,
                  ),
                ),
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
            Icon(Icons.lightbulb_outline_rounded, color: orange, size: 15),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                'Use letters or short strings up to 12 characters for a clear DP visualization.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: .45),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _inputField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) => TextField(
    controller: controller,
    style: const TextStyle(color: Colors.white, fontSize: 13),
    cursorColor: cyan,
    decoration: InputDecoration(
      labelText: label,
      hintText: 'ABCBDAB',
      labelStyle: TextStyle(
        color: Colors.white.withValues(alpha: .58),
        fontSize: 12,
      ),
      hintStyle: TextStyle(
        color: Colors.white.withValues(alpha: .25),
        fontSize: 12,
      ),
      prefixIcon: Icon(icon, color: cyan.withValues(alpha: .8), size: 19),
      filled: true,
      fillColor: visualizationColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: .08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: cyan.withValues(alpha: .55)),
      ),
    ),
  );

  Widget _generateButton() => ElevatedButton.icon(
    onPressed: _generateNumbers,
    icon: const Icon(Icons.auto_awesome_rounded, size: 17),
    label: const Text(
      'Generate Strings',
      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: purple,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    ),
  );
  Widget _loadButton() => ElevatedButton.icon(
    onPressed: _loadArray,
    icon: const Icon(Icons.download_rounded, size: 17),
    label: const Text(
      'Load Input',
      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
    ),
    style: ElevatedButton.styleFrom(
      backgroundColor: cyan.withValues(alpha: .14),
      foregroundColor: cyan,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
    ),
  );

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

  Widget _buildVisualization() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          Icons.grid_on_rounded,
          'LCS Dynamic Programming Table',
          cyan,
        ),
        const SizedBox(height: 8),
        Text(
          'Rows represent prefixes of the first string; columns represent prefixes of the second string.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .48),
            fontSize: 10.5,
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildDpTable(),
        ),
        const SizedBox(height: 14),
        _buildLegend(),
        const SizedBox(height: 12),
        _buildCurrentInfo(),
        const SizedBox(height: 12),
        _buildStatusCard(),
      ],
    ),
  );

  Widget _buildDpTable() {
    final cols = dpTable.isEmpty ? 0 : dpTable.first.length;
    return Column(
      children: [
        Row(
          children: [
            _tableCell('', header: true),
            _tableCell('', header: true),
            for (int j = 0; j < secondString.length; j++)
              _tableCell(secondString[j], header: true, charHeader: true),
          ],
        ),
        for (int i = 0; i < dpTable.length; i++)
          Row(
            children: [
              _tableCell(
                i == 0 ? '' : firstString[i - 1],
                header: true,
                charHeader: i != 0,
              ),
              for (int j = 0; j < cols; j++) _dpCell(i, j),
            ],
          ),
      ],
    );
  }

  Widget _tableCell(
    String value, {
    bool header = false,
    bool charHeader = false,
  }) => Container(
    width: 44,
    height: 40,
    margin: const EdgeInsets.all(2),
    decoration: BoxDecoration(
      color: header ? background2 : cardColor,
      borderRadius: BorderRadius.circular(7),
      border: Border.all(
        color: header
            ? cyan.withValues(alpha: .18)
            : Colors.white.withValues(alpha: .07),
      ),
    ),
    child: Center(
      child: Text(
        value,
        style: TextStyle(
          color: charHeader ? orange : Colors.white.withValues(alpha: .38),
          fontSize: charHeader ? 14 : 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );

  Widget _dpCell(int row, int column) {
    final active = row == currentRow && column == currentColumn;
    final path = pathCells.contains('$row:$column');
    final color = active
        ? cyan
        : path
        ? green
        : Colors.white;
    return Container(
      width: 44,
      height: 40,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: active
            ? cyan.withValues(alpha: .16)
            : path
            ? green.withValues(alpha: .10)
            : cardColor,
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: active
              ? cyan
              : path
              ? green.withValues(alpha: .55)
              : Colors.white.withValues(alpha: .07),
        ),
      ),
      child: Center(
        child: Text(
          '${dpTable[row][column]}',
          style: TextStyle(
            color: color.withValues(alpha: active || path ? 1 : .78),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() => Wrap(
    spacing: 12,
    runSpacing: 8,
    children: [
      _legendItem('Current Cell', cyan),
      _legendItem('LCS Path', green),
      _legendItem('Character Compare', orange),
      _legendItem('First String', blue),
      _legendItem('Second String', purple),
    ],
  );
  Widget _legendItem(String title, Color color) => Row(
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
          color: Colors.white.withValues(alpha: .58),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Widget _buildCurrentInfo() {
    final message = currentRow > 0 && currentColumn > 0
        ? 'Compare ${firstString[currentRow - 1]} with ${secondString[currentColumn - 1]} → DP[$currentRow][$currentColumn] = ${dpTable[currentRow][currentColumn]}'
        : isCompleted
        ? 'LCS = "$lcsResult"  •  Length = ${lcsResult.length}'
        : 'Press Next Step or Play to build the DP table.';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: visualizationColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cyan.withValues(alpha: .12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: cyan, size: 17),
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
    final color = isRunning
        ? orange
        : isCompleted
        ? green
        : cyan;
    final icon = isRunning
        ? Icons.play_circle_rounded
        : isCompleted
        ? Icons.check_circle_rounded
        : Icons.info_outline_rounded;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: .18)),
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
                color: Colors.white.withValues(alpha: .72),
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: .065)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .18),
          blurRadius: 16,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: child,
  );
  Widget _sectionTitle(IconData icon, String title, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
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
  Widget _infoBox(String title, String value, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .055),
      borderRadius: BorderRadius.circular(9),
      border: Border.all(color: color.withValues(alpha: .16)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color.withValues(alpha: .8),
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

  Widget _executionStepItem(int index, LcsEvent event) {
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
}
