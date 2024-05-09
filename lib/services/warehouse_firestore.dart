import 'package:cloud_firestore/cloud_firestore.dart';

class WarehouseFirestoreService {
  // get collection of warehouses
  final CollectionReference warehouses =
      FirebaseFirestore.instance.collection('warehouses');

  // Create a new warehouse
  Future<String> createWarehouse(String name) async {
    await warehouses.add(
      {'name': name, 'palettes': []},
    );
    return warehouses.id;
  }

  // Read a warehouse
  Stream<QuerySnapshot> readWarehouse() {
    final warehouseStream = warehouses.snapshots();

    return warehouseStream;
  }

  // Read a palette by id
  Future readWarehouseById(String id) async {
    final palette = await warehouses.doc(id).get();
    return palette;
  }

  // get warehouse names and ids and return as a map
  Future<Map<String, String>> getWarehouseNames() async {
    final warehouse = await warehouses.get();
    final warehouseNames = <String, String>{};

    for (var i = 0; i < warehouse.docs.length; i++) {
      warehouseNames[warehouse.docs[i].id] = warehouse.docs[i]['name'];
    }

    return warehouseNames;
  }

  // Update a warehouse
  Future<void> updateWarehouse(String id, String name) async {
    await warehouses.doc(id).update(
      {
        'name': name,
      },
    );
  }

  // add a palette to a warehouse in json format like {paletteId: paletteName}
  Future<void> addPaletteToWarehouse(
      String whId, String paletteId, String paletteName) async {
    await warehouses.doc(whId).update(
      {
        'palettes': FieldValue.arrayUnion([
          {paletteId: paletteName}
        ]),
      },
    );
  }

  // Remove a palette from a warehouse by warehouse name
  Future<void> removePaletteFromWarehouse(String whId, String paletteId) async {
    await warehouses.doc(whId).update(
      {
        'palettes': FieldValue.arrayRemove([paletteId]),
      },
    );
  }

  // Delete a warehouse
  Future<void> deleteWarehouse(String id) async {
    await warehouses.doc(id).delete();
  }
}
