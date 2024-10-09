import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/components/button.dart';
import 'package:myapp/pages/palettes/palette_i_page.dart';
import 'package:myapp/pages/palettes/palettes_page.dart';
import 'package:myapp/services/palette_firestore.dart';
import 'package:myapp/services/transaction_firestore.dart';
import 'package:myapp/services/warehouse_firestore.dart';

class UpdatePalettePage extends StatefulWidget {
  final String paletteId;
  final String oldWhId;
  final String paletteName;
  const UpdatePalettePage(
      {super.key,
      required this.paletteId,
      required this.oldWhId,
      required this.paletteName});

  @override
  State<UpdatePalettePage> createState() => _UpdatePalettePageState();
}

class Warehouses {
  final String id;
  final String name;

  Warehouses(this.id, this.name);
}

class _UpdatePalettePageState extends State<UpdatePalettePage> {
  @override
  void initState() {
    super.initState();
    paletteIdCtl.text = widget.paletteId;
    paletteNameCtl.text = widget.paletteName;
  }

  final _formGlobalKey = GlobalKey<FormState>();

  String hintText = 'Select Warehouse';

  // controllers
  final TextEditingController paletteNameCtl = TextEditingController();
  final TextEditingController newwhIdCtl = TextEditingController();
  final TextEditingController whNameCtl = TextEditingController();
  final TextEditingController paletteIdCtl = TextEditingController();

  // services
  final PaletteFirestoreService paletteService = PaletteFirestoreService();
  final WarehouseFirestoreService warehouseService =
      WarehouseFirestoreService();
  final TransactionFirestoreService transactionservice =
      TransactionFirestoreService();

  updateButtonTap() {
    // print(_selectedWarehouse);
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
                        // print(widget.oldWhId);
                        paletteService.updatePalette(
                          widget.paletteId,
                          paletteNameCtl.text,
                          newwhIdCtl.text,
                          whNameCtl.text,
                        );
                        transactionservice.createTransaction(
                            operatorEmail!, 'Update Palette', widget.paletteId);
                        warehouseService.removePaletteFromWarehouse(
                            widget.oldWhId, widget.paletteId);
                        warehouseService.addPaletteToWarehouse(newwhIdCtl.text,
                            widget.paletteId, paletteNameCtl.text);
                        // show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Product updated'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        paletteNameCtl.clear();
                        whNameCtl.clear();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PalettePage(
                              productId: widget.paletteId,
                              paletteName: paletteNameCtl.text,
                            ),
                          ),
                        );
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
                      onTap: () {
                        Navigator.pop(context);
                      },
                      text: 'No',
                    ),
                    MyButton(
                      onTap: () async {
                        String? operatorEmail =
                            FirebaseAuth.instance.currentUser!.email;
                        await transactionservice.createTransaction(
                            operatorEmail!, 'Delete Palette', widget.paletteId);
                        await paletteService.deletePalette(
                          widget.paletteId,
                          paletteNameCtl.text,
                        );
                        // show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Palette deleted'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PalettesPage(),
                          ),
                        );
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
    return Dismissible(
      key: Key(widget.paletteId),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Navigator.popAndPushNamed(context, '/palettes');
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.grey[100],
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
            ),
            title: Text(
              'Edit Palette',
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
          key: _formGlobalKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              scrollDirection: Axis.vertical,
              children: <Widget>[
                TextField(
                  enabled: true,
                  controller: paletteNameCtl,
                  obscureText: false,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    hintText: 'Palette name',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 16),
                StreamBuilder(
                    stream: warehouseService.readWarehouse(),
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
                                    whNameCtl.text = value.name;
                                    newwhIdCtl.text = value.id;
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
      ),
    );
  }

  @override
  void dispose() {
    paletteNameCtl.dispose();
    newwhIdCtl.dispose();
    paletteIdCtl.dispose();
    whNameCtl.dispose();
    super.dispose();
  }
}
