import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme.dart';
import '../globals.dart';

class AddSalesEntryScreen extends StatefulWidget {
  const AddSalesEntryScreen({Key? key}) : super(key: key);

  @override
  State<AddSalesEntryScreen> createState() => _AddSalesEntryScreenState();
}

class _AddSalesEntryScreenState extends State<AddSalesEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  String? selectedProductId;
  String? selectedCategory;
  String? selectedRegion;
  String? selectedWeather;
  String? selectedSeasonality;
  String? selectedHoliday;
  List<String> productIds = [];
  bool isLoadingProducts = false;
  bool isSubmitting = false;
  String? errorMsg;
  bool isFetchingProduct = false;

  // Controllers
  final unitsSoldController = TextEditingController();
  final priceController = TextEditingController();
  final discountController = TextEditingController();
  final competitorPricingController = TextEditingController();
  final salesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchProductIds();
    // Listen for changes to auto-calculate sales
    unitsSoldController.addListener(_updateSales);
    priceController.addListener(_updateSales);
    discountController.addListener(_updateSales);
  }

  @override
  void dispose() {
    unitsSoldController.dispose();
    priceController.dispose();
    discountController.dispose();
    competitorPricingController.dispose();
    salesController.dispose();
    super.dispose();
  }

  void _updateSales() {
    final units = int.tryParse(unitsSoldController.text) ?? 0;
    final price = double.tryParse(priceController.text) ?? 0.0;
    final discount = double.tryParse(discountController.text) ?? 0.0;
    final sales = (units * price) * (1 - discount / 100);
    salesController.text = sales.toStringAsFixed(2);
  }

  Future<void> fetchProductIds() async {
    setState(() {
      isLoadingProducts = true;
    });
    try {
      final response = await http.get(Uri.parse('$API_URL/products?access_token=$accessToken'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          productIds = data.map((e) => e['ProductID'].toString()).toList();
        });
      }
    } catch (e) {
      // ignore error, show empty dropdown
    } finally {
      setState(() {
        isLoadingProducts = false;
      });
    }
  }

  Future<void> fetchProductDetails(String productId) async {
    setState(() {
      isFetchingProduct = true;
    });
    try {
      final response = await http.get(Uri.parse('$API_URL/products/$productId?access_token=$accessToken'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        priceController.text = data['Price'].toString();
        discountController.text = data['Discount'].toString();
        _updateSales();
      }
    } catch (e) {
      // ignore error, keep previous value
    } finally {
      setState(() {
        isFetchingProduct = false;
      });
    }
  }

  Future<void> submitEntry() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isSubmitting = true;
      errorMsg = null;
    });
    try {
      final response = await http.post(
        Uri.parse('$API_URL/add_entry'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Date': selectedDate?.toIso8601String().substring(0, 10),
          'Product ID': selectedProductId,
          'Category': selectedCategory,
          'Region': selectedRegion,
          'Units Sold': int.tryParse(unitsSoldController.text),
          'Price': double.tryParse(priceController.text),
          'Discount': double.tryParse(discountController.text),
          'Weather Condition': selectedWeather,
          'Holiday/Promotion': selectedHoliday == 'Yes' ? 1 : 0,
          'Competitor Pricing': double.tryParse(competitorPricingController.text),
          'Seasonality': selectedSeasonality,
          'Sales': double.tryParse(salesController.text),
          'access_token': accessToken,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry added successfully!')));
        Navigator.pop(context);
      } else {
        setState(() {
          errorMsg = data['error'] ?? 'Failed to add entry.';
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = 'Could not connect to server.';
      });
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Add Sales Entry', style: TextStyle(color: Colors.white),),
        backgroundColor: AppColors.button,
      ),
      body: isLoadingProducts
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date Picker
                    Text('Date', style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                        ),
                        child: Text(
                          selectedDate == null ? 'Select Date' : selectedDate!.toIso8601String().substring(0, 10),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Product ID Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedProductId,
                      items: productIds
                          .map((id) => DropdownMenuItem(value: id, child: Text(id)))
                          .toList(),
                      onChanged: (val) {
                        setState(() => selectedProductId = val);
                        if (val != null) fetchProductDetails(val);
                      },
                      decoration: const InputDecoration(labelText: 'Product ID'),
                      validator: (val) => val == null ? 'Select a product' : null,
                    ),
                    const SizedBox(height: 16),
                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: ['Toys', 'Clothing', 'Groceries', 'Electronics', 'Furniture']
                          .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedCategory = val),
                      decoration: const InputDecoration(labelText: 'Category'),
                      validator: (val) => val == null ? 'Select a category' : null,
                    ),
                    const SizedBox(height: 16),
                    // Region Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedRegion,
                      items: ['South', 'North', 'West', 'East']
                          .map((reg) => DropdownMenuItem(value: reg, child: Text(reg)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedRegion = val),
                      decoration: const InputDecoration(labelText: 'Region'),
                      validator: (val) => val == null ? 'Select a region' : null,
                    ),
                    const SizedBox(height: 16),
                    // Units Sold
                    TextFormField(
                      controller: unitsSoldController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Units Sold'),
                      validator: (val) => (int.tryParse(val ?? '') ?? 0) > 0 ? null : 'Enter valid units',
                    ),
                    const SizedBox(height: 16),
                    // Price
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price',
                        suffixIcon: isFetchingProduct
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : null,
                      ),
                      validator: (val) => (double.tryParse(val ?? '') ?? 0) > 0 ? null : 'Enter valid price',
                    ),
                    const SizedBox(height: 16),
                    // Discount
                    TextFormField(
                      controller: discountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Discount'),
                      validator: (val) => (double.tryParse(val ?? '') ?? 0) >= 0 ? null : 'Enter valid discount',
                    ),
                    const SizedBox(height: 16),
                    // Weather Condition Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedWeather,
                      items: ['Sunny', 'Cloudy', 'Snowy', 'Rainy']
                          .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedWeather = val),
                      decoration: const InputDecoration(labelText: 'Weather Condition'),
                      validator: (val) => val == null ? 'Select weather' : null,
                    ),
                    const SizedBox(height: 16),
                    // Holiday/Promotion Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedHoliday,
                      items: ['Yes', 'No']
                          .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedHoliday = val),
                      decoration: const InputDecoration(labelText: 'Holiday/Promotion'),
                      validator: (val) => val == null ? 'Select Yes/No' : null,
                    ),
                    const SizedBox(height: 16),
                    // Competitor Pricing
                    TextFormField(
                      controller: competitorPricingController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Competitor Pricing'),
                      validator: (val) => (double.tryParse(val ?? '') ?? 0) >= 0 ? null : 'Enter valid price',
                    ),
                    const SizedBox(height: 16),
                    // Seasonality Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedSeasonality,
                      items: ['Winter', 'Autumn', 'Spring', 'Summer']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) => setState(() => selectedSeasonality = val),
                      decoration: const InputDecoration(labelText: 'Seasonality'),
                      validator: (val) => val == null ? 'Select seasonality' : null,
                    ),
                    const SizedBox(height: 16),
                    // Sales (auto-calculated)
                    TextFormField(
                      controller: salesController,
                      enabled: false,
                      decoration: const InputDecoration(labelText: 'Sales (auto-calculated)'),
                    ),
                    const SizedBox(height: 24),
                    if (errorMsg != null) ...[
                      Text(errorMsg!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 12),
                    ],
                    ElevatedButton(
                      onPressed: isSubmitting ? null : submitEntry,
                      child: isSubmitting
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Add Entry', style: TextStyle(color: Colors.white),),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 