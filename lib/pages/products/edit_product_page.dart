import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/components/button.dart';
import 'package:myapp/components/textfield.dart';
import 'package:myapp/services/activity_firestore.dart';
import 'package:myapp/services/palette_firestore.dart';
import 'package:myapp/services/product_firestore.dart';
import 'package:myapp/services/supplier_firestore.dart';
import 'package:myapp/services/transaction_firestore.dart';

class EditProductPage extends StatefulWidget {
  final String productId;
  const EditProductPage({super.key, required this.productId});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class Supplier {
  final String id;
  final String name;

  Supplier(this.id, this.name);
}

class _EditProductPageState extends State<EditProductPage> {
  String hintText = 'Select Supplier';

  // Controllers
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController supplierNameController = TextEditingController();
  final TextEditingController supplierIdController = TextEditingController();

  // Services
  final SupplierFirestoreService supplierFirestoreService =
      SupplierFirestoreService();
  final ProductFirestoreService productFirestoreService =
      ProductFirestoreService();
  final PaletteFirestoreService paletteFirestoreService =
      PaletteFirestoreService();
  final TransactionFirestoreService transactionFirestoreService =
      TransactionFirestoreService();

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
                        String? operatorEmail =
                            FirebaseAuth.instance.currentUser!.email;
                        transactionFirestoreService.createTransaction(
                            operatorEmail!, 'Update product', widget.productId);
                        productFirestoreService.updateProduct(
                            widget.productId,
                            productNameController.text,
                            supplierIdController.text,
                            supplierNameController.text);
                        // show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product updated'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      text: 'Yes',
                    ),
                    MyButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      text: 'No',
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
                    'Are you sure you want to delete this product?',
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
                      onTap: () async {
                        String? operatorEmail =
                            FirebaseAuth.instance.currentUser!.email;
                        await transactionFirestoreService.createTransaction(
                            operatorEmail!, 'Delete product', widget.productId);
                        await paletteFirestoreService
                            .removeProductFromAllPalette(widget.productId);
                        await productFirestoreService
                            .deleteProduct(widget.productId);
                        await ActivityFirestoreService()
                            .deleteActivityByProductId(widget.productId);
                        // show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product deleted'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.popAndPushNamed(context, '/products');
                      },
                      text: 'Yes',
                    ),
                    MyButton(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      text: 'No',
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
          // if homepage, no back button
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            'Edit Product',
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
                  controller: productNameController,
                  hintText: 'Product Name',
                  obscureText: false,
                  enabled: true),
              const SizedBox(height: 25.0),
              StreamBuilder(
                stream: supplierFirestoreService.readSupplier(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Supplier> suppliers = snapshot.data!.docs.map((doc) {
                      return Supplier(doc.id, doc['name']);
                    }).toList();

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DropdownButton(
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: suppliers
                                .map<DropdownMenuItem<Supplier>>(
                                    (suppliers) => DropdownMenuItem(
                                          value: suppliers,
                                          child: Text(suppliers.name),
                                        ))
                                .toList(),
                            onChanged: (Supplier? value) {
                              if (value != null) {
                                setState(() {
                                  hintText = value.name;
                                  supplierNameController.text = value.name;
                                  supplierIdController.text = value.id;
                                });
                              }
                            },
                            hint: Text(hintText)),
                      ),
                    );
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
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
