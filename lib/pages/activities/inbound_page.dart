// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/pages/activities/edit_activity_page.dart';
import 'package:myapp/pages/activities/new_inbound_page.dart';
import 'package:myapp/services/activity_firestore.dart';
import 'package:myapp/services/palette_firestore.dart';
import 'package:myapp/services/product_firestore.dart';
import 'package:myapp/services/supplier_firestore.dart';

class InboundPage extends StatefulWidget {
  const InboundPage({super.key});

  @override
  State<InboundPage> createState() => _InboundPageState();
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

class _InboundPageState extends State<InboundPage> {
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
        MaterialPageRoute(builder: (context) => InboundPage()),
      );
    } else if (products.contains(barcodeScanRes)) {
      // User scanned a barcode
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewInboundPage(productId: barcodeScanRes),
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
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        title: Text(
          'Inbound',
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
          icon: Icon(Icons.arrow_back),
        ),
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
          stream: activityService.readInboundActivity(),
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
                  String warehouseId = data['wh_id'];
                  String unit = data['unit'];
                  int qty = data['qty'];
                  Timestamp timestamp = data['timestamp'];
                  // get product name by product id

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditActivityPage(
                            activityId: activity.id,
                          ),
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
                                              DocumentSnapshot product =
                                                  snapshot.data
                                                      as DocumentSnapshot;
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
                                          color: Colors.green,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.green.shade400,
                                              Colors.green.shade300,
                                            ],
                                          ),
                                        ),
                                        child: Text(
                                          type,
                                          style: TextStyle(
                                            color: Colors.green.shade900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'QTY: ',
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      '$qty $unit',
                                      style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  FutureBuilder(
                                    future: paletteservice
                                        .readPaletteById(paletteId),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        DocumentSnapshot palette =
                                            snapshot.data as DocumentSnapshot;
                                        Map<String, dynamic> paletteData =
                                            palette.data()
                                                as Map<String, dynamic>;
                                        String name = paletteData['name'];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Image.asset(
                                                'assets/images/rack.png',
                                                height: 20,
                                                width: 20,
                                              ),
                                              Text(
                                                name.toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
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
                                  FutureBuilder(
                                    future: warehouseservice
                                        .readWarehouseById(warehouseId),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        DocumentSnapshot warehouse =
                                            snapshot.data as DocumentSnapshot;
                                        Map<String, dynamic> warehouseData =
                                            warehouse.data()
                                                as Map<String, dynamic>;
                                        String name = warehouseData['name'];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                name.toUpperCase(),
                                                style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              SvgPicture.asset(
                                                'assets/vectors/warehouseicon.svg',
                                                height: 20,
                                                width: 20,
                                              ),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return Text('Loading...');
                                      }
                                    },
                                  ),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    // Icon
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: 8.0, right: 8.0),
                                      child: Icon(
                                        Icons.access_time,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    // Timestamp text
                                    Text(
                                      // format to DD-MM-YYYY HH:MM:SS and add 0 if single digit
                                      '${timestamp.toDate().day.toString().padLeft(2, '0')}-${timestamp.toDate().month.toString().padLeft(2, '0')}-${timestamp.toDate().year} ${timestamp.toDate().hour.toString().padLeft(2, '0')}:${timestamp.toDate().minute.toString().padLeft(2, '0')}:${timestamp.toDate().second.toString().padLeft(2, '0')}',
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    // Divider
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(horizontal: 12),
                                      height: 1,
                                      width: 1,
                                      color: Colors.grey[400],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Column(
                  children: const [
                    CircularProgressIndicator(),
                    Text('No data...'),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
