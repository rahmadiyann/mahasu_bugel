import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/services/activity_firestore.dart';
import 'package:myapp/services/product_firestore.dart';
import 'package:myapp/services/warehouse_firestore.dart';

final WarehouseFirestoreService warehouseservice = WarehouseFirestoreService();

class PaletteFirestoreService {
  // get collection of palettes
  final CollectionReference palettes =
      FirebaseFirestore.instance.collection('palettes');

  final CollectionReference warehouses =
      FirebaseFirestore.instance.collection('warehouses');

  final ProductFirestoreService productser = ProductFirestoreService();

  // return warehouse name by palette id
  Future<String> getWarehouseId(String id) async {
    final palette = await palettes.doc(id).get();
    final whid = palette['whid'];
    return whid;
  }

  // check if theres any document in the collection
  Future<QuerySnapshot> getAllPalette() {
    return palettes.get();
  }

  // return warehouse name by palette id
  Future<String> getWarehouseName(String id) async {
    final palette = await palettes.doc(id).get();
    final whName = palette['whname'];
    return whName;
  }

  Future<List<String>> getAllPaletteIds() async {
    try {
      QuerySnapshot querySnapshot = await palettes.get();
      List<String> productIds = [];
      for (var doc in querySnapshot.docs) {
        productIds.add(doc.id);
      }
      return productIds;
    } catch (error) {
      // Handle any errors here
      return []; // Return an empty list in case of error
    }
  }

  // new function to fetch palette name from a given id
  Future<String> getPaletteName(String id) async {
    try {
      DocumentSnapshot doc = await palettes.doc(id).get();
      return doc['name'];
    } catch (error) {
      // Handle any errors here
      return ''; // Return an empty string in case of error
    }
  }

  Future<bool> checkPaletteExist(String name) async {
    try {
      QuerySnapshot querySnapshot = await palettes.get();
      for (var doc in querySnapshot.docs) {
        if (doc['name'] == name) {
          return true;
        }
      }
      return false;
    } catch (error) {
      // Handle any errors here
      return false; // Return an empty list in case of error
    }
  }

  // Create a new palette
  Future<String> createPalette(String name, String whId, String whName) async {
    bool paletteExist = await checkPaletteExist(name);
    if (paletteExist) {
      return 'Palette already exist';
    } else {
      DocumentReference paletteRef = await palettes.add(
        {
          'name': name,
          'whid': whId,
          'whname': whName,
          'soStatus': 'Confirmed',
          'lastStockOpname': Timestamp.now(),
          'products': [],
          'createdAt': Timestamp.now()
        },
      );
      return paletteRef.id;
    }
  }

  // Get unconfirmed palette
  Stream<QuerySnapshot> readUnconfirmedPalette() {
    final unconfirmedPaletteStream =
        palettes.where('soStatus', isEqualTo: 'Unconfirmed').snapshots();

    return unconfirmedPaletteStream;
  }

  //given palette id, return its whid
  Future<String> getwhidbypaletteid(String paletteId) async {
    final palette = await palettes.doc(paletteId).get();
    final whid = palette['whid'];
    return whid;
  }

// get palette id, name and whid and return as <Map<String, Map<String, String>>>
  Future<Map<String, Map<String, String>>> getPaletteNames() async {
    final palette = await palettes.get();
    final paletteNames = <String, Map<String, String>>{};

    for (var i = 0; i < palette.docs.length; i++) {
      final doc = palette.docs[i];
      paletteNames[doc.id] = {'name': doc['name'], 'whid': doc['whid']};
    }

    return paletteNames;
  }

  // get paletteWhId by paletteId
  Future<String> getPaletteWhId(String id) async {
    final palette = await palettes.doc(id).get();
    final whId = palette['whid'];
    return whId;
  }

  // Read a palette
  Stream<QuerySnapshot> readPalette() {
    final paletteStream = palettes.snapshots();

    return paletteStream;
  }

  Stream<DocumentSnapshot> streamPaletteById(String id) {
    return palettes.doc(id).snapshots();
  }

  // Read a palette by id
  Future readPaletteById(String id) async {
    final palette = await palettes.doc(id).get();
    return palette;
  }

  // Update a palette
  Future<void> updatePalette(
      String id, String name, String whId, String whName) async {
    await palettes.doc(id).update(
      {
        'name': name,
        'whid': whId,
        'whname': whName,
      },
    );
  }

  // get paletteName by paletteId
  Future<String> getPaletteNameById(String id) async {
    final palette = await palettes.doc(id).get();
    final name = palette['name'];
    return name;
  }

  // Stock Opname a palette
  Future<void> stockOpnamePalette(String id) async {
    await palettes.doc(id).update(
      {
        'soStatus': 'Confirmed',
        'lastStockOpname': DateTime.now(),
      },
    );
  }

  // Reset palette's stock opname status
  Future<void> resetStockOpnamePalette(String id) async {
    await palettes.doc(id).update(
      {
        'soStatus': 'Unconfirmed',
      },
    );
  }

  Future checkProductQtyList(String id, String productId, String unit) async {
    final palette = await palettes.doc(id).get();
    final products = palette['products'];

    for (var i = 0; i < products.length; i++) {
      if (products[i]['productId'] == productId &&
          products[i]['qty_list'][unit] != null) {
        return products[i]['qty_list'][unit];
      }
    }
    return 0;
  }

  Future<void> incrementProduct(String id, String productId, String productName,
      String unit, int qty) async {
    final product = await palettes.doc(id).get();
    List<Map<String, dynamic>> products =
        List<Map<String, dynamic>>.from(product.get('products') ?? []);

    bool updated = false;
    unit = unit.toLowerCase();
    for (int i = 0; i < products.length; i++) {
      if (products[i]['productId'] == productId) {
        // Ensure qty_list is parsed correctly
        Map<String, dynamic> qtyList =
            (products[i]['qty_list'] as Map<String, dynamic>);

        // Update the quantity of the existing unit or add a new unit
        qtyList[unit] = (qtyList[unit] ?? 0) + qty;

        // Update the qty_list for the product
        products[i]['qty_list'] = qtyList;

        updated = true;
        break;
      }
    }

    if (!updated) {
      // Add new product with qty_list containing initial unit and qty
      products.add({
        'productId': productId,
        'productName': productName,
        'qty_list': {
          unit: qty,
        }
      });
    }

    await palettes.doc(id).update({
      'products': products,
    });
  }

  Future<void> decrementProduct(
      String id, String productId, String unit, int qty) async {
    final product = await palettes.doc(id).get();
    List<Map<String, dynamic>> products =
        List<Map<String, dynamic>>.from(product.get('products') ?? []);

    bool found = false;
    unit = unit.toLowerCase();
    for (int i = 0; i < products.length; i++) {
      if (products[i]['productId'] == productId) {
        // Ensure qty_list is parsed correctly
        Map<String, dynamic> qtyList =
            (products[i]['qty_list'] as Map<String, dynamic>);

        // Update the quantity of the existing unit or add a new unit
        qtyList[unit] =
            (qtyList[unit] ?? 0) - qty; // Corrected decrement operation

        // Update the qty_list for the product
        products[i]['qty_list'] = qtyList;

        if (qtyList[unit] <= 0) {
          qtyList.remove(unit);
        }

        if (qtyList.isEmpty) {
          products.removeAt(i);
        }

        found = true;
        break;
      }
    }

    if (!found) {}

    await palettes.doc(id).update({
      'products': products,
    });
  }

  // delete product from all palettes
  Future<void> removeProductFromAllPalette(String productId) async {
    final palette = await palettes.get();

    for (var i = 0; i < palette.docs.length; i++) {
      final products = palette.docs[i]['products'];
      for (var j = 0; j < products.length; j++) {
        if (products[j]['productId'] == productId) {
          log('found!!!!');
          // delete the product entry in the products list
          products.removeAt(j);
        }
      }

      await palettes.doc(palette.docs[i].id).update({
        'products': products,
      });
    }
  }

  // Delete a palette
  Future<void> deletePalette(String id, String name) async {
    log('--deletePalette--');
    log('paletteId: $id');
    // check if palette has products
    final palette = await palettes.doc(id).get();
    // remove palette from warehouse
    await warehouseservice.removePaletteFromAllWarehouses(id, name);
    final products = palette['products'];
    if (products.isNotEmpty) {
      for (var i = 0; i < products.length; i++) {
        await productser.deletePaletteFromProduct(
          products[i]['productId'],
          id,
        );
      }
    }
    await ActivityFirestoreService().deleteActivityByPaletteId(id);
    await palettes.doc(id).delete();
  }
}
