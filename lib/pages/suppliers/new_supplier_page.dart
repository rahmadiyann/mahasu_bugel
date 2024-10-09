import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/components/button.dart';
import 'package:myapp/pages/suppliers/suppliers_page.dart';
import 'package:myapp/services/supplier_firestore.dart';
import 'package:myapp/services/transaction_firestore.dart';

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

    if (supplierNameCtl.text.isEmpty ||
        supplierPhoneCtl.text.isEmpty ||
        supplierAddressCtl.text.isEmpty ||
        supplierContactCtl.text.isEmpty) {
      var emptyFields = [];
      if (supplierNameCtl.text.isEmpty) {
        emptyFields.add('Supplier name');
      }
      if (supplierPhoneCtl.text.isEmpty) {
        emptyFields.add('Supplier phone number');
      }
      if (supplierAddressCtl.text.isEmpty) {
        emptyFields.add('Supplier address');
      }
      if (supplierContactCtl.text.isEmpty) {
        emptyFields.add('Supplier contact name');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Please fill in the following field(s): ${emptyFields.join(', ')}'),
        ),
      );
      return;
    }
    final supplierId = await supplierService.createSupplier(
        supplierNameCtl.text,
        supplierAddressCtl.text,
        supplierContactCtl.text,
        supplierPhoneCtl.text);

    await transactionservice.createTransaction(
        operatorEmail!, 'Create supplier', supplierId);
    // show snack bar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New supplier created'),
        duration: Duration(seconds: 2),
      ),
    );
    supplierNameCtl.clear();
    supplierAddressCtl.clear();
    supplierNameCtl.clear();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SuppliersPage(),
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
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintText: 'Supplier name',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              TextField(
                enabled: true,
                controller: supplierAddressCtl,
                obscureText: false,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintText: 'Supplier address',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              TextField(
                enabled: true,
                controller: supplierContactCtl,
                obscureText: false,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintText: 'Supplier contact name',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              TextField(
                enabled: true,
                controller: supplierPhoneCtl,
                obscureText: false,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintText: 'Supplier phone number',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              MyButton(
                onTap: onTap,
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
