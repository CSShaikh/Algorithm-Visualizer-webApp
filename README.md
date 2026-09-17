# Algorithm Visualizer

A Flutter-based interactive algorithm visualizer for learning how searching, sorting, tree and graph algorithms execute step by step.

## Current algorithms

### Searching
- Linear Search
- Binary Search
- Jump Search
- Interpolation Search

### Sorting
- Bubble Sort
- Selection Sort
- Insertion Sort
- Merge Sort
- Quick Sort
- Heap Sort

### Trees
- Preorder Traversal
- Inorder Traversal
- Postorder Traversal
- Level Order Traversal
- Binary Tree
- Binary Search Tree

### Graphs
- Dijkstra
- Breadth-First Search (BFS)
- Depth-First Search (DFS)

## Architecture

The project intentionally follows a beginner-friendly rule:

> One algorithm = one main screen file.

An algorithm screen contains its own algorithm state, event generation, visualization, controls and source-code presentation. Shared page arrangement is provided by `lib/core/widgets/algorithm_screen_shell.dart`; this widget does not contain algorithm logic.

`lib/registry/algorithm_registry.dart` is the single source of truth for algorithm metadata, categories, availability and screen creation.

## Responsive design

Algorithm pages use the shared responsive shell:

- Desktop: visualization + controls on the left, source code + execution steps on the right.
- Tablet: the workspace collapses as needed to avoid cramped columns.
- Mobile: all sections become a single vertical flow with wrapping controls.

Visualizations and code panels use bounded scroll areas where content can be larger than the available viewport.

## Live source-code highlighting

During execution, the current visualization event updates the active source-code line. The source-code panel highlights that line while the corresponding visualization state is shown.

## Theme

Application colors live in `lib/core/theme/app_colors.dart` and application themes live in `lib/core/theme/app_theme.dart`. Theme state is controlled by `lib/core/theme/theme_controller.dart`.

## Adding a new algorithm

1. Create one screen file inside the appropriate `lib/algorithms/...` folder.
2. Keep the algorithm logic and visualization in that screen file.
3. Add one `Algorithm` entry to `AlgorithmRegistry.all`.
4. Add one case to `AlgorithmRegistry.buildScreen()`.
5. Add a test for the registry/screen mapping when the behavior is important.

Do not add a second logic file unless the project requirements explicitly change.

## Run

```bash
flutter pub get
flutter run -d chrome
```

## Test

```bash
flutter test
```

## Important project rule

The splash screen is intentionally kept separate and should not be modified as part of algorithm-screen refactors unless that requirement is explicitly changed.
