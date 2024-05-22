import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UnitContainer extends StatelessWidget {
  final String unit;
  final int qty;
  const UnitContainer({super.key, required this.unit, required this.qty});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 1),
        borderRadius: BorderRadius.circular(5),
        color: const Color.fromARGB(255, 249, 224, 144),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              unit,
              style: GoogleFonts.nunitoSans(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Text(qty.toString())
          ],
        ),
      ),
    );
  }
}
