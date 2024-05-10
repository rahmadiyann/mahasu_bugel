import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityFirestoreService {
  // get collection of activitys
  final CollectionReference activitys =
      FirebaseFirestore.instance.collection('activities');

  final CollectionReference product =
      FirebaseFirestore.instance.collection('products');

  final CollectionReference palette =
      FirebaseFirestore.instance.collection('palettes');

  // Read a activity
  Stream<QuerySnapshot> readActivity() {
    final activityStream = activitys.snapshots();

    return activityStream;
  }

  Stream<QuerySnapshot> filteredActivityStream(
      DateTime startOfDay, DateTime endOfDay) {
    final startOfDayTimestamp =
        Timestamp.fromMillisecondsSinceEpoch(startOfDay.millisecondsSinceEpoch);
    final endOfDayTimestamp =
        Timestamp.fromMillisecondsSinceEpoch(endOfDay.millisecondsSinceEpoch);

    final activities = activitys
        .where('timestamp', isGreaterThanOrEqualTo: startOfDayTimestamp)
        .where('timestamp', isLessThanOrEqualTo: endOfDayTimestamp)
        .snapshots();

    return activities;
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
  Future<void> createActivity(String type, String productId, String paletteId,
      String unit, int qty, String whId) async {
    await activitys.add(
      {
        'type': type,
        'product_id': productId,
        'palette_id': paletteId,
        'wh_id': whId,
        'unit': unit,
        'qty': qty,
        'timestamp': DateTime.now(),
      },
    );
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
}
