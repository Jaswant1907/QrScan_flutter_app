import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ClipboardData, Clipboard;
import 'package:url_launcher/url_launcher.dart';

class LinkDetailsScreen extends StatelessWidget {
  final String url;

  const LinkDetailsScreen({super.key, required this.url});

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Link copied to clipboard')));
  }

  Future<void> _openLink() async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Link Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: ListTile(
                title: const Text('Scanned Link'),
                subtitle: Text(url, overflow: TextOverflow.ellipsis),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyToClipboard(context),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.open_in_browser),
                label: const Text('Open Link'),
                onPressed: _openLink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
