import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/components/button.dart';
import 'package:myapp/services/activity_firestore.dart';
import 'package:myapp/services/palette_firestore.dart';
import 'package:myapp/services/product_firestore.dart';
import 'package:myapp/services/transaction_firestore.dart';
import 'package:myapp/services/warehouse_firestore.dart';

class EditActivityPage extends StatefulWidget {
  final String activityId;
  const EditActivityPage({super.key, required this.activityId});

  @override
  State<EditActivityPage> createState() => _EditActivityPageState();
}

class _EditActivityPageState extends State<EditActivityPage> {
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _paletteNameController = TextEditingController();
  final TextEditingController _warehouseNameController =
      TextEditingController();
  final TextEditingController _oldQtyController = TextEditingController();
  late String productName;
  late String paletteName;
  late String warehouseName;
  late int oldQty;
  late String oldUnit;
  ProductFirestoreService productService = ProductFirestoreService();
  ActivityFirestoreService activityService = ActivityFirestoreService();
  PaletteFirestoreService paletteService = PaletteFirestoreService();
  WarehouseFirestoreService warehouseService = WarehouseFirestoreService();
  TransactionFirestoreService transactionService =
      TransactionFirestoreService();

  @override
  void initState() {
    super.initState();
    loadProduct();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _productNameController.dispose();
    _paletteNameController.dispose();
    _warehouseNameController.dispose();
    _oldQtyController.dispose();
    super.dispose();
  }

  // fetch data
  Future<void> loadProduct() async {
    final activity = activityService.readActivityById(widget.activityId);
    oldQty = await activity.then((value) => value['qty']);
    oldUnit = await activity.then((value) => value['unit']);
    productName = await activity.then(
      (value) => productService.getProductNameById(
        value['product_id'],
      ),
    );
    paletteName = await activity.then(
      (value) => paletteService.getPaletteName(
        value['palette_id'],
      ),
    );
    warehouseName = await activity.then(
      (value) => paletteService.getWarehouseName(
        value['palette_id'],
      ),
    );
    setState(() {
      _productNameController.text = productName;
      _paletteNameController.text = paletteName;
      _warehouseNameController.text = warehouseName;
      _oldQtyController.text = '${oldQty.toString()} ${oldUnit.toUpperCase()}';
    });
  }

  updateButtonTap() {
    _qtyController.text.isNotEmpty
        ? showModalBottomSheet(
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
                          'Are you sure you want to update this activity?',
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
                            onTap: () async {
                              String? operatorEmail =
                                  FirebaseAuth.instance.currentUser!.email;
                              // print(widget.oldWhId);
                              String message = await activityService
                                  .updateActivityByActivityId(
                                widget.activityId,
                                int.parse(_qtyController.text),
                              );
                              if (message == 'Success') {
                                transactionService.createTransaction(
                                    operatorEmail!,
                                    "Update Activity",
                                    widget.activityId);
                                // show snackbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Product updated'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                                Navigator.pop(context);
                                Navigator.pop(context);
                              } else {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
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
          )
        : ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill in the new quantity'),
              duration: Duration(seconds: 2),
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
          'Edit Activity',
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            scrollDirection: Axis.vertical,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                _productNameController.text.toUpperCase(),
                                style: GoogleFonts.getFont(
                                  'Nunito Sans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                  height: 1.3,
                                  color: const Color(0xFF1E232C),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/rack.png',
                                  height: 15,
                                  width: 15,
                                ),
                                Text(
                                  _paletteNameController.text,
                                  style: GoogleFonts.getFont(
                                    'Nunito Sans',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    height: 1.3,
                                    color: const Color(0xFF1E232C),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Row(
                              children: [
                                Image.asset(
                                  'assets/images/warehouseicon.png',
                                  height: 15,
                                  width: 15,
                                ),
                                Text(
                                  _warehouseNameController.text,
                                  style: GoogleFonts.getFont(
                                    'Nunito Sans',
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                    height: 1.3,
                                    color: const Color(0xFF1E232C),
                                  ),
                                ),
                              ],
                            ),
                            const Row(
                              children: [],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Quantity before',
                            style: GoogleFonts.getFont(
                              'Nunito Sans',
                              fontWeight: FontWeight.w200,
                              fontSize: 14,
                              height: 1.3,
                              color: const Color(0xFF1E232C),
                            ),
                          ),
                        ),
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        enabled: false,
                        controller: _oldQtyController,
                        obscureText: false,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          hintText: 'Quantity',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Quantity after',
                            style: GoogleFonts.getFont(
                              'Nunito Sans',
                              fontWeight: FontWeight.w200,
                              fontSize: 14,
                              height: 1.3,
                              color: const Color(0xFF1E232C),
                            ),
                          ),
                        ),
                      ),
                      TextField(
                        keyboardType: TextInputType.number,
                        enabled: true,
                        controller: _qtyController,
                        obscureText: false,
                        decoration: const InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          hintText: 'New quantity',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  updateButtonTap();
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
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        'Update',
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
