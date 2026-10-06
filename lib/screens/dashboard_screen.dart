import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/theme_controller.dart';
import '../models/algorithm.dart';
import '../registry/algorithm_registry.dart';

// ================================================================
// DASHBOARD SCREEN
// ================================================================
//
// Architecture:
// - Algorithm model lives in models/algorithm.dart.
// - Algorithm metadata + screen mapping live in registry/algorithm_registry.dart.
// - This file contains dashboard UI only.
//
// The dashboard intentionally uses Algorithm directly. There is no
// duplicate AlgorithmItem model here.
// ================================================================

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  bool isSidebarOpen = true;
  bool get isDarkMode => ThemeController.instance.isDarkMode;

  String selectedCategory = 'All';
  String selectedDifficulty = 'All';
  String selectedStatusFilter = 'All';
  String searchQuery = '';

  final TextEditingController searchController = TextEditingController();

  List<String> get _allCategoryFilters => ['All', ..._categoryLabels];

  static const double mobileBreakpoint = 700;
  static const double tabletBreakpoint = 1100;
  static const double largeDesktopBreakpoint = 1450;

  Color get _background =>
      isDarkMode ? const Color(0xFF060B16) : const Color(0xFFF3F7FC);

  Color get _background2 => isDarkMode ? const Color(0xFF0B1220) : Colors.white;

  Color get _cardColor => isDarkMode ? const Color(0xFF0B1428) : Colors.white;

  Color get _primaryText =>
      isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF172033);

  Color get _secondaryText =>
      isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  Color get _mutedText =>
      isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  Color get _sidebarSearchBackground =>
      isDarkMode ? const Color(0xFF030712) : const Color(0xFFF1F5F9);

  Color get _heroText => isDarkMode ? Colors.white : const Color(0xFFF8FAFC);

  Color get _heroSecondaryText =>
      isDarkMode ? Colors.white60 : const Color(0xFFCBD5E1);

  // ==============================================================
  // ALGORITHMS
  // ==============================================================

  /// Single source of truth comes from AlgorithmRegistry.
  List<Algorithm> get algorithms => AlgorithmRegistry.all;

  List<Algorithm> _algorithmsForCategory(String category) {
    return algorithms
        .where((algorithm) => algorithm.categoryLabel == category)
        .toList(growable: false);
  }

  List<String> get _categoryLabels {
    final labels = <String>[];

    for (final algorithm in algorithms) {
      if (!labels.contains(algorithm.categoryLabel)) {
        labels.add(algorithm.categoryLabel);
      }
    }

    return labels;
  }

  Color _categoryColor(String category) {
    if (category == 'All') {
      return AppColors.cyan;
    }

    final matching = _algorithmsForCategory(category);

    if (matching.isNotEmpty) {
      return matching.first.color;
    }

    switch (category) {
      case 'Searching':
        return AppColors.green;
      case 'Sorting':
        return AppColors.purple;
      case 'Graphs':
        return AppColors.blue;
      case 'Trees':
        return AppColors.orange;
      case 'Array Algorithms':
        return AppColors.cyan;
      case 'Linked List Algorithms':
        return AppColors.orange;

      case 'Mathematical Algorithms':
        return AppColors.info;
      case 'Matrix Algorithms':
        return AppColors.cyan;
      case 'Dynamic Programming Algorithms':
        return AppColors.purple;
      case 'Supervised Learning Algorithms':
        return AppColors.green;
      default:
        return AppColors.cyan;
    }
  }

  IconData _categoryIcon(String category) {
    if (category == 'All') {
      return Icons.grid_view_rounded;
    }

    switch (category) {
      case 'Searching':
        return Icons.search_rounded;
      case 'Sorting':
        return Icons.bar_chart_rounded;
      case 'Graphs':
        return Icons.hub_rounded;
      case 'Trees':
        return Icons.account_tree_rounded;
      case 'Array Algorithms':
        return Icons.view_array_rounded;

      case 'Linked List Algorithms':
        return Icons.link_rounded;

      case 'Mathematical Algorithms':
        return Icons.calculate_rounded;
      case 'Matrix Algorithms':
        return Icons.grid_view_rounded;
      case 'Dynamic Programming Algorithms':
        return Icons.account_tree_rounded;
      case 'Supervised Learning Algorithms':
        return Icons.school_rounded;

      default:
        return Icons.category_rounded;
    }
  }

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
    ThemeController.instance.toggle();
    setState(() {});
  }

  // ==============================================================
  // SIDEBAR
  // ==============================================================

  void _toggleSidebar() {
    setState(() {
      isSidebarOpen = !isSidebarOpen;
    });
  }

  // ==============================================================
  // SEARCH
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
      selectedIndex = category == 'All' ? 0 : 1;
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

  void _goToDashboard() {
    setState(() {
      selectedIndex = 0;
      selectedCategory = 'All';
      selectedDifficulty = 'All';
      selectedStatusFilter = 'All';
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
  // OPEN ALGORITHM
  // ==============================================================

  void _openAlgorithm(Algorithm item) {
    final screen = AlgorithmRegistry.buildScreen(item.id);

    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      return;
    }

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
                  '${item.title} is coming soon',
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
                child: Container(color: Colors.black.withValues(alpha: .55)),
              ),
            ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 330),
            curve: Curves.easeInOutCubic,
            top: 0,
            bottom: 0,
            left: isSidebarOpen ? 0 : -300,
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
        ? (isSidebarOpen ? 250.0 : 72.0)
        : (isSidebarOpen ? 280.0 : 72.0);

    return Scaffold(
      backgroundColor: _background,
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 330),
            curve: Curves.easeInOutCubic,
            width: sidebarWidth,
            child: RepaintBoundary(
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: tablet ? 250 : 280,
                      child: IgnorePointer(
                        ignoring: !isSidebarOpen,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 170),
                          curve: Curves.easeOut,
                          opacity: isSidebarOpen ? 1 : 0,
                          child: _buildSidebar(),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        ignoring: isSidebarOpen,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 170),
                          curve: Curves.easeIn,
                          opacity: isSidebarOpen ? 0 : 1,
                          child: _buildCollapsedSidebar(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
            color: _background.withValues(alpha: .97),
            border: Border(
              bottom: BorderSide(
                color: AppColors.cyan.withValues(alpha: isDarkMode ? .08 : .18),
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
              _topIconButton(
                isDarkMode
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                _toggleTheme,
              ),
              if (!mobile && !tablet) ...[
                const SizedBox(width: 8),
                _topIconButton(Icons.person_outline_rounded, () {}),
              ],
            ],
          ),
        );
      },
    );
  }

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
          border: Border.all(color: AppColors.cyan.withValues(alpha: .18)),
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

  Widget _buildResponsiveTopSearch() {
    return Container(
      decoration: BoxDecoration(
        color: _background2,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.cyan.withValues(alpha: .16)),
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
          border: Border.all(color: AppColors.cyan.withValues(alpha: .14)),
        ),
        child: Icon(icon, color: _primaryText.withValues(alpha: .75), size: 21),
      ),
    );
  }

  // ==============================================================
  // SIDEBAR
  // ==============================================================

  Widget _buildSidebar() {
    final categories = _categoryLabels;

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
                    ...categories.map(
                      (category) => _categoryGroup(
                        title: category,
                        icon: _categoryIcon(category),
                        color: _categoryColor(category),
                        count: _algorithmsForCategory(category).length,
                        algorithms: _algorithmsForCategory(category),
                      ),
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
                  border: Border.all(
                    color: AppColors.cyan.withValues(alpha: .14),
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${AlgorithmRegistry.implemented.length} READY  •  '
                    '${AlgorithmRegistry.all.length} TOTAL  •  '
                    '${_categoryLabels.length} CATEGORIES',
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
          color: active
              ? AppColors.cyan.withValues(alpha: .08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active
                ? AppColors.cyan.withValues(alpha: .22)
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
                    ? AppColors.cyan.withValues(alpha: .10)
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
                      color: AppColors.cyan.withValues(alpha: .35),
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

  Widget _buildSidebarSearch() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: _sidebarSearchBackground,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: AppColors.cyan.withValues(alpha: isDarkMode ? .12 : .20),
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
    required List<Algorithm> algorithms,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: () => _selectCategory(title),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .055),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: .15)),
            ),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .10),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .08),
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
        ),
        const SizedBox(height: 6),
        ...algorithms.map((algorithm) {
          final active =
              searchQuery.isEmpty &&
              selectedCategory == title &&
              selectedIndex == 1;

          return InkWell(
            onTap: () => _openAlgorithm(algorithm),
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
                      color: algorithm.color.withValues(alpha: .75),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      algorithm.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: active ? color : _secondaryText,
                        fontSize: 10,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (algorithm.isComingSoon) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Text(
                        'Soon',
                        style: TextStyle(
                          color: AppColors.orange,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                  Icon(
                    Icons.chevron_right_rounded,
                    color: _mutedText.withValues(alpha: .55),
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
    final categories = _categoryLabels;

    return Container(
      color: _background2,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Logo
            _buildLogo(size: 50),

            const SizedBox(height: 28),

            // Dashboard
            _collapsedSidebarItem(
              icon: Icons.dashboard_rounded,
              active: selectedIndex == 0,
              onTap: _goToDashboard,
            ),

            const SizedBox(height: 14),

            // Scrollable categories
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    ...categories.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _collapsedSidebarItem(
                          icon: _categoryIcon(category),
                          active:
                              selectedCategory == category &&
                              selectedIndex == 1,
                          color: _categoryColor(category),
                          onTap: () => _selectCategory(category),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expand sidebar button
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
          color: active ? itemColor.withValues(alpha: .10) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: active
                ? itemColor.withValues(alpha: .30)
                : Colors.transparent,
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
          BoxShadow(
            color: AppColors.cyan.withValues(alpha: .22),
            blurRadius: 25,
          ),
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

    final filtered = algorithms
        .where((algorithm) {
          final query = searchQuery.toLowerCase().trim();

          final matchesQuery = query.isEmpty ||
              algorithm.title.toLowerCase().contains(query) ||
              algorithm.categoryLabel.toLowerCase().contains(query) ||
              algorithm.description.toLowerCase().contains(query) ||
              algorithm.complexity.toLowerCase().contains(query) ||
              algorithm.difficulty.toLowerCase().contains(query) ||
              algorithm.id.toLowerCase().contains(query);

          final matchesCategory = selectedCategory == 'All' ||
              algorithm.categoryLabel == selectedCategory;

          final matchesDifficulty = selectedDifficulty == 'All' ||
              algorithm.difficulty.toLowerCase() ==
                  selectedDifficulty.toLowerCase();

          final matchesStatus = selectedStatusFilter == 'All' ||
              (selectedStatusFilter == 'Ready' && algorithm.isImplemented) ||
              (selectedStatusFilter == 'Soon' && algorithm.isComingSoon);

          return matchesQuery &&
              matchesCategory &&
              matchesDifficulty &&
              matchesStatus;
        })
        .toList(growable: false);

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
                SizedBox(height: mobile ? 18 : 22),
                _buildOverviewSection(),
                SizedBox(height: mobile ? 22 : 28),
                _buildHorizontalCategoryBar(),
                const SizedBox(height: 12),
                _buildFilterBar(),
                SizedBox(height: mobile ? 22 : 30),
                _buildSectionHeader(
                  title: searchQuery.isNotEmpty
                      ? 'Search Results'
                      : selectedCategory == 'All'
                          ? 'All Algorithms'
                          : '$selectedCategory Algorithms',
                  subtitle: searchQuery.isNotEmpty
                      ? '${filtered.length} algorithm(s) found'
                      : selectedCategory == 'All'
                          ? 'Showing all ${filtered.length} algorithms across categories'
                          : 'Explore ${selectedCategory.toLowerCase()} algorithms interactively',
                  color: selectedCategory == 'All'
                      ? AppColors.cyan
                      : _categoryColor(selectedCategory),
                  count: filtered.length,
                  icon: selectedCategory == 'All'
                      ? Icons.grid_view_rounded
                      : _categoryIcon(selectedCategory),
                ),
                SizedBox(height: mobile ? 14 : 18),
                if (filtered.isEmpty)
                  _buildEmptyState()
                else
                  _buildAlgorithmGrid(filtered),
                SizedBox(height: mobile ? 32 : 45),
                const SizedBox(height: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // HORIZONTAL CATEGORY BAR
  // ==============================================================

  Widget _buildHorizontalCategoryBar() {
    final categories = _allCategoryFilters;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = selectedCategory == cat;
              final catColor = _categoryColor(cat);
              final count = cat == 'All'
                  ? algorithms.length
                  : _algorithmsForCategory(cat).length;

              return InkWell(
                onTap: () => _selectCategory(cat),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? catColor.withValues(alpha: isDarkMode ? .18 : .12)
                        : _cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? catColor.withValues(alpha: .65)
                          : (isDarkMode
                              ? Colors.white.withValues(alpha: .06)
                              : Colors.black.withValues(alpha: .06)),
                      width: isSelected ? 1.4 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: catColor.withValues(alpha: .15),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _categoryIcon(cat),
                        size: 16,
                        color: isSelected ? catColor : _secondaryText,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        cat,
                        style: TextStyle(
                          color: isSelected ? _primaryText : _secondaryText,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? catColor.withValues(alpha: .24)
                              : (isDarkMode
                                  ? Colors.white.withValues(alpha: .06)
                                  : Colors.black.withValues(alpha: .05)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: isSelected ? catColor : _mutedText,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // DIFFICULTY & STATUS FILTER BAR
  // ==============================================================

  Widget _buildFilterBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          Text(
            'DIFFICULTY:',
            style: TextStyle(
              color: _mutedText,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(width: 8),
          ...['All', 'Easy', 'Medium', 'Hard'].map((diff) {
            final active = selectedDifficulty == diff;
            Color diffColor;
            switch (diff) {
              case 'Easy':
                diffColor = AppColors.green;
                break;
              case 'Medium':
                diffColor = AppColors.orange;
                break;
              case 'Hard':
                diffColor = AppColors.pink;
                break;
              default:
                diffColor = AppColors.cyan;
            }
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(diff),
                selected: active,
                onSelected: (_) {
                  setState(() => selectedDifficulty = diff);
                },
                selectedColor: diffColor.withValues(alpha: .18),
                backgroundColor: _cardColor,
                side: BorderSide(
                  color: active
                      ? diffColor.withValues(alpha: .6)
                      : (isDarkMode
                          ? Colors.white.withValues(alpha: .06)
                          : Colors.black.withValues(alpha: .06)),
                ),
                labelStyle: TextStyle(
                  color: active
                      ? (isDarkMode ? Colors.white : diffColor)
                      : _secondaryText,
                  fontSize: 10.5,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            );
          }),
          const SizedBox(width: 14),
          Text(
            'STATUS:',
            style: TextStyle(
              color: _mutedText,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: .8,
            ),
          ),
          const SizedBox(width: 8),
          ...['All', 'Ready', 'Soon'].map((st) {
            final active = selectedStatusFilter == st;
            final color = st == 'Ready'
                ? AppColors.green
                : st == 'Soon'
                    ? AppColors.orange
                    : AppColors.blue;
            final labelText = st == 'Ready'
                ? '⚡ Interactive'
                : st == 'Soon'
                    ? '⏳ Soon'
                    : 'All';
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: Text(labelText),
                selected: active,
                onSelected: (_) {
                  setState(() => selectedStatusFilter = st);
                },
                selectedColor: color.withValues(alpha: .18),
                backgroundColor: _cardColor,
                side: BorderSide(
                  color: active
                      ? color.withValues(alpha: .6)
                      : (isDarkMode
                          ? Colors.white.withValues(alpha: .06)
                          : Colors.black.withValues(alpha: .06)),
                ),
                labelStyle: TextStyle(
                  color: active
                      ? (isDarkMode ? Colors.white : color)
                      : _secondaryText,
                  fontSize: 10.5,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
              ),
            );
          }),
          if (selectedCategory != 'All' ||
              selectedDifficulty != 'All' ||
              selectedStatusFilter != 'All' ||
              searchQuery.isNotEmpty) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  selectedCategory = 'All';
                  selectedDifficulty = 'All';
                  selectedStatusFilter = 'All';
                  searchQuery = '';
                  searchController.clear();
                });
              },
              icon: const Icon(Icons.refresh_rounded, size: 15),
              label: const Text('Reset'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.cyan,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
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
            ? 285.0
            : tablet
            ? 260.0
            : 235.0;

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
            border: Border.all(color: AppColors.cyan.withValues(alpha: .25)),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyan.withValues(alpha: .07),
                blurRadius: 35,
              ),
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

  Widget _heroBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.cyan.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.cyan.withValues(alpha: .30)),
      ),
      child: Text(
        'ALGORITHM VISUALIZER • ${AlgorithmRegistry.implemented.length} READY • ${AlgorithmRegistry.comingSoon.length} SOON',
        style: const TextStyle(
          color: AppColors.cyan,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _heroGraphic() {
    return Container(
      width: 125,
      height: 125,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.cyan.withValues(alpha: .06),
        border: Border.all(color: AppColors.cyan.withValues(alpha: .20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan.withValues(alpha: .10),
            blurRadius: 35,
          ),
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
              border: Border.all(color: AppColors.blue.withValues(alpha: .30)),
            ),
          ),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.purple.withValues(alpha: .12),
              border: Border.all(
                color: AppColors.purple.withValues(alpha: .35),
              ),
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
                color: color.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: .20)),
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
            color: color.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: color.withValues(alpha: .30)),
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

  Widget _buildAlgorithmGrid(List<Algorithm> filtered) {
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
            ? 220.0
            : width < 900
            ? 225.0
            : 220.0;

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
            final algorithm = filtered[index];

            return AlgorithmCardWidget(
              item: algorithm,
              onTap: () => _openAlgorithm(algorithm),
              isDarkMode: isDarkMode,
              searchQuery: searchQuery,
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
        border: Border.all(color: AppColors.cyan.withValues(alpha: .16)),
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
            'Try another algorithm name, category, difficulty, status, or complexity.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _secondaryText, fontSize: 12),
          ),
          if (searchQuery.isNotEmpty ||
              selectedCategory != 'All' ||
              selectedDifficulty != 'All' ||
              selectedStatusFilter != 'All') ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  selectedCategory = 'All';
                  selectedDifficulty = 'All';
                  selectedStatusFilter = 'All';
                  searchQuery = '';
                  searchController.clear();
                });
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Reset filters'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cyan,
                side: BorderSide(
                  color: AppColors.cyan.withValues(alpha: .28),
                ),
              ),
            ),
          ],
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
              (
                Icons.category_rounded,
                '${AlgorithmRegistry.all.length}',
                'Total Algorithms',
                AppColors.cyan,
              ),
              (
                Icons.check_circle_rounded,
                '${AlgorithmRegistry.implemented.length}',
                'Interactive Ready',
                AppColors.green,
              ),
              (
                Icons.hourglass_top_rounded,
                '${AlgorithmRegistry.comingSoon.length}',
                'Coming Soon',
                AppColors.orange,
              ),
              (
                Icons.folder_copy_rounded,
                '${_categoryLabels.length}',
                'Categories',
                AppColors.purple,
              ),
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
// ALGORITHM CARD
// ====================================================================
//
// Uses the real Algorithm model from models/algorithm.dart.
// ====================================================================

class AlgorithmCardWidget extends StatefulWidget {
  final Algorithm item;
  final VoidCallback onTap;
  final bool isDarkMode;
  final String searchQuery;

  const AlgorithmCardWidget({
    super.key,
    required this.item,
    required this.onTap,
    required this.isDarkMode,
    this.searchQuery = '',
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
              color: hovered
                  ? color.withValues(alpha: .45)
                  : color.withValues(alpha: .20),
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isDarkMode
                    ? color.withValues(alpha: hovered ? .12 : .02)
                    : Colors.black.withValues(alpha: hovered ? .10 : .05),
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
                        color: color.withValues(alpha: .10),
                        border: Border.all(color: color.withValues(alpha: .18)),
                      ),
                      child: Icon(
                        widget.item.icon,
                        color: color,
                        size: mobile ? 21 : 23,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HighlightedText(
                      text: widget.item.title,
                      query: widget.searchQuery,
                      maxLines: 1,
                      baseStyle: TextStyle(
                        color: primaryText,
                        fontSize: mobile ? 14 : 15,
                        fontWeight: FontWeight.w800,
                      ),
                      highlightColor: color,
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
                        ).withValues(alpha: .10),
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
                    if (widget.item.isComingSoon) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.orange.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.orange.withValues(alpha: .30),
                          ),
                        ),
                        child: const Text(
                          'SOON',
                          style: TextStyle(
                            color: AppColors.orange,
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .5,
                          ),
                        ),
                      ),
                    ],
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
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(minWidth: 0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: .09),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.speed_rounded, color: color, size: 13),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                widget.item.complexity,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    const Spacer(),
                    Text(
                      widget.item.isComingSoon ? 'Coming Soon' : 'Visualize',
                      style: TextStyle(
                        color: hovered
                            ? color
                            : secondaryText.withValues(alpha: .82),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      widget.item.isComingSoon
                          ? Icons.hourglass_top_rounded
                          : Icons.arrow_forward_rounded,
                      color: hovered
                          ? color
                          : secondaryText.withValues(alpha: .60),
                      size: 17,
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

class _HighlightedText extends StatelessWidget {
  final String text;
  final String query;
  final int maxLines;
  final TextStyle baseStyle;
  final Color highlightColor;

  const _HighlightedText({
    required this.text,
    required this.query,
    required this.maxLines,
    required this.baseStyle,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: baseStyle,
      );
    }

    final lower = text.toLowerCase();
    final needle = trimmed.toLowerCase();
    final start = lower.indexOf(needle);
    if (start < 0) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: baseStyle,
      );
    }

    final end = start + needle.length;
    return Text.rich(
      TextSpan(
        children: [
          if (start > 0) TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: baseStyle.copyWith(
              color: highlightColor,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (end < text.length) TextSpan(text: text.substring(end)),
        ],
        style: baseStyle,
      ),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
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
        border: Border.all(color: color.withValues(alpha: .20)),
        boxShadow: isDarkMode
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .05),
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
              color: color.withValues(alpha: .10),
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
              color.withValues(alpha: .10),
              color.withValues(alpha: .025),
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
          ? Colors.white.withValues(alpha: .018)
          : const Color(0xFF94A3B8).withValues(alpha: .055)
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
