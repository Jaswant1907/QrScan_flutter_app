import 'package:flutter/material.dart';
import 'package:qscan_app_flutter/presentation/repository/history_repo.dart';
import 'package:qscan_app_flutter/presentation/screens/history_screen.dart';
import 'package:qscan_app_flutter/presentation/screens/scanner_screen.dart';
import '../../core/utils/responsive_utils.dart';

class HomeTab extends StatefulWidget {
  final String userName;

  const HomeTab({super.key, this.userName = "User"});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  int scansToday = 0;
  int totalHistory = 0;
  int favorites = 0;

  @override
  void initState() {
    super.initState();
    _loadScanData();
  }

  Future<void> _loadScanData() async {
    final historyRepo = HistoryRepository();

    int todayScans = await historyRepo.getScansToday();
    int historyScans = await historyRepo.getTotalScans();

    int favs = 35;

    setState(() {
      scansToday = todayScans;
      totalHistory = historyScans;
      favorites = favs;
    });
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtil(context);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: responsive.wp(5),
            vertical: responsive.hp(2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Welcome, ${widget.userName}!",
                    style: TextStyle(
                      fontSize: responsive.sp(7),
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: Colors.grey[700]),
                    onPressed: () {},
                  ),
                ],
              ),

              SizedBox(height: responsive.hp(3)),

              // Summary Cards
              SizedBox(
                height: responsive.hp(16),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildSummaryCard(
                      title: "Scans Today",
                      count: scansToday.toString(),
                      icon: Icons.qr_code_scanner,
                      color: Colors.blueAccent,
                      responsive: responsive,
                    ),
                    _buildSummaryCard(
                      title: "Total History",
                      count: totalHistory.toString(),
                      icon: Icons.history,
                      color: Colors.orange,
                      responsive: responsive,
                    ),
                    _buildSummaryCard(
                      title: "Favorites",
                      count: favorites.toString(),
                      icon: Icons.favorite,
                      color: Colors.redAccent,
                      responsive: responsive,
                    ),
                  ],
                ),
              ),

              SizedBox(height: responsive.hp(4)),

              Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: responsive.sp(6),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),

              SizedBox(height: responsive.hp(1.5)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    icon: Icons.qr_code_scanner,
                    label: "Scan QR",
                    responsive: responsive,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScannerScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.history,
                    label: "History",
                    responsive: responsive,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.favorite_border,
                    label: "Favorites",
                    responsive: responsive,
                    onTap: () {},
                  ),
                ],
              ),

              SizedBox(height: responsive.hp(5)),

              // Featured Section
              Text(
                "Featured",
                style: TextStyle(
                  fontSize: responsive.sp(6),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),

              SizedBox(height: responsive.hp(1.5)),

              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      "Your featured content goes here",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: responsive.sp(4.5),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    required ResponsiveUtil responsive,
  }) {
    return Container(
      width: responsive.wp(35),
      margin: EdgeInsets.only(right: responsive.wp(4)),
      padding: EdgeInsets.all(responsive.wp(4)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: responsive.wp(9), color: color),
          const Spacer(),
          Text(
            count,
            style: TextStyle(
              fontSize: responsive.sp(9),
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: responsive.sp(4),
              color: color.withOpacity(0.75),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required ResponsiveUtil responsive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: responsive.wp(22),
        height: responsive.wp(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: responsive.wp(10), color: Colors.blue),
            SizedBox(height: responsive.hp(1.5)),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: responsive.sp(4.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
