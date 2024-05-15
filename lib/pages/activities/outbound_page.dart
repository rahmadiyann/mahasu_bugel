// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Mahasu/components/myappbar.dart';
import 'package:Mahasu/pages/activities/new_outbound_page.dart';
import 'package:Mahasu/services/activity_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Mahasu/services/palette_firestore.dart';
import 'package:Mahasu/services/product_firestore.dart';
import 'package:Mahasu/services/supplier_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class OutboundPage extends StatefulWidget {
  const OutboundPage({super.key});

  @override
  State<OutboundPage> createState() => _OutboundPageState();
}

class Supplier {
  final String id;
  final String name;

  Supplier(this.id, this.name);
}

class Palette {
  final String id;
  final String name;

  Palette(this.id, this.name);
}

class _OutboundPageState extends State<OutboundPage> {
  final ActivityFirestoreService activityService = ActivityFirestoreService();
  final ProductFirestoreService productService = ProductFirestoreService();
  final SupplierFirestoreService supplierservice = SupplierFirestoreService();
  final PaletteFirestoreService paletteservice = PaletteFirestoreService();

  Future<void> scanBarcode() async {
    // fetch all product doc id and return as list
    List<String> products = await productService.getAllProductIds();

    String barcodeScanRes;
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.QR);
    // once scanned, navigate to new inbound page and pass the barcode result
    if (barcodeScanRes == '-1') {
      // User pressed "Cancel"
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => OutboundPage()),
      );
    } else if (products.contains(barcodeScanRes)) {
      // User scanned a barcode
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewOutboundPage(productId: barcodeScanRes),
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
                      'Product does not exist',
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

  Future<bool> checkPaletteExist() async {
    final palette = await paletteservice.getAllPalette();
    return palette.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const MyAppBar(
        isHomePage: false,
        title: 'Outbound',
        isAction: false,
        destinationPage: OutboundPage(),
      ),
      floatingActionButton: FutureBuilder<bool>(
        future: checkPaletteExist(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData && snapshot.data!) {
            return FloatingActionButton(
              onPressed: scanBarcode,
              backgroundColor: Colors.grey,
              child: const Icon(Icons.qr_code_scanner),
            );
          } else {
            return Container(); // Return an empty container if no palettes exist
          }
        },
      ),
      body: Center(
        child: StreamBuilder(
          stream: activityService.readOutboundActivity(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List activityList = snapshot.data!.docs;

              // Sort the activityList by timestamp in descending order
              activityList
                  .sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

              return ListView.builder(
                itemCount: activityList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot activity = activityList[index];

                  Map<String, dynamic> data =
                      activity.data() as Map<String, dynamic>;
                  String type = data['type'];
                  String productId = data['product_id'];
                  String paletteId = data['palette_id'];
                  String unit = data['unit'];
                  int qty = data['qty'];
                  Timestamp timestamp = data['timestamp'];
                  // get product name by product id

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade400, width: 1),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: FutureBuilder(
                                        future: productService
                                            .readProductById(productId),
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            DocumentSnapshot product = snapshot
                                                .data as DocumentSnapshot;
                                            Map<String, dynamic> productData =
                                                product.data()
                                                    as Map<String, dynamic>;
                                            String name = productData['name'];
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Text(
                                                name,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Text('Loading...');
                                          }
                                        }),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      // margin: EdgeInsets.only(left: 10),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                          // green if outbound, yellow if outbound
                                          color: Colors.yellow,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          gradient: LinearGradient(colors: [
                                            Colors.yellow.shade400,
                                            Colors.yellow.shade300,
                                          ])),
                                      child: Text(
                                        type,
                                        style: TextStyle(
                                          color: Colors.yellow.shade900,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'QTY: $qty $unit',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            Row(children: [
                              FutureBuilder(
                                future:
                                    paletteservice.readPaletteById(paletteId),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    DocumentSnapshot palette =
                                        snapshot.data as DocumentSnapshot;
                                    Map<String, dynamic> paletteData =
                                        palette.data() as Map<String, dynamic>;
                                    String name = paletteData['name'];
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Row(
                                        children: [
                                          Image.asset('assets/images/rack.png',
                                              height: 20, width: 20),
                                          SizedBox(width: 20),
                                          Text(
                                            name,
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return Text('Loading...');
                                  }
                                },
                              ),
                            ]),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  // Icon
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 8.0, right: 8.0),
                                    child: Icon(
                                      Icons.access_time,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                                  SizedBox(width: 13),
                                  // Timestamp text
                                  Text(
                                    // format to DD-MM-YYYY HH:MM:SS and add 0 if single digit
                                    '${timestamp.toDate().day.toString().padLeft(2, '0')}-${timestamp.toDate().month.toString().padLeft(2, '0')}-${timestamp.toDate().year} ${timestamp.toDate().hour.toString().padLeft(2, '0')}:${timestamp.toDate().minute.toString().padLeft(2, '0')}:${timestamp.toDate().second.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  );
                },
              );
            } else {
              return Center(
                  child: Column(children: const [
                CircularProgressIndicator(),
                Text('Loading...'),
              ]));
            }
          },
        ),
      ),
    );
  }
}
