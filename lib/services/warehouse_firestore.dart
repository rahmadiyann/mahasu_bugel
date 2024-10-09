import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/services/activity_firestore.dart';
import 'package:myapp/services/palette_firestore.dart';

class WarehouseFirestoreService {
  // get collection of warehouses
  final CollectionReference warehouses =
      FirebaseFirestore.instance.collection('warehouses');

  final PaletteFirestoreService palletservice = PaletteFirestoreService();
  final ActivityFirestoreService activityservice = ActivityFirestoreService();

  Future<bool> checkWarehouseExist(String name) async {
    final warehouses = await this.warehouses.get();
    for (var doc in warehouses.docs) {
      if (doc['name'] == name) {
        return true;
      }
    }
    return false;
  }

  // Create a new warehouse
  Future<String> createWarehouse(String name) async {
    bool warehouseExist = await checkWarehouseExist(name);
    if (warehouseExist) {
      return 'Warehouse exist';
    } else {
      DocumentReference warehouseref = await warehouses.add(
        {'name': name, 'palettes': {}},
      );
      return warehouseref.id;
    }
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

  //get warehouse name by id
  Future<String> getWarehouseNameById(String id) async {
    final warehouse = await warehouses.doc(id).get();
    return warehouse['name'];
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

  // Add a palette to a warehouse by warehouse id
  Future<void> addPaletteToWarehouse(
      String whId, String paletteId, String paletteName) async {
    // get the list of palettes in the warehouse
    final warehouse = await warehouses.doc(whId).get();
    final palettes = warehouse['palettes'];
    if (palettes != null) {
      // add the paletteId:paletteName map to the palettes map
      await warehouses.doc(whId).update({
        'palettes': FieldValue.arrayUnion([
          {paletteId: paletteName}
        ]),
      });
    }
  }

  // remove palette from warehouse by warehouse id
  Future<void> removePaletteFromWarehouse(String whId, String paletteId) async {
    await warehouses.doc(whId).update(
      {
        'palettes': FieldValue.arrayRemove([paletteId]),
      },
    );
  }

  // Delete a warehouse
  // Future<void> deleteWarehouse(String id, String paletteName) async {
  //   // get all palettes in the warehouse
  //   final warehouse = await warehouses.doc(id).get();
  //   final palettes = warehouse['palettes'];
  //   // for every palette, run paletteservice.deletePalette
  //   for (var i = 0; i < palettes.length; i++) {
  //     String paletteId = palettes[i].keys.first;
  //     await palletservice.deletePalette(paletteId);
  //   }
  //   // delete the activity by warehouse id
  //   await activityservice.deleteActivityByWarehouseId(id);
  //   await warehouses.doc(id).delete();
  // }

  // Remove palette if exists from all warehouses given palette id
  Future<void> removePaletteFromAllWarehouses(
      String paletteId, paletteName) async {
    final warehouse = await warehouses.get();

    for (var i = 0; i < warehouse.docs.length; i++) {
      await warehouses.doc(warehouse.docs[i].id).update(
        {
          'palettes': FieldValue.arrayRemove([
            {paletteId: paletteName}
          ]),
        },
      );
    }
  }
}
