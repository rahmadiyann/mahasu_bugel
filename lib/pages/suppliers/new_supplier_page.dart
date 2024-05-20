// ignore_for_file: prefer_const_constructors
import 'package:Mahasu/services/transaction_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Mahasu/components/button.dart';
import 'package:Mahasu/pages/suppliers/suppliers_page.dart';
import 'package:Mahasu/services/supplier_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class NewSupplierPage extends StatefulWidget {
  const NewSupplierPage({super.key});

  @override
  State<NewSupplierPage> createState() => _NewSupplierPageState();
}

class Warehouses {
  final String id;
  final String name;

  Warehouses(this.id, this.name);
}

class _NewSupplierPageState extends State<NewSupplierPage> {
  final _formGlobalKey = GlobalKey<FormState>();

  String hintText = 'Select Supplier';

  // controllers
  final TextEditingController supplierNameCtl = TextEditingController();
  final TextEditingController supplierPhoneCtl = TextEditingController();
  final TextEditingController supplierContactCtl = TextEditingController();
  final TextEditingController supplierAddressCtl = TextEditingController();

  // services
  final SupplierFirestoreService supplierService = SupplierFirestoreService();
  final TransactionFirestoreService transactionservice =
      TransactionFirestoreService();

  onTap() async {
    String? operatorEmail = FirebaseAuth.instance.currentUser!.email;
    await transactionservice.createTransaction(
        operatorEmail!, 'Create supplier');
    supplierService.createSupplier(
        supplierNameCtl.text,
        supplierAddressCtl.text,
        supplierContactCtl.text,
        supplierPhoneCtl.text);

    // show snack bar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('New supplier created'),
        duration: const Duration(seconds: 2),
      ),
    );
    supplierNameCtl.clear();
    supplierAddressCtl.clear();
    supplierNameCtl.clear();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AllSuppliersPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        // if homepage, no back button
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Add new supplier',
          style: GoogleFonts.nunitoSans(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 1.4,
              color: Colors.black,
            ),
          ),
        ),
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
                controller: supplierNameCtl,
                obscureText: false,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintText: 'Supplier name',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              TextField(
                enabled: true,
                controller: supplierAddressCtl,
                obscureText: false,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintText: 'Supplier address',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              TextField(
                enabled: true,
                controller: supplierContactCtl,
                obscureText: false,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintText: 'Supplier contact name',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              TextField(
                enabled: true,
                controller: supplierPhoneCtl,
                obscureText: false,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintText: 'Supplier phone number',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              MyButton(
                onTap: (supplierNameCtl.text.isNotEmpty &&
                        supplierNameCtl.text.isNotEmpty &&
                        supplierAddressCtl.text.isNotEmpty &&
                        supplierPhoneCtl.text.isNotEmpty)
                    ? onTap
                    : () {
                        // show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Center(
                                child: Text('Please fill in all the fields')),
                          ),
                        );
                      },
                text: 'Create new supplier',
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    supplierNameCtl.dispose();
    supplierAddressCtl.dispose();
    supplierPhoneCtl.dispose();
    super.dispose();
  }
}
