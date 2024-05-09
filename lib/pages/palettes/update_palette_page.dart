// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:Mahasu/components/button.dart';
import 'package:Mahasu/pages/palettes/palette_page.dart';
import 'package:Mahasu/services/palette_firestore.dart';
import 'package:Mahasu/services/warehouse_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

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
  final _formGlobalKey = GlobalKey<FormState>();
  bool _isPaletteNameValid = false;

  late String _selectedWarehouse;

  // controllers
  final TextEditingController paletteNameCtl = TextEditingController();
  final TextEditingController newwhIdCtl = TextEditingController();
  final TextEditingController whNameCtl = TextEditingController();
  final TextEditingController paletteIdCtl = TextEditingController();

  // services
  final PaletteFirestoreService paletteService = PaletteFirestoreService();
  final WarehouseFirestoreService warehouseService =
      WarehouseFirestoreService();

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
                SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
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
                SizedBox(height: 30),
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
                        paletteService.updatePalette(
                          widget.paletteId,
                          paletteNameCtl.text,
                          newwhIdCtl.text,
                          whNameCtl.text,
                        );
                        warehouseService.removePaletteFromWarehouse(
                            widget.oldWhId, widget.paletteId);
                        warehouseService.addPaletteToWarehouse(newwhIdCtl.text,
                            widget.paletteId, paletteNameCtl.text);
                        // show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Product updated'),
                            duration: const Duration(seconds: 2),
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
                SizedBox(height: 20)
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
                SizedBox(height: 20),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(251, 154, 154, 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/warningicon.png',
                      height: 100,
                      width: 100,
                      color: Color.fromRGBO(255, 70, 70, 1),
                    ),
                  ),
                ),
                SizedBox(height: 30),
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
                        paletteService.deletePalette(
                          widget.paletteId,
                        );
                        // show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Product deleted'),
                            duration: const Duration(seconds: 2),
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
                SizedBox(height: 20)
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
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PalettePage(
                    productId: widget.paletteId,
                    paletteName: widget.paletteName,
                  ),
                ),
              );
            },
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
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: GestureDetector(
                onTap: () {
                  _isPaletteNameValid
                      ? updateButtonTap()
                      : ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in the palette name'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                },
                child: Container(
                  width: 70,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Color(0xFFFAFAFA),
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
                onEditingComplete: () {
                  setState(() {
                    _isPaletteNameValid = paletteNameCtl.text.isNotEmpty;
                  });
                },
                enabled: true,
                controller: paletteNameCtl,
                obscureText: false,
                decoration: InputDecoration(
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  hintText: 'Palette Name',
                  hintStyle: const TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.black),
              ),
              const SizedBox(height: 16),
              StreamBuilder(
                  stream: warehouseService.readWarehouse(),
                  builder: (context, snapshot) {
                    // get whname using paletteservice
                    paletteService
                        .getWarehouseName(widget.paletteId)
                        .then((value) {
                      _selectedWarehouse = value;
                    });
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
                                  _selectedWarehouse = value.name;
                                  whNameCtl.text = value.name;
                                  newwhIdCtl.text = value.id;
                                });
                              }
                            },
                            hint: Text(_selectedWarehouse),
                          ),
                        ),
                      );
                    } else {
                      return const Text('No data');
                    }
                  }),
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

  @override
  void dispose() {
    paletteNameCtl.dispose();
    newwhIdCtl.dispose();
    super.dispose();
  }
}
