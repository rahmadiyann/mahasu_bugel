import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/services/palette_firestore.dart';
import 'package:myapp/services/product_firestore.dart';

class ActivityFirestoreService {
  // get collection of activitys
  final CollectionReference activitys =
      FirebaseFirestore.instance.collection('activities');

  final CollectionReference product =
      FirebaseFirestore.instance.collection('products');

  final CollectionReference palette =
      FirebaseFirestore.instance.collection('palettes');

  final PaletteFirestoreService paletteService = PaletteFirestoreService();
  final ProductFirestoreService productService = ProductFirestoreService();

  // Read a activity
  Stream<QuerySnapshot> readActivity() {
    final activityStream = activitys.snapshots();

    return activityStream;
  }

  // Read activity by activityId
  Future<Map<String, dynamic>> readActivityById(String activityId) async {
    final activity = await activitys.doc(activityId).get();
    return activity.data() as Map<String, dynamic>;
  }

  // read all activity and return as a list
  Future<List<Map<String, dynamic>>> readAllActivity() async {
    final activity = await activitys.get();
    List<Map<String, dynamic>> activityList = [];
    for (var i = 0; i < activity.docs.length; i++) {
      final doc = activity.docs[i];
      activityList.add(doc.data() as Map<String, dynamic>);
    }
    return activityList;
  }

  Stream<QuerySnapshot> filteredActivityStream(
      DateTime? startOfDay, DateTime? endOfDay) {
    if (startOfDay == null || endOfDay == null) {
      DateTime today = DateTime.now();
      DateTime startOfDay =
          DateTime(today.year, today.month, today.day, 0, 0, 0);
      DateTime endOfDay =
          DateTime(today.year, today.month, today.day, 23, 59, 59);
      final startOfDayTimestamp = Timestamp.fromMillisecondsSinceEpoch(
          startOfDay.millisecondsSinceEpoch);
      final endOfDayTimestamp =
          Timestamp.fromMillisecondsSinceEpoch(endOfDay.millisecondsSinceEpoch);
      final activities = activitys
          .where('timestamp', isGreaterThanOrEqualTo: startOfDayTimestamp)
          .where('timestamp', isLessThanOrEqualTo: endOfDayTimestamp)
          .snapshots();

      return activities;
    } else {
      final startOfDayTimestamp = Timestamp.fromMillisecondsSinceEpoch(
          startOfDay.millisecondsSinceEpoch);
      final endOfDayTimestamp =
          Timestamp.fromMillisecondsSinceEpoch(endOfDay.millisecondsSinceEpoch);
      final activities = activitys
          .where('timestamp', isGreaterThanOrEqualTo: startOfDayTimestamp)
          .where('timestamp', isLessThanOrEqualTo: endOfDayTimestamp)
          .snapshots();

      return activities;
    }
  }

  // Read inbound activity
  Stream<QuerySnapshot> readInboundActivity() {
    final inboundActivityStream =
        activitys.where('type', isEqualTo: 'Inbound').snapshots();

    return inboundActivityStream;
  }

  // Read outbound activity
  Stream<QuerySnapshot> readOutboundActivity() {
    final outboundActivityStream =
        activitys.where('type', isEqualTo: 'Outbound').snapshots();

    return outboundActivityStream;
  }

// Create a new activity
  Future<String> createActivity(String type, String productId, String paletteId,
      String unit, int qty, String whId, String operator) async {
    // Add the new activity to the collection and get the DocumentReference
    DocumentReference docRef = await activitys.add(
      {
        'type': type,
        'product_id': productId,
        'palette_id': paletteId,
        'wh_id': whId,
        'unit': unit,
        'qty': qty,
        'timestamp': DateTime.now(),
        'operator': operator
      },
    );
    // Return the document reference
    return docRef.id;
  }

  // delete activity by paletteId
  Future<void> deleteActivityByPaletteId(String paletteId) async {
    final activity =
        await activitys.where('palette_id', isEqualTo: paletteId).get();
    for (var i = 0; i < activity.docs.length; i++) {
      final doc = activity.docs[i];
      await activitys.doc(doc.id).delete();
    }
  }

  // delete activity by productId
  Future<void> deleteActivityByProductId(String productId) async {
    final activity =
        await activitys.where('product_id', isEqualTo: productId).get();
    for (var i = 0; i < activity.docs.length; i++) {
      final doc = activity.docs[i];
      await activitys.doc(doc.id).delete();
    }
  }

  // delete activity by warehouseId
  Future<void> deleteActivityByWarehouseId(String whId) async {
    final activity = await activitys.where('wh_id', isEqualTo: whId).get();
    for (var i = 0; i < activity.docs.length; i++) {
      final doc = activity.docs[i];
      await activitys.doc(doc.id).delete();
    }
  }

  // update activity by activityId
  Future<String> updateActivityByActivityId(
      String activityId, int newQty) async {
    // delete the old activity then create a new one

    // read the old activity
    final activity = await activitys.doc(activityId).get();
    final data = activity.data() as Map<String, dynamic>;
    final productId = data['product_id'];
    final paletteId = data['palette_id'];
    final oldUnit = data['unit'];
    int oldQty = data['qty'];

    // if new qty is bigger than old qty, increment product qty in palette collection and product collection
    if (oldQty == newQty) {
      return 'Success';
    } else if (oldQty < newQty) {
      final productName = await productService.getProductNameById(productId);
      final paletteName = await paletteService.getPaletteName(paletteId);
      await paletteService.incrementProduct(
          paletteId, productId, oldUnit, productName, newQty - oldQty);
      await productService.incrementProduct(
          productId, paletteId, paletteName, oldUnit, newQty - oldQty);
      await productService.incrementProductTotalQty(
          productId, oldUnit, newQty - oldQty);

      // update the activity
      await activitys.doc(activityId).update({'qty': newQty});
      return 'Success';
    }
    int currentQty = await paletteService.checkProductQtyList(
      paletteId,
      productId,
      oldUnit,
    );
    if (currentQty < newQty) {
      return 'Not enough QTY';
    }
    await paletteService.decrementProduct(
        paletteId, productId, oldUnit, oldQty - newQty);
    await productService.decrementProductQtyList(
        productId, paletteId, oldUnit, oldQty - newQty);
    await productService.decrementProductTotalQty(
        productId, oldUnit, oldQty - newQty);

    await activitys.doc(activityId).update({'qty': newQty});
    return 'Success';
  }
}
