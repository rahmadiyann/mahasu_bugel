import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:myapp/firebase_options.dart';
import 'package:myapp/pages/activities/inbound_page.dart';
import 'package:myapp/pages/activities/outbound_page.dart';
import 'package:myapp/pages/auth/auth_check.dart';
import 'package:myapp/pages/auth/login_page.dart';
import 'package:myapp/pages/home_page.dart';
import 'package:myapp/pages/palettes/new_palette_page.dart';
import 'package:myapp/pages/palettes/palettes_page.dart';
import 'package:myapp/pages/products/new_product_page.dart';
import 'package:myapp/pages/products/products_page.dart';
import 'package:myapp/pages/suppliers/new_supplier_page.dart';
import 'package:myapp/pages/suppliers/suppliers_page.dart';
import 'package:myapp/pages/warehouses/warehouse_page.dart';

void main() async {
  await dotenv.load(fileName: '.env');

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
        '/products': (context) => const ProductsPage(),
        '/new-product': (context) => const NewProductPage(),
        '/palettes': (context) => const PalettesPage(),
        '/new-palette': (context) => const NewPalettePage(),
        '/warehouses': (context) => const WarehousesPage(),
        '/suppliers': (context) => const SuppliersPage(),
        '/new-supplier': (context) => const NewSupplierPage(),
        '/inbound': (context) => const InboundPage(),
        '/outbound': (context) => const OutboundPage(),
      },
    );
  }
}
