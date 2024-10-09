import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myapp/services/product_firestore.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher.dart';

class DownloadProductButton extends StatefulWidget {
  const DownloadProductButton({super.key});

  @override
  State<DownloadProductButton> createState() => _DownloadProductButtonState();
}

class _DownloadProductButtonState extends State<DownloadProductButton> {
  final ProductFirestoreService productservice = ProductFirestoreService();

  Future<String> onTap() async {
    final products = await productservice.readAllProduct();

    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    var productNameCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0));
    productNameCell.value = TextCellValue('Product Name');
    var meterCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0));
    meterCell.value = TextCellValue('Meter');
    var rollCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0));
    rollCell.value = TextCellValue('Roll');
    var yardCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0));
    yardCell.value = TextCellValue('Yard');
    var palletCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: 0));
    palletCell.value = TextCellValue('Pallet');
    var sqmCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: 0));
    sqmCell.value = TextCellValue('SQM');
    var sheetCell =
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: 0));
    sheetCell.value = TextCellValue('Sheet');

    for (var i = 0; i < products.length; i++) {
      String productName = products[i]['name'];
      String meter = products[i]['meters'].toString();
      String roll = products[i]['rolls'].toString();
      String yard = products[i]['yards'].toString();
      String pallet = products[i]['pallets'].toString();
      String sqm = products[i]['sqm'].toString();
      String sheets = products[i]['sheets'].toString();

      var productNameCell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: i + 1));
      productNameCell.value = TextCellValue(productName);

      var meterCell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: i + 1));
      meterCell.value = TextCellValue(meter);

      var rollCell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: i + 1));
      rollCell.value = TextCellValue(roll);

      var yardCell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: i + 1));
      yardCell.value = TextCellValue(yard);

      var palletCell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: i + 1));
      palletCell.value = TextCellValue(pallet);

      var sqmCell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: i + 1));
      sqmCell.value = TextCellValue(sqm);

      var sheetCell = sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: i + 1));
      sheetCell.value = TextCellValue(sheets);
    }

    var fileBytes = excel.save();
    final firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('excel/${basename('products-${DateTime.now()}.xlsx')}');

    try {
      // ignore: unused_local_variable
      final metadata = await firebaseStorageRef.getMetadata();
    } on FirebaseException catch (storageError) {
      if (storageError.code == 'object-not-found') {
        final Uint8List data = Uint8List.fromList(fileBytes!);
        final uploadTask = firebaseStorageRef.putData(data);
        final TaskSnapshot storageSnapshot =
            await uploadTask.whenComplete(() => null);
        final downloadUrl = await storageSnapshot.ref.getDownloadURL();
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
        String urlPath = await onTap();
        final Uri url = Uri.parse(urlPath);
        launchUrl(url);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Download product data',
                style: GoogleFonts.nunitoSans(
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.black,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: Icon(
                  Icons.download,
                  color: Color(0xFF058B06),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
