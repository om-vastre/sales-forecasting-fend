import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/options_screen.dart';
import 'screens/manage_products_screen.dart';
import 'screens/add_sales_entry_screen.dart';

void main() {
  runApp(const SalesForecastingApp());
}

class SalesForecastingApp extends StatelessWidget {
  const SalesForecastingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sales Forecasting',
      theme: appTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/options': (context) => const OptionsScreen(),
        '/manage_products': (context) => const ManageProductsScreen(),
        '/add_sales_entry': (context) => const AddSalesEntryScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
