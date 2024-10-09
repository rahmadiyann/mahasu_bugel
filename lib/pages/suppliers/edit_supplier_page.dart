import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/components/button.dart';
import 'package:myapp/components/textfield.dart';
import 'package:myapp/services/supplier_firestore.dart';
import 'package:myapp/services/transaction_firestore.dart';

class EditSupplierPage extends StatefulWidget {
  final String supplierId;
  final String supplierName;
  final String supplierPhone;
  final String supplierAddress;
  const EditSupplierPage(
      {super.key,
      required this.supplierId,
      required this.supplierName,
      required this.supplierPhone,
      required this.supplierAddress});

  @override
  State<EditSupplierPage> createState() => _EditSupplierPageState();
}

class _EditSupplierPageState extends State<EditSupplierPage> {
  // Controllers
  final TextEditingController supplierNameController = TextEditingController();
  final TextEditingController supplierPhoneController = TextEditingController();
  final TextEditingController supplierAddressController =
      TextEditingController();

  // Services
  final SupplierFirestoreService supplierFirestoreService =
      SupplierFirestoreService();
  final TransactionFirestoreService transactionservice =
      TransactionFirestoreService();

  // initialize controllers to be set to the values of the page parameters
  @override
  void initState() {
    super.initState();
    supplierNameController.text = widget.supplierName;
    supplierPhoneController.text = widget.supplierPhone;
    supplierAddressController.text = widget.supplierAddress;
  }

  updateButtonTap() {
    showModalBottomSheet(
      useSafeArea: true,
      showDragHandle: false,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: Colors.white,
          child: SizedBox(
            height: 400,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(251, 210, 154, 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/warningicon.png',
                      height: 100,
                      width: 100,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 100,
                  width: 300,
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Are you sure you want to update this product?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MyButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      text: 'No',
                    ),
                    MyButton(
                      onTap: () {
                        String? operatorEmail =
                            FirebaseAuth.instance.currentUser!.email;
                        transactionservice.createTransaction(
                          operatorEmail!,
                          'update supplier',
                          widget.supplierId,
                        );
                        supplierFirestoreService.updateSupplier(
                            widget.supplierId,
                            supplierNameController.text,
                            supplierAddressController.text,
                            supplierPhoneController.text);
                        // show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Supplier updated'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      text: 'Yes',
                    ),
                  ],
                ),
                const SizedBox(height: 20)
              ],
            ),
          ),
        ),
      ),
    );
  }

  deleteButtonTap() {
    showModalBottomSheet(
      useSafeArea: true,
      showDragHandle: false,
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: Container(
          color: Colors.white,
          child: SizedBox(
            height: 400,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(251, 154, 154, 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/warningicon.png',
                      height: 100,
                      width: 100,
                      color: const Color.fromRGBO(255, 70, 70, 1),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 100,
                  width: 300,
                  alignment: Alignment.topCenter,
                  child: Text(
                    'Are you sure you want to delete this supplier?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MyButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      text: 'No',
                    ),
                    MyButton(
                      onTap: () {
                        String? operatorEmail =
                            FirebaseAuth.instance.currentUser!.email;
                        transactionservice.createTransaction(
                          operatorEmail!,
                          'delete supplier',
                          widget.supplierId,
                        );
                        supplierFirestoreService
                            .deleteSupplier(widget.supplierId);
                        // show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Supplier deleted'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      text: 'Yes',
                    ),
                  ],
                ),
                const SizedBox(height: 20)
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.grey[100],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Edit: ${widget.supplierName}',
            style: GoogleFonts.nunitoSans(
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 20,
                height: 1.4,
                color: Colors.black,
              ),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: () {
                  updateButtonTap();
                },
                child: Container(
                  width: 70,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Text(
                      'SAVE',
                      style: GoogleFonts.nunitoSans(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.4,
                          color: Color(0xFF058B06),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
      body: Form(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: <Widget>[
              MyTextField(
                  controller: supplierNameController,
                  hintText: 'Supplier Name',
                  obscureText: false,
                  enabled: true),
              const SizedBox(height: 25.0),
              MyTextField(
                  controller: supplierAddressController,
                  hintText: 'Supplier Address',
                  obscureText: false,
                  enabled: true),
              const SizedBox(height: 25.0),
              MyTextField(
                  controller: supplierPhoneController,
                  hintText: 'Supplier Phone',
                  obscureText: false,
                  number: true,
                  enabled: true),
              const SizedBox(height: 400),
              GestureDetector(
                onTap: deleteButtonTap,
                child: Container(
                  height: 50,
                  width: 200,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade400, Colors.red.shade600],
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.white),
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
}
