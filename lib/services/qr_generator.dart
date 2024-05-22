// ignore_for_file: unnecessary_null_comparison

import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path/path.dart' as Path;

Future<String> generateQRCode(String qrCodeText, String type) async {
  try {
    // Reference to the file in Firebase Storage
    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('$type/${Path.basename(qrCodeText)}.jpg');

    try {
      // Check if the file already exists in Firebase Storage
      final metadata = await firebaseStorageRef.getMetadata();
      if (metadata != null && metadata.size! > 0) {
        // If the file exists, return the download URL
        final downloadUrl = await firebaseStorageRef.getDownloadURL();
        return downloadUrl;
      }
    } catch (storageError) {
      if (storageError is FirebaseException &&
          storageError.code == 'object-not-found') {
        // If the file does not exist, proceed to generate and upload the QR code
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

    if (qrImage == null) {
      throw Exception("QR code image generation failed");
    }

    // Convert QR code image to JPEG bytes
    final qrImageBytes = qrImage.buffer.asUint8List();
    final img.Image? qrImageDecoded = img.decodeImage(qrImageBytes);
    if (qrImageDecoded == null) {
      throw Exception("QR code image decoding failed");
    }
    final jpegData = Uint8List.fromList(img.encodeJpg(qrImageDecoded));

    // Upload image to Firebase Storage
    final uploadTask = firebaseStorageRef.putData(jpegData);

    // Get download URL
    final TaskSnapshot storageSnapshot = await uploadTask;
    final downloadUrl = await storageSnapshot.ref.getDownloadURL();

    return downloadUrl;
  } catch (error) {
    return error.toString();
  }
}
