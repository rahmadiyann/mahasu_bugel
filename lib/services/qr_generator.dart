// ignore_for_file: unnecessary_null_comparison

import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path/path.dart' as Path;

Future<String> generateQRCode(String qrCodeText, String type) async {
  try {
    // Check if the file already exists in Firebase Storage
    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('$type/${Path.basename(qrCodeText)}.png');
    try {
      final metadata = await firebaseStorageRef.getMetadata();
      if (metadata != null && metadata.size! > 0) {
        final downloadUrl = await firebaseStorageRef.getDownloadURL();
        return downloadUrl;
      }
    } catch (storageError) {
      if (storageError is FirebaseException &&
          storageError.code == 'object-not-found') {
        final qrImage = await QrPainter(
          data: qrCodeText,
          version: QrVersions.auto,
          gapless: false,
          errorCorrectionLevel: QrErrorCorrectLevel.Q,
        ).toImageData(300);

        // Convert QR code image to bytes
        final qrImageData = Uint8List.fromList(qrImage!.buffer.asUint8List());

        // Upload image to Firebase Storage
        final uploadTask = firebaseStorageRef.putData(qrImageData);

        // Get download URL
        final TaskSnapshot storageSnapshot =
            await uploadTask.whenComplete(() => null);
        final downloadUrl = await storageSnapshot.ref.getDownloadURL();

        return downloadUrl;
      } else {
        // Rethrow the error if it's not "object-not-found"
        rethrow;
      }
    }

    // Generate QR code image
    final qrImage = await QrPainter(
      data: qrCodeText,
      version: QrVersions.auto,
      gapless: false,
      errorCorrectionLevel: QrErrorCorrectLevel.Q,
    ).toImageData(300);

    // Convert QR code image to bytes
    final qrImageData = Uint8List.fromList(qrImage!.buffer.asUint8List());

    // Upload image to Firebase Storage
    final uploadTask = firebaseStorageRef.putData(qrImageData);

    // Get download URL
    final TaskSnapshot storageSnapshot =
        await uploadTask.whenComplete(() => null);
    final downloadUrl = await storageSnapshot.ref.getDownloadURL();

    return downloadUrl;
  } catch (error) {
    return error.toString();
  }
}
