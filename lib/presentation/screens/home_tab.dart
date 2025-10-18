import 'package:flutter/material.dart';

class HomeTab extends StatelessWidget {
  final String userName;

  const HomeTab({super.key, this.userName = "User"});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Welcome, $userName!",
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings),
                    color: Colors.grey[700],
                    onPressed: () {
                      // Navigate to settings or profile
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Summary Cards Row
              SizedBox(
                height: 130,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildSummaryCard(
                      title: "Scans Today",
                      count: "25",
                      icon: Icons.qr_code_scanner,
                      color: Colors.blueAccent,
                    ),
                    _buildSummaryCard(
                      title: "Total History",
                      count: "1200",
                      icon: Icons.history,
                      color: Colors.orange,
                    ),
                    _buildSummaryCard(
                      title: "Favorites",
                      count: "30",
                      icon: Icons.favorite,
                      color: Colors.redAccent,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),

              // Quick Action buttons
              Text(
                "Quick Actions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildActionButton(
                    icon: Icons.qr_code_scanner,
                    label: "Scan QR",
                    onTap: () {
                      // Navigate to scanner
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.history,
                    label: "History",
                    onTap: () {
                      // Navigate to history
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.favorite_border,
                    label: "Favorites",
                    onTap: () {
                      // Navigate to favorites
                    },
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Featured Section
              Text(
                "Featured",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
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
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
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
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 35, color: color),
          const Spacer(),
          Text(
            count,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 14, color: color.withOpacity(0.75)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
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
            Icon(icon, size: 36, color: Colors.blue),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
