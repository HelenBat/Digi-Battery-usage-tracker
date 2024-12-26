import 'package:flutter/material.dart';

class CarbonCircle extends StatelessWidget {
  final double co2Value; // in grams

  const CarbonCircle({Key? key, required this.co2Value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert grams to kilograms
    final double co2Kg = co2Value / 1000.0;

    // Circle diameter = 80% of the screen width
    final double screenWidth = MediaQuery.of(context).size.width;
    final double diameter = screenWidth * 0.8;

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color.fromARGB(255, 241, 251, 210),
        border: Border.all(
          color: const Color.fromARGB(255, 0, 0, 0),
          width: 2,
        ),
      ),
      // Center the text in both axes
      child: Center(
        // Use a Column so we can style the number and unit differently
        child: Column(
          mainAxisSize: MainAxisSize.min, // fits the content
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // The big, bold CO2 amount
            Text(
              co2Kg.toStringAsFixed(3),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                // Make the numeric value bigger
                fontSize: diameter * 0.18, 
              ),
            ),
            // The smaller "kg of CO2" text
            Text(
              'kg of CO2',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                // Smaller than the numeric value
                fontSize: diameter * 0.12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
