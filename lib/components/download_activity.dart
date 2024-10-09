// ignore_for_file: unnecessary_null_comparison

import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/services/activity_firestore.dart';
import 'package:myapp/services/palette_firestore.dart';
import 'package:myapp/services/product_firestore.dart';
import 'package:myapp/services/warehouse_firestore.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadExcelButton extends StatefulWidget {
  const DownloadExcelButton({super.key});

  @override
  State<DownloadExcelButton> createState() => _DownloadExcelButtonState();
}

class _DownloadExcelButtonState extends State<DownloadExcelButton> {
  final ActivityFirestoreService activityservice = ActivityFirestoreService();
  final PaletteFirestoreService paletteservice = PaletteFirestoreService();
  final WarehouseFirestoreService warehouseservice =
      WarehouseFirestoreService();
  final ProductFirestoreService productservice = ProductFirestoreService();

  Future<String> downloadExcel() async {
    final activities = await activityservice.readAllActivity();

    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    var timestampCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
    timestampCell.value = TextCellValue('Timestamp');

    var typeCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0));
    typeCell.value = TextCellValue('Type');

    var operatorCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0));
    operatorCell.value = TextCellValue('Operator');

    var productNameCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0));
    productNameCell.value = TextCellValue('Product Name');

    var paletteNameCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0));
    paletteNameCell.value = TextCellValue('Palette Name');

    var warehouseNameCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0));
    warehouseNameCell.value = TextCellValue('Warehouse Name');

    var unitCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0));
    unitCell.value = TextCellValue('Unit');

    var qtyCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: 0));
    qtyCell.value = TextCellValue('Quantity');

    for (var i = 0; i < activities.length; i++) {
      String productId = activities[i]['product_id'];
      String operatorName = activities[i]['operator'];
      String paletteId = activities[i]['palette_id'];
      String warehouseId = activities[i]['wh_id'];
      String unit = activities[i]['unit'];
      int qty = activities[i]['qty'];
      DateTime timestamp = activities[i]['timestamp'].toDate();
      String type = activities[i]['type'];

      String productName = await productservice.getProductNameById(productId);
      String paletteName = await paletteservice.getPaletteName(paletteId);
      String warehouseName =
          await warehouseservice.getWarehouseNameById(warehouseId);

      // append data to excel
      var timestampCell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1));
      timestampCell.value = TextCellValue(timestamp.toString());

      var typeCell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1));
      typeCell.value = TextCellValue(type);

      var operatorCell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1));
      operatorCell.value = TextCellValue(operatorName);

      var productNameCell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1));
      productNameCell.value = TextCellValue(productName);

      var paletteNameCell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1));
      paletteNameCell.value = TextCellValue(paletteName);

      var warehouseNameCell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1));
      warehouseNameCell.value = TextCellValue(warehouseName);

      var unitCell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1));
      unitCell.value = TextCellValue(unit);

      var qtyCell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: i + 1));
      qtyCell.value = TextCellValue(qty.toString());
    }

    var fileBytes = excel.save();
    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('excel/${basename('transaction-${DateTime.now()}.xlsx')}');

    try {
      final metadata = await firebaseStorageRef.getMetadata();
      if (metadata == null) {
        final Uint8List data = Uint8List.fromList(fileBytes!);
        final uploadTask = firebaseStorageRef.putData(data);
        final TaskSnapshot storageSnapshot =
            await uploadTask.whenComplete(() => null);
        final downloadUrl = await storageSnapshot.ref.getDownloadURL();
        return downloadUrl;
      }
    } on FirebaseException catch (storageError) {
      if (storageError.code == 'object-not-found') {
        final Uint8List data = Uint8List.fromList(fileBytes!);
        final uploadTask = firebaseStorageRef.putData(data);
        final TaskSnapshot storageSnapshot =
            await uploadTask.whenComplete(() => null);
        final downloadUrl = await storageSnapshot.ref.getDownloadURL();
        // print(downloadUrl);
        return downloadUrl;
      } else {
        rethrow;
      }
    } catch (error) {
      return error.toString();
    }
    return 'wow what happened';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        String urlPath = await downloadExcel();
        final Uri url = Uri.parse(urlPath);
        launchUrl(url);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            'Download Data',
            style: GoogleFonts.nunitoSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color.fromARGB(255, 148, 146, 146),
            ),
          ),
        ),
      ),
    );
  }
}
