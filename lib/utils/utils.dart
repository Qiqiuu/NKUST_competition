import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';

class Utils {
  static void showSnackbar(
    BuildContext context,
    String message, {
    bool boolProperty = true,
    bool showFromTop = false,
  }) {
    final topPadding = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.jetBrainsMono(
            fontWeight: FontWeight.bold,
            fontSize: 40,
          ),
        ),
        backgroundColor: boolProperty
            ? const Color(0xFF10B981)
            : const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: showFromTop
            ? EdgeInsets.only(
                top: topPadding + 20,
                left: 16,
                right: 16,
                bottom: screenHeight - topPadding - 150,
              )
            : EdgeInsets.all(16),
      ),
    );
  }

  static Future<List<Map<String, dynamic>>> loadMedicineData() async {
    final jsonString = await rootBundle.loadString('assets/medicines.json');

    final Map<String, dynamic> jsonData = json.decode(jsonString);

    return List<Map<String, dynamic>>.from(jsonData['medicines']);
  }

  static Future<List<Map<String, dynamic>>> matchMedicines(String text) async {
    final medicines = await loadMedicineData();

    final lowerText = text.toLowerCase();

    List<Map<String, dynamic>> matched = [];

    for (final med in medicines) {
      final medProductName = med['product_name'].toString().toLowerCase();
      final medScientificName = med['scientific_name'].toString().toLowerCase();

      if (medProductName.contains(lowerText) ||
          medScientificName.contains(lowerText) ||
          lowerText.contains(medProductName) ||
          lowerText.contains(medScientificName)) {
        matched.add(med);
      }
    }
    return matched;
  }
}
