import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:myapp/services/activity_firestore.dart';

Future<String> stripPhoneNumber(String phoneNumber) async {
  String strippedPhoneNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
  return strippedPhoneNumber;
}

downloadExcel() async {
  final ActivityFirestoreService activityservice = ActivityFirestoreService();
  var excel = Excel.createExcel();
  Sheet sheet = excel['Sheet1'];

  // create header
  var typeCell =
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
  typeCell.value = TextCellValue('Type');
  var productNameCell =
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0));
  productNameCell.value = TextCellValue('Product Name');
  var paletteNameCell =
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0));
  paletteNameCell.value = TextCellValue('Palette Name');
  var warehouseNameCell =
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0));
  warehouseNameCell.value = TextCellValue('Warehouse Name');
  var unitCell =
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0));
  unitCell.value = TextCellValue('Unit');
  var qtyCell =
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0));
  qtyCell.value = TextCellValue('Quantity');
  var timestampCell =
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0));
  timestampCell.value = TextCellValue('Timestamp');

  // read every transaction from activityservice.readactivity
  final activities = activityservice.readActivity();
  debugPrint('activities: $activities');
  activities.forEach(
    (element) async {
      for (var i = 0; i < element.docs.length; i++) {
        DocumentSnapshot activity = element.docs[i];
        debugPrint('activity: ${activity.data()}');
        // Map<String, dynamic> data = activity.data() as Map<String, dynamic>;

        // String type = data['type'];
        // String productId = data['product_id'];
        // final productName = await productservice.getProductNameById(productId);
        // String paletteId = data['palette_id'];
        // final paletteName = await paletteservice.getPaletteName(paletteId);
        // String warehouseId = data['wh_id'];
        // final warehouseName =
        //     await warehouseservice.getWarehouseNameById(warehouseId);
        // String unit = data['unit'];
        // int qty = data['qty'];
        // Timestamp timestamp = data['timestamp'];

        // // append data to excel
        // var typeCell = sheet
        //     .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1));
        // typeCell.value = TextCellValue(type);
        // var productNameCell = sheet
        //     .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1));
        // productNameCell.value = TextCellValue(productName);
        // var paletteNameCell = sheet
        //     .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1));
        // paletteNameCell.value = TextCellValue(paletteName);
        // var warehouseNameCell = sheet
        //     .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1));
        // warehouseNameCell.value = TextCellValue(warehouseName);
        // var unitCell = sheet
        //     .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1));
        // unitCell.value = TextCellValue(unit);
        // var qtyCell = sheet
        //     .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1));
        // qtyCell.value = DoubleCellValue(qty.toDouble());
        // var timestampCell = sheet
        //     .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1));
        // timestampCell.value = TextCellValue(
        //     '${timestamp.toDate().hour.toString().padLeft(2, '0')}:${timestamp.toDate().minute.toString().padLeft(2, '0')}:${timestamp.toDate().second.toString().padLeft(2, '0')}');
      }
    },
  );
  // try {
  //   // save the excel file to firebase storage
  //   var fileBytes = excel.save();
  //   final firebaseStorageRef = FirebaseStorage.instance.ref().child(
  //       'excel/${basename('transactions${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}.xlsx')}');
  //   try {
  //     final metadata = await firebaseStorageRef.getMetadata();
  //     if (metadata != null && metadata.size! > 0) {
  //       final downloadUrl = await firebaseStorageRef.getDownloadURL();
  //       return downloadUrl;
  //     }
  //   } catch (storageError) {
  //     if (storageError is FirebaseException &&
  //         storageError.code == 'object-not-found') {
  //       final Uint8List data = Uint8List.fromList(fileBytes!);
  //       final uploadTask = firebaseStorageRef.putData(data);
  //       final TaskSnapshot storageSnapshot =
  //           await uploadTask.whenComplete(() => null);
  //       final downloadUrl = await storageSnapshot.ref.getDownloadURL();
  //       return downloadUrl;
  //     } else {
  //       rethrow;
  //     }
  //   }
  // } catch (e) {
  //   return e.toString();
  // }
  // throw StateError('No download URL found');
}
