import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/pages/products/product_i_page.dart';
import 'package:myapp/pages/suppliers/edit_supplier_page.dart';
import 'package:myapp/services/supplier_firestore.dart';

class SupplierPage extends StatefulWidget {
  final String supplierId;
  final String supplierName;
  final String supplierAddress;
  final String supplierPhone;
  const SupplierPage({
    super.key,
    required this.supplierId,
    required this.supplierName,
    required this.supplierAddress,
    required this.supplierPhone,
  });

  @override
  State<SupplierPage> createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  final SupplierFirestoreService supplierService = SupplierFirestoreService();

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
            Navigator.pop(
              context,
            );
          },
        ),
        title: Text(
          widget.supplierName.toUpperCase(),
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
                    builder: (context) => EditSupplierPage(
                      supplierId: widget.supplierId,
                      supplierName: widget.supplierName,
                      supplierAddress: widget.supplierAddress,
                      supplierPhone: widget.supplierPhone,
                    ),
                  ),
                );
              },
              child: Container(
                width: 70,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
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
      body: StreamBuilder(
        stream: supplierService.streamSupplierById(widget.supplierId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List products = snapshot.data!['products'];

            if (products.isEmpty) {
              return Center(
                child: Text(
                  '${widget.supplierName} has no products...',
                  style: GoogleFonts.nunitoSans(
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      height: 1.4,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ProductPage(
                              productId: products[index].keys.first,
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.grey.shade400, width: 1),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade300,
                              blurRadius: 10,
                              offset: const Offset(0, 10),
                            ),
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 30,
                                    height: 30,
                                    child: SvgPicture.asset(
                                        'assets/vectors/allproducticon.svg',
                                        fit: BoxFit.contain),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      products[index].values.first,
                                      overflow: TextOverflow.clip,
                                      style: GoogleFonts.nunitoSans(
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          height: 1.4,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 6.7, 0, 1.7),
                              width: 6.7,
                              height: 10.7,
                              child:
                                  Image.asset('assets/images/arrowright.png'),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
