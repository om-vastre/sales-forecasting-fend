import 'package:flutter/material.dart';
import '../theme.dart';
import '../globals.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class OptionsScreen extends StatefulWidget {
  const OptionsScreen({super.key});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  bool isDownloading = false;
  String? downloadError;

  Future<void> downloadDataset() async {
    setState(() {
      isDownloading = true;
      downloadError = null;
    });
    try {
      final url = Uri.parse('$API_URL/download_dataset?access_token=$accessToken');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/dataset.csv');
        await file.writeAsBytes(response.bodyBytes);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dataset downloaded to ${file.path}'), action: SnackBarAction(label: 'Open', onPressed: () => OpenFile.open(file.path))),
        );
      } else {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          downloadError = data['error'] ?? 'Failed to download dataset.';
        });
      }
    } catch (e) {
      setState(() {
        downloadError = 'Could not download dataset.';
      });
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Options', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.button,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.button.withOpacity(0.15),
                  child: const Icon(Icons.inventory, color: Color(0xFF4B32E3)),
                ),
                title: const Text('Manage Products in Inventory'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () => Navigator.pushNamed(context, '/manage_products'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.15),
                  child: const Icon(Icons.add_chart, color: Colors.green),
                ),
                title: const Text('Add Sales Entry'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () => Navigator.pushNamed(context, '/add_sales_entry'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.purple.withOpacity(0.15),
                  child: const Icon(Icons.download, color: Colors.purple),
                ),
                title: const Text('Export Sales Data'),
                trailing: isDownloading
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: isDownloading ? null : downloadDataset,
              ),
            ),
            if (downloadError != null) ...[
              const SizedBox(height: 12),
              Text(downloadError!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
