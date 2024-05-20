import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionFirestoreService {
  final CollectionReference transactions =
      FirebaseFirestore.instance.collection('transactions');

  // Create transaction
  Future<void> createTransaction(
      String operator, String transactionType) async {
    await transactions.add(
      {
        'operator': operator,
        'transactionType': transactionType,
        'timestamp': Timestamp.now(),
      },
    );
  }
}
