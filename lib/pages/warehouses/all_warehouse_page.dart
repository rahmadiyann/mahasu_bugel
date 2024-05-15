// ignore_for_file: prefer_const_constructors, unused_local_variable

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Mahasu/components/myappbar.dart';
import 'package:Mahasu/pages/palettes/palette_page.dart';
import 'package:Mahasu/services/warehouse_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class WarehousesPage extends StatefulWidget {
  const WarehousesPage({super.key});

  @override
  State<WarehousesPage> createState() => _WarehousesPageState();
}

class _WarehousesPageState extends State<WarehousesPage> {
  final WarehouseFirestoreService warehouseservice =
      WarehouseFirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final int initialDisplayCount = 5;
  Map<String, bool> showAllPalettes =
      {}; // To keep track of which warehouses are showing all palettes

  void openWarehouseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (_nameController.text == '') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in the quantity'),
                  ),
                );
                return;
              }
              warehouseservice.createWarehouse(_nameController.text);
              _nameController.clear();
              Navigator.of(context).pop();
            },
            child: const Text('Add Warehouse'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const MyAppBar(
        isHomePage: false,
        isAction: false,
        title: 'Warehouses',
        destinationPage: WarehousesPage(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openWarehouseBox,
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: StreamBuilder(
          stream: warehouseservice.readWarehouse(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List warehouseList = snapshot.data!.docs;

              return ListView.builder(
                itemCount: warehouseList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot warehouse = warehouseList[index];
                  String docId = warehouse.id;

                  Map<String, dynamic> data =
                      warehouse.data() as Map<String, dynamic>;
                  String warehouseName = data['name'];
                  List palettes = data['palettes'];

                  // Initialize the state for showing palettes if not already set
                  if (showAllPalettes[docId] == null) {
                    showAllPalettes[docId] = false;
                  }

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: SvgPicture.asset(
                                'assets/vectors/warehouseicon.svg',
                                width: 40,
                              ),
                            ),
                            // Warehouse name
                            Text(
                              warehouseName.toUpperCase(),
                              style: GoogleFonts.nunitoSans(
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  height: 1.4,
                                  color: Color(0xFF000000),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Divider
                        const Divider(
                          color: Color(0xFFE0E0E0),
                          thickness: 1,
                          height: 0,
                        ),
                        // Conditional rendering of inner ListView.builder for palettes
                        if (palettes.isNotEmpty)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(10),
                            itemCount: showAllPalettes[docId]!
                                ? palettes.length
                                : (palettes.length > initialDisplayCount
                                    ? initialDisplayCount
                                    : palettes.length),
                            itemBuilder: (context, paletteIndex) {
                              Map<String, dynamic> palette =
                                  palettes[paletteIndex];
                              return GestureDetector(
                                onTap: () {
                                  // Navigate to the palette page
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PalettePage(
                                        productId: palette.keys.first,
                                        paletteName: palette.values.first,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.shade400, width: 1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Palette: ',
                                              style: GoogleFonts.nunitoSans(
                                                textStyle: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                  height: 1.4,
                                                  color: Color(0xFF000000),
                                                ),
                                              ),
                                            ),
                                            Text(
                                              palette.values.first,
                                              style: GoogleFonts.nunitoSans(
                                                textStyle: const TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 14,
                                                  height: 1.4,
                                                  color: Color(0xFF000000),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              0, 6.7, 0, 1.7),
                                          width: 6.7,
                                          height: 10.7,
                                          child: Image.asset(
                                              'assets/images/arrowright.png'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        if (palettes.length > initialDisplayCount)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                showAllPalettes[docId] =
                                    !showAllPalettes[docId]!;
                              });
                            },
                            child: Icon(
                              showAllPalettes[docId]!
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            } else {
              return const Text('No data');
            }
          },
        ),
      ),
    );
  }
}
