import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/components/button.dart';
import 'package:myapp/pages/suppliers/supplier_i_page.dart';
import 'package:myapp/services/phonestripper.dart';
import 'package:myapp/services/supplier_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  final SupplierFirestoreService supplierservice = SupplierFirestoreService();

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
            'All Suppliers',
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
                  Navigator.pushNamed(context, '/new-supplier');
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
          ]),
      body: Center(
        child: StreamBuilder(
          stream: supplierservice.readSupplier(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List supplierList = snapshot.data!.docs;

              return ListView.builder(
                itemCount: supplierList.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot supplier = supplierList[index];
                  String docId = supplier.id;

                  Map<String, dynamic> data =
                      supplier.data() as Map<String, dynamic>;

                  String supplierName = data['name'];
                  String supplierAddress = data['address'];
                  String supplierPhone = data['phone'];
                  String supplierContact = data['contact'];
                  bool isContactMale = supplierContact.contains('Mr.');

                  // display as list tile

                  return GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SupplierPage(
                            supplierId: docId,
                            supplierName: supplierName,
                            supplierAddress: supplierAddress,
                            supplierPhone: supplierPhone,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade400, width: 1),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/vectors/suppliericon.svg',
                                      height: 15,
                                      width: 15,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      supplierName.length > 15
                                          ? '${supplierName.substring(0, 15)}...'
                                          : supplierName,
                                      style: GoogleFonts.nunitoSans(
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          height: 1.4,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    isContactMale
                                        ? Image.asset(
                                            'assets/images/male.png',
                                            height: 15,
                                            width: 15,
                                          )
                                        : Image.asset(
                                            'assets/images/female.png',
                                            height: 15,
                                            width: 15,
                                          ),
                                    const SizedBox(width: 5),
                                    Text(
                                      supplierContact,
                                      style: GoogleFonts.nunitoSans(
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                          height: 1.4,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/pinpoint.png',
                                      height: 15,
                                      width: 15,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      supplierAddress.length > 15
                                          ? '${supplierAddress.substring(0, 15)}...'
                                          : supplierAddress,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.nunitoSans(
                                        textStyle: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          height: 1.4,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () {
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                const SizedBox(height: 20),
                                                Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color.fromRGBO(
                                                        251, 222, 154, 1),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Image.asset(
                                                      'assets/images/warningicon.png',
                                                      // height: 100,
                                                      // width: 100,
                                                      // color: Color.fromRGBO(
                                                      //     198, 181, 47, 1),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 30),
                                                Container(
                                                  margin: const EdgeInsets
                                                      .symmetric(vertical: 10),
                                                  height: 100,
                                                  width: 300,
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: Text(
                                                    'You will be redirected to WhatsApp to chat with the supplier. Continue?',
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        GoogleFonts.nunitoSans(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceAround,
                                                  children: [
                                                    MyButton(
                                                      onTap: () {
                                                        Navigator.pop(context);
                                                      },
                                                      text: 'No',
                                                    ),
                                                    MyButton(
                                                      onTap: () async {
                                                        // redirect to link
                                                        String
                                                            phoneNumberFormatted =
                                                            await stripPhoneNumber(
                                                                supplierPhone);
                                                        final Uri url = Uri.parse(
                                                            'https://wa.me/$phoneNumberFormatted');
                                                        launchUrl(url);
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
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 179, 255, 181),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Icon(
                                          Icons.phone,
                                          size: 15,
                                          color: Colors.black,
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          supplierPhone,
                                          style: GoogleFonts.nunitoSans(
                                            textStyle: const TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              height: 1.4,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            } else {
              return const Text('No data');
            }
          },
        ),
      ),
    );
  }
}
