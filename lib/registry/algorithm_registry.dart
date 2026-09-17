import 'package:flutter/material.dart';

import '../algorithms/graph_algorithms/dijkstra_screen.dart';
import '../algorithms/graph_algorithms/bfs_screen.dart';
import '../algorithms/graph_algorithms/dfs_screen.dart';
import '../algorithms/tree_algorithms/level_order_traversal_screen.dart';
import '../algorithms/tree_algorithms/binary_tree_screen.dart';
import '../algorithms/tree_algorithms/binary_search_tree_screen.dart';
import '../algorithms/searching_algorithms/binary_search_screen.dart';
import '../algorithms/searching_algorithms/interpolation_search_screen.dart';
import '../algorithms/searching_algorithms/jump_search_screen.dart';
import '../algorithms/searching_algorithms/linear_search_screen.dart';
import '../algorithms/sorting_algorithms/bubble_sort_screen.dart';
import '../algorithms/sorting_algorithms/heap_sort_screen.dart';
import '../algorithms/sorting_algorithms/insertion_sort_screen.dart';
import '../algorithms/sorting_algorithms/merge_sort_screen.dart';
import '../algorithms/sorting_algorithms/quick_sort_screen.dart';
import '../algorithms/sorting_algorithms/selection_sort_screen.dart';
import '../algorithms/tree_algorithms/inorder_traversal_screen.dart';
import '../algorithms/tree_algorithms/postorder_traversal_screen.dart';
import '../algorithms/tree_algorithms/preorder_traversal_screen.dart';

import '../models/algorithm.dart';
import '../core/theme/app_colors.dart';

/// Central registry of all algorithms known to the application.
///
/// The registry is the single source of truth for:
/// - algorithm metadata
/// - category
/// - complexity
/// - difficulty
/// - availability
/// - screen creation
///
/// New algorithms should eventually be added here instead of adding
/// another long if/else chain inside the dashboard.
abstract final class AlgorithmRegistry {
  AlgorithmRegistry._();

  // ---------------------------------------------------------------------------
  // ALL ALGORITHMS
  // ---------------------------------------------------------------------------

  static const List<Algorithm> all = [
    // -------------------------------------------------------------------------
    // SEARCHING
    // -------------------------------------------------------------------------

    Algorithm(
      id: 'linear-search',
      title: 'Linear Search',
      description:
          'Searches elements one by one until the required value is found.',
      complexity: 'O(n)',
      categoryLabel: 'Searching',
      category: AlgorithmCategory.searching,
      color: AppColors.cyan,
      icon: Icons.search_rounded,
      difficulty: 'Easy',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'binary-search',
      title: 'Binary Search',
      description:
          'Searches sorted data by repeatedly dividing the search space.',
      complexity: 'O(log n)',
      categoryLabel: 'Searching',
      category: AlgorithmCategory.searching,
      color: AppColors.cyan,
      icon: Icons.manage_search_rounded,
      difficulty: 'Easy',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'jump-search',
      title: 'Jump Search',
      description:
          'Jumps through sorted blocks and performs linear search locally.',
      complexity: 'O(√n)',
      categoryLabel: 'Searching',
      category: AlgorithmCategory.searching,
      color: AppColors.green,
      icon: Icons.double_arrow_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'interpolation-search',
      title: 'Interpolation Search',
      description:
          'Estimates the position of a value in uniformly distributed sorted data.',
      complexity: 'O(log log n)',
      categoryLabel: 'Searching',
      category: AlgorithmCategory.searching,
      color: AppColors.blue,
      icon: Icons.my_location_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),

    // -------------------------------------------------------------------------
    // SORTING
    // -------------------------------------------------------------------------

    Algorithm(
      id: 'bubble-sort',
      title: 'Bubble Sort',
      description:
          'Repeatedly compares adjacent elements and swaps them.',
      complexity: 'O(n²)',
      categoryLabel: 'Sorting',
      category: AlgorithmCategory.sorting,
      color: AppColors.cyan,
      icon: Icons.swap_vert_rounded,
      difficulty: 'Easy',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'selection-sort',
      title: 'Selection Sort',
      description:
          'Selects the minimum element and places it at the correct position.',
      complexity: 'O(n²)',
      categoryLabel: 'Sorting',
      category: AlgorithmCategory.sorting,
      color: AppColors.blue,
      icon: Icons.select_all_rounded,
      difficulty: 'Easy',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'insertion-sort',
      title: 'Insertion Sort',
      description:
          'Builds the final sorted array one item at a time.',
      complexity: 'O(n²)',
      categoryLabel: 'Sorting',
      category: AlgorithmCategory.sorting,
      color: AppColors.orange,
      icon: Icons.input_rounded,
      difficulty: 'Easy',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'merge-sort',
      title: 'Merge Sort',
      description:
          'Divides the array into smaller parts and merges sorted parts.',
      complexity: 'O(n log n)',
      categoryLabel: 'Sorting',
      category: AlgorithmCategory.sorting,
      color: AppColors.green,
      icon: Icons.merge_type_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'quick-sort',
      title: 'Quick Sort',
      description:
          'Uses a pivot to partition elements into smaller subarrays.',
      complexity: 'O(n log n)',
      categoryLabel: 'Sorting',
      category: AlgorithmCategory.sorting,
      color: AppColors.purple,
      icon: Icons.call_split_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'heap-sort',
      title: 'Heap Sort',
      description:
          'Uses a heap data structure to efficiently sort elements.',
      complexity: 'O(n log n)',
      categoryLabel: 'Sorting',
      category: AlgorithmCategory.sorting,
      color: AppColors.pink,
      icon: Icons.account_tree_rounded,
      difficulty: 'Hard',
      status: AlgorithmStatus.implemented,
    ),

    // -------------------------------------------------------------------------
    // TREES
    // -------------------------------------------------------------------------

    Algorithm(
      id: 'preorder-traversal',
      title: 'Preorder Traversal',
      description:
          'Visits the root before recursively visiting the left and right subtrees.',
      complexity: 'O(n)',
      categoryLabel: 'Trees',
      category: AlgorithmCategory.trees,
      color: AppColors.orange,
      icon: Icons.account_tree_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'inorder-traversal',
      title: 'Inorder Traversal',
      description:
          'Visits the left subtree, root, and then the right subtree.',
      complexity: 'O(n)',
      categoryLabel: 'Trees',
      category: AlgorithmCategory.trees,
      color: AppColors.green,
      icon: Icons.account_tree_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'postorder-traversal',
      title: 'Postorder Traversal',
      description:
          'Visits the left and right subtrees before visiting the root.',
      complexity: 'O(n)',
      categoryLabel: 'Trees',
      category: AlgorithmCategory.trees,
      color: AppColors.purple,
      icon: Icons.account_tree_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'level-order-traversal',
      title: 'Level Order Traversal',
      description:
          'Visits tree nodes level by level using a queue.',
      complexity: 'O(n)',
      categoryLabel: 'Trees',
      category: AlgorithmCategory.trees,
      color: AppColors.cyan,
      icon: Icons.account_tree_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'binary-tree',
      title: 'Binary Tree',
      description:
          'Introduces the structure and traversal of a binary tree.',
      complexity: 'O(n)',
      categoryLabel: 'Trees',
      category: AlgorithmCategory.trees,
      color: AppColors.blue,
      icon: Icons.account_tree_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'binary-search-tree',
      title: 'Binary Search Tree',
      description:
          'Visualizes insertion and searching in a binary search tree.',
      complexity: 'O(log n)',
      categoryLabel: 'Trees',
      category: AlgorithmCategory.trees,
      color: AppColors.pink,
      icon: Icons.account_tree_rounded,
      difficulty: 'Hard',
      status: AlgorithmStatus.implemented,
    ),

    // -------------------------------------------------------------------------
    // GRAPHS
    // -------------------------------------------------------------------------

    Algorithm(
      id: 'dijkstra',
      title: 'Dijkstra',
      description:
          'Finds the shortest path between vertices in a weighted graph.',
      complexity: 'O((V+E) log V)',
      categoryLabel: 'Graphs',
      category: AlgorithmCategory.graphs,
      color: AppColors.green,
      icon: Icons.route_rounded,
      difficulty: 'Hard',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'bfs',
      title: 'Breadth-First Search',
      description:
          'Traverses a graph level by level using a queue.',
      complexity: 'O(V + E)',
      categoryLabel: 'Graphs',
      category: AlgorithmCategory.graphs,
      color: AppColors.cyan,
      icon: Icons.hub_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'dfs',
      title: 'Depth-First Search',
      description:
          'Explores a graph deeply before backtracking.',
      complexity: 'O(V + E)',
      categoryLabel: 'Graphs',
      category: AlgorithmCategory.graphs,
      color: AppColors.purple,
      icon: Icons.account_tree_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),
  ];

  // ---------------------------------------------------------------------------
  // IMPLEMENTED ALGORITHMS
  // ---------------------------------------------------------------------------

  static List<Algorithm> get implemented {
    return all.where((algorithm) => algorithm.isImplemented).toList();
  }

  // ---------------------------------------------------------------------------
  // COMING SOON ALGORITHMS
  // ---------------------------------------------------------------------------

  static List<Algorithm> get comingSoon {
    return all.where((algorithm) => algorithm.isComingSoon).toList();
  }

  // ---------------------------------------------------------------------------
  // CATEGORY FILTER
  // ---------------------------------------------------------------------------

  static List<Algorithm> byCategory(AlgorithmCategory category) {
    return all.where((algorithm) => algorithm.category == category).toList();
  }

  // ---------------------------------------------------------------------------
  // LOOKUP
  // ---------------------------------------------------------------------------

  static Algorithm? findById(String id) {
    for (final algorithm in all) {
      if (algorithm.id == id) {
        return algorithm;
      }
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // SCREEN BUILDER
  // ---------------------------------------------------------------------------

  static Widget? buildScreen(String id) {
    switch (id) {
      case 'linear-search':
        return const LinearSearchScreen();

      case 'binary-search':
        return const BinarySearchScreen();

      case 'jump-search':
        return const JumpSearchScreen();

      case 'interpolation-search':
        return const InterpolationSearchScreen();

      case 'bubble-sort':
        return const BubbleSortScreen();

      case 'selection-sort':
        return const SelectionSortScreen();

      case 'insertion-sort':
        return const InsertionSortScreen();

      case 'merge-sort':
        return const MergeSortScreen();

      case 'quick-sort':
        return const QuickSortScreen();

      case 'heap-sort':
        return const HeapSortScreen();

      case 'preorder-traversal':
        return const PreorderTraversalScreen();

      case 'inorder-traversal':
        return const InorderTraversalScreen();

      case 'postorder-traversal':
        return const PostorderTraversalScreen();

      case 'dijkstra':
        return const DijkstraScreen();

      case 'bfs':
        return const BfsScreen();

      case 'dfs':
        return const DfsScreen();

      case 'level-order-traversal':
        return const LevelOrderTraversalScreen();

      case 'binary-tree':
        return const BinaryTreeScreen();

      case 'binary-search-tree':
        return const BinarySearchTreeScreen();


      default:
        return null;
    }
  }
}