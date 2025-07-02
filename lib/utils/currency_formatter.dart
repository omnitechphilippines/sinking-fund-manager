import 'package:flutter/services.dart';

class CurrencyFormatter extends TextInputFormatter {
  final RegExp _decimalRegex = RegExp(r'^\d*\.?\d{0,2}$');

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (_decimalRegex.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}