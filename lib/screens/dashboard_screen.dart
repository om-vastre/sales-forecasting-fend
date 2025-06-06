import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import '../theme.dart';
import '../globals.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Dropdown values
  String salesChartRange = 'Next Week';
  String statsRange = 'This Day';
  bool isLoadingGraph = false;
  bool isLoadingStats = false;
  bool isLoggingOut = false;
  String? graphError;
  String? statsError;
  String? logoutError;

  List<Map<String, dynamic>> salesPredictions = [];
  double? avgPrediction;
  double? todaySale;
  int? qtySold;

  // Dropdown options
  final List<String> salesChartOptions = ['Next Week', 'Next Month'];
  final List<String> statsOptions = ['This Day', 'Last 7 Days', 'Last 30 Days'];

  @override
  void initState() {
    super.initState();
    fetchSalesGraph();
    fetchStats();
  }

  Future<void> fetchSalesGraph() async {
    setState(() {
      isLoadingGraph = true;
      graphError = null;
      salesPredictions = [];
      avgPrediction = null;
    });
    String model = salesChartRange == 'Next Week' ? 'week' : 'month';
    int nDays = salesChartRange == 'Next Week' ? 7 : 30;
    try {
      final response = await http.post(
        Uri.parse('$API_URL/predict_last'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': model,
          'n_days': nDays,
          'access_token': accessToken,
        }),
      ).timeout(const Duration(seconds: 15));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['predictions'] != null) {
        salesPredictions = List<Map<String, dynamic>>.from(data['predictions']);
        // Calculate avg
        if (salesPredictions.isNotEmpty) {
          avgPrediction = salesPredictions
                  .map((e) => (e['Predicted_Sales'] as num).toDouble())
                  .reduce((a, b) => a + b) /
              salesPredictions.length;
        }
      } else {
        graphError = data['error'] ?? 'Failed to load sales graph.';
      }
    } catch (e) {
      graphError = 'Could not connect to server.';
    } finally {
      setState(() {
        isLoadingGraph = false;
      });
    }
  }

  Future<void> fetchStats() async {
    setState(() {
      isLoadingStats = true;
      statsError = null;
      todaySale = null;
      qtySold = null;
    });
    String range;
    switch (statsRange) {
      case 'This Day':
        range = 'day';
        break;
      case 'Last 7 Days':
        range = '7days';
        break;
      case 'Last 30 Days':
        range = '30days';
        break;
      default:
        range = 'day';
    }
    try {
      final response = await http.post(
        Uri.parse('$API_URL/getstats'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'access_token': accessToken,
          'range': statsRange,
        }),
      ).timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['rupees'] != null && data['qty'] != null) {
        todaySale = (data['rupees'] as num).toDouble();
        qtySold = (data['qty'] as num).toInt();
      } else {
        statsError = data['error'] ?? 'Failed to load statistics.';
      }
    } catch (e) {
      statsError = 'Could not connect to server.';
    } finally {
      setState(() {
        isLoadingStats = false;
      });
    }
  }

  Future<void> handleLogout() async {
    setState(() {
      isLoggingOut = true;
      logoutError = null;
    });
    try {
      final response = await http.post(
        Uri.parse('$API_URL/logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'access_token': accessToken}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        accessToken = null;
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/');
      } else {
        setState(() {
          logoutError = data['error'] ?? 'Logout failed.';
        });
      }
    } catch (e) {
      setState(() {
        logoutError = 'Could not connect to server.';
      });
    } finally {
      setState(() {
        isLoggingOut = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        backgroundColor: AppColors.button,
        elevation: 0,
        title: const Text('Sales Forecasting', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: isLoggingOut
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.logout, color: Colors.white),
            onPressed: isLoggingOut ? null : handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sales Chart Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: salesChartRange,
                  isExpanded: true,
                  items: salesChartOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: const TextStyle(fontSize: 18)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        salesChartRange = val;
                      });
                      fetchSalesGraph();
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Sales Graph
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sales Graph', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: isLoadingGraph
                        ? const Center(child: CircularProgressIndicator())
                        : graphError != null
                            ? Center(child: Text(graphError!, style: const TextStyle(color: Colors.red)))
                            : salesPredictions.isEmpty
                                ? const Center(child: Text('No data'))
                                : LineChart(
                                    LineChartData(
                                      gridData: FlGridData(show: true, drawVerticalLine: false),
                                      titlesData: FlTitlesData(
                                        leftTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: true, reservedSize: 0, getTitlesWidget: (value, meta) => Text('')), // Hide numbers
                                        ),
                                        bottomTitles: AxisTitles(
                                          sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: (value, meta) {
                                            int idx = value.toInt();
                                            if (idx < 0 || idx >= salesPredictions.length) return const SizedBox();
                                            return Text(salesPredictions[idx]['Date'].substring(5), style: const TextStyle(fontSize: 10));
                                          }),
                                        ),
                                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      ),
                                      borderData: FlBorderData(show: true, border: Border.all(width: 0.5, color: AppColors.button)),
                                      minX: 0,
                                      maxX: (salesPredictions.length - 1).toDouble(),
                                      minY: salesPredictions.map((e) => (e['Predicted_Sales'] as num).toDouble()).reduce((a, b) => a < b ? a : b),
                                      maxY: salesPredictions.map((e) => (e['Predicted_Sales'] as num).toDouble()).reduce((a, b) => a > b ? a : b),
                                      lineBarsData: [
                                        LineChartBarData(
                                          spots: [
                                            for (int i = 0; i < salesPredictions.length; i++)
                                              FlSpot(i.toDouble(), (salesPredictions[i]['Predicted_Sales'] as num).toDouble()),
                                          ],
                                          isCurved: true,
                                          color: AppColors.button,
                                          barWidth: 1,
                                          dotData: FlDotData(show: true),
                                          belowBarData: BarAreaData(show: true, color: AppColors.button.withOpacity(0.15)),
                                        ),
                                      ],
                                    ),
                                  ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text('Y-axis: Sales', style: TextStyle(fontSize: 14)),
                      Text('X-axis: Days', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Statistics Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Statistics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: statsRange,
                          items: statsOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                statsRange = val;
                              });
                              fetchStats();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  isLoadingStats
                      ? const Center(child: CircularProgressIndicator())
                      : statsError != null
                          ? Center(child: Text(statsError!, style: const TextStyle(color: Colors.red)))
                          : Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text("Total Sale is", style: TextStyle(fontSize: 16)),
                                      const SizedBox(height: 8),
                                      Text(
                                        todaySale != null ? '₹ ${todaySale!.toStringAsFixed(0)}' : '-',
                                        style: const TextStyle(fontSize: 24, color: Colors.teal, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 40,
                                  color: const Color(0xFFE0E0E0),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      const Text('Qty. Sold', style: TextStyle(fontSize: 16)),
                                      const SizedBox(height: 8),
                                      Text(
                                        qtySold != null ? qtySold.toString() : '-',
                                        style: const TextStyle(fontSize: 24, color: Colors.teal, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Predictions Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Predictions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 12),
                  avgPrediction == null
                      ? const Text('No prediction data')
                      : Row(
                          children: [
                            Text(
                              avgPrediction! >= 0
                                  ? '+ ₹ ${avgPrediction!.toStringAsFixed(0)}'
                                  : '- ₹ ${avgPrediction!.abs().toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: avgPrediction! >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              avgPrediction! >= 0 ? 'Positive Prediction' : 'Negative Prediction',
                              style: TextStyle(
                                fontSize: 16,
                                color: avgPrediction! >= 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.button,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(context, '/options');
        },
      ),
    );
  }
} 