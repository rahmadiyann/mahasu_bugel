// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:Mahasu/pages/products/edit_product_page.dart';
import 'package:Mahasu/services/product_firestore.dart';
import 'package:Mahasu/services/qr_generator.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductPage extends StatefulWidget {
  final String productId;
  const ProductPage({super.key, required this.productId});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ProductFirestoreService productservice = ProductFirestoreService();

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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
          backgroundColor: Colors.grey[100],
          // if homepage, no back button
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.popAndPushNamed(context, '/products');
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
              margin: EdgeInsets.symmetric(horizontal: 10),
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
          stream: productservice.streamProductById(widget.productId),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final DocumentSnapshot palette = snapshot.data!;
              if (palette.data() == null) {
                return Center(
                  child: Text('No data...'),
                );
              } else {
                final Map<String, dynamic> data =
                    palette.data() as Map<String, dynamic>;

                String productName = data['name'];

                // prepare the products list
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
                                          fit: BoxFit.contain),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      productName.length > 30
                                          ? '${productName.substring(0, 30).toUpperCase()}...'
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
                            ],
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
                                String paletteName = product['palette_name'];

                                // prepare the qty list
                                final Map<String, dynamic> qtyList =
                                    (product['qty_list']
                                        as Map<String, dynamic>);

                                return GestureDetector(
                                  onTap: () {},
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
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Image.asset(
                                                'assets/images/rack.png',
                                                height: 30,
                                                width: 30),
                                            Text(
                                              paletteName.toUpperCase(),
                                              style: GoogleFonts.nunitoSans(
                                                textStyle: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 30,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 15),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (qtyList['Meter'] != null)
                                              Column(children: [
                                                Text('Meter'),
                                                Text('${qtyList['Meter']}')
                                              ]),
                                            if (qtyList['Roll'] != null)
                                              Column(children: [
                                                Text('Roll'),
                                                Text('${qtyList['Roll']}')
                                              ]),
                                            if (qtyList['Yard'] != null)
                                              Column(children: [
                                                Text('Yard'),
                                                Text('${qtyList['Yard']}')
                                              ]),
                                            if (qtyList['SQM'] != null)
                                              Column(children: [
                                                Text('SQM'),
                                                Text('${qtyList['SQM']}')
                                              ]),
                                            if (qtyList['Pallet'] != null)
                                              Column(children: [
                                                Text('Pallet'),
                                                Text('${qtyList['Pallet']}')
                                              ]),
                                            if (qtyList['Sheet'] != null)
                                              Column(children: [
                                                Text('Sheet'),
                                                Text('${qtyList['Sheet']}')
                                              ]),
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
                    )
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
    );
  }
}
