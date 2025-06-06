import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme.dart';
import '../globals.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({Key? key}) : super(key: key);

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  List<Map<String, dynamic>> products = [];
  bool isLoading = false;
  String? errorMsg;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
      errorMsg = null;
    });
    try {
      final response = await http.get(Uri.parse('$API_URL/products?access_token=$accessToken'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        products = data.cast<Map<String, dynamic>>();
      } else {
        final data = jsonDecode(response.body);
        errorMsg = data['error'] ?? 'Failed to load products.';
      }
    } catch (e) {
      errorMsg = 'Could not connect to server.';
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> showEditProductDialog(Map<String, dynamic> product) async {
    final priceController = TextEditingController(text: product['Price'].toString());
    final discountController = TextEditingController(text: product['Discount'].toString());
    final qtyController = TextEditingController(text: product['QtyRemaining'].toString());
    bool isSubmitting = false;
    String? dialogError;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit ${product['ProductID']}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price'),
                  ),
                  SizedBox(height: 15,),
                  TextField(
                    controller: discountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Discount'),
                  ),
                  SizedBox(height: 15,),
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Qty Remaining'),
                  ),
                  
                  if (dialogError != null) ...[
                    Text(dialogError!, style: const TextStyle(color: Colors.red)),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setState(() => isSubmitting = true);
                          try {
                            final response = await http.put(
                              Uri.parse('$API_URL/products/${product['ProductID']}'),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({
                                'Price': double.tryParse(priceController.text),
                                'Discount': double.tryParse(discountController.text),
                                'QtyRemaining': int.tryParse(qtyController.text),
                                'access_token': accessToken,
                              }),
                            );
                            final data = jsonDecode(response.body);
                            if (response.statusCode == 200) {
                              Navigator.pop(context);
                              fetchProducts();
                            } else {
                              setState(() => dialogError = data['error'] ?? 'Failed to update product.');
                            }
                          } catch (e) {
                            setState(() => dialogError = 'Could not update product.');
                          } finally {
                            setState(() => isSubmitting = false);
                          }
                        },
                  child: isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> showDeleteProductDialog(String productId) async {
    bool isSubmitting = false;
    String? dialogError;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Delete Product'),
              content: dialogError != null
                  ? Text(dialogError!, style: const TextStyle(color: Colors.red))
                  : Text('Are you sure you want to delete $productId?'),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setState(() => isSubmitting = true);
                          try {
                            final response = await http.delete(
                              Uri.parse('$API_URL/products/$productId?access_token=$accessToken'),
                            );
                            final data = jsonDecode(response.body);
                            if (response.statusCode == 200) {
                              Navigator.pop(context);
                              fetchProducts();
                            } else {
                              setState(() => dialogError = data['error'] ?? 'Failed to delete product.');
                            }
                          } catch (e) {
                            setState(() => dialogError = 'Could not delete product.');
                          } finally {
                            setState(() => isSubmitting = false);
                          }
                        },
                  child: isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Delete', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> showAddProductDialog() async {
    final idController = TextEditingController();
    final priceController = TextEditingController();
    final discountController = TextEditingController();
    final qtyController = TextEditingController();
    bool isSubmitting = false;
    String? dialogError;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Product'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: idController,
                      decoration: const InputDecoration(labelText: 'Product ID'),
                    ),
                    SizedBox(height: 15,),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price'),
                    ),
                    SizedBox(height: 15,),
                    TextField(
                      controller: discountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Discount'),
                    ),
                    SizedBox(height: 15,),
                    TextField(
                      controller: qtyController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Qty Remaining'),
                    ),
                    if (dialogError != null) ...[
                      const SizedBox(height: 8),
                      Text(dialogError!, style: const TextStyle(color: Colors.red)),
                    ]
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          setState(() => isSubmitting = true);
                          try {
                            final response = await http.post(
                              Uri.parse('$API_URL/products'),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({
                                'ProductID': idController.text.trim(),
                                'Price': double.tryParse(priceController.text),
                                'Discount': double.tryParse(discountController.text),
                                'QtyRemaining': int.tryParse(qtyController.text),
                                'access_token': accessToken,
                              }),
                            );
                            final data = jsonDecode(response.body);
                            if (response.statusCode == 201) {
                              Navigator.pop(context);
                              fetchProducts();
                            } else {
                              setState(() => dialogError = data['error'] ?? 'Failed to add product.');
                            }
                          } catch (e) {
                            setState(() => dialogError = 'Could not add product.');
                          } finally {
                            setState(() => isSubmitting = false);
                          }
                        },
                  child: isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Add', style: TextStyle(color: Colors.white),),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Manage Products', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.button,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Product',
            onPressed: showAddProductDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg != null
              ? Center(child: Text(errorMsg!, style: const TextStyle(color: Colors.red)))
              : products.isEmpty
                  ? const Center(child: Text('No products found.'))
                  : ListView.separated(
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, idx) {
                        final product = products[idx];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.button.withOpacity(0.15),
                            child: const Icon(Icons.shopping_bag, color: Color(0xFF4B32E3)),
                          ),
                          title: Text(product['ProductID'] ?? ''),
                          subtitle: Text('Price: ₹${product['Price']} | Discount: ${product['Discount']}% | Qty: ${product['QtyRemaining']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Color.fromARGB(255, 208, 208, 208)),
                                tooltip: 'Edit',
                                onPressed: () => showEditProductDialog(product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Color.fromARGB(135, 244, 67, 54)),
                                tooltip: 'Delete',
                                onPressed: () => showDeleteProductDialog(product['ProductID']),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
} 