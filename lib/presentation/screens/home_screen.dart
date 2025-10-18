import 'package:flutter/material.dart';
import 'package:qscan_app_flutter/presentation/screens/history_screen.dart';
import 'package:qscan_app_flutter/presentation/screens/scanner_screen.dart';
import 'package:qscan_app_flutter/presentation/screens/home_tab.dart';
import 'package:qscan_app_flutter/presentation/widget/tab_chips.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;
  final List<Widget> pages = [HomeTab(), HistoryScreen()];
  static const List<String> _labels = ['Home', 'History'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onChipTap(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color.fromARGB(255, 53, 65, 157);
    final Color backgroundColor = const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 4,
        title: const Text(
          "QScan App",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              //
            },
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            TabChips(
              labels: _labels,
              selectedIndex: _selectedIndex,
              onTap: _onChipTap,
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    setState(() => _selectedIndex = index);
                  },
                  children: pages,
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ScannerScreen()),
          );
        },
        shape: CircleBorder(),
        backgroundColor: primaryColor,
        elevation: 8,

        child: const Icon(Icons.qr_code_scanner_outlined, size: 30),
      ),
      //  floatingActionButtonLocation: FloatingActionButtonLocation.,
    );
  }
}
