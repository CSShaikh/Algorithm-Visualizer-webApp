import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LinearRegressionScreen extends StatefulWidget {
  const LinearRegressionScreen({super.key});
  @override
  State<LinearRegressionScreen> createState() => _LinearRegressionScreenState();
}

enum LinearRegressionEventType {
  initialize,
  mean,
  slope,
  intercept,
  predict,
  residual,
  complete,
}

class LinearRegressionEvent {
  final LinearRegressionEventType type;
  final List<double> x;
  final List<double> y;
  final double meanX;
  final double meanY;
  final double slope;
  final double intercept;
  final int currentIndex;
  final double prediction;
  final double residual;
  final String title;
  final String description;
  final String operation;
  const LinearRegressionEvent({
    required this.type,
    required this.x,
    required this.y,
    required this.meanX,
    required this.meanY,
    required this.slope,
    required this.intercept,
    required this.currentIndex,
    required this.prediction,
    required this.residual,
    required this.title,
    required this.description,
    required this.operation,
  });
}

class _LinearRegressionScreenState extends State<LinearRegressionScreen> {
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

  List<double> xValues = [1, 2, 3, 4, 5, 6];
  List<double> yValues = [2, 4, 5, 4, 5, 7];
  final xController = TextEditingController(text: '1, 2, 3, 4, 5, 6');
  final yController = TextEditingController(text: '2, 4, 5, 4, 5, 7');
  List<LinearRegressionEvent> events = [];
  List<LinearRegressionEvent> executionHistory = [];
  int currentStep = 0;
  bool isRunning = false;
  bool isCompleted = false;
  double speed = 1.0;
  Timer? timer;
  double meanX = 0,
      meanY = 0,
      slope = 0,
      intercept = 0,
      prediction = 0,
      residual = 0;
  int currentIndex = -1, activeCodeLine = 0;
  String equation = '';
  String executionMessage = 'Ready to start the Linear Regression Algorithm.';

  final String sourceCode = '''
LinearRegression fit(List<double> x, List<double> y) {
  final n = x.length;
  final meanX = x.reduce((a, b) => a + b) / n;
  final meanY = y.reduce((a, b) => a + b) / n;

  double numerator = 0;
  double denominator = 0;
  for (int i = 0; i < n; i++) {
    numerator += (x[i] - meanX) * (y[i] - meanY);
    denominator += pow(x[i] - meanX, 2);
  }

  final slope = numerator / denominator;
  final intercept = meanY - slope * meanX;
  return LinearRegression(slope, intercept);
}

final prediction = intercept + slope * x;
final residual = y - prediction;
''';

  @override
  void initState() {
    super.initState();
    _generateEvents();
  }

  @override
  void dispose() {
    timer?.cancel();
    xController.dispose();
    yController.dispose();
    super.dispose();
  }

  List<double> _copy(List<double> v) => [...v];
  String _fmt(double v) => v.abs() < 0.00005 ? '0' : v.toStringAsFixed(2);

  void _generateEvents() {
    final generated = <LinearRegressionEvent>[];
    final n = xValues.length;
    final mx = (xValues.reduce((a, b) => a + b) / n).toDouble();
    final my = (yValues.reduce((a, b) => a + b) / n).toDouble();
    double nume = 0, deno = 0;
    generated.add(
      LinearRegressionEvent(
        type: LinearRegressionEventType.initialize,
        x: _copy(xValues),
        y: _copy(yValues),
        meanX: 0,
        meanY: 0,
        slope: 0,
        intercept: 0,
        currentIndex: -1,
        prediction: 0,
        residual: 0,
        title: 'Regression Initialized',
        description:
            'Load paired training samples and prepare the least-squares calculation.',
        operation: 'n = $n paired samples',
      ),
    );
    generated.add(
      LinearRegressionEvent(
        type: LinearRegressionEventType.mean,
        x: _copy(xValues),
        y: _copy(yValues),
        meanX: mx,
        meanY: my,
        slope: 0,
        intercept: 0,
        currentIndex: -1,
        prediction: 0,
        residual: 0,
        title: 'Calculate Means',
        description:
            'Calculate the average input and output values used by the least-squares formula.',
        operation: 'meanX = ${_fmt(mx)}, meanY = ${_fmt(my)}',
      ),
    );
    for (int i = 0; i < n; i++) {
      nume += (xValues[i] - mx) * (yValues[i] - my);
      deno += pow(xValues[i] - mx, 2).toDouble();
      generated.add(
        LinearRegressionEvent(
          type: LinearRegressionEventType.slope,
          x: _copy(xValues),
          y: _copy(yValues),
          meanX: mx,
          meanY: my,
          slope: deno == 0 ? 0.0 : (nume / deno).toDouble(),
          intercept: 0,
          currentIndex: i,
          prediction: 0,
          residual: 0,
          title: 'Build Slope',
          description:
              'Accumulate the covariance numerator and variance denominator for sample $i.',
          operation:
              'numerator += (${_fmt(xValues[i])}-${_fmt(mx)}) × (${_fmt(yValues[i])}-${_fmt(my)})',
        ),
      );
    }
    final m = deno == 0 ? 0.0 : (nume / deno).toDouble();
    final b = (my - m * mx).toDouble();
    generated.add(
      LinearRegressionEvent(
        type: LinearRegressionEventType.intercept,
        x: _copy(xValues),
        y: _copy(yValues),
        meanX: mx,
        meanY: my,
        slope: m,
        intercept: b,
        currentIndex: -1,
        prediction: 0,
        residual: 0,
        title: 'Calculate Intercept',
        description: 'Use the mean point to calculate the y-intercept.',
        operation: 'b = meanY - slope × meanX = ${_fmt(b)}',
      ),
    );
    for (int i = 0; i < n; i++) {
      final pred = (b + m * xValues[i]).toDouble();
      generated.add(
        LinearRegressionEvent(
          type: LinearRegressionEventType.predict,
          x: _copy(xValues),
          y: _copy(yValues),
          meanX: mx,
          meanY: my,
          slope: m,
          intercept: b,
          currentIndex: i,
          prediction: pred,
          residual: 0,
          title: 'Predict Value',
          description:
              'Use the fitted line to predict y for the current x value.',
          operation:
              'ŷ = ${_fmt(b)} + ${_fmt(m)} × ${_fmt(xValues[i])} = ${_fmt(pred)}',
        ),
      );
      generated.add(
        LinearRegressionEvent(
          type: LinearRegressionEventType.residual,
          x: _copy(xValues),
          y: _copy(yValues),
          meanX: mx,
          meanY: my,
          slope: m,
          intercept: b,
          currentIndex: i,
          prediction: pred,
          residual: (yValues[i] - pred).toDouble(),
          title: 'Calculate Residual',
          description:
              'Measure the vertical error between the observed point and the regression line.',
          operation:
              'residual = ${_fmt(yValues[i])} - ${_fmt(pred)} = ${_fmt(yValues[i] - pred)}',
        ),
      );
    }
    generated.add(
      LinearRegressionEvent(
        type: LinearRegressionEventType.complete,
        x: _copy(xValues),
        y: _copy(yValues),
        meanX: mx,
        meanY: my,
        slope: m,
        intercept: b,
        currentIndex: -1,
        prediction: 0,
        residual: 0,
        title: 'Regression Complete',
        description: 'The least-squares line is fitted to the training data.',
        operation: 'ŷ = ${_fmt(b)} ${m >= 0 ? '+' : '-'} ${_fmt(m.abs())}x',
      ),
    );
    events = generated;
    meanX = 0;
    meanY = 0;
    slope = 0;
    intercept = 0;
    prediction = 0;
    residual = 0;
    currentIndex = -1;
    equation = '';
    activeCodeLine = 0;
  }

  void _applyEvent(LinearRegressionEvent e, {bool updateState = true}) {
    meanX = e.meanX;
    meanY = e.meanY;
    slope = e.slope;
    intercept = e.intercept;
    currentIndex = e.currentIndex;
    prediction = e.prediction;
    residual = e.residual;
    equation = e.intercept == 0 && e.slope == 0
        ? ''
        : 'ŷ = ${_fmt(e.intercept)} ${e.slope >= 0 ? '+' : '-'} ${_fmt(e.slope.abs())}x';
    activeCodeLine = _codeLineForEvent(e.type);
    executionMessage = '${e.title}: ${e.description}';
    if (e.type == LinearRegressionEventType.complete) {
      currentIndex = -1;
      executionMessage = 'Regression Complete: $equation';
    }
    if (updateState) {
      setState(() {});
    }
  }

  void _rebuildVisualState() {
    meanX = 0;
    meanY = 0;
    slope = 0;
    intercept = 0;
    prediction = 0;
    residual = 0;
    currentIndex = -1;
    equation = '';
    activeCodeLine = 0;
    executionMessage = 'Ready to start the Linear Regression Algorithm.';
    for (final e in executionHistory) {
      _applyEvent(e, updateState: false);
    }
  }

  void _reset() {
    timer?.cancel();
    setState(() {
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      meanX = 0;
      meanY = 0;
      slope = 0;
      intercept = 0;
      prediction = 0;
      residual = 0;
      currentIndex = -1;
      equation = '';
      activeCodeLine = 0;
      executionMessage = 'Ready to start the Linear Regression Algorithm.';
    });
    _generateEvents();
  }

  int _codeLineForEvent(LinearRegressionEventType t) {
    switch (t) {
      case LinearRegressionEventType.initialize:
        return 2;
      case LinearRegressionEventType.mean:
        return 4;
      case LinearRegressionEventType.slope:
        return 9;
      case LinearRegressionEventType.intercept:
        return 14;
      case LinearRegressionEventType.predict:
        return 19;
      case LinearRegressionEventType.residual:
        return 20;
      case LinearRegressionEventType.complete:
        return 21;
    }
  }

  Color _eventColor(LinearRegressionEventType t) {
    switch (t) {
      case LinearRegressionEventType.initialize:
        return blue;
      case LinearRegressionEventType.mean:
        return purple;
      case LinearRegressionEventType.slope:
        return orange;
      case LinearRegressionEventType.intercept:
        return pink;
      case LinearRegressionEventType.predict:
        return cyan;
      case LinearRegressionEventType.residual:
        return red;
      case LinearRegressionEventType.complete:
        return green;
    }
  }

  IconData _eventIcon(LinearRegressionEventType t) {
    switch (t) {
      case LinearRegressionEventType.initialize:
        return Icons.play_arrow_rounded;
      case LinearRegressionEventType.mean:
        return Icons.functions_rounded;
      case LinearRegressionEventType.slope:
        return Icons.trending_up_rounded;
      case LinearRegressionEventType.intercept:
        return Icons.call_split_rounded;
      case LinearRegressionEventType.predict:
        return Icons.auto_graph_rounded;
      case LinearRegressionEventType.residual:
        return Icons.straighten_rounded;
      case LinearRegressionEventType.complete:
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

  List<double>? _parse(String text) {
    final p = text.trim().split(RegExp(r'[\s,]+'));
    if (p.length < 2 || p.length > 12) return null;
    final r = <double>[];
    for (final v in p) {
      final d = double.tryParse(v);
      if (d == null || d.abs() > 9999) return null;
      r.add(d);
    }
    return r;
  }

  void _loadData() {
    final xs = _parse(xController.text), ys = _parse(yController.text);
    if (xs == null || ys == null || xs.length != ys.length) {
      _showSnackBar(
        'Enter equal X and Y lists with 2 to 12 valid numbers.',
        red,
      );
      return;
    }
    timer?.cancel();
    setState(() {
      xValues = xs;
      yValues = ys;
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      executionMessage =
          'Training data loaded. Ready to fit the regression line.';
    });
    _generateEvents();
    _showSnackBar('Training data loaded successfully.', green);
  }

  void _generateNumbers() {
    final samples = <List<List<double>>>[
      [
        [1, 2, 3, 4, 5, 6],
        [2, 4, 5, 4, 5, 7],
      ],
      [
        [1, 2, 3, 4, 5],
        [3, 5, 7, 8, 11],
      ],
      [
        [2, 4, 6, 8, 10],
        [1, 3, 4, 7, 9],
      ],
      [
        [1, 2, 3, 4, 5, 6, 7],
        [2, 3, 5, 7, 8, 10, 11],
      ],
    ];
    final s = samples[Random().nextInt(samples.length)];
    xController.text = s[0].map(_fmt).join(', ');
    yController.text = s[1].map(_fmt).join(', ');
    xValues = [...s[0]];
    yValues = [...s[1]];
    timer?.cancel();
    setState(() {
      executionHistory.clear();
      currentStep = 0;
      isRunning = false;
      isCompleted = false;
      executionMessage = 'New training dataset generated.';
    });
    _generateEvents();
    _showSnackBar('New training dataset generated.', purple);
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
      final e = events[currentStep];
      executionHistory.add(e);
      currentStep++;
      _applyEvent(e);
      if (currentStep >= events.length) {
        timer?.cancel();
        setState(() {
          isRunning = false;
          isCompleted = true;
        });
      }
    });
  }

  void _togglePlayPause() {
    if (isRunning) {
      timer?.cancel();
      setState(() => isRunning = false);
    } else {
      _play();
    }
  }

  void _nextStep() {
    if (currentStep >= events.length) {
      return;
    }
    final e = events[currentStep];
    executionHistory.add(e);
    currentStep++;
    _applyEvent(e);
    if (currentStep >= events.length) {
      setState(() => isCompleted = true);
    }
  }

  void _previousStep() {
    if (executionHistory.isEmpty) {
      return;
    }
    executionHistory.removeLast();
    currentStep = max(0, currentStep - 1);
    setState(() => isCompleted = false);
    _rebuildVisualState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: w < 700 ? 12 : 22,
                vertical: 16,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1500),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 14),
                      _buildInfo(),
                      const SizedBox(height: 14),
                      _buildInput(),
                      const SizedBox(height: 14),
                      _buildWorkspace(w),
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

  Widget _buildHeader() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: background2,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: blue.withValues(alpha: .18)),
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
            gradient: const LinearGradient(colors: [blue, purple]),
            borderRadius: BorderRadius.circular(11),
          ),
          child: const Icon(
            Icons.model_training_rounded,
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
                'Linear Regression Algorithm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Supervised learning • least-squares best-fit line visualization',
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
    final c = isRunning
        ? orange
        : isCompleted
        ? green
        : cyan;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: .22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRunning
                ? Icons.play_circle_rounded
                : isCompleted
                ? Icons.check_circle_rounded
                : Icons.circle_outlined,
            color: c,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            isRunning
                ? 'Running'
                : isCompleted
                ? 'Completed'
                : 'Ready',
            style: TextStyle(
              color: c,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.white.withValues(alpha: .06)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .16),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: child,
  );
  Widget _sectionTitle(IconData icon, String title, Color color) => Row(
    children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 8),
      Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
  Widget _buildInfo() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          Icons.info_outline_rounded,
          'Algorithm Information',
          cyan,
        ),
        const SizedBox(height: 12),
        Text(
          'Linear Regression fits a straight line that minimizes the sum of squared residuals between observed and predicted values.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .64),
            height: 1.5,
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _infoBox('Time', 'O(n)', orange),
            _infoBox('Space', 'O(1)', blue),
            _infoBox('Type', 'Supervised Learning', purple),
            _infoBox('Method', 'Least Squares', green),
            _infoBox('Input', 'X + Y Pairs', red),
            _infoBox('Result', 'Best-fit Line', cyan),
          ],
        ),
      ],
    ),
  );
  Widget _infoBox(String a, String b, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: c.withValues(alpha: .06),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: c.withValues(alpha: .12)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          a,
          style: TextStyle(
            color: Colors.white.withValues(alpha: .42),
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          b,
          style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
  Widget _buildInput() => _card(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(Icons.input_rounded, 'Training Data', cyan),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth < 800) {
              return Column(
                children: [
                  _inputField(
                    'X values',
                    xController,
                    Icons.horizontal_rule_rounded,
                  ),
                  const SizedBox(height: 10),
                  _inputField(
                    'Y values',
                    yController,
                    Icons.vertical_align_top_rounded,
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
                    'X values',
                    xController,
                    Icons.horizontal_rule_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _inputField(
                    'Y values',
                    yController,
                    Icons.vertical_align_top_rounded,
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
        const SizedBox(height: 9),
        Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded, color: orange, size: 15),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                'Use equal-length X and Y lists with 2 to 12 numeric samples.',
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
  Widget _inputField(String label, TextEditingController c, IconData icon) =>
      TextField(
        controller: c,
        style: const TextStyle(color: Colors.white, fontSize: 12),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.white.withValues(alpha: .48),
            fontSize: 11,
          ),
          prefixIcon: Icon(icon, color: cyan, size: 17),
          filled: true,
          fillColor: visualizationColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: .06)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: .06)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            borderSide: BorderSide(color: cyan),
          ),
        ),
      );
  Widget _generateButton() => ElevatedButton.icon(
    onPressed: _generateNumbers,
    icon: const Icon(Icons.casino_rounded, size: 17),
    label: const Text('Generate Data'),
    style: ElevatedButton.styleFrom(
      backgroundColor: purple,
      foregroundColor: Colors.white,
      minimumSize: const Size(0, 46),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
  Widget _loadButton() => ElevatedButton.icon(
    onPressed: _loadData,
    icon: const Icon(Icons.upload_rounded, size: 17),
    label: const Text('Load Data'),
    style: ElevatedButton.styleFrom(
      backgroundColor: cyan,
      foregroundColor: background,
      minimumSize: const Size(0, 46),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
  Widget _buildWorkspace(double w) {
    if (w < 950) {
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
          Icons.auto_graph_rounded,
          'Linear Regression Visualization',
          cyan,
        ),
        const SizedBox(height: 7),
        Text(
          'Observed samples, fitted regression line, predictions and residuals are shown step-by-step.',
          style: TextStyle(
            color: Colors.white.withValues(alpha: .48),
            fontSize: 10.5,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 360,
          width: double.infinity,
          child: CustomPaint(
            painter: _RegressionPainter(
              x: xValues,
              y: yValues,
              slope: slope,
              intercept: intercept,
              currentIndex: currentIndex,
              prediction: prediction,
              showLine: slope != 0 || intercept != 0,
              cyan: cyan,
              green: green,
              orange: orange,
              red: red,
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildLegend(),
        const SizedBox(height: 11),
        _buildEquationCard(),
        const SizedBox(height: 11),
        _buildCurrentInfo(),
        const SizedBox(height: 11),
        _buildStatusCard(),
      ],
    ),
  );
  Widget _buildLegend() => Wrap(
    spacing: 13,
    runSpacing: 8,
    children: [
      _legendItem('Data Point', cyan),
      _legendItem('Regression Line', green),
      _legendItem('Current Sample', orange),
      _legendItem('Residual', red),
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
  Widget _buildEquationCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: visualizationColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: green.withValues(alpha: .15)),
    ),
    child: Row(
      children: [
        const Icon(Icons.functions_rounded, color: green, size: 18),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            equation.isEmpty
                ? 'Best-fit equation will appear after slope and intercept are calculated.'
                : equation,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    ),
  );
  Widget _buildCurrentInfo() {
    String m;
    if (currentIndex >= 0 && prediction != 0) {
      m = 'Sample $currentIndex: x = ${_fmt(xValues[currentIndex])}, observed y = ${_fmt(yValues[currentIndex])}, predicted y = ${_fmt(prediction)}, residual = ${_fmt(residual)}';
    } else if (isCompleted) {
      m = 'Model fitted successfully: $equation';
    } else {
      m = 'Press Next Step or Play to fit the least-squares regression line.';
    }
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
              m,
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
    final c = isRunning
        ? orange
        : isCompleted
        ? green
        : cyan;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: c.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withValues(alpha: .18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isRunning
                ? Icons.play_circle_rounded
                : isCompleted
                ? Icons.check_circle_rounded
                : Icons.info_outline_rounded,
            color: c,
            size: 18,
          ),
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

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool primary = false,
  }) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 17),
    label: Text(label),
    style: OutlinedButton.styleFrom(
      foregroundColor: primary ? background : Colors.white,
      backgroundColor: primary ? cyan : null,
      side: BorderSide(
        color: primary ? cyan : Colors.white.withValues(alpha: .10),
      ),
      minimumSize: const Size(0, 42),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );
  Widget _buildControls() => _card(
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
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.speed_rounded, color: cyan, size: 17),
            const SizedBox(width: 8),
            Text(
              'Speed',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .55),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            Expanded(
              child: Slider(
                value: speed,
                min: .5,
                max: 3,
                divisions: 5,
                activeColor: cyan,
                inactiveColor: Colors.white.withValues(alpha: .08),
                onChanged: (v) {
                  setState(() => speed = v);
                  if (isRunning) _play();
                },
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
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: events.isEmpty ? 0 : currentStep / events.length,
            minHeight: 4,
            backgroundColor: Colors.white.withValues(alpha: .06),
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
                color: Colors.white.withValues(alpha: .45),
                fontSize: 10,
              ),
            ),
            Text(
              isCompleted
                  ? 'Execution Finished'
                  : isRunning
                  ? 'Running'
                  : 'Ready',
              style: TextStyle(
                color: isCompleted ? green : cyan,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    ),
  );
  Widget _buildSourceCode() {
    final lines = sourceCode.trim().split('\n');
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _sectionTitle(Icons.code_rounded, 'Source Code', purple),
              const Spacer(),
              IconButton(
                onPressed: _copyCode,
                icon: const Icon(Icons.copy_rounded, color: cyan, size: 17),
                tooltip: 'Copy code',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 370,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: visualizationColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(lines.length, (i) {
                  final line = lines[i];
                  final active = activeCodeLine == i + 1;
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: active
                          ? cyan.withValues(alpha: .08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 25,
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: active
                                  ? cyan
                                  : Colors.white.withValues(alpha: .24),
                              fontSize: 9,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            line,
                            style: TextStyle(
                              color: active
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: .58),
                              fontSize: 9.5,
                              fontFamily: 'monospace',
                              height: 1.35,
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
          _sectionTitle(Icons.timeline_rounded, 'Execution Steps', orange),
          const SizedBox(height: 10),
          if (executionHistory.isEmpty)
            Text(
              'No steps executed yet. Use Play or Next Step.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .42),
                fontSize: 11,
              ),
            )
          else
            SizedBox(
              height: 420,
              child: ListView.builder(
                itemCount: executionHistory.length,
                itemBuilder: (context, i) {
                  final e = executionHistory[i];
                  final c = _eventColor(e.type);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 7),
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: .045),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: c.withValues(alpha: .12)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(_eventIcon(e.type), color: c, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${i + 1}. ${e.title}',
                                style: TextStyle(
                                  color: c,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                e.description,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .58),
                                  fontSize: 9.5,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                e.operation,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: .38),
                                  fontSize: 9,
                                  fontFamily: 'monospace',
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
}

class _RegressionPainter extends CustomPainter {
  final List<double> x, y;
  final double slope, intercept, prediction;
  final int currentIndex;
  final bool showLine;
  final Color cyan, green, orange, red;

  _RegressionPainter({
    required this.x,
    required this.y,
    required this.slope,
    required this.intercept,
    required this.currentIndex,
    required this.prediction,
    required this.showLine,
    required this.cyan,
    required this.green,
    required this.orange,
    required this.red,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (x.isEmpty || y.isEmpty) return;

    final minXData = x.reduce(min);
    final maxXData = x.reduce(max);
    final xRange = (maxXData - minXData).abs();
    final xPad = xRange < 0.001 ? 1.0 : xRange * 0.12;
    final minX = minXData - xPad;
    final maxX = maxXData + xPad;

    final fittedMinY = intercept + slope * minX;
    final fittedMaxY = intercept + slope * maxX;

    final allY = <double>[...y];
    if (showLine) {
      allY.add(fittedMinY);
      allY.add(fittedMaxY);
    }
    if (currentIndex >= 0 && currentIndex < x.length && prediction.isFinite) {
      allY.add(prediction);
    }

    var minY = allY.reduce(min);
    var maxY = allY.reduce(max);
    final yRange = (maxY - minY).abs();
    final yPad = yRange < 0.001 ? 1.0 : yRange * 0.14;
    minY -= yPad;
    maxY += yPad;

    final dx = (maxX - minX).abs() < 0.001 ? 1.0 : maxX - minX;
    final dy = (maxY - minY).abs() < 0.001 ? 1.0 : maxY - minY;

    const left = 48.0;
    const right = 18.0;
    const top = 22.0;
    const bottom = 38.0;
    final plot = Rect.fromLTRB(
      left,
      top,
      size.width - right,
      size.height - bottom,
    );

    Offset map(double xv, double yv) => Offset(
      plot.left + (xv - minX) / dx * plot.width,
      plot.bottom - (yv - minY) / dy * plot.height,
    );

    final grid = Paint()
      ..color = Colors.white.withValues(alpha: .055)
      ..strokeWidth = 1;

    final labelStyle = TextStyle(
      color: Colors.white.withValues(alpha: .38),
      fontSize: 9,
      fontWeight: FontWeight.w600,
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i <= 4; i++) {
      final ratio = i / 4;
      final xx = plot.left + ratio * plot.width;
      final yy = plot.bottom - ratio * plot.height;

      canvas.drawLine(Offset(xx, plot.top), Offset(xx, plot.bottom), grid);
      canvas.drawLine(Offset(plot.left, yy), Offset(plot.right, yy), grid);

      textPainter.text = TextSpan(
        text: _axisNumber(minX + ratio * dx),
        style: labelStyle,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(xx - textPainter.width / 2, plot.bottom + 8),
      );

      textPainter.text = TextSpan(
        text: _axisNumber(minY + ratio * dy),
        style: labelStyle,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(plot.left - textPainter.width - 8, yy - textPainter.height / 2),
      );
    }

    final axis = Paint()
      ..color = Colors.white.withValues(alpha: .18)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(plot.left, plot.bottom),
      Offset(plot.right, plot.bottom),
      axis,
    );
    canvas.drawLine(
      Offset(plot.left, plot.top),
      Offset(plot.left, plot.bottom),
      axis,
    );

    if (showLine) {
      final line = Paint()
        ..color = green
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(map(minX, fittedMinY), map(maxX, fittedMaxY), line);
    }

    for (int i = 0; i < x.length; i++) {
      final observed = map(x[i], y[i]);

      if (i == currentIndex && prediction.isFinite) {
        final predicted = map(x[i], prediction);
        final residualPaint = Paint()
          ..color = red.withValues(alpha: .85)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(observed, predicted, residualPaint);

        final predictionPaint = Paint()..color = red;
        canvas.drawCircle(predicted, 4.5, predictionPaint);
      }

      final pointPaint = Paint()..color = i == currentIndex ? orange : cyan;
      canvas.drawCircle(observed, i == currentIndex ? 7 : 5, pointPaint);
    }

    textPainter.text = TextSpan(text: 'X', style: labelStyle);
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(plot.right - textPainter.width, plot.bottom + 22),
    );

    textPainter.text = TextSpan(text: 'Y', style: labelStyle);
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(plot.left - textPainter.width - 22, plot.top - 2),
    );
  }

  String _axisNumber(double value) {
    if (value.abs() < 0.0001) return '0';
    if ((value - value.roundToDouble()).abs() < 0.0001) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  @override
  bool shouldRepaint(covariant _RegressionPainter old) =>
      old.slope != slope ||
      old.intercept != intercept ||
      old.currentIndex != currentIndex ||
      old.prediction != prediction ||
      old.x != x ||
      old.y != y;
}
