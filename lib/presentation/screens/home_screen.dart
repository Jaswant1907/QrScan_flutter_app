import 'package:flutter/material.dart';
import 'package:qscan_app_flutter/presentation/screens/history_screen.dart';
import 'package:qscan_app_flutter/presentation/screens/scanner_screen.dart';
import 'package:qscan_app_flutter/presentation/screens/home_tab.dart';
import 'package:qscan_app_flutter/presentation/widget/tab_chips.dart';
import '../../core/utils/responsive_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final PageController _pageController;
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomeTab(key: PageStorageKey('home_tab')),
    HistoryScreen(key: PageStorageKey('history_screen')),
  ];

  static const List<String> _labels = ['Home', 'History'];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onChipTap(int index) {
    if (_selectedIndex == index) return;
    setState(() {
      _selectedIndex = index;
    });
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtil(context);
    final Color primaryColor = const Color(0xFF35419D);
    final Color backgroundColor = const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 4,
        title: const Text(
          'QScan App',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        actions: [IconButton(icon: const Icon(Icons.menu), onPressed: () {})],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: responsive.hp(1.5)),
            TabChips(
              labels: _labels,
              selectedIndex: _selectedIndex,
              onTap: _onChipTap,
            ),
            SizedBox(height: responsive.hp(1.5)),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: responsive.wp(4)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  children: _pages,
                ),
              ),
            ),
            SizedBox(height: responsive.hp(2)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const ScannerScreen()),
          );
          if (result == true) {
            setState(() {
              _selectedIndex = 1;
            });
            _pageController.jumpToPage(1);
          }
        },
        shape: CircleBorder(),
        backgroundColor: primaryColor,
        elevation: 8,
        child: const Icon(Icons.qr_code_scanner_outlined, size: 30),
      ),
    );
  }
}
