import 'package:cloud_firestore/cloud_firestore.dart';

class ProductFirestoreService {
  // get collection of products
  final CollectionReference products =
      FirebaseFirestore.instance.collection('products');

  Future<List<String>> getAllProductIds() async {
    try {
      QuerySnapshot querySnapshot = await products.get();
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

  Future<bool> checkProductExist(String name) async {
    final products = await this.products.get();
    for (var doc in products.docs) {
      if (doc['name'] == name) {
        return true;
      }
    }
    return false;
  }

  // Create a new product
  Future<String> createProduct(
      String name, String supplierId, String supplierName) async {
    bool productExist = await checkProductExist(name);

    if (productExist) {
      return 'Product exist';
    } else {
      DocumentReference productRef = await products.add(
        {
          'name': name,
          'supplier': {
            'id': supplierId,
            'name': supplierName,
          },
          'created_at': Timestamp.now(),
          'palettes': [],
          'meters': 0,
          'rolls': 0,
          'yards': 0,
          'sqm': 0,
          'pallets': 0,
          'kgm': 0,
          'bags': 0,
          'sheets': 0
        },
      );
      return productRef.id;
    }
  }

  // Increment product total qty
  Future<void> incrementProductTotalQty(String id, String unit, int qty) async {
    final product = await products.doc(id).get();

    int totalQty = product[unit.toLowerCase()] + qty;

    await products.doc(id).update({unit.toLowerCase(): totalQty});
  }

  // Increment product total qty
  Future<void> decrementProductTotalQty(String id, String unit, int qty) async {
    final product = await products.doc(id).get();

    int totalQty = product[unit.toLowerCase()] - qty;

    await products.doc(id).update({unit.toLowerCase(): totalQty});
  }

  Stream<QuerySnapshot> readProduct() {
    final paletteStream = products.snapshots();
    return paletteStream;
  }

  // read all product and return as a list
  Future<List<Map<String, dynamic>>> readAllProduct() async {
    final products = await this.products.get();
    List<Map<String, dynamic>> productList = [];
    for (var i = 0; i < products.docs.length; i++) {
      final doc = products.docs[i];
      productList.add(doc.data() as Map<String, dynamic>);
    }
    return productList;
  }

  // Read product by id
  Future<DocumentSnapshot> readProductById(String id) async {
    final product = await products.doc(id).get();

    return product;
  }

  // get productname by id
  Future<String> getProductNameById(String id) async {
    final product = await products.doc(id).get();
    return product.get('name');
  }

  // get palettes by productid
  Future<List<Map<String, dynamic>>> getPalettesByProductId(String id) async {
    final product = await products.doc(id).get();
    if (product.get('palettes') == null) {
      return [];
    } else {
      return List<Map<String, dynamic>>.from(product.get('palettes') ?? []);
    }
  }

  // get qty_list of palette given palette_id

  // Stream builder product by id
  Stream<DocumentSnapshot> streamProductById(String id) {
    return products.doc(id).snapshots();
  }

  // Add, and qty to product's qty list when an activity is created
  // Move qty_list to inside the palette inside in_palette
  Future<void> incrementProduct(String productId, String paletteId,
      String paletteName, String unit, int qty) async {
    final palette = await products.doc(productId).get();
    List<Map<String, dynamic>> palettes =
        List<Map<String, dynamic>>.from(palette.get('palettes') ?? []);

    bool updated = false;

    for (int i = 0; i < palettes.length; i++) {
      if (palettes[i]['palette_id'] == paletteId) {
        // Ensure qty_list is parsed correctly
        Map<String, dynamic> qtyList =
            (palettes[i]['qty_list'] as Map<String, dynamic>);

        // Update the quantity of the existing unit or add a new unit
        qtyList[unit.toLowerCase()] = (qtyList[unit.toLowerCase()] ?? 0) + qty;

        // Update the qty_list for the product
        palettes[i]['qty_list'] = qtyList;

        updated = true;
        break;
      }
    }

    if (!updated) {
      // Add new product with qty_list containing initial unit and qty
      palettes.add(
        {
          'palette_id': paletteId,
          'palette_name': paletteName,
          'qty_list': {
            unit.toLowerCase(): qty,
          }
        },
      );
    }

    await products.doc(productId).update({
      'palettes': palettes,
    });
  }

  Future<void> decrementProductQtyList(
      String productId, String paletteId, String unit, int qty) async {
    final product = await products.doc(productId).get();
    List<Map<String, dynamic>> palettes =
        List<Map<String, dynamic>>.from(product.get('palettes') ?? []);

    bool found = false;

    for (int i = 0; i < palettes.length; i++) {
      if (palettes[i]['palette_id'] == paletteId) {
        // Ensure qty_list is parsed correctly
        Map<String, dynamic> qtyList =
            (palettes[i]['qty_list'] as Map<String, dynamic>);

        // Update the quantity of the existing unit or add a new unit
        qtyList[unit.toLowerCase()] = (qtyList[unit.toLowerCase()] ?? 0) - qty;

        // Update the qty_list for the product
        palettes[i]['qty_list'] = qtyList;

        // if all units are removed, remove the palette from the product
        if (qtyList[unit.toLowerCase()] <= 0) {
          qtyList.remove(unit.toLowerCase());
        }

        if (qtyList.isEmpty) {
          palettes.removeAt(i);
        }

        found = true;
        break;
      }
    }

    if (!found) {}

    await products.doc(productId).update({
      'palettes': palettes,
    });
  }

  Future checkProductQtyList(String id, String paletteId, String unit) async {
    final product = await products.doc(id).get();
    final palettes = product['palettes'];

    for (var i = 0; i < palettes.length; i++) {
      if (palettes[i]['palette_id'] == paletteId &&
          palettes[i]['qty_list'][unit.toLowerCase()] != null) {
        return palettes[i]['qty_list'][unit.toLowerCase()];
      }
    }
    return 0;
  }

  Stream<QuerySnapshot> getProducts() {
    return products.snapshots();
  }

  // Update a product
  Future<void> updateProduct(
      String id, String name, String supplierId, String supplierName) async {
    await products.doc(id).update(
      {
        'name': name,
      },
    );
  }

  // Delete a product
  Future<void> deleteProduct(String id) async {
    await products.doc(id).delete();
  }

  // delete palette from product and decrement qty
  Future<void> deletePaletteFromProduct(
      String productId, String paletteId) async {
    final product = await products.doc(productId).get();
    List<Map<String, dynamic>> palettes =
        List<Map<String, dynamic>>.from(product.get('palettes') ?? []);

    // get the qty in the palette
    for (var i = 0; i < palettes.length; i++) {
      if (palettes[i]['palette_id'] == paletteId) {
        final qtyList = palettes[i]['qty_list'];
        for (var key in qtyList.keys) {
          await decrementProductTotalQty(productId, key, qtyList[key]);
        }
        palettes.removeAt(i); // Remove the palette from the list
        break;
      }
    }
    // Update the product with the modified palette list
    await products.doc(productId).update({'palettes': palettes});
  }
}
