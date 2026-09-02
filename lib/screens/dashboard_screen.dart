import 'package:flutter/material.dart';

import '../algorithms/searching_algorithms/linear_search_screen.dart';
import '../algorithms/searching_algorithms/binary_search_screen.dart';
import '../algorithms/searching_algorithms/jump_search_screen.dart';
import '../algorithms/searching_algorithms/interpolation_search_screen.dart';
import '../algorithms/sorting_algorithms/bubble_sort_screen.dart';
import '../algorithms/sorting_algorithms/selection_sort_screen.dart';
import '../algorithms/sorting_algorithms/insertion_sort_screen.dart';
import '../algorithms/sorting_algorithms/merge_sort_screen.dart';
import '../algorithms/sorting_algorithms/quick_sort_screen.dart';
import '../algorithms/sorting_algorithms/heap_sort_screen.dart';

// ================================================================
// APP COLORS
// ================================================================

class AppColors {
  static const Color background = Color(0xFF030712);
  static const Color background2 = Color(0xFF07101F);
  static const Color card = Color(0xFF0B1428);

  static const Color cyan = Color(0xFF00E5FF);
  static const Color blue = Color(0xFF2979FF);
  static const Color purple = Color(0xFF9C27FF);
  static const Color green = Color(0xFF00E676);
  static const Color orange = Color(0xFFFFB300);
  static const Color pink = Color(0xFFFF4081);
}

// ================================================================
// DASHBOARD SCREEN
// ================================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // ==============================================================
  // STATE
  // ==============================================================

  int selectedIndex = 0;

  bool isSidebarOpen = true;
  bool isDarkMode = true;

  String selectedCategory = 'Searching';
  String searchQuery = '';

  final TextEditingController searchController = TextEditingController();

  // ==============================================================
  // BREAKPOINTS
  // ==============================================================

  static const double mobileBreakpoint = 700;
  static const double tabletBreakpoint = 1100;
  static const double largeDesktopBreakpoint = 1450;

  // ==============================================================
  // THEME COLORS
  // ==============================================================

  Color get _background {
    return isDarkMode ? const Color(0xFF060B16) : const Color(0xFFF3F7FC);
  }

  Color get _background2 {
    return isDarkMode ? const Color(0xFF0B1220) : Colors.white;
  }

  Color get _cardColor {
    return isDarkMode ? const Color(0xFF0B1428) : Colors.white;
  }

  Color get _primaryText {
    return isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF172033);
  }

  Color get _secondaryText {
    return isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  }

  Color get _mutedText {
    return isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
  }

  Color get _borderColor {
    return isDarkMode ? Colors.white.withOpacity(.07) : const Color(0xFFD9E2EC);
  }

  Color get _sidebarSearchBackground {
    return isDarkMode ? const Color(0xFF030712) : const Color(0xFFF1F5F9);
  }

  Color get _heroText {
    return isDarkMode ? Colors.white : const Color(0xFFF8FAFC);
  }

  Color get _heroSecondaryText {
    return isDarkMode ? Colors.white60 : const Color(0xFFCBD5E1);
  }

  // ==============================================================
  // ALGORITHMS
  // ==============================================================

  final List<AlgorithmItem> algorithms = [
    // ============================================================
    // SEARCHING
    // ============================================================

    AlgorithmItem(
      title: 'Linear Search',
      description:
          'Searches elements one by one until the required value is found.',
      complexity: 'O(n)',
      category: 'Searching',
      color: AppColors.cyan,
      icon: Icons.search_rounded,
      difficulty: 'Easy',
    ),

    AlgorithmItem(
      title: 'Binary Search',
      description:
          'Searches sorted data by repeatedly dividing the search space.',
      complexity: 'O(log n)',
      category: 'Searching',
      color: AppColors.cyan,
      icon: Icons.manage_search_rounded,
      difficulty: 'Easy',
    ),

    AlgorithmItem(
      title: 'Jump Search',
      description:
          'Jumps through sorted blocks and performs linear search locally.',
      complexity: 'O(√n)',
      category: 'Searching',
      color: AppColors.green,
      icon: Icons.double_arrow_rounded,
      difficulty: 'Medium',
    ),

    AlgorithmItem(
      title: 'Interpolation Search',
      description:
          'Estimates the position of a value in uniformly distributed sorted data.',
      complexity: 'O(log log n)',
      category: 'Searching',
      color: AppColors.blue,
      icon: Icons.my_location_rounded,
      difficulty: 'Medium',
    ),

    // ============================================================
    // SORTING
    // ============================================================
    AlgorithmItem(
      title: 'Bubble Sort',
      description: 'Repeatedly compares adjacent elements and swaps them.',
      complexity: 'O(n²)',
      category: 'Sorting',
      color: AppColors.cyan,
      icon: Icons.swap_vert_rounded,
      difficulty: 'Easy',
    ),

    AlgorithmItem(
      title: 'Selection Sort',
      description:
          'Selects the minimum element and places it at the correct position.',
      complexity: 'O(n²)',
      category: 'Sorting',
      color: AppColors.blue,
      icon: Icons.select_all_rounded,
      difficulty: 'Easy',
    ),

    AlgorithmItem(
      title: 'Insertion Sort',
      description: 'Builds the final sorted array one item at a time.',
      complexity: 'O(n²)',
      category: 'Sorting',
      color: AppColors.orange,
      icon: Icons.input_rounded,
      difficulty: 'Easy',
    ),

    AlgorithmItem(
      title: 'Merge Sort',
      description:
          'Divides the array into smaller parts and merges sorted parts.',
      complexity: 'O(n log n)',
      category: 'Sorting',
      color: AppColors.green,
      icon: Icons.merge_type_rounded,
      difficulty: 'Medium',
    ),

    AlgorithmItem(
      title: 'Quick Sort',
      description: 'Uses a pivot to partition elements into smaller subarrays.',
      complexity: 'O(n log n)',
      category: 'Sorting',
      color: AppColors.purple,
      icon: Icons.call_split_rounded,
      difficulty: 'Medium',
    ),

    AlgorithmItem(
      title: 'Heap Sort',
      description: 'Uses a heap data structure to efficiently sort elements.',
      complexity: 'O(n log n)',
      category: 'Sorting',
      color: AppColors.pink,
      icon: Icons.account_tree_rounded,
      difficulty: 'Hard',
    ),

    // ============================================================
    // GRAPH
    // ============================================================
    AlgorithmItem(
      title: 'Dijkstra',
      description:
          'Finds the shortest path between vertices in a weighted graph.',
      complexity: 'O((V+E) log V)',
      category: 'Graph',
      color: AppColors.green,
      icon: Icons.route_rounded,
      difficulty: 'Hard',
    ),

    AlgorithmItem(
      title: 'BFS',
      description: 'Traverses a graph level by level using a queue.',
      complexity: 'O(V + E)',
      category: 'Graph',
      color: AppColors.cyan,
      icon: Icons.hub_rounded,
      difficulty: 'Medium',
    ),

    AlgorithmItem(
      title: 'DFS',
      description: 'Explores a graph deeply before backtracking.',
      complexity: 'O(V + E)',
      category: 'Graph',
      color: AppColors.purple,
      icon: Icons.account_tree_rounded,
      difficulty: 'Medium',
    ),

    // ============================================================
    // TREES
    // ============================================================
    AlgorithmItem(
      title: 'Binary Tree',
      description:
          'A hierarchical structure where each node has at most two children.',
      complexity: 'Depends',
      category: 'Trees',
      color: AppColors.purple,
      icon: Icons.device_hub_rounded,
      difficulty: 'Medium',
    ),

    AlgorithmItem(
      title: 'Binary Search Tree',
      description:
          'An ordered tree structure designed for efficient searching.',
      complexity: 'Avg O(log n)',
      category: 'Trees',
      color: AppColors.blue,
      icon: Icons.schema_rounded,
      difficulty: 'Medium',
    ),
  ];

  // ==============================================================
  // DISPOSE
  // ==============================================================

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ==============================================================
  // THEME
  // ==============================================================

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  // ==============================================================
  // SIDEBAR TOGGLE
  // ==============================================================

  void _toggleSidebar() {
    setState(() {
      isSidebarOpen = !isSidebarOpen;
    });
  }

  // ==============================================================
  // CLEAR SEARCH
  // ==============================================================

  void _clearSearch() {
    setState(() {
      searchQuery = '';
      searchController.clear();
    });
  }

  // ==============================================================
  // CATEGORY
  // ==============================================================

  void _selectCategory(String category) {
    setState(() {
      selectedIndex = 1;
      selectedCategory = category;
      searchQuery = '';
      searchController.clear();
    });

    if (_isMobile(context)) {
      setState(() {
        isSidebarOpen = false;
      });
    }
  }

  // ==============================================================
  // DASHBOARD
  // ==============================================================

  void _goToDashboard() {
    setState(() {
      selectedIndex = 0;
      selectedCategory = 'Searching';
      searchQuery = '';
      searchController.clear();
    });

    if (_isMobile(context)) {
      setState(() {
        isSidebarOpen = false;
      });
    }
  }

  // ==============================================================
  // OPEN ALGORITHM BY NAME
  // ==============================================================

  void _openAlgorithmByName(String name) {
    final item = algorithms.firstWhere((element) => element.title == name);

    _openAlgorithm(item);
  }

  // ==============================================================
  // OPEN ALGORITHM
  // ==============================================================

  void _openAlgorithm(AlgorithmItem item) {
    // ------------------------------------------------------------
    // LINEAR SEARCH
    // ------------------------------------------------------------

    if (item.title == 'Linear Search') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LinearSearchScreen()),
      );

      return;
    }

    // ------------------------------------------------------------
    // BINARY SEARCH
    // ------------------------------------------------------------

    if (item.title == 'Binary Search') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BinarySearchScreen()),
      );

      return;
    }

    //Bubble Sort
    if (item.title == 'Bubble Sort') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BubbleSortScreen()),
      );

      return;
    }

    // Jump Search //
    if (item.title == 'Jump Search') {
      // Navigate to Jump Search screen
      // Replace with your actual Jump Search screen widget
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const JumpSearchScreen()),
      );

      return;
    }

    // Interpolation Search //
    if (item.title == 'Interpolation Search') {
      // Navigate to Interpolation Search screen
      // Replace with your actual Interpolation Search screen widget
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const InterpolationSearchScreen()),
      );

      return;
    }

    // Selection Sort
    if (item.title == 'Selection Sort') {
      // Navigate to Selection Sort screen
      // Replace with your actual Selection Sort screen widget
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SelectionSortScreen()),
      );

      return;
    }

    // Insertion Sort//
    if (item.title == 'Insertion Sort') {
      // Navigate to Insertion Sort screen
      // Replace with your actual Insertion Sort screen widget
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const InsertionSortScreen()),
      );

      return;
    }

    // Merge Sort
    if (item.title == 'Merge Sort') {
      // Navigate to Merge Sort screen
      // Replace with your actual Merge Sort screen widget
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MergeSortScreen()),
      );

      return;
    }

    // Quick Sort //
    if (item.title == 'Quick Sort') {
      // Navigate to Quick Sort screen
      // Replace with your actual Quick Sort screen widget
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QuickSortScreen()),
      );

      return;
    }

    // Heap Sort //
    if (item.title == 'Heap Sort') {
      // Navigate to Heap Sort screen
      // Replace with your actual Heap Sort screen widget
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HeapSortScreen()),
      );

      return;
    }
    // ------------------------------------------------------------
    // FUTURE ALGORITHMS
    // ------------------------------------------------------------

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: _cardColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              Icon(item.icon, color: item.color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${item.title} selected',
                  style: TextStyle(
                    color: _primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ==============================================================
  // RESPONSIVE
  // ==============================================================

  bool _isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  double _contentHorizontalPadding(double width) {
    if (width < mobileBreakpoint) {
      return 16;
    }

    if (width < tabletBreakpoint) {
      return 24;
    }

    if (width < largeDesktopBreakpoint) {
      return 32;
    }

    return 45;
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < mobileBreakpoint) {
      return _buildMobileLayout();
    }

    return _buildDesktopTabletLayout();
  }

  // ==============================================================
  // MOBILE LAYOUT
  // ==============================================================

  Widget _buildMobileLayout() {
    return Scaffold(
      backgroundColor: _background,
      body: Stack(
        children: [
          Column(
            children: [
              _buildTopBar(),
              Expanded(child: _buildMainContent()),
            ],
          ),

          if (isSidebarOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isSidebarOpen = false;
                  });
                },
                child: Container(color: Colors.black.withOpacity(.55)),
              ),
            ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            top: 0,
            bottom: 0,
            left: isSidebarOpen ? 0 : -290,
            width: 280,
            child: Material(color: Colors.transparent, child: _buildSidebar()),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // DESKTOP / TABLET
  // ==============================================================

  Widget _buildDesktopTabletLayout() {
    final tablet = _isTablet(context);

    final sidebarWidth = tablet
        ? (isSidebarOpen ? 250.0 : 78.0)
        : (isSidebarOpen ? 270.0 : 92.0);

    return Scaffold(
      backgroundColor: _background,
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            width: sidebarWidth,
            child: RepaintBoundary(
              child: isSidebarOpen ? _buildSidebar() : _buildCollapsedSidebar(),
            ),
          ),

          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(child: _buildMainContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // TOP BAR
  // ==============================================================

  Widget _buildTopBar() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final mobile = width < mobileBreakpoint;

        final tablet = width >= mobileBreakpoint && width < tabletBreakpoint;

        final topBarHeight = mobile ? 68.0 : 86.0;

        return Container(
          height: topBarHeight,
          padding: EdgeInsets.symmetric(
            horizontal: mobile
                ? 12
                : tablet
                ? 18
                : 28,
          ),
          decoration: BoxDecoration(
            color: _background.withOpacity(.97),
            border: Border(
              bottom: BorderSide(
                color: AppColors.cyan.withOpacity(isDarkMode ? .08 : .18),
              ),
            ),
          ),
          child: Row(
            children: [
              _topMenuButton(mobile: mobile),

              SizedBox(width: mobile ? 10 : 14),

              Expanded(
                child: _topTitle(mobile: mobile, tablet: tablet),
              ),

              if (!mobile && !tablet) ...[
                const SizedBox(width: 14),

                SizedBox(
                  width: width >= 1350 ? 300 : 240,
                  height: 46,
                  child: _buildResponsiveTopSearch(),
                ),

                const SizedBox(width: 12),
              ],

              if (!mobile) ...[
                _topIconButton(
                  isDarkMode
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                  _toggleTheme,
                ),

                if (!tablet) ...[
                  const SizedBox(width: 8),

                  _topIconButton(Icons.person_outline_rounded, () {}),
                ],
              ],
            ],
          ),
        );
      },
    );
  }

  // ==============================================================
  // TOP MENU
  // ==============================================================

  Widget _topMenuButton({required bool mobile}) {
    return InkWell(
      onTap: _toggleSidebar,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: mobile ? 44 : 48,
        height: mobile ? 44 : 48,
        decoration: BoxDecoration(
          color: _background2,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.cyan.withOpacity(.18)),
        ),
        child: Icon(
          mobile
              ? Icons.menu_rounded
              : isSidebarOpen
              ? Icons.menu_open_rounded
              : Icons.menu_rounded,
          color: AppColors.cyan,
          size: 23,
        ),
      ),
    );
  }

  // ==============================================================
  // TOP TITLE
  // ==============================================================

  Widget _topTitle({required bool mobile, required bool tablet}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ALGORITHM VISUALIZER',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _primaryText,
            fontSize: mobile
                ? 14
                : tablet
                ? 16
                : 18,
            fontWeight: FontWeight.w900,
            letterSpacing: mobile ? .7 : 1.4,
          ),
        ),

        if (!mobile) ...[
          const SizedBox(height: 4),

          Text(
            'Interactive learning environment',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _secondaryText, fontSize: 10),
          ),
        ],
      ],
    );
  }

  // ==============================================================
  // TOP SEARCH
  // ==============================================================

  Widget _buildResponsiveTopSearch() {
    return Container(
      decoration: BoxDecoration(
        color: _background2,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.cyan.withOpacity(.16)),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        style: TextStyle(color: _primaryText, fontSize: 12),
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.cyan,
            size: 20,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close_rounded, size: 17),
                  color: _secondaryText,
                )
              : null,
          hintText: 'Search algorithm...',
          hintStyle: TextStyle(color: _secondaryText, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  // ==============================================================
  // TOP ICON
  // ==============================================================

  Widget _topIconButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: _background2,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: AppColors.cyan.withOpacity(.14)),
        ),
        child: Icon(icon, color: _primaryText.withOpacity(.75), size: 21),
      ),
    );
  }

  // ==============================================================
  // SIDEBAR
  // ==============================================================

  Widget _buildSidebar() {
    return Container(
      width: double.infinity,
      color: _background2,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  _buildLogo(),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ALGORITHMS',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: _primaryText,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Interactive library',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: _secondaryText, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _sidebarItem(
                icon: Icons.dashboard_rounded,
                title: 'DASHBOARD',
                subtitle: 'Overview & algorithms',
                active: selectedIndex == 0,
                onTap: _goToDashboard,
              ),
            ),

            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _buildSidebarSearch(),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    _categoryGroup(
                      title: 'Searching',
                      icon: Icons.search_rounded,
                      color: AppColors.green,
                      count: 4,
                      algorithms: const [
                        'Linear Search',
                        'Binary Search',
                        'Jump Search',
                        'Interpolation Search',
                      ],
                    ),

                    _categoryGroup(
                      title: 'Sorting',
                      icon: Icons.bar_chart_rounded,
                      color: AppColors.purple,
                      count: 6,
                      algorithms: const [
                        'Bubble Sort',
                        'Selection Sort',
                        'Insertion Sort',
                        'Merge Sort',
                        'Quick Sort',
                        'Heap Sort',
                      ],
                    ),

                    _categoryGroup(
                      title: 'Graph',
                      icon: Icons.hub_rounded,
                      color: AppColors.blue,
                      count: 3,
                      algorithms: const ['Dijkstra', 'BFS', 'DFS'],
                    ),

                    _categoryGroup(
                      title: 'Trees',
                      icon: Icons.account_tree_rounded,
                      color: AppColors.orange,
                      count: 2,
                      algorithms: const ['Binary Tree', 'Binary Search Tree'],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: _sidebarSearchBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cyan.withOpacity(.14)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '15 ALGORITHMS  •  4 CATEGORIES',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _secondaryText,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .7,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // SIDEBAR ITEM
  // ==============================================================

  Widget _sidebarItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool active,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: active ? AppColors.cyan.withOpacity(.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? AppColors.cyan.withOpacity(.22)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: active
                    ? AppColors.cyan.withOpacity(.10)
                    : _sidebarSearchBackground,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                color: active ? AppColors.cyan : _secondaryText,
                size: 19,
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active ? _primaryText : _secondaryText,
                      fontSize: 10,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      letterSpacing: .4,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _mutedText, fontSize: 8.5),
                  ),
                ],
              ),
            ),

            if (active)
              Container(
                width: 5,
                height: 25,
                decoration: BoxDecoration(
                  color: AppColors.cyan,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyan.withOpacity(.35),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // SIDEBAR SEARCH
  // ==============================================================

  Widget _buildSidebarSearch() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: _sidebarSearchBackground,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.cyan.withOpacity(isDarkMode ? .12 : .20),
        ),
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
        style: TextStyle(color: _primaryText, fontSize: 12),
        decoration: InputDecoration(
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.cyan,
            size: 20,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: _secondaryText,
                )
              : null,
          hintText: 'Search algorithms...',
          hintStyle: TextStyle(color: _mutedText, fontSize: 12),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  // ==============================================================
  // CATEGORY GROUP
  // ==============================================================

  Widget _categoryGroup({
    required String title,
    required IconData icon,
    required Color color,
    required int count,
    required List<String> algorithms,
  }) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(.055),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: color.withOpacity(.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: color,
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 6),

        ...algorithms.map((algorithm) {
          final item = this.algorithms.firstWhere(
            (element) => element.title == algorithm,
          );

          final active =
              searchQuery.isEmpty &&
              selectedCategory == title &&
              selectedIndex == 1;

          return InkWell(
            onTap: () {
              _openAlgorithmByName(algorithm);
            },
            borderRadius: BorderRadius.circular(9),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(.75),
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: 9),

                  Expanded(
                    child: Text(
                      algorithm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: active ? color : _secondaryText,
                        fontSize: 10,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),

                  Icon(
                    Icons.chevron_right_rounded,
                    color: _mutedText.withOpacity(.55),
                    size: 16,
                  ),
                ],
              ),
            ),
          );
        }),

        const SizedBox(height: 12),
      ],
    );
  }

  // ==============================================================
  // COLLAPSED SIDEBAR
  // ==============================================================

  Widget _buildCollapsedSidebar() {
    return Container(
      color: _background2,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            _buildLogo(size: 50),

            const SizedBox(height: 28),

            _collapsedSidebarItem(
              icon: Icons.dashboard_rounded,
              active: selectedIndex == 0,
              onTap: _goToDashboard,
            ),

            const SizedBox(height: 14),

            _collapsedSidebarItem(
              icon: Icons.search_rounded,
              active: selectedCategory == 'Searching',
              color: AppColors.green,
              onTap: () => _selectCategory('Searching'),
            ),

            const SizedBox(height: 12),

            _collapsedSidebarItem(
              icon: Icons.bar_chart_rounded,
              active: selectedCategory == 'Sorting',
              color: AppColors.purple,
              onTap: () => _selectCategory('Sorting'),
            ),

            const SizedBox(height: 12),

            _collapsedSidebarItem(
              icon: Icons.hub_rounded,
              active: selectedCategory == 'Graph',
              color: AppColors.blue,
              onTap: () => _selectCategory('Graph'),
            ),

            const SizedBox(height: 12),

            _collapsedSidebarItem(
              icon: Icons.account_tree_rounded,
              active: selectedCategory == 'Trees',
              color: AppColors.orange,
              onTap: () => _selectCategory('Trees'),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _collapsedSidebarItem(
                icon: Icons.keyboard_double_arrow_right_rounded,
                active: false,
                color: AppColors.cyan,
                onTap: _toggleSidebar,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // COLLAPSED SIDEBAR ITEM
  // ==============================================================

  Widget _collapsedSidebarItem({
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
    Color? color,
  }) {
    final itemColor = color ?? AppColors.cyan;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          color: active ? itemColor.withOpacity(.10) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: active ? itemColor.withOpacity(.30) : Colors.transparent,
          ),
        ),
        child: Icon(icon, color: active ? itemColor : _secondaryText, size: 24),
      ),
    );
  }

  // ==============================================================
  // LOGO
  // ==============================================================

  Widget _buildLogo({double size = 54}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.cyan, AppColors.blue],
        ),
        boxShadow: [
          BoxShadow(color: AppColors.cyan.withOpacity(.22), blurRadius: 25),
        ],
      ),
      child: Icon(
        Icons.account_tree_rounded,
        color: Colors.white,
        size: size * .52,
      ),
    );
  }

  // ==============================================================
  // MAIN CONTENT
  // ==============================================================

  Widget _buildMainContent() {
    final width = MediaQuery.of(context).size.width;

    final mobile = width < mobileBreakpoint;

    final filtered = algorithms.where((algorithm) {
      final query = searchQuery.toLowerCase().trim();

      if (query.isEmpty) {
        return algorithm.category == selectedCategory;
      }

      return algorithm.title.toLowerCase().contains(query) ||
          algorithm.category.toLowerCase().contains(query) ||
          algorithm.description.toLowerCase().contains(query);
    }).toList();

    final horizontalPadding = _contentHorizontalPadding(width);

    return Container(
      color: _background,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: DashboardGridPainter(isDarkMode: isDarkMode),
              ),
            ),
          ),

          if (isDarkMode)
            Positioned(
              top: -180,
              right: -150,
              child: _Glow(size: mobile ? 300 : 430, color: AppColors.cyan),
            ),

          if (isDarkMode)
            Positioned(
              bottom: -200,
              left: -160,
              child: _Glow(size: mobile ? 300 : 400, color: AppColors.purple),
            ),

          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              mobile ? 18 : 26,
              horizontalPadding,
              mobile ? 30 : 45,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBreadcrumb(),

                SizedBox(height: mobile ? 16 : 24),

                _buildHero(),

                SizedBox(height: mobile ? 28 : 42),

                _buildSectionHeader(
                  title: searchQuery.isEmpty
                      ? '$selectedCategory Algorithms'
                      : 'Search Results',
                  subtitle: searchQuery.isEmpty
                      ? 'Explore algorithms interactively'
                      : '${filtered.length} algorithm(s) found',
                  color: AppColors.cyan,
                  count: filtered.length,
                  icon: Icons.search_rounded,
                ),

                SizedBox(height: mobile ? 14 : 18),

                if (filtered.isEmpty)
                  _buildEmptyState()
                else
                  _buildAlgorithmGrid(filtered),

                SizedBox(height: mobile ? 32 : 45),

                _buildOverviewSection(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // BREADCRUMB
  // ==============================================================

  Widget _buildBreadcrumb() {
    return Row(
      children: [
        Text(
          'DASHBOARD',
          style: TextStyle(
            color: _secondaryText,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),

        const SizedBox(width: 9),

        const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.cyan,
          size: 17,
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            searchQuery.isEmpty ? selectedCategory.toUpperCase() : 'SEARCH',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.cyan,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // HERO
  // ==============================================================

  Widget _buildHero() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final mobile = width < 650;

        final tablet = width >= 650 && width < 950;

        final heroHeight = mobile
            ? 350.0
            : tablet
            ? 260.0
            : 230.0;

        return Container(
          width: double.infinity,
          height: heroHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(mobile ? 22 : 26),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF071B36), Color(0xFF080F22), Color(0xFF180A2F)],
            ),
            border: Border.all(color: AppColors.cyan.withOpacity(.25)),
            boxShadow: [
              BoxShadow(color: AppColors.cyan.withOpacity(.07), blurRadius: 35),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -70,
                top: -90,
                child: _Glow(size: mobile ? 220 : 260, color: AppColors.cyan),
              ),

              Positioned(
                right: 20,
                bottom: -130,
                child: _Glow(size: mobile ? 220 : 260, color: AppColors.purple),
              ),

              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: mobile ? 20 : 30,
                  vertical: mobile ? 24 : 28,
                ),
                child: mobile
                    ? _buildMobileHeroContent()
                    : _buildDesktopHeroContent(showIcon: !tablet),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==============================================================
  // MOBILE HERO
  // ==============================================================

  Widget _buildMobileHeroContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _heroBadge(),

        const SizedBox(height: 16),

        Text(
          'Explore.\nVisualize.\nUnderstand.',
          style: TextStyle(
            color: _heroText,
            fontSize: 28,
            height: 1.05,
            fontWeight: FontWeight.w900,
            letterSpacing: -.8,
          ),
        ),

        const SizedBox(height: 14),

        Text(
          'Select an algorithm to start an interactive '
          'visualization and understand how it works step by step.',
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _heroSecondaryText,
            fontSize: 12,
            height: 1.55,
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // DESKTOP HERO
  // ==============================================================

  Widget _buildDesktopHeroContent({required bool showIcon}) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _heroBadge(),

              const SizedBox(height: 15),

              Text(
                'Explore. Visualize. Understand.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _heroText,
                  fontSize: showIcon ? 32 : 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.8,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Select an algorithm to start an interactive '
                'visualization and understand how it works step by step.',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _heroSecondaryText,
                  fontSize: 13,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),

        if (showIcon) ...[const SizedBox(width: 25), _heroGraphic()],
      ],
    );
  }

  // ==============================================================
  // HERO BADGE
  // ==============================================================

  Widget _heroBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.cyan.withOpacity(.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.cyan.withOpacity(.30)),
      ),
      child: const Text(
        'WELCOME TO THE LAB',
        style: TextStyle(
          color: AppColors.cyan,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ==============================================================
  // HERO GRAPHIC
  // ==============================================================

  Widget _heroGraphic() {
    return Container(
      width: 125,
      height: 125,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cyan.withOpacity(.06),
        border: Border.all(color: AppColors.cyan.withOpacity(.20)),
        boxShadow: [
          BoxShadow(color: AppColors.cyan.withOpacity(.10), blurRadius: 35),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.blue.withOpacity(.30)),
            ),
          ),

          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.purple.withOpacity(.12),
              border: Border.all(color: AppColors.purple.withOpacity(.35)),
            ),
            child: const Icon(
              Icons.account_tree_rounded,
              color: AppColors.cyan,
              size: 25,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // SECTION HEADER
  // ==============================================================

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required Color color,
    required int count,
    required IconData icon,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 650;

        final titleBlock = Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: color.withOpacity(.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(.20)),
              ),
              child: Icon(icon, color: color, size: 21),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: _secondaryText, fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        );

        final countChip = Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: color.withOpacity(.08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withOpacity(.30)),
          ),
          child: Text(
            '$count ALGORITHMS',
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: .6,
            ),
          ),
        );

        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [titleBlock, const SizedBox(height: 11), countChip],
          );
        }

        return Row(
          children: [
            Expanded(child: titleBlock),
            const SizedBox(width: 14),
            countChip,
          ],
        );
      },
    );
  }

  // ==============================================================
  // GRID
  // ==============================================================

  Widget _buildAlgorithmGrid(List<AlgorithmItem> filtered) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int columns;

        if (width < 650) {
          columns = 1;
        } else if (width < 1450) {
          columns = 2;
        } else {
          columns = 3;
        }

        final spacing = width < 650 ? 14.0 : 18.0;

        final cardHeight = width < 650
            ? 225.0
            : width < 900
            ? 235.0
            : 245.0;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filtered.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: cardHeight,
          ),
          itemBuilder: (context, index) {
            return AlgorithmCardWidget(
              item: filtered[index],
              onTap: () {
                _openAlgorithm(filtered[index]);
              },
              isDarkMode: isDarkMode,
            );
          },
        );
      },
    );
  }

  // ==============================================================
  // EMPTY STATE
  // ==============================================================

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 55, horizontal: 20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cyan.withOpacity(.16)),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, color: AppColors.cyan, size: 45),

          const SizedBox(height: 14),

          Text(
            'No algorithms found',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _primaryText,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'Try searching for another algorithm.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // OVERVIEW
  // ==============================================================

  Widget _buildOverviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Visualizer Overview',
          style: TextStyle(
            color: _primaryText,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 15),

        LayoutBuilder(
          builder: (context, constraints) {
            int columns;

            if (constraints.maxWidth < 600) {
              columns = 1;
            } else if (constraints.maxWidth < 1000) {
              columns = 2;
            } else {
              columns = 4;
            }

            final stats = [
              (Icons.category_rounded, '15', 'Algorithms', AppColors.cyan),
              (Icons.animation_rounded, 'STEP', 'Animations', AppColors.purple),
              (Icons.speed_rounded, 'BIG-O', 'Analysis', AppColors.green),
              (Icons.school_rounded, 'DSA', 'Learning', AppColors.orange),
            ];

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stats.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent: 88,
              ),
              itemBuilder: (context, index) {
                final stat = stats[index];

                return StatCard(
                  icon: stat.$1,
                  value: stat.$2,
                  label: stat.$3,
                  color: stat.$4,
                  isDarkMode: isDarkMode,
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// ====================================================================
// ALGORITHM MODEL
// ====================================================================

class AlgorithmItem {
  final String title;
  final String description;
  final String complexity;
  final String category;
  final Color color;
  final IconData icon;
  final String difficulty;

  const AlgorithmItem({
    required this.title,
    required this.description,
    required this.complexity,
    required this.category,
    required this.color,
    required this.icon,
    required this.difficulty,
  });
}

// ====================================================================
// ALGORITHM CARD
// ====================================================================

class AlgorithmCardWidget extends StatefulWidget {
  final AlgorithmItem item;
  final VoidCallback onTap;
  final bool isDarkMode;

  const AlgorithmCardWidget({
    super.key,
    required this.item,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  State<AlgorithmCardWidget> createState() => _AlgorithmCardWidgetState();
}

class _AlgorithmCardWidgetState extends State<AlgorithmCardWidget> {
  bool hovered = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.item.color;

    final primaryText = widget.isDarkMode
        ? const Color(0xFFF8FAFC)
        : const Color(0xFF172033);

    final secondaryText = widget.isDarkMode
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    final cardColor = widget.isDarkMode
        ? const Color(0xFF0B1428)
        : Colors.white;

    final mobile = MediaQuery.of(context).size.width < 650;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          hovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          transform: Matrix4.translationValues(
            0,
            hovered && !mobile ? -5 : 0,
            0,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(mobile ? 18 : 20),
            border: Border.all(
              color: hovered ? color.withOpacity(.45) : color.withOpacity(.20),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isDarkMode
                    ? color.withOpacity(hovered ? .12 : .02)
                    : Colors.black.withOpacity(hovered ? .10 : .05),
                blurRadius: hovered ? 24 : 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(mobile ? 16 : 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: mobile ? 44 : 47,
                      height: mobile ? 44 : 47,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color: color.withOpacity(.10),
                        border: Border.all(color: color.withOpacity(.18)),
                      ),
                      child: Icon(
                        widget.item.icon,
                        color: color,
                        size: mobile ? 21 : 23,
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        widget.item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primaryText,
                          fontSize: mobile ? 14 : 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    const SizedBox(width: 6),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _difficultyColor(
                          widget.item.difficulty,
                        ).withOpacity(.10),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        widget.item.difficulty.toUpperCase(),
                        style: TextStyle(
                          color: _difficultyColor(widget.item.difficulty),
                          fontSize: 7,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Expanded(
                  child: Text(
                    widget.item.description,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: secondaryText,
                      fontSize: mobile ? 11.5 : 12.5,
                      height: 1.5,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(.09),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.speed_rounded, color: color, size: 13),

                          const SizedBox(width: 5),

                          Text(
                            widget.item.complexity,
                            style: TextStyle(
                              color: color,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    Icon(
                      Icons.arrow_forward_rounded,
                      color: hovered ? color : secondaryText.withOpacity(.60),
                      size: 19,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _difficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return AppColors.green;

      case 'Medium':
        return AppColors.orange;

      case 'Hard':
        return AppColors.pink;

      default:
        return AppColors.cyan;
    }
  }
}

// ====================================================================
// STAT CARD
// ====================================================================

class StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final bool isDarkMode;

  const StatCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDarkMode ? const Color(0xFF0B1428) : Colors.white;

    final labelColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: color.withOpacity(.20)),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(.05),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withOpacity(.10),
            ),
            child: Icon(icon, color: color, size: 21),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: labelColor, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ====================================================================
// GLOW
// ====================================================================

class _Glow extends StatelessWidget {
  final double size;
  final Color color;

  const _Glow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(.10),
              color.withOpacity(.025),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}

// ====================================================================
// GRID BACKGROUND
// ====================================================================

class DashboardGridPainter extends CustomPainter {
  final bool isDarkMode;

  DashboardGridPainter({required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode
          ? Colors.white.withOpacity(.018)
          : const Color(0xFF94A3B8).withOpacity(.16)
      ..strokeWidth = .7;

    const spacing = 45.0;

    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant DashboardGridPainter oldDelegate) {
    return oldDelegate.isDarkMode != isDarkMode;
  }
}
