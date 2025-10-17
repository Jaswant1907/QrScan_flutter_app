import 'package:flutter/material.dart';
import 'package:qscan_app_flutter/presentation/screens/history_screen.dart';
import 'package:qscan_app_flutter/presentation/screens/scanner_screen.dart';
import 'package:qscan_app_flutter/presentation/screens/text_screen.dart';
import 'package:qscan_app_flutter/presentation/widget/tab_chips.dart';

void main() {
  runApp(const MyApp());
}

/// Root app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chip Tab Switcher',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

/// Main screen embedding scanner header + chip-based tabs
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  static const List<Widget> _pages = [TextScreen(), HistoryScreen()];

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
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            // Scanner header card
            // Inside your build method, replace your current header container with:
            Container(
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 2),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.padding, size: 22, color: Colors.grey[700]),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Scanner",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                  Icon(Icons.menu, size: 22, color: Colors.grey[700]),
                ],
              ),
            ),

            TabChips(
              labels: ['Home', 'History'],
              selectedIndex: _selectedIndex,
              onTap: (index) {
                setState(() => _selectedIndex = index);
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),

            // Floating chips row

            // Content pages
            // Expanded(
            //   child: PageView(
            //     controller: _pageController,
            //     physics: const NeverScrollableScrollPhysics(),
            //     children: _pages,
            //   ),
            // ),
          ],
        ),
      ),

      // Floating action button to go to scanner screen
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ScannerScreen()),
          );
        },

        backgroundColor: Colors.blue, // button color
        shape: const CircleBorder(), // force circular shape
        // your icon
        child: const Icon(Icons.qr_code_scanner_outlined),
      ),
    );
  }
}
