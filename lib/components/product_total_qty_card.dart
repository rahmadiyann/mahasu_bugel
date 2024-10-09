import 'package:flutter/material.dart';

class TotalQtyCard extends StatelessWidget {
  final String unit;
  final String text;
  const TotalQtyCard({super.key, required this.unit, required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(unit),
            Text(
              text.toString(),
            )
          ],
        ),
      ),
    );
  }
}
