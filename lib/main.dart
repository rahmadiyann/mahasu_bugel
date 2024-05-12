import 'package:Mahasu/components/download_activity.dart';
import 'package:Mahasu/pages/activities/inbound_page.dart';
import 'package:Mahasu/pages/activities/outbound_page.dart';
import 'package:Mahasu/pages/auth/login_page.dart';
import 'package:Mahasu/pages/home_page.dart';
import 'package:Mahasu/pages/palettes/all_palette_page.dart';
import 'package:Mahasu/pages/products/product_page.dart';
import 'package:Mahasu/pages/suppliers/suppliers_page.dart';
import 'package:Mahasu/pages/testingpages/newoutboundpage.dart';
import 'package:Mahasu/pages/warehouses/all_warehouse_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Mahasu/firebase_options.dart';
import 'package:Mahasu/pages/auth/auth_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthCheckPage(),
        routes: {
          '/auth-check': (context) => const AuthCheckPage(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/products': (context) => const AllProductPage(),
          '/palettes': (context) => const allPalettePage(),
          '/warehouses': (context) => const WarehousesPage(),
          '/suppliers': (context) => const AllSuppliersPage(),
          '/inbound': (context) => const InboundPage(),
          '/outbound': (context) => const OutboundPage(),
        });
  }
}
