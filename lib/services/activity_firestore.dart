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

    return readActivity().where((snapshot) =>
        // Access the timestamp field from QueryDocumentSnapshot within QuerySnapshot
        snapshot.docs
            .where((doc) =>
                doc['timestamp']?.compareTo(startOfDayTimestamp) >= 0 &&
                doc['timestamp']?.compareTo(endOfDayTimestamp) <= 0)
            .isNotEmpty);
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
}
