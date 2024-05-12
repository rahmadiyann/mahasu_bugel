// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Mahasu/pages/palettes/all_palette_page.dart';
import 'package:Mahasu/pages/palettes/update_palette_page.dart';
import 'package:Mahasu/services/palette_firestore.dart';
import 'package:Mahasu/services/qr_generator.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class PalettePage extends StatefulWidget {
  final String productId;
  final String paletteName;
  const PalettePage(
      {super.key, required this.productId, required this.paletteName});

  @override
  State<PalettePage> createState() => _PalettePageState();
}

class _PalettePageState extends State<PalettePage> {
  final PaletteFirestoreService paletteService = PaletteFirestoreService();

  Future<void> getQR({
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
                    child: Flexible(child: Text('Error: ${snapshot.error}')),
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

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.productId),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => allPalettePage(),
          ),
        );
      },
      child: Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.grey[100],
            // if homepage, no back button
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.popAndPushNamed(context, '/palettes');
              },
            ),
            title: Text(
              widget.paletteName.toUpperCase(),
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
                  onTap: () async {
                    String oldWhid =
                        await paletteService.getWarehouseId(widget.productId);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpdatePalettePage(
                          paletteId: widget.productId,
                          oldWhId: oldWhid,
                          paletteName: widget.paletteName,
                        ),
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
                        'EDIT',
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
        body: Center(
          child: StreamBuilder(
            stream: paletteService.streamPaletteById(widget.productId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final DocumentSnapshot palette = snapshot.data!;
                if (palette.data() == null) {
                  return const Center(
                    child: Text('No data...'),
                  );
                } else {
                  final Map<String, dynamic> data =
                      palette.data() as Map<String, dynamic>;
                  String productName = data['name'];
                  String whName = data['whname'];

                  // prepare the products list
                  final List<Map<String, dynamic>> products =
                      List<Map<String, dynamic>>.from(data['products'] ?? []);

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Image.asset('assets/images/rack.png',
                                          height: 30, width: 30),
                                      SizedBox(width: 4),
                                      Text(
                                        productName.toUpperCase(),
                                        style: GoogleFonts.nunitoSans(
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 30,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(children: [
                                    Image.asset(
                                        'assets/images/warehouseicon.png',
                                        height: 30,
                                        width: 30),
                                    SizedBox(width: 4),
                                    Text(
                                      whName.toUpperCase(),
                                      style: GoogleFonts.nunitoSans(
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 30,
                                        ),
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: products.isNotEmpty
                            ? ListView.builder(
                                itemCount: products.length,
                                itemBuilder: (context, index) {
                                  final Map<String, dynamic> product =
                                      products[index];
                                  String productName = product['productName'];

                                  // prepare the qty list
                                  final Map<String, dynamic> qtyList =
                                      (product['qty_list']
                                          as Map<String, dynamic>);

                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 25,
                                                width: 25,
                                                child: SvgPicture.asset(
                                                    'assets/vectors/allproducticon.svg',
                                                    fit: BoxFit.contain),
                                              ),
                                              SizedBox(width: 10),
                                              Expanded(
                                                child: Text(
                                                  productName.toUpperCase(),
                                                  overflow: TextOverflow.clip,
                                                  style: GoogleFonts.nunitoSans(
                                                    textStyle: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 15),
                                        Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                if (qtyList['Meters'] != null)
                                                  Container(
                                                    height: 70,
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color:
                                                          Colors.green.shade200,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Meters',
                                                            style: GoogleFonts
                                                                .nunitoSans(
                                                              textStyle:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                              '${qtyList['Meters']}')
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                if (qtyList['Yards'] != null)
                                                  Container(
                                                    height: 70,
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: Colors
                                                          .yellow.shade200,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Yards',
                                                            style: GoogleFonts
                                                                .nunitoSans(
                                                              textStyle:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                              '${qtyList['Yards']}')
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                if (qtyList['Rolls'] != null)
                                                  Container(
                                                    height: 70,
                                                    width: 80,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color: Colors.white,
                                                          width: 1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color:
                                                          Colors.blue.shade200,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            'Rolls',
                                                            style: GoogleFonts
                                                                .nunitoSans(
                                                              textStyle:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          ),
                                                          Text(
                                                              '${qtyList['Rolls']}')
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  if (qtyList['Pallets'] !=
                                                      null)
                                                    Container(
                                                      height: 70,
                                                      width: 80,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: Color.fromARGB(
                                                            255, 223, 144, 249),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Pallets',
                                                              style: GoogleFonts
                                                                  .nunitoSans(
                                                                textStyle:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                                '${qtyList['Pallets']}')
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  if (qtyList['SQM'] != null)
                                                    Container(
                                                      height: 70,
                                                      width: 80,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 144, 249, 247),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'SQM',
                                                              style: GoogleFonts
                                                                  .nunitoSans(
                                                                textStyle:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                                '${qtyList['SQM']}')
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  if (qtyList['Sheets'] != null)
                                                    Container(
                                                      height: 70,
                                                      width: 80,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Colors.white,
                                                            width: 1),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 249, 224, 144),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Sheets',
                                                              style: GoogleFonts
                                                                  .nunitoSans(
                                                                textStyle:
                                                                    const TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                                '${qtyList['Sheets']}')
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                ]),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : Center(
                                child: Text(
                                  'Palette: ${widget.paletteName} has no products...',
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
                      ),
                    ],
                  );
                }
              } else {
                return Center(
                  child: Text('No data...'),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
