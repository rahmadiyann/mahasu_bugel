import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/components/button.dart';
import 'package:myapp/pages/palettes/palette_i_page.dart';
import 'package:myapp/pages/products/product_i_page.dart';
import 'package:myapp/services/activity_firestore.dart';
import 'package:myapp/services/palette_firestore.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class PalettesPage extends StatefulWidget {
  const PalettesPage({super.key});

  @override
  State<PalettesPage> createState() => _PalettesPageState();
}

class _PalettesPageState extends State<PalettesPage> {
  final ActivityFirestoreService activityservice = ActivityFirestoreService();
  final PaletteFirestoreService paletteservice = PaletteFirestoreService();
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

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

  Future<void> scanBarcode() async {
    List<String> palettes = await paletteservice.getAllPaletteIds();

    String barcodeScanRes;
    late String paletteName;
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.QR);

    if (barcodeScanRes == '-1') {
      Navigator.pop(context);
    } else if (palettes.contains(barcodeScanRes)) {
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
                        'assets/images/erroricon.png',
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Stock Opname Confirmed'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
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
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/new-palette');
              },
              child: Container(
                width: 70,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFAFA),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search palettes...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: paletteservice.readPalette(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List stockOpnames = snapshot.data!.docs;

                  // Filter palettes based on the search query
                  if (searchQuery.isNotEmpty) {
                    stockOpnames = stockOpnames.where((palette) {
                      String paletteName = palette['name'];
                      return paletteName
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase());
                    }).toList();
                  }

                  // Sort the palettes by soStatus, the unconfirmed ones first
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

                      DateTime dt =
                          (data['lastStockOpname'] as Timestamp).toDate();

                      return GestureDetector(
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
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.grey.shade400, width: 1),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(right: 5),
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: soStatus == 'Unconfirmed'
                                                  ? Colors.red
                                                  : Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: soStatus == 'Unconfirmed'
                                                ? const Icon(
                                                    Icons.error_outline,
                                                    color: Colors.white,
                                                  )
                                                : const Icon(
                                                    Icons.check,
                                                    color: Colors.yellow,
                                                  ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              showQRCodeModal(context, docId);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: BoxDecoration(
                                                color: Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                              ),
                                              child: const Icon(
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
                                const Divider(
                                  color: Color(0xFFE0E0E0),
                                  thickness: 1,
                                ),
                                if (data['products'] != null &&
                                    data['products'].isNotEmpty)
                                  ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
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
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade400,
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 5.0),
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
                                                      const SizedBox(width: 5),
                                                      Expanded(
                                                        child: Text(
                                                          product[
                                                              'productName'],
                                                          overflow: TextOverflow
                                                              .ellipsis,
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
                                                        if (product['qty_list'][
                                                                    'Meters'] !=
                                                                null ||
                                                            product['qty_list'][
                                                                    'meters'] !=
                                                                null)
                                                          Text(
                                                              'Meters: ${product['qty_list']['Meters'] ?? product['qty_list']['meters']}'),
                                                        if (product['qty_list']
                                                                    ['Rolls'] !=
                                                                null ||
                                                            product['qty_list']
                                                                    ['rolls'] !=
                                                                null)
                                                          Text(
                                                              'Rolls: ${product['qty_list']['Rolls'] ?? product['qty_list']['rolls']}'),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        if (product['qty_list']
                                                                    ['Yards'] !=
                                                                null ||
                                                            product['qty_list']
                                                                    ['yards'] !=
                                                                null)
                                                          Text(
                                                              'Yards: ${product['qty_list']['Yards'] ?? product['qty_list']['yards']}'),
                                                        if (product['qty_list'][
                                                                    'Sheets'] !=
                                                                null ||
                                                            product['qty_list'][
                                                                    'sheets'] !=
                                                                null)
                                                          Text(
                                                              'Sheets: ${product['qty_list']['Sheets'] ?? product['qty_list']['sheets']}'),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        if (product['qty_list']
                                                                    ['SQM'] !=
                                                                null ||
                                                            product['qty_list']
                                                                    ['sqm'] !=
                                                                null)
                                                          Text(
                                                              'SQM: ${product['qty_list']['SQM'] ?? product['qty_list']['sqm']}'),
                                                        if (product['qty_list'][
                                                                    'Pallets'] !=
                                                                null ||
                                                            product['qty_list'][
                                                                    'pallets'] !=
                                                                null)
                                                          Text(
                                                              'Pallets: ${product['qty_list']['Pallets'] ?? product['qty_list']['pallets']}'),
                                                      ],
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        if (product['qty_list']
                                                                    ['KGM'] !=
                                                                null ||
                                                            product['qty_list']
                                                                    ['kgm'] !=
                                                                null)
                                                          Text(
                                                              'KGM: ${product['qty_list']['KGM'] ?? product['qty_list']['kgm']}'),
                                                        if (product['qty_list']
                                                                    ['Bags'] !=
                                                                null ||
                                                            product['qty_list']
                                                                    ['bags'] !=
                                                                null)
                                                          Text(
                                                              'Bags: ${product['qty_list']['Bags'] ?? product['qty_list']['bags']}'),
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
                                const SizedBox(height: 25),
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
                                                    fontWeight:
                                                        FontWeight.normal,
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
        ],
      ),
    );
  }
}
