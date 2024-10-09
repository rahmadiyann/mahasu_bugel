// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/components/button.dart';
import 'package:myapp/components/download_activity.dart';
import 'package:myapp/components/previewcards.dart';
import 'package:myapp/pages/activities/edit_activity_page.dart';
import 'package:myapp/pages/activities/inbound_page.dart';
import 'package:myapp/pages/activities/outbound_page.dart';
import 'package:myapp/pages/auth/auth_check.dart';
import 'package:myapp/pages/palettes/palettes_page.dart';
import 'package:myapp/pages/products/products_page.dart';
import 'package:myapp/pages/suppliers/suppliers_page.dart';
import 'package:myapp/pages/warehouses/warehouse_page.dart';
import 'package:myapp/services/activity_firestore.dart';
import 'package:myapp/services/palette_firestore.dart';
import 'package:myapp/services/product_firestore.dart';
import 'package:myapp/services/supplier_firestore.dart';
import 'package:myapp/services/warehouse_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WarehouseFirestoreService warehouseservice =
      WarehouseFirestoreService();
  final PaletteFirestoreService paletteservice = PaletteFirestoreService();
  final ProductFirestoreService productservice = ProductFirestoreService();
  final SupplierFirestoreService supplierservice = SupplierFirestoreService();
  final ActivityFirestoreService activityservice = ActivityFirestoreService();
  // Get the current date
  DateTime startOfDay = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 0, 0, 0);
  DateTime endOfDay = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, 23, 59, 59);
  bool _isFiltered = false;

  logout() async {
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
                    color: Color.fromRGBO(251, 154, 154, 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/warningicon.png',
                      height: 100,
                      width: 100,
                      color: Color.fromRGBO(255, 70, 70, 1),
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
                    'Are you sure you want to log out?',
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
                        FirebaseAuth.instance.signOut();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AuthCheckPage(),
                          ),
                        );
                      },
                      text: 'Yes',
                    ),
                  ],
                ),
                SizedBox(height: 20)
              ],
            ),
          ),
        ),
      ),
    );
  }

  var monthName = {
    1: 'January',
    2: 'February',
    3: 'March',
    4: 'April',
    5: 'May',
    6: 'June',
    7: 'July',
    8: 'August',
    9: 'September',
    10: 'October',
    11: 'November',
    12: 'December'
  };

  // define ontap function to navigate to a given page
  void ontap(BuildContext context, Widget destinationPage) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => destinationPage,
      ),
    );
  }

  selectDateRange() async {
    final dateTimeRange = await showDateRangePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendar,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    setState(
      () {
        // debugPrint(dateTimeRange as String);
        if (dateTimeRange != null) {
          startOfDay = dateTimeRange.start;
          endOfDay = DateTime(dateTimeRange.end.year, dateTimeRange.end.month,
              dateTimeRange.end.day, 23, 59, 59, 999, 999);
          _isFiltered = true;
        } else {
          startOfDay = DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day, 0, 0, 0);
          endOfDay = DateTime(DateTime.now().year, DateTime.now().month,
              DateTime.now().day, 23, 59, 59);
          _isFiltered = false;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // use F5f5f5 as background color
      backgroundColor: Color(0xFFF5F5F5),
      body: Column(
        children: [
          const SizedBox(height: 70),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Welcome!',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000000),
                  ),
                ),
                GestureDetector(
                  onTap: logout,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Image.asset(
                      'assets/images/mahasu.png',
                      width: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Dashboard',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color.fromARGB(255, 91, 90, 90),
                  ),
                ),
              ),
            ],
          ),
          // GridView of 6 columns and 2 rows
          Expanded(
            child: GridView.count(
              padding: const EdgeInsets.all(10),
              crossAxisCount: 3,
              scrollDirection: Axis.vertical,
              children: [
                MyPreviewCard(
                  ontap: () {
                    ontap(context, InboundPage());
                  },
                  stream: activityservice.readInboundActivity(),
                  title: 'Inbound',
                  imagePath: 'assets/vectors/inboundicon.svg',
                ),
                MyPreviewCard(
                  ontap: () {
                    ontap(context, OutboundPage());
                  },
                  stream: activityservice.readOutboundActivity(),
                  title: 'Outbound',
                  imagePath: 'assets/vectors/outboundicon.svg',
                ),
                MyPreviewCard(
                    ontap: () {
                      ontap(context, PalettesPage());
                    },
                    stream: paletteservice.readPalette(),
                    title: 'Palettes',
                    imagePath: 'assets/vectors/stockopnameicon.svg'),
                MyPreviewCard(
                  ontap: () {
                    ontap(context, ProductsPage());
                  },
                  stream: productservice.readProduct(),
                  title: 'All Products',
                  imagePath: 'assets/vectors/allproducticon.svg',
                ),
                MyPreviewCard(
                  ontap: () {
                    ontap(context, const SuppliersPage());
                  },
                  stream: supplierservice.readSupplier(),
                  title: 'Supplier',
                  imagePath: 'assets/vectors/suppliericon.svg',
                ),
                MyPreviewCard(
                  ontap: () {
                    ontap(context, const WarehousesPage());
                  },
                  stream: warehouseservice.readWarehouse(),
                  title: 'Warehouses',
                  imagePath: 'assets/vectors/warehouseicon.svg',
                ),
              ],
            ),
          ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Activity Preview',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color.fromARGB(255, 91, 90, 90),
                      ),
                    ),
                  ),
                  DownloadExcelButton(),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    selectDateRange();
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          'assets/vectors/calendaricon.svg',
                          height: 25,
                          width: 25,
                        ),
                      ),
                      (startOfDay.day == DateTime.now().day &&
                              startOfDay.month == DateTime.now().month &&
                              startOfDay.year == DateTime.now().year)
                          ? Text(
                              'Today',
                              style: GoogleFonts.nunitoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color.fromARGB(255, 148, 146, 146),
                              ),
                            )
                          : Row(
                              children: [
                                Text(
                                  // format (DD/MM/YYYY) with month name and add 0 if day is less than 10
                                  '${startOfDay.day < 10 ? '0' : ''}${startOfDay.day} ${monthName[startOfDay.month]} ${startOfDay.year}',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromARGB(255, 148, 146, 146),
                                  ),
                                ),
                                Text(' - '),
                                Text(
                                  // format (DD/MM/YYYY) with month name and add 0 if day is less than 10
                                  '${endOfDay.day < 10 ? '0' : ''}${endOfDay.day} ${monthName[endOfDay.month]} ${endOfDay.year}',
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color.fromARGB(255, 148, 146, 146),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
                _isFiltered
                    ? GestureDetector(
                        onTap: () {
                          setState(
                            () {
                              startOfDay = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  0,
                                  0,
                                  0);
                              endOfDay = DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                  23,
                                  59,
                                  59);
                              _isFiltered = false;
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/images/clearfilter.png',
                            height: 20,
                            width: 20,
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          Flexible(
            child: StreamBuilder(
              stream:
                  activityservice.filteredActivityStream(startOfDay, endOfDay),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List activityList = snapshot.data!.docs;

                  // filter activity that has the same date as today
                  activityList.sort(
                    (a, b) => b['timestamp'].compareTo(
                      a['timestamp'],
                    ),
                  );

                  return ListView(
                    children: activityList.asMap().entries.map((entry) {
                      DocumentSnapshot activity = entry.value;

                      Map<String, dynamic> data =
                          activity.data() as Map<String, dynamic>;

                      String type = data['type'];
                      String productId = data['product_id'];
                      String paletteId = data['palette_id'];
                      String unit = data['unit'];
                      int qty = data['qty'];
                      Timestamp timestamp = data['timestamp'];

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
                          margin: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 2,
                                  offset: const Offset(0, 3),
                                ),
                              ]),
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
                                          future: productservice
                                              .readProductById(productId),
                                          builder: (context, snapshot) {
                                            if (snapshot.hasData) {
                                              DocumentSnapshot product =
                                                  snapshot.data
                                                      as DocumentSnapshot;

                                              if (product.data() == null) {
                                                return Text('Loading...');
                                              } else {
                                                Map<String, dynamic>
                                                    productData = product.data()
                                                        as Map<String, dynamic>;
                                                String name =
                                                    productData['name'];
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                    name,
                                                    style:
                                                        GoogleFonts.nunitoSans(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF000000),
                                                    ),
                                                  ),
                                                );
                                              }
                                            } else {
                                              return Text('Loading...');
                                            }
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: type == 'Inbound'
                                                ? Colors.green
                                                : Colors.yellow,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            gradient: LinearGradient(
                                              colors: [
                                                type == 'Inbound'
                                                    ? Colors.green.shade400
                                                    : Colors.yellow.shade400,
                                                type == 'Inbound'
                                                    ? Colors.green.shade300
                                                    : Colors.yellow.shade300,
                                              ],
                                            ),
                                          ),
                                          child: Text(
                                            type,
                                            style: TextStyle(
                                              color: type == 'Inbound'
                                                  ? Colors.green.shade900
                                                  : Colors.yellow.shade900,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'QTY: ',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          '$qty ${unit.toUpperCase()}',
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
                                            DocumentSnapshot palette = snapshot
                                                .data as DocumentSnapshot;
                                            if (palette.exists) {
                                              Map<String, dynamic> paletteData =
                                                  palette.data()
                                                      as Map<String, dynamic>;
                                              String name = paletteData['name'];
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Row(
                                                  children: [
                                                    Image.asset(
                                                      'assets/images/rack.png',
                                                      height: 15,
                                                      width: 15,
                                                    ),
                                                    Text(
                                                      name.toUpperCase(),
                                                      style: TextStyle(
                                                          color: Colors.grey,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else {
                                              return Text('Loading...');
                                            }
                                          } else {
                                            return Text('Loading...');
                                          }
                                        },
                                      ),
                                      // FutureBuilder(
                                      //   future: warehouseservice
                                      //       .readWarehouseById(warehouseId),
                                      //   builder: (context, snapshot) {
                                      //     if (snapshot.hasData) {
                                      //       debugPrint("homepage: ${warehouseId.toString()}");
                                      //       DocumentSnapshot warehouse =
                                      //           snapshot.data
                                      //               as DocumentSnapshot;
                                      //       if (warehouse.data() == null) {
                                      //         return Text('Loading...');
                                      //       } else {
                                      //         Map<String, dynamic>
                                      //             warehouseData =
                                      //             warehouse.data()
                                      //                 as Map<String, dynamic>;
                                      //         String name =
                                      //             warehouseData['name'];
                                      //         return Padding(
                                      //           padding:
                                      //               const EdgeInsets.symmetric(
                                      //                   horizontal: 8),
                                      //           child: Row(
                                      //             mainAxisAlignment:
                                      //                 MainAxisAlignment.start,
                                      //             children: [
                                      //               Text(
                                      //                 name.toUpperCase(),
                                      //                 style: TextStyle(
                                      //                   color: Colors.grey,
                                      //                   fontWeight:
                                      //                       FontWeight.bold,
                                      //                 ),
                                      //               ),
                                      //               SizedBox(width: 10),
                                      //               Image.asset(
                                      //                 'assets/images/warehouseicon.png',
                                      //                 height: 15,
                                      //                 width: 15,
                                      //               ),
                                      //             ],
                                      //           ),
                                      //         );
                                      //       }
                                      //     } else {
                                      //       return Text('Loading...');
                                      //     }
                                      //   },
                                      // ),
                                    ],
                                  ),
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              left: 8.0, right: 8.0),
                                          child: Icon(
                                            Icons.access_time,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          '${timestamp.toDate().day.toString().padLeft(2, '0')}/${timestamp.toDate().month.toString().padLeft(2, '0')}/${timestamp.toDate().year.toString()} ${timestamp.toDate().hour.toString().padLeft(2, '0')}:${timestamp.toDate().minute.toString().padLeft(2, '0')}:${timestamp.toDate().second.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 12),
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
                    }).toList(),
                  );
                } else {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 25),
                        Text('Waiting for incoming transaction..'),
                      ],
                    ),
                  );
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
