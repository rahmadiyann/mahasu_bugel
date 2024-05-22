// ignore_for_file: prefer_const_constructors, camel_case_types, use_build_context_synchronously

import 'package:Mahasu/pages/products/product_i_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Mahasu/components/button.dart';
import 'package:Mahasu/pages/palettes/palette_page.dart';
import 'package:Mahasu/services/activity_firestore.dart';
import 'package:Mahasu/services/palette_firestore.dart';
import 'package:Mahasu/services/qr_generator.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class allPalettePage extends StatefulWidget {
  const allPalettePage({super.key});

  @override
  State<allPalettePage> createState() => _allPalettePageState();
}

class _allPalettePageState extends State<allPalettePage> {
  final ActivityFirestoreService activityservice = ActivityFirestoreService();
  final PaletteFirestoreService paletteservice = PaletteFirestoreService();
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold();
  // }

  Future<void> _capturePng({
    required String textToGenerate,
    required String type,
  }) async {
    try {
      showModalBottomSheet(
        context: context,
        builder: (context) => FutureBuilder<dynamic>(
          future: generateQRCode(textToGenerate, type),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                  color: Colors.white,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ));
            } else if (snapshot.hasError) {
              return Container(
                  color: Colors.white,
                  child: Center(
                    child: Text('Error: ${snapshot.error}'),
                  ));
            } else if (snapshot.hasData) {
              return Container(
                color: Colors.white,
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
                        child: // Display the QR code image from the returned URL
                            Image.network(
                          snapshot.data!,
                          width: 200,
                          height: 200,
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
                        'QR Code',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              );
            } else {
              return Container(
                color: Colors.white,
                child: Center(
                  child: Text('No data'),
                ),
              );
            }
          },
        ),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> scanBarcode() async {
    // fetch all product doc id and return as list
    List<String> palettes = await paletteservice.getAllPaletteIds();

    String barcodeScanRes;
    late String paletteName;
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.QR);
    // once scanned, navigate to new inbound page and pass the barcode result
    if (barcodeScanRes == '-1') {
      // User pressed "Cancel"
      Navigator.pop(context);
    } else if (palettes.contains(barcodeScanRes)) {
      // User scanned a barcode
      paletteName = await paletteservice.getPaletteName(barcodeScanRes);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PalettePage(
            productId: barcodeScanRes,
            paletteName: paletteName,
          ),
        ),
      );
    } else {
// No product
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
                        'assets/images/erroricon.png',
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
                      'Palette does not exist',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
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
  }

  void onTap(String id) {
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
                    'Are you sure you want to confirm this stock opname?',
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
                        paletteservice.stockOpnamePalette(id);
                        // show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Stock Opname Confirmed'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      text: 'Yes',
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
      backgroundColor: Colors.grey[100],
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
          'All Palettes',
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
                Navigator.pushNamed(context, '/new-palette');
              },
              child: Container(
                width: 70,
                height: 30,
                decoration: BoxDecoration(
                  color: Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 5.3, 7.8, 5.3),
                      width: 12,
                      height: 12,
                      child: const SizedBox(
                        width: 12,
                        height: 12,
                        child: Icon(
                          Icons.add,
                          color: Color(0xFF058B06),
                          size: 12,
                        ),
                      ),
                    ),
                    Text(
                      'Add',
                      style: GoogleFonts.nunitoSans(
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          height: 1.4,
                          color: Color(0xFF058B06),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          scanBarcode();
        },
        backgroundColor: Colors.grey,
        child: const Icon(Icons.qr_code_scanner),
      ),
      body: Center(
        child: StreamBuilder(
          stream: paletteservice.readPalette(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List stockOpnames = snapshot.data!.docs;

              // sort the palette by soStatus, the unconfirmed ones first
              stockOpnames.sort((a, b) {
                String aStatus = a['soStatus'];
                String bStatus = b['soStatus'];
                return bStatus.compareTo(aStatus);
              });

              return ListView.builder(
                itemCount: stockOpnames.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot opnames = stockOpnames[index];
                  String docId = opnames.id;

                  Map<String, dynamic> data =
                      opnames.data() as Map<String, dynamic>;
                  String paletteName = data['name'];
                  String soStatus = data['soStatus'];
                  String whName = data['whname'];

                  DateTime dt = (data['lastStockOpname'] as Timestamp).toDate();

                  // sort by stock opname status, unconfirmed comes first

                  // print('type of lastSO: ${dt.runtimeType}');
                  // print('value of lastSO: $dt');
                  // print('is lastSO null? ${dt == null}');

                  return GestureDetector(
                    // navigate to update palette page on tap
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PalettePage(
                              productId: docId, paletteName: paletteName),
                        ),
                      );
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade400, width: 1),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Image.asset('assets/images/rack.png',
                                          height: 25, width: 25),
                                      Text(
                                        paletteName.toUpperCase(),
                                        style: GoogleFonts.nunitoSans(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Image.asset(
                                            'assets/images/warehouseicon.png',
                                            height: 25,
                                            width: 25),
                                        Text(
                                          whName.toUpperCase(),
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ]),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(right: 5),
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: soStatus == 'Unconfirmed'
                                              ? Colors.red
                                              : Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: soStatus == 'Unconfirmed'
                                            ? Icon(
                                                Icons.error_outline,
                                                color: Colors.white,
                                              )
                                            : Icon(
                                                Icons.check,
                                                color: Colors.yellow,
                                              ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _capturePng(
                                              textToGenerate: docId,
                                              type: 'palette');
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(5),
                                          decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Icon(
                                            Icons.qr_code,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            // Divider
                            const Divider(
                              color: Color(0xFFE0E0E0),
                              thickness: 1,
                            ),

                            if (data['products'] != null &&
                                data['products'].isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(10),
                                itemCount: data['products'].length,
                                itemBuilder: (context, index) {
                                  Map<String, dynamic> product =
                                      data['products'][index];
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductPage(
                                            productId: product['productId'],
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade400,
                                            width: 1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  SizedBox(
                                                    height: 15,
                                                    width: 15,
                                                    child: SvgPicture.asset(
                                                      'assets/vectors/allproducticon.svg',
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                  SizedBox(width: 5),
                                                  Expanded(
                                                    child: Text(
                                                      product['productName'],
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: GoogleFonts
                                                          .nunitoSans(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    // there is a map of 'Meters': qty, 'Rolls': qty, and 'Yards': qty inside qty_list. If each exists, display the qty
                                                    if (product['qty_list']
                                                            ['Meters'] !=
                                                        null)
                                                      Text(
                                                          'Meters: ${product['qty_list']['Meters']}'),
                                                    if (product['qty_list']
                                                            ['Rolls'] !=
                                                        null)
                                                      Text(
                                                          'Rolls: ${product['qty_list']['Rolls']}'),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    if (product['qty_list']
                                                            ['Yards'] !=
                                                        null)
                                                      Text(
                                                          'Yards: ${product['qty_list']['Yards']}'),
                                                    if (product['qty_list']
                                                            ['Sheets'] !=
                                                        null)
                                                      Text(
                                                          'Sheets: ${product['qty_list']['Sheets']}'),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    if (product['qty_list']
                                                            ['SQM'] !=
                                                        null)
                                                      Text(
                                                          'SQM: ${product['qty_list']['SQM']}'),
                                                    if (product['qty_list']
                                                            ['Pallets'] !=
                                                        null)
                                                      Text(
                                                          'Pallets: ${product['qty_list']['Pallets']}'),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    if (product['qty_list']
                                                            ['KGM'] !=
                                                        null)
                                                      Text(
                                                          'KGM: ${product['qty_list']['KGM']}'),
                                                    if (product['qty_list']
                                                            ['Bags'] !=
                                                        null)
                                                      Text(
                                                          'Bags: ${product['qty_list']['Bags']}'),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            else
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'No products....',
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w200,
                                    ),
                                  ),
                                ],
                              ),

                            SizedBox(height: 25),
                            data['soStatus'] == 'Unconfirmed'
                                ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              'Last Stock Opname: ',
                                              style: GoogleFonts.nunitoSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            Text(
                                              '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}',
                                              style: GoogleFonts.nunitoSans(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            )
                                          ],
                                        ),
                                        MyButton(
                                            onTap: () => onTap(docId),
                                            text: "Confirm Stock Opname")
                                      ],
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                      children: [
                                        Text(
                                          'Last Stock Opname: ',
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                        Text(
                                          '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}',
                                          style: GoogleFonts.nunitoSans(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        ),
      ),
    );
  }
}
