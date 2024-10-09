import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/components/textfield.dart';
import 'package:myapp/services/activity_firestore.dart';
import 'package:myapp/services/palette_firestore.dart';
import 'package:myapp/services/product_firestore.dart';
import 'package:myapp/services/supplier_firestore.dart';
import 'package:myapp/services/transaction_firestore.dart';

class NewInboundPage extends StatefulWidget {
  final String productId;
  const NewInboundPage({super.key, required this.productId});

  @override
  State<NewInboundPage> createState() => _NewInboundPageState();
}

class Product {
  final String name;
  final String supplier;

  Product({required this.name, required this.supplier});
}

class _NewInboundPageState extends State<NewInboundPage> {
  final ActivityFirestoreService activityService = ActivityFirestoreService();
  final ProductFirestoreService productService = ProductFirestoreService();
  final SupplierFirestoreService supplierservice = SupplierFirestoreService();
  final PaletteFirestoreService paletteservice = PaletteFirestoreService();
  final TransactionFirestoreService transactionservice =
      TransactionFirestoreService();
  late TextEditingController productNameCtl = TextEditingController();
  late TextEditingController supplierNameCtl = TextEditingController();
  final _formGlobalKey = GlobalKey<FormState>();
  String _selectedUnit = "Meters";
  final List<String> _unitList = [
    "Meters",
    "Yards",
    "Rolls",
    'SQM',
    "Pallets",
    "Sheets",
    "KGM",
    "Bags"
  ];
  late String _selectedPaletteId = '';
  late String _whId = '';
  late String _paletteName = '';

  // using palette service, make a list of palette names and remember its id
  @override
  void initState() {
    super.initState();
    productNameCtl = TextEditingController();
    supplierNameCtl = TextEditingController();

    fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchData() async {
    try {
      final productSnapshot =
          await productService.readProductById(widget.productId);
      if (productSnapshot.exists) {
        final productData = productSnapshot.data() as Map<String, dynamic>;
        setState(() {
          productNameCtl.text = productData['name'] ?? '';
          supplierNameCtl.text =
              (productData['supplier'] as Map<String, dynamic>?)?['name'] ?? '';
        });
      } else {
        // Handle case where product doesn't exist
      }
    } catch (error) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController productIdCtl =
        TextEditingController(text: widget.productId);
    final TextEditingController descCtl = TextEditingController();
    final TextEditingController qtyCtl = TextEditingController();

    onTap() async {
      String? operatorEmail = FirebaseAuth.instance.currentUser!.email;
      if (qtyCtl.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in the quantity'),
          ),
        );
        return;
      }

      _selectedUnit = _selectedUnit.toLowerCase();

      // print(_paletteName);
      final docId = await activityService.createActivity(
          'Inbound',
          productIdCtl.text,
          _selectedPaletteId,
          _selectedUnit,
          int.parse(qtyCtl.text),
          _whId,
          operatorEmail!);

      await productService.incrementProduct(
        productIdCtl.text,
        _selectedPaletteId,
        _paletteName,
        _selectedUnit,
        int.parse(qtyCtl.text),
      );

      await productService.incrementProductTotalQty(
        productIdCtl.text,
        _selectedUnit,
        int.parse(qtyCtl.text),
      );

      await paletteservice.incrementProduct(
        _selectedPaletteId,
        productIdCtl.text,
        productNameCtl.text,
        _selectedUnit,
        int.parse(qtyCtl.text),
      );

      await paletteservice.resetStockOpnamePalette(_selectedPaletteId);
      transactionservice.createTransaction(operatorEmail, 'New inbound', docId);

      // clear all text field
      descCtl.clear();
      qtyCtl.clear();
      // while processing, show loading indicator

      // after processing, show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inbound successfully added'),
        ),
      );

      // after snackbar, navigate back to the previous page
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          'Add new inbound',
          style: GoogleFonts.nunitoSans(
            textStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 1.4,
              color: Colors.black,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Form(
        key: _formGlobalKey,
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
                                productNameCtl.text.toUpperCase(),
                                softWrap: true,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  supplierNameCtl.text
                                      .split(' ')
                                      .take(2)
                                      .join(' ')
                                      .toUpperCase(),
                                  overflow: TextOverflow.ellipsis,
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
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Palette ',
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
              FutureBuilder<Map<String, Map<String, String>>>(
                future: paletteservice.getPaletteNames(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final paletteNames = snapshot.data!;

                    if (_selectedPaletteId.isEmpty && paletteNames.isNotEmpty) {
                      _selectedPaletteId = paletteNames.keys.first;
                      final whid = paletteNames[_selectedPaletteId]!['whid'];
                      _whId = whid!;
                      _paletteName = paletteNames[_selectedPaletteId]!['name']!;
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedPaletteId,
                      items: paletteNames.entries.map((entry) {
                        final innerMap = entry.value;
                        final paletteName = innerMap['name'];
                        return DropdownMenuItem<String>(
                          value: entry.key,
                          child: Text(paletteName!),
                        );
                      }).toList()
                        ..sort(
                          (a, b) {
                            final aText = a.child as Text;
                            final bText = b.child as Text;
                            return int.parse(aText.data!)
                                .compareTo(int.parse(bText.data!));
                          },
                        ),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedPaletteId = newValue!;
                          final whid = paletteNames[newValue]!['whid'];
                          _whId = whid!;
                          _paletteName = paletteNames[newValue]!['name']!;
                        });
                      },
                      decoration: const InputDecoration(
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        hintText: "Unit",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 30),
              // Dropdown for unit
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Unit ',
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
              DropdownButtonFormField<String>(
                value: _selectedUnit,
                items: _unitList
                    .map((e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value!;
                  });
                },
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintText: "Unit",
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 30),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Quantity ',
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
                controller: qtyCtl,
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
              const SizedBox(height: 30),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Description ',
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
              MyTextField(
                  controller: descCtl,
                  hintText: "Description",
                  obscureText: false,
                  enabled: true),
              const SizedBox(height: 50),
              GestureDetector(
                onTap: onTap,
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
                    child: Text(
                      'Add Inbound',
                      style: TextStyle(color: Colors.white),
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
