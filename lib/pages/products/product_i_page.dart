import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/components/product_total_qty_card.dart';
import 'package:myapp/pages/palettes/palette_i_page.dart';
import 'package:myapp/pages/products/edit_product_page.dart';
import 'package:myapp/services/product_firestore.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class ProductPage extends StatefulWidget {
  final String productId;
  const ProductPage({super.key, required this.productId});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ProductFirestoreService productservice = ProductFirestoreService();

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
          'Product Detail',
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditProductPage(productId: widget.productId),
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
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream: productservice.streamProductById(widget.productId),
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
                int metersQty = data['meters'];
                int rollsQty = data['rolls'];
                int yardsQty = data['yards'];
                int sqmQty = data['sqm'];
                int palletsQty = data['pallets'];
                int sheetsQty = data['sheets'];
                int kgmQty = data['kgm'];
                int bagsQty = data['bags'];

                final List<Map<String, dynamic>> products =
                    List<Map<String, dynamic>>.from(data['palettes'] ?? []);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      height: 25,
                                      width: 25,
                                      child: SvgPicture.asset(
                                        'assets/vectors/allproducticon.svg',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      productName.length > 25
                                          ? '${productName.substring(0, 25).toUpperCase()}...'
                                          : productName.toUpperCase(),
                                      overflow: TextOverflow.clip,
                                      maxLines: 1,
                                      style: GoogleFonts.nunitoSans(
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showQRCodeModal(
                                    context,
                                    widget.productId,
                                  );
                                },
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFAFAFA),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.qr_code,
                                      color: Color(0xFF058B06),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TotalQtyCard(
                                unit: 'Meters',
                                text: metersQty.toString(),
                              ),
                              TotalQtyCard(
                                unit: 'Rolls',
                                text: rollsQty.toString(),
                              ),
                              TotalQtyCard(
                                unit: 'Yards',
                                text: yardsQty.toString(),
                              ),
                              TotalQtyCard(
                                unit: 'SQM',
                                text: sqmQty.toString(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              TotalQtyCard(
                                unit: 'Pallets',
                                text: palletsQty.toString(),
                              ),
                              TotalQtyCard(
                                unit: 'Sheets',
                                text: sheetsQty.toString(),
                              ),
                              TotalQtyCard(
                                unit: 'KGM',
                                text: kgmQty.toString(),
                              ),
                              TotalQtyCard(
                                unit: 'Bags',
                                text: bagsQty.toString(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                      thickness: 2,
                      indent: 20,
                      endIndent: 20,
                    ),
                    Expanded(
                      child: products.isNotEmpty
                          ? ListView.builder(
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final Map<String, dynamic> product =
                                    products[index];
                                String paletteId = product['palette_id'];
                                String paletteName = product['palette_name'];

                                final Map<String, dynamic> qtyList =
                                    (product['qty_list']
                                        as Map<String, dynamic>);

                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PalettePage(
                                          productId: paletteId,
                                          paletteName: paletteName,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Image.asset(
                                                    'assets/images/rack.png',
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                  Text(
                                                    paletteName,
                                                    style:
                                                        GoogleFonts.nunitoSans(
                                                      textStyle:
                                                          const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 16,
                                                        height: 1.4,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  showQRCodeModal(
                                                      context, paletteName);
                                                },
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFFFAFAFA),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.qr_code,
                                                      color: Color(0xFF058B06),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              TotalQtyCard(
                                                unit: 'Meters',
                                                text: (qtyList['meters'] ?? 0)
                                                    .toString(),
                                              ),
                                              TotalQtyCard(
                                                unit: 'Rolls',
                                                text: (qtyList['rolls'] ?? 0)
                                                    .toString(),
                                              ),
                                              TotalQtyCard(
                                                unit: 'Yards',
                                                text: (qtyList['yards'] ?? 0)
                                                    .toString(),
                                              ),
                                              TotalQtyCard(
                                                unit: 'SQM',
                                                text: (qtyList['sqm'] ?? 0)
                                                    .toString(),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              TotalQtyCard(
                                                unit: 'Pallets',
                                                text: (qtyList['pallets'] ?? 0)
                                                    .toString(),
                                              ),
                                              TotalQtyCard(
                                                unit: 'Sheets',
                                                text: (qtyList['sheets'] ?? 0)
                                                    .toString(),
                                              ),
                                              TotalQtyCard(
                                                unit: 'KGM',
                                                text: (qtyList['KGM'] ?? 0)
                                                    .toString(),
                                              ),
                                              TotalQtyCard(
                                                unit: 'Bags',
                                                text: (qtyList['Bags'] ?? 0)
                                                    .toString(),
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
                          : Center(
                              child: Text(
                                'No data...',
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
    );
  }
}
