import 'package:flutter/material.dart';

/// Category of an algorithm available in the application.
enum AlgorithmCategory {
  searching,
  sorting,
  trees,
  graphs,
}

/// Availability state of an algorithm.
enum AlgorithmStatus {
  implemented,
  comingSoon,
}

/// Immutable definition of an algorithm.
///
/// This model contains only metadata. Actual algorithm implementation
/// and visualization logic will remain outside this model.
class Algorithm {
  final String id;
  final String title;
  final String description;
  final String complexity;
  final String categoryLabel;
  final AlgorithmCategory category;
  final Color color;
  final IconData icon;
  final String difficulty;
  final AlgorithmStatus status;

  const Algorithm({
    required this.id,
    required this.title,
    required this.description,
    required this.complexity,
    required this.categoryLabel,
    required this.category,
    required this.color,
    required this.icon,
    required this.difficulty,
    required this.status,
  });

  bool get isImplemented => status == AlgorithmStatus.implemented;

  bool get isComingSoon => status == AlgorithmStatus.comingSoon;
}