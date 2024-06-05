// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'package:Mahasu/services/transaction_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Mahasu/components/myappbar.dart';
import 'package:Mahasu/pages/products/product_page.dart';
import 'package:Mahasu/services/product_firestore.dart';
import 'package:Mahasu/services/supplier_firestore.dart';

class NewProductPage extends StatefulWidget {
  const NewProductPage({super.key});

  @override
  State<NewProductPage> createState() => _NewProductPageState();
}

class Warehouses {
  final String id;
  final String name;

  Warehouses(this.id, this.name);
}

class _NewProductPageState extends State<NewProductPage> {
  final _formGlobalKey = GlobalKey<FormState>();

  String hintText = 'Select Supplier';

  // controllers
  final TextEditingController productNameCtl = TextEditingController();
  final TextEditingController productIdCtl = TextEditingController();
  final TextEditingController supplierNameCtl = TextEditingController();
  final TextEditingController supplierIdCtl = TextEditingController();

  // services
  final ProductFirestoreService productService = ProductFirestoreService();
  final SupplierFirestoreService supplierService = SupplierFirestoreService();
  final TransactionFirestoreService transactionservice =
      TransactionFirestoreService();

  onTap() async {
    String? operatorEmail = FirebaseAuth.instance.currentUser!.email;

    String productId = await productService.createProduct(
        productNameCtl.text, supplierIdCtl.text, supplierNameCtl.text);

    if (productId == 'Product exist') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product name ${productNameCtl.text} already exist'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    await supplierService.addProductToSupplier(
        supplierIdCtl.text, productId, productNameCtl.text);

    await transactionservice.createTransaction(
        operatorEmail!, 'Create product', productId);

    // show snack bar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New product created'),
        duration: const Duration(seconds: 2),
      ),
    );
    productIdCtl.clear();
    productNameCtl.clear();
    supplierIdCtl.clear();
    supplierNameCtl.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: 'New Product',
        isHomePage: false,
        isAction: false,
        backPageDestination: AllProductPage(),
        destinationPage: NewProductPage(),
      ),
      body: Form(
        key: _formGlobalKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: <Widget>[
              TextField(
                enabled: true,
                controller: productNameCtl,
                obscureText: false,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintText: 'Product name',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              StreamBuilder(
                  stream: supplierService.readSupplier(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<Warehouses> warehouseList =
                          snapshot.data!.docs.map((doc) {
                        return Warehouses(doc.id, doc['name']);
                      }).toList();

                      return Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5)),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton(
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: warehouseList
                                .map<DropdownMenuItem<Warehouses>>(
                                    (supplier) => DropdownMenuItem(
                                          value: supplier,
                                          child: Text(supplier.name),
                                        ))
                                .toList(),
                            onChanged: (Warehouses? value) {
                              if (value != null) {
                                setState(() {
                                  hintText = value.name;
                                  supplierNameCtl.text = value.name;
                                  supplierIdCtl.text = value.id;
                                });
                              }
                            },
                            hint: Text(hintText),
                          ),
                        ),
                      );
                    } else {
                      return const Text('No data');
                    }
                  }),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: (productNameCtl.text.isNotEmpty &&
                        supplierNameCtl.text.isNotEmpty &&
                        supplierIdCtl.text.isNotEmpty)
                    ? onTap
                    : () {
                        // show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Center(
                              child: Text('Please fill in the required fields'),
                            ),
                          ),
                        );
                      },
                child: Container(
                  height: 50,
                  width: 200,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Submit',
                        style: const TextStyle(color: Colors.white),
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

  @override
  void dispose() {
    supplierIdCtl.dispose();
    supplierNameCtl.dispose();
    productNameCtl.dispose();
    productIdCtl.dispose();
    super.dispose();
  }
}
