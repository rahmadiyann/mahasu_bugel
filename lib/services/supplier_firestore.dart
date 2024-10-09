import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierFirestoreService {
  // get collection of suppliers
  final CollectionReference suppliers =
      FirebaseFirestore.instance.collection('suppliers');

  // Create a new supplier with the document ID as the supplier name
  Future<String> createSupplier(
      String name, String address, String contact, String phone) async {
    // Set the document ID to the supplier's name
    await suppliers.doc(name).set(
      {
        'name': name,
        'address': address,
        'contact': contact,
        'phone': phone,
        'products': []
      },
    );

    // Return the supplier name as the document ID
    return name;
  }

  // Read a supplier
  Stream<QuerySnapshot> readSupplier() {
    final supplierStream = suppliers.snapshots();

    return supplierStream;
  }

  Stream<DocumentSnapshot> streamSupplierById(String id) {
    return suppliers.doc(id).snapshots();
  }

  Future<void> readSupplierFuture() {
    return suppliers.get();
  }

  // add product to supplier
  Future<void> addProductToSupplier(
      String supplierId, String productId, String productName) async {
    await suppliers.doc(supplierId).update({
      'products': FieldValue.arrayUnion([
        {
          productId: productName,
        }
      ])
    });
  }

  // remove product from supplier
  Future<void> removeProductFromSupplier(
      String supplierId, String productId) async {
    await suppliers.doc(supplierId).update({
      'products': FieldValue.arrayRemove([
        {'id': productId}
      ])
    });
  }

  // Update a supplier
  Future<void> updateSupplier(
      String id, String name, String address, String phone) async {
    await suppliers.doc(id).update(
      {
        'name': name,
        'address': address,
        'phone': phone,
      },
    );
  }

  // Delete a supplier
  Future<void> deleteSupplier(String id) async {
    await suppliers.doc(id).delete();
  }
}
