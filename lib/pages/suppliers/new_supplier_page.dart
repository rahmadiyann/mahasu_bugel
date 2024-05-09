// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:Mahasu/components/button.dart';
import 'package:Mahasu/components/myappbar.dart';
import 'package:Mahasu/pages/suppliers/suppliers_page.dart';
import 'package:Mahasu/services/supplier_firestore.dart';

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

  // validation
  bool _isSupplierNameValid = false;
  bool _isSupplierContactValid = false;
  bool _isSupplierPhoneValid = false;
  bool _isSupplierAddressValid = false;

  // services
  final SupplierFirestoreService supplierService = SupplierFirestoreService();

  onTap() async {
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
      appBar: MyAppBar(
        title: 'New Supplier',
        isHomePage: false,
        isAction: false,
        backPageDestination: AllSuppliersPage(),
        destinationPage: NewSupplierPage(),
      ),
      body: Form(
        key: _formGlobalKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: <Widget>[
              TextField(
                onEditingComplete: () {
                  setState(() {
                    _isSupplierNameValid = supplierNameCtl.text.isNotEmpty;
                  });
                },
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
                onEditingComplete: () {
                  setState(() {
                    _isSupplierAddressValid =
                        supplierAddressCtl.text.isNotEmpty;
                  });
                },
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
                onEditingComplete: () {
                  setState(() {
                    _isSupplierContactValid =
                        supplierContactCtl.text.isNotEmpty;
                  });
                },
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
                onEditingComplete: () {
                  setState(() {
                    _isSupplierPhoneValid = supplierPhoneCtl.text.isNotEmpty;
                  });
                },
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
                onTap: (_isSupplierAddressValid &&
                        _isSupplierNameValid &&
                        _isSupplierContactValid &&
                        _isSupplierPhoneValid)
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
