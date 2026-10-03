import 'package:a_algorithm_visualizer/algorithms/array_algorithms/two_pointer_screen.dart';
import 'package:a_algorithm_visualizer/algorithms/mathematical_algorithms/euclidean_algorithm.dart';
import 'package:a_algorithm_visualizer/algorithms/mathematical_algorithms/fibonacci_algorithm.dart';
import 'package:a_algorithm_visualizer/algorithms/mathematical_algorithms/factorial_algorithm.dart';
import 'package:a_algorithm_visualizer/algorithms/matrix_algorithms/matrix_addition_algorithm.dart';
import 'package:a_algorithm_visualizer/algorithms/matrix_algorithms/matrix_multiplication_algorithm.dart';
import 'package:a_algorithm_visualizer/algorithms/matrix_algorithms/matrix_transpose_algorithm.dart';
import 'package:a_algorithm_visualizer/algorithms/dynamic_programming_algorithms/lcs_algorithm.dart';
import 'package:a_algorithm_visualizer/algorithms/dynamic_programming_algorithms/lis_algorithm.dart';
import 'package:a_algorithm_visualizer/algorithms/sorting_algorithms/counting_sort_screen.dart';
import 'package:flutter/material.dart';

import '../algorithms/graph_algorithms/dijkstra_screen.dart';
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
      description: 'Repeatedly compares adjacent elements and swaps them.',
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
      description: 'Builds the final sorted array one item at a time.',
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
      description: 'Uses a pivot to partition elements into smaller subarrays.',
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
      description: 'Uses a heap data structure to efficiently sort elements.',
      complexity: 'O(n log n)',
      categoryLabel: 'Sorting',
      category: AlgorithmCategory.sorting,
      color: AppColors.pink,
      icon: Icons.account_tree_rounded,
      difficulty: 'Hard',
      status: AlgorithmStatus.implemented,
    ),
    Algorithm(
      id: 'counting-sort',
      title: 'Counting Sort',
      description:
          'Counts the occurrences of each element and calculates their positions.',
      complexity: 'O(n + k)',
      categoryLabel: 'Sorting',
      category: AlgorithmCategory.sorting,
      color: AppColors.cyan,
      icon: Icons.format_list_numbered_rounded,
      difficulty: 'Medium',
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
      description: 'Visits the left subtree, root, and then the right subtree.',
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
      description: 'Visits tree nodes level by level using a queue.',
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
      description: 'Introduces the structure and traversal of a binary tree.',
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
      description: 'Traverses a graph level by level using a queue.',
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
      description: 'Explores a graph deeply before backtracking.',
      complexity: 'O(V + E)',
      categoryLabel: 'Graphs',
      category: AlgorithmCategory.graphs,
      color: AppColors.purple,
      icon: Icons.account_tree_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),

    // -------------------------------------------------------------------------
    // ARRAY ALGORITHMS
    // -------------------------------------------------------------------------
    Algorithm(
      id: 'two-pointer',
      title: 'Two Pointer Technique',
      description:
          'Uses two pointers to solve problems on sorted arrays or linked lists.',
      complexity: 'O(n)',
      categoryLabel: 'Array Algorithms',
      category: AlgorithmCategory.arrayAlgorithms,
      color: AppColors.orange,
      icon: Icons.compare_arrows_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),

    // -------------------------------------------------------------------------
    // LINKED LIST ALGORITHMS
    // -------------------------------------------------------------------------
    Algorithm(
      id: 'find-middle-linked-list',
      title: 'Find Middle Element',
      description:
          'Finds the middle element of a linked list using the slow and fast pointer technique.',
      complexity: 'O(n)',
      categoryLabel: 'Linked List Algorithms',
      category: AlgorithmCategory.linkedListAlgorithms,
      color: AppColors.orange,
      icon: Icons.center_focus_strong_rounded,
      difficulty: 'Easy',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'reverse-linked-list',
      title: 'Reverse Linked List',
      description:
          'Reverses the direction of all links in a singly linked list.',
      complexity: 'O(n)',
      categoryLabel: 'Linked List Algorithms',
      category: AlgorithmCategory.linkedListAlgorithms,
      color: AppColors.cyan,
      icon: Icons.sync_alt_rounded,
      difficulty: 'Easy',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'find-loop-start-linked-list',
      title: 'Find Start of Loop',
      description:
          'Detects a loop in a linked list and finds the node where the loop starts.',
      complexity: 'O(n)',
      categoryLabel: 'Linked List Algorithms',
      category: AlgorithmCategory.linkedListAlgorithms,
      color: AppColors.purple,
      icon: Icons.loop_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'third-element-from-tail',
      title: 'Find 3rd Element from Tail',
      description: 'Finds the third element from the end of a linked list.',
      complexity: 'O(n)',
      categoryLabel: 'Linked List Algorithms',
      category: AlgorithmCategory.linkedListAlgorithms,
      color: AppColors.blue,
      icon: Icons.format_list_numbered_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'sort-linked-list',
      title: 'Sort Linked List',
      description: 'Sorts the elements of a linked list into ascending order.',
      complexity: 'O(n log n)',
      categoryLabel: 'Linked List Algorithms',
      category: AlgorithmCategory.linkedListAlgorithms,
      color: AppColors.green,
      icon: Icons.sort_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'merge-two-sorted-linked-lists',
      title: 'Merge Two Sorted Linked Lists',
      description:
          'Merges two sorted linked lists into a single sorted linked list.',
      complexity: 'O(n + m)',
      categoryLabel: 'Linked List Algorithms',
      category: AlgorithmCategory.linkedListAlgorithms,
      color: AppColors.pink,
      icon: Icons.merge_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),

    Algorithm(
      id: 'linked-list-to-binary-tree',
      title: 'Convert Linked List to Binary Tree',
      description: 'Converts linked list data into a binary tree structure.',
      complexity: 'O(n)',
      categoryLabel: 'Linked List Algorithms',
      category: AlgorithmCategory.linkedListAlgorithms,
      color: AppColors.orange,
      icon: Icons.account_tree_rounded,
      difficulty: 'Hard',
      status: AlgorithmStatus.implemented,
    ),

    /// Mathematical Algorithms///

    /// Eculidean Algorithm///
    Algorithm(
      id: 'euclidean_algorithm',
      title: 'Euclidean Algorithm',
      categoryLabel: 'Mathematical Algorithms',
      description:
          'Find the Greatest Common Divisor (GCD) of two numbers using repeated remainder operations.',
      difficulty: 'Easy',
      complexity: 'O(log min(a,b))',
      category: AlgorithmCategory.mathematicalAlgorithms,
      icon: Icons.calculate_rounded,
      color: AppColors.info,
      status: AlgorithmStatus.implemented,
    ),

    ///Fibonacci Algorithm///
    Algorithm(
      id: 'factorial',
      title: 'Factorial Algorithm',
      description:
          'Calculates the factorial of a non-negative integer using iterative multiplication.',
      complexity: 'O(n)',
      categoryLabel: 'Mathematical Algorithms',
      category: AlgorithmCategory.mathematicalAlgorithms,
      color: AppColors.info,
      icon: Icons.calculate_rounded,
      difficulty: 'Easy',
      status: AlgorithmStatus.implemented,
    ),
    Algorithm(
      id: 'fibonacci',
      title: 'Fibonacci Algorithm',
      description:
          'Generates Fibonacci numbers step by step using an iterative approach.',
      complexity: 'O(n)',
      categoryLabel: 'Mathematical Algorithms',
      category: AlgorithmCategory.mathematicalAlgorithms,
      color: AppColors.info,
      icon: Icons.auto_graph_rounded,
      difficulty: 'Easy',
      status: AlgorithmStatus.implemented,
    ),

    // -------------------------------------------------------------------------
    // MATRIX ALGORITHMS
    // -------------------------------------------------------------------------
    Algorithm(
      id: 'matrix-addition',
      title: 'Matrix Addition Algorithm',
      description:
          'Adds corresponding elements of two matrices to create a result matrix.',
      complexity: 'O(n × m)',
      categoryLabel: 'Matrix Algorithms',
      category: AlgorithmCategory.matrixAlgorithms,
      color: AppColors.cyan,
      icon: Icons.grid_view_rounded,
      difficulty: 'Easy',
      status: AlgorithmStatus.implemented,
    ),
    Algorithm(
      id: 'matrix-transpose',
      title: 'Matrix Transpose Algorithm',
      description:
          'Swaps the rows and columns of a matrix to create its transpose.',
      complexity: 'O(n × m)',
      categoryLabel: 'Matrix Algorithms',
      category: AlgorithmCategory.matrixAlgorithms,
      color: AppColors.cyan,
      icon: Icons.swap_vert_rounded,
      difficulty: 'Easy',
      status: AlgorithmStatus.implemented,
    ),
    Algorithm(
      id: 'matrix-multiplication',
      title: 'Matrix Multiplication Algorithm',
      description:
          'Multiplies rows of one matrix by columns of another to create a result matrix.',
      complexity: 'O(n³)',
      categoryLabel: 'Matrix Algorithms',
      category: AlgorithmCategory.matrixAlgorithms,
      color: AppColors.cyan,
      icon: Icons.close_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),
    Algorithm(
      id: 'lis',
      title: 'Longest Increasing Subsequence (LIS) Algorithm',
      description:
          'Finds the longest strictly increasing subsequence of an integer sequence using dynamic programming and parent tracking.',
      complexity: 'O(n²)',
      categoryLabel: 'Dynamic Programming Algorithms',
      category: AlgorithmCategory.dynamicProgrammingAlgorithms,
      color: AppColors.purple,
      icon: Icons.trending_up_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),
    Algorithm(
      id: 'lcs',
      title: 'Longest Common Subsequence (LCS) Algorithm',
      description:
          'Finds the longest sequence shared by two strings using dynamic programming and backtracking.',
      complexity: 'O(m × n)',
      categoryLabel: 'Dynamic Programming Algorithms',
      category: AlgorithmCategory.dynamicProgrammingAlgorithms,
      color: AppColors.purple,
      icon: Icons.account_tree_rounded,
      difficulty: 'Medium',
      status: AlgorithmStatus.implemented,
    ),
  ];

  static List<Algorithm> get implemented {
    return all.where((algorithm) => algorithm.isImplemented).toList();
  }

  static List<Algorithm> get comingSoon {
    return all.where((algorithm) => algorithm.isComingSoon).toList();
  }

  static List<Algorithm> byCategory(AlgorithmCategory category) {
    return all.where((algorithm) => algorithm.category == category).toList();
  }

  static Algorithm? findById(String id) {
    for (final algorithm in all) {
      if (algorithm.id == id) {
        return algorithm;
      }
    }
    return null;
  }

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
      case 'counting-sort':
        return const CountingSortScreen();
      case 'preorder-traversal':
        return const PreorderTraversalScreen();
      case 'inorder-traversal':
        return const InorderTraversalScreen();
      case 'postorder-traversal':
        return const PostorderTraversalScreen();
      case 'dijkstra':
        return const DijkstraScreen();
      case 'two-pointer':
        return const TwoPointerScreen();
      case 'matrix-addition':
        return const MatrixAdditionAlgorithmScreen();
      case 'matrix-multiplication':
        return const MatrixMultiplicationAlgorithmScreen();
      case 'matrix-transpose':
        return const MatrixTransposeAlgorithmScreen();
      case 'lis':
        return const LisAlgorithmScreen();
      case 'lcs':
        return const LcsAlgorithmScreen();
      case 'euclidean_algorithm':
        return const EuclideanAlgorithmScreen();
      case 'factorial':
        return const FactorialAlgorithmScreen();
      case 'fibonacci':
        return const FibonacciAlgorithmScreen();
      default:
        return null;
    }
  }
}
