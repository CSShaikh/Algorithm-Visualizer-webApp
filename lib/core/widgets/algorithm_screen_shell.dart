import 'package:flutter/material.dart';

/// Shared responsive structure used by every algorithm visualizer screen.
///
/// Each algorithm keeps its own implementation, visualization and controls in
/// its single screen file. This widget only owns the common page arrangement.
class AlgorithmScreenShell extends StatelessWidget {
  const AlgorithmScreenShell({
    super.key,
    required this.header,
    required this.algorithmInfo,
    required this.inputSection,
    required this.visualization,
    required this.controls,
    required this.sourceCode,
    required this.executionSteps,
    this.additionalContent,
    this.maxWidth = 1500,
  });

  final Widget header;
  final Widget algorithmInfo;
  final Widget inputSection;
  final Widget visualization;
  final Widget controls;
  final Widget sourceCode;
  final Widget executionSteps;
  final Widget? additionalContent;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final horizontalPadding = width < 600 ? 12.0 : 18.0;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              width < 600 ? 10 : 16,
              horizontalPadding,
              width < 600 ? 24 : 30,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    header,
                    const SizedBox(height: 14),
                    algorithmInfo,
                    const SizedBox(height: 14),
                    inputSection,
                    if (additionalContent != null) ...[
                      const SizedBox(height: 14),
                      additionalContent!,
                    ],
                    const SizedBox(height: 14),
                    _workspace(width),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _workspace(double width) {
    final compact = width < 950;

    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          visualization,
          const SizedBox(height: 14),
          controls,
          const SizedBox(height: 14),
          sourceCode,
          const SizedBox(height: 14),
          executionSteps,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              visualization,
              const SizedBox(height: 14),
              controls,
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              sourceCode,
              const SizedBox(height: 14),
              executionSteps,
            ],
          ),
        ),
      ],
    );
  }
}
