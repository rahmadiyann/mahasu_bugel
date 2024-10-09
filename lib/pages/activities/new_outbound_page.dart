import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/components/textfield.dart';
import 'package:myapp/services/activity_firestore.dart';
import 'package:myapp/services/palette_firestore.dart';
import 'package:myapp/services/product_firestore.dart';
import 'package:myapp/services/supplier_firestore.dart';
import 'package:myapp/services/transaction_firestore.dart';

class NewOutboundPage extends StatefulWidget {
  final String productId;
  const NewOutboundPage({super.key, required this.productId});

  @override
  State<NewOutboundPage> createState() => _NewOutboundPageState();
}

class Product {
  final String name;
  final String supplier;

  Product({required this.name, required this.supplier});
}

class Palette {
  final String id;
  final String name;
  final Map<String, dynamic> qtyList;

  Palette({required this.id, required this.name, required this.qtyList});
}

class Unit {
  final String name;

  Unit({required this.name});
}

class _NewOutboundPageState extends State<NewOutboundPage> {
  final ActivityFirestoreService activityService = ActivityFirestoreService();
  final ProductFirestoreService productService = ProductFirestoreService();
  final SupplierFirestoreService supplierservice = SupplierFirestoreService();
  final PaletteFirestoreService paletteservice = PaletteFirestoreService();
  final TransactionFirestoreService transactionService =
      TransactionFirestoreService();
  final _formGlobalKey = GlobalKey<FormState>();

  late TextEditingController productNameCtl = TextEditingController();
  late TextEditingController supplierNameCtl = TextEditingController();
  String _selectedUnit = '';
  String _selectedPaletteId = '';
  late List qtyList = [];
  String paletteHintText = 'Select palette';
  String unitHintText = 'Select unit';
  bool _isLoading = false;

  // using palette service, make a list of palette names and remember its id
  @override
  void initState() {
    super.initState();
    productNameCtl = TextEditingController();
    supplierNameCtl = TextEditingController();

    fetchData();
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
      _isLoading = true;
      String whId = await paletteservice.getPaletteWhId(_selectedPaletteId);
      String? operatorEmail = FirebaseAuth.instance.currentUser!.email;
      // print(qtyCtl.text);
      // print(_selectedPaletteId);
      // print(_selectedUnit);
      // print(descCtl.text);
      // if any of the text field is empty, show snackbar and show which field is empty
      if (qtyCtl.text.isEmpty ||
          _selectedPaletteId.isEmpty ||
          _selectedUnit.isEmpty) {
        var emptyField = [];
        if (qtyCtl.text.isEmpty) {
          emptyField.add('Quantity');
        }
        if (_selectedPaletteId.isEmpty) {
          emptyField.add('Palette');
        }
        if (_selectedUnit.isEmpty) {
          emptyField.add('Unit');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Please fill in the following field(s): ${emptyField.join(', ')}'),
          ),
        );
        return;
      }
      _selectedUnit = _selectedUnit.toLowerCase();
      int currentQty = await productService.checkProductQtyList(
          productIdCtl.text, _selectedPaletteId, _selectedUnit);
      if (currentQty < int.parse(qtyCtl.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QTY not enough'),
          ),
        );
      } else if (currentQty - int.parse(qtyCtl.text) == 0) {
        final docid = await activityService.createActivity(
            'Outbound',
            productIdCtl.text,
            _selectedPaletteId,
            _selectedUnit,
            int.parse(qtyCtl.text),
            whId,
            operatorEmail!);

        await productService.decrementProductQtyList(productIdCtl.text,
            _selectedPaletteId, _selectedUnit, int.parse(qtyCtl.text));

        await productService.decrementProductTotalQty(
          productIdCtl.text,
          _selectedUnit,
          int.parse(qtyCtl.text),
        );

        await paletteservice.decrementProduct(_selectedPaletteId,
            productIdCtl.text, _selectedUnit, int.parse(qtyCtl.text));

        await paletteservice.resetStockOpnamePalette(_selectedPaletteId);

        await transactionService.createTransaction(
            operatorEmail, 'New outbound', docid);
        // clear all text field
        descCtl.clear();
        qtyCtl.clear();
        // while processing, show loading indicator
        _isLoading = false;
        // after processing, show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Outbound successfully added'),
          ),
        );
        // after snackbar, navigate back to the previous page
        Navigator.popAndPushNamed(context, '/outbound');
      } else {
        _isLoading = true;
        final docid = await activityService.createActivity(
            'Outbound',
            productIdCtl.text,
            _selectedPaletteId,
            _selectedUnit,
            int.parse(qtyCtl.text),
            whId,
            operatorEmail!);

        await productService.decrementProductQtyList(productIdCtl.text,
            _selectedPaletteId, _selectedUnit, int.parse(qtyCtl.text));

        await productService.decrementProductTotalQty(
          productIdCtl.text,
          _selectedUnit,
          int.parse(qtyCtl.text),
        );
        await paletteservice.decrementProduct(_selectedPaletteId,
            productIdCtl.text, _selectedUnit, int.parse(qtyCtl.text));

        await paletteservice.resetStockOpnamePalette(_selectedPaletteId);

        await transactionService.createTransaction(
            operatorEmail, 'New outbound', docid);

        // clear all text field
        descCtl.clear();
        qtyCtl.clear();
        // while processing, show loading indicator
        _isLoading = false;
        // after processing, show snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Outbound successfully added'),
          ),
        );

        // after snackbar, navigate back to the previous page
        Navigator.pop(context);
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          'Add new outbound',
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
              FutureBuilder(
                future: productService.getPalettesByProductId(widget.productId),
                builder: (context,
                    AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData) {
                    return const Text('No data available');
                  } else {
                    final palettesList = snapshot.data!;

                    if (palettesList.isEmpty) {
                      return const Center(
                        child: Text('No stock for this product'),
                      );
                    }
                    List<Palette> paletteList = palettesList
                        .map(
                          (e) => Palette(
                              id: e['palette_id'] as String,
                              name: e['palette_name'] as String,
                              qtyList: e['qty_list'] as Map<String, dynamic>),
                        )
                        .toList();

                    return Column(
                      children: [
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
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<Palette>(
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: paletteList
                                  .map<DropdownMenuItem<Palette>>(
                                    (palette) => DropdownMenuItem(
                                      value: palette,
                                      child: Text(palette.name),
                                    ),
                                  )
                                  .toList()
                                ..sort(
                                  (a, b) {
                                    final aText = a.child as Text;
                                    final bText = b.child as Text;
                                    return int.parse(aText.data!)
                                        .compareTo(int.parse(bText.data!));
                                  },
                                ),
                              onChanged: (Palette? value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedPaletteId = value.id;
                                    paletteHintText = value.name;
                                    qtyList = value.qtyList.entries
                                        .map((e) => {
                                              'unit': e.key,
                                              'qty': e.value,
                                            })
                                        .toList();
                                  });
                                }
                              },
                              hint: Text(paletteHintText),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Dropdown for unit
                        _selectedPaletteId.isEmpty
                            ? Container()
                            : Container(
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
                        _selectedPaletteId.isEmpty
                            ? const SizedBox()
                            : Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: DropdownButton(
                                        isExpanded: true,
                                        underline: const SizedBox(),
                                        items: qtyList
                                            .map<
                                                DropdownMenuItem<
                                                    Map<String, dynamic>>>(
                                              (qty) => DropdownMenuItem(
                                                value: qty,
                                                child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(qty['unit']),
                                                      Text(
                                                          qty['qty'].toString())
                                                    ]),
                                              ),
                                            )
                                            .toList(),
                                        onChanged:
                                            (Map<String, dynamic>? value) {
                                          if (value != null) {
                                            setState(() {
                                              unitHintText = value['unit'];
                                              _selectedUnit = value['unit'];
                                            });
                                          }
                                        },
                                        hint: Text(unitHintText),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  _selectedUnit.isEmpty
                                      ? Container()
                                      : Column(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  0, 0, 0, 8),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  'Quantity ',
                                                  style: GoogleFonts.getFont(
                                                    'Nunito Sans',
                                                    fontWeight: FontWeight.w200,
                                                    fontSize: 14,
                                                    height: 1.3,
                                                    color:
                                                        const Color(0xFF1E232C),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TextField(
                                              keyboardType:
                                                  TextInputType.number,
                                              enabled: true,
                                              controller: qtyCtl,
                                              obscureText: false,
                                              decoration: const InputDecoration(
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.grey),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Colors.blue),
                                                ),
                                                hintText: 'Quantity',
                                                hintStyle: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                            const SizedBox(height: 30),
                                            Container(
                                              margin: const EdgeInsets.fromLTRB(
                                                  0, 0, 0, 8),
                                              child: Align(
                                                alignment: Alignment.topLeft,
                                                child: Text(
                                                  'Description ',
                                                  style: GoogleFonts.getFont(
                                                    'Nunito Sans',
                                                    fontWeight: FontWeight.w200,
                                                    fontSize: 14,
                                                    height: 1.3,
                                                    color:
                                                        const Color(0xFF1E232C),
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
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10),
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      Colors.green.shade400,
                                                      Colors.green.shade600
                                                    ],
                                                    begin: AlignmentDirectional
                                                        .topStart,
                                                    end: AlignmentDirectional
                                                        .bottomEnd,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    _isLoading
                                                        ? 'Processing...'
                                                        : 'Add Outbound',
                                                    style: const TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                ],
                              ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
