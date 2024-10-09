import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/services/palette_firestore.dart';
import 'package:myapp/services/transaction_firestore.dart';
import 'package:myapp/services/warehouse_firestore.dart';

class NewPalettePage extends StatefulWidget {
  const NewPalettePage({super.key});

  @override
  State<NewPalettePage> createState() => _NewPalettePageState();
}

class Warehouses {
  final String id;
  final String name;

  Warehouses(this.id, this.name);
}

class _NewPalettePageState extends State<NewPalettePage> {
  final _formGlobalKey = GlobalKey<FormState>();

  String hintText = 'Select Warehouse';

  // controllers
  final TextEditingController paletteNameCtl = TextEditingController();
  final TextEditingController whIdCtl = TextEditingController();
  final TextEditingController whNameCtl = TextEditingController();
  final TextEditingController paletteIdCtl = TextEditingController();

  // services
  final PaletteFirestoreService paletteService = PaletteFirestoreService();
  final WarehouseFirestoreService warehouseService =
      WarehouseFirestoreService();
  final TransactionFirestoreService transactionservice =
      TransactionFirestoreService();

  onTap() async {
    String? operatorEmail = FirebaseAuth.instance.currentUser!.email;

    if (paletteNameCtl.text == '' ||
        whIdCtl.text == '' ||
        whNameCtl.text == '') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all the fields'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    String paletteId = await paletteService.createPalette(
        paletteNameCtl.text, whIdCtl.text, whNameCtl.text);
    if (paletteId == 'Palette already exist') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Palette with name ${paletteNameCtl.text} already exist'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    await warehouseservice.addPaletteToWarehouse(
        whIdCtl.text, paletteId, paletteNameCtl.text);

    await transactionservice.createTransaction(
        operatorEmail!, 'Create Palette', paletteId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New palette created'),
        duration: Duration(seconds: 2),
      ),
    );
    paletteIdCtl.clear();
    paletteNameCtl.clear();
    whIdCtl.clear();
    whNameCtl.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const ValueKey('new-palette'),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Navigator.popAndPushNamed(context, '/palettes');
      },
      child: Scaffold(
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
            'New Palette',
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
                                    whIdCtl.text = value.id;
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
                      child: Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text(
                          'Submit',
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
    whIdCtl.dispose();
    paletteIdCtl.dispose();
    whNameCtl.dispose();
    super.dispose();
  }
}
