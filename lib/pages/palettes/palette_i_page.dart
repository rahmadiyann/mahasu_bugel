import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/components/unit_container.dart';
import 'package:myapp/pages/palettes/palettes_page.dart';
import 'package:myapp/pages/palettes/update_palette_page.dart';
import 'package:myapp/pages/products/product_i_page.dart';
import 'package:myapp/services/palette_firestore.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

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

  void showQRCodeModal(BuildContext context, String textToGenerate) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        color: Colors.white,
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
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: PrettyQrView.data(
                    data: textToGenerate,
                    errorCorrectLevel: QrErrorCorrectLevel.H,
                  ),
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
                'QR Code',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
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
            builder: (context) => const PalettesPage(),
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
                Navigator.pop(context);
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
                margin: const EdgeInsets.symmetric(horizontal: 10),
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
                      color: const Color(0xFFFAFAFA),
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
                                          height: 20, width: 20),
                                      const SizedBox(width: 4),
                                      Text(
                                        productName.toUpperCase(),
                                        style: GoogleFonts.nunitoSans(
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(children: [
                                    Image.asset(
                                        'assets/images/warehouseicon.png',
                                        height: 20,
                                        width: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      whName.toUpperCase(),
                                      style: GoogleFonts.nunitoSans(
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 20,
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
                                  String productId = product['productId'];

                                  // prepare the qty list
                                  final Map<String, dynamic> qtyList =
                                      (product['qty_list']
                                          as Map<String, dynamic>);

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductPage(
                                            productId: productId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
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
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    productName.toUpperCase(),
                                                    overflow: TextOverflow.clip,
                                                    style:
                                                        GoogleFonts.nunitoSans(
                                                      textStyle:
                                                          const TextStyle(
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
                                                  if (qtyList['Meters'] !=
                                                          null ||
                                                      qtyList['meters'] != null)
                                                    UnitContainer(
                                                      unit: 'Meters',
                                                      qty: qtyList['Meters'] ??
                                                          qtyList['meters'],
                                                    ),
                                                  if (qtyList['Yards'] !=
                                                          null ||
                                                      qtyList['yards'] != null)
                                                    UnitContainer(
                                                      unit: 'Yards',
                                                      qty: qtyList['Yards'] ??
                                                          qtyList['yards'],
                                                    ),
                                                  if (qtyList['Rolls'] !=
                                                          null ||
                                                      qtyList['rolls'] != null)
                                                    UnitContainer(
                                                      unit: 'Rolls',
                                                      qty: qtyList['Rolls'] ??
                                                          qtyList['rolls'],
                                                    ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  if (qtyList['Pallets'] !=
                                                          null ||
                                                      qtyList['pallets'] !=
                                                          null)
                                                    UnitContainer(
                                                      unit: 'Pallets',
                                                      qty: qtyList['Pallets'] ??
                                                          qtyList['pallets'],
                                                    ),
                                                  if (qtyList['SQM'] != null ||
                                                      qtyList['sqm'] != null)
                                                    UnitContainer(
                                                      unit: 'SQM',
                                                      qty: qtyList['SQM'] ??
                                                          qtyList['sqm'],
                                                    ),
                                                  if (qtyList['Sheets'] !=
                                                          null ||
                                                      qtyList['sheets'] != null)
                                                    UnitContainer(
                                                      unit: 'Sheets',
                                                      qty: qtyList['Sheets'] ??
                                                          qtyList['sheets'],
                                                    ),
                                                ],
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  if (qtyList['KGM'] != null ||
                                                      qtyList['kgm'] != null)
                                                    UnitContainer(
                                                      unit: 'KGM',
                                                      qty: qtyList['KGM'] ??
                                                          qtyList['kgm'],
                                                    ),
                                                  if (qtyList['Bags'] != null ||
                                                      qtyList['bags'] != null)
                                                    UnitContainer(
                                                      unit: 'Bags',
                                                      qty: qtyList['Bags'] ??
                                                          qtyList['bags'],
                                                    ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
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
                return const Center(
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
