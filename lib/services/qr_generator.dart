import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;

Future<String> uploadQrCodeImage(String type, String code) async {
  // Ensure Firebase is initialized
  await Firebase.initializeApp();

  // Validate type
  if (type != 'products' && type != 'palettes') {
    throw ArgumentError('Invalid type. Must be "products" or "palettes".');
  }

  // Generate QR code image
  final qrValidationResult = QrValidator.validate(
    data: code,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.L,
  );
  if (qrValidationResult.status != QrValidationStatus.valid) {
    throw Exception('Invalid QR code data');
  }
  final qrCode = qrValidationResult.qrCode!;

  // Create a canvas for the QR code
  final painter = QrPainter.withQr(
    qr: qrCode,
    color: const Color(0xFF000000),
    emptyColor: const Color(0xFFFFFFFF),
    gapless: true,
  );

  final tempDir = await getTemporaryDirectory();
  final qrFilePath = p.join(tempDir.path, 'qr_code.png');
  final qrFile = File(qrFilePath);

  final pictureRecorder = PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  const size = 200.0;
  painter.paint(canvas, const Size(size, size));
  final picture = pictureRecorder.endRecording();
  final imgBytes = await picture
      .toImage(size.toInt(), size.toInt())
      .then((image) => image.toByteData(format: ImageByteFormat.png))
      .then((byteData) => byteData!.buffer.asUint8List());

  // Write the PNG file
  await qrFile.writeAsBytes(imgBytes);

  // Convert PNG to JPG
  final decodedImg = img.decodeImage(imgBytes);
  if (decodedImg == null) {
    throw Exception('Failed to decode image');
  }
  final jpgBytes = img.encodeJpg(decodedImg);

  final jpgFilePath = p.join(tempDir.path, 'qr_code.jpg');
  final jpgFile = File(jpgFilePath);
  await jpgFile.writeAsBytes(jpgBytes);

  // Create Firebase Storage instance
  final storage = FirebaseStorage.instance;

  // Check if file already exists
  final fileName = '${type}-${code}.jpg';
  final storagePath = '$type/$fileName';
  final ref = storage.ref().child(storagePath);
  try {
    final downloadUrl = await ref.getDownloadURL();
    return downloadUrl; // File already exists, return the download link
  } catch (e) {
    // File does not exist, proceed to upload
  }

  // Upload the file to Firebase Storage
  final uploadTask = await ref.putFile(jpgFile);
  final downloadUrl = await uploadTask.ref.getDownloadURL();

  // Clean up temporary files
  await qrFile.delete();
  await jpgFile.delete();

  return downloadUrl;
}
