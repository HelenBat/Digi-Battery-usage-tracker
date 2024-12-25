import 'package:flutter/material.dart';

class CarbonCircle extends StatelessWidget {
  final double co2Value; // in grams

  const CarbonCircle({Key? key, required this.co2Value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.greenAccent.withOpacity(0.2),
        border: Border.all(color: Colors.green, width: 4),
      ),
      child: Center(
        child: Text(
          "${co2Value.toStringAsFixed(2)} g CO₂",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
