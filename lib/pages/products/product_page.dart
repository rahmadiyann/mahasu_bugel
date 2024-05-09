// ignore_for_file: prefer_const_constructors, use_build_context_synchronously
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:Mahasu/pages/products/new_product_page.dart';
import 'package:Mahasu/pages/products/product_i_page.dart';
import 'package:Mahasu/services/product_firestore.dart';
import 'package:Mahasu/services/qr_generator.dart';
import 'package:Mahasu/services/supplier_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AllProductPage extends StatefulWidget {
  const AllProductPage({super.key});

  @override
  State<AllProductPage> createState() => _AllProductPageState();
}

class Supplier {
  final String id;
  final String name;

  Supplier(this.id, this.name);
}

class _AllProductPageState extends State<AllProductPage> {
  final SupplierFirestoreService supplierService = SupplierFirestoreService();
  final ProductFirestoreService productService = ProductFirestoreService();

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
    List<String> products = await productService.getAllProductIds();

    String barcodeScanRes;
    barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.QR);
    // once scanned, navigate to new inbound page and pass the barcode result
    if (barcodeScanRes == '-1') {
      // User pressed "Cancel"
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AllProductPage()),
      );
    } else if (products.contains(barcodeScanRes)) {
      // User scanned a barcode
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductPage(productId: barcodeScanRes),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
          backgroundColor: Colors.grey[200],
          // if homepage, no back button
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.popAndPushNamed(context, '/home');
            },
          ),
          title: Text(
            'All Products',
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewProductPage(),
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
          ]),
      floatingActionButton: FloatingActionButton(
        onPressed: scanBarcode,
        backgroundColor: Colors.grey,
        child: const Icon(Icons.qr_code_scanner),
      ),
      body: Center(
        child: StreamBuilder(
          stream: productService.readProduct(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List productList = snapshot.data!.docs;

              // sort by created_at
              productList.sort((a, b) {
                return a['created_at'].compareTo(b['created_at']);
              });

              return ListView.builder(
                itemCount: productList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot product = productList[index];
                  String docId = product.id;

                  Map<String, dynamic> data =
                      product.data() as Map<String, dynamic>;
                  String name = data['name'];

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductPage(
                            productId: docId,
                          ),
                        ),
                      );
                      // showDialog(
                      //   context: context,
                      //   builder: (context) => AlertDialog(
                      //       content: Column(
                      //         children: [
                      //           TextField(
                      //             controller: _nameController..text = name,
                      //             decoration:
                      //                 const InputDecoration(labelText: 'Name'),
                      //           ),
                      //           TextField(
                      //             controller: _supplierNameController
                      //               ..text = data['supplier']['name'],
                      //             decoration: const InputDecoration(
                      //                 labelText: 'Supplier Name'),
                      //             enabled: false,
                      //           ),
                      //           const SizedBox(height: 10),
                      //           // Dropdown field of suppliers
                      //           StreamBuilder(
                      //             stream: supplierService.readSupplier(),
                      //             builder: (context, snapshot) {
                      //               if (snapshot.hasData) {
                      //                 List<Supplier> supplierList =
                      //                     snapshot.data!.docs.map((doc) {
                      //                   return Supplier(doc.id, doc['name']);
                      //                 }).toList();

                      //                 return DropdownButton(
                      //                   items: supplierList
                      //                       .map<DropdownMenuItem<Supplier>>(
                      //                           (supplier) => DropdownMenuItem(
                      //                                 value: supplier,
                      //                                 child:
                      //                                     Text(supplier.name),
                      //                               ))
                      //                       .toList(),
                      //                   onChanged: (Supplier? value) {
                      //                     if (value != null) {
                      //                       setState(() {
                      //                         _supplierNameController.text =
                      //                             value.name;
                      //                         _supplierIdController.text =
                      //                             value.id;
                      //                       });
                      //                     }
                      //                   },
                      //                   hint: const Text('Select Supplier'),
                      //                 );
                      //               } else {
                      //                 return const Text('No data');
                      //               }
                      //             },
                      //           ),
                      //         ],
                      //       ),
                      //       actions: [
                      //         ElevatedButton(
                      //           onPressed: () async {
                      //             await productService.updateProduct(
                      //                 docId,
                      //                 _nameController.text,
                      //                 _supplierIdController.text,
                      //                 _supplierNameController.text);
                      //             await supplierService
                      //                 .removeProductFromSupplier(
                      //               data['supplier']['id'],
                      //               docId,
                      //             );
                      //             await supplierService.addProductToSupplier(
                      //                 _supplierIdController.text,
                      //                 docId,
                      //                 _nameController.text);
                      //             _nameController.clear();
                      //             _productIdcontroller.clear();
                      //             _supplierNameController.clear();
                      //             _supplierIdController.clear();
                      //             // snackbar
                      //             ScaffoldMessenger.of(context).showSnackBar(
                      //               const SnackBar(
                      //                 content: Text('Product updated'),
                      //                 duration: Duration(seconds: 2),
                      //               ),
                      //             );
                      //             Navigator.of(context).pop();
                      //           },
                      //           child: const Text('Update Product'),
                      //         )
                      //       ]),
                      // );
                    },
                    child: Container(
                      margin:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Color.fromARGB(255, 146, 143, 143),
                          width: 1,
                        ),
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Color.fromARGB(255, 255, 255, 255),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    margin: const EdgeInsets.fromLTRB(
                                        10, 15, 10, 10),
                                    child: SvgPicture.asset(
                                      'assets/vectors/allproducticon.svg',
                                      width: 20,
                                    ),
                                  ),
                                  Expanded(
                                    // Use Expanded for the product name Text widget
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 8, 20, 0),
                                      child: Text(
                                        name,
                                        style: GoogleFonts.nunitoSans(
                                          textStyle: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            height: 1.4,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'ID: $docId',
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _capturePng(
                                          textToGenerate: docId,
                                          type: 'product',
                                        );
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFAFAFA),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Icon(
                                          Icons.qr_code,
                                          color: Color(0xFF058B06),
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Center(child: Text('No Data'));
            }
          },
        ),
      ),
    );
  }
}
