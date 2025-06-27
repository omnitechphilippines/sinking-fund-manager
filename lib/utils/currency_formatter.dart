import 'package:flutter/services.dart';

class CurrencyFormatter extends TextInputFormatter {
  // final NumberFormat _formatter = NumberFormat.decimalPattern();
  final RegExp _decimalRegex = RegExp(r'^\d*\.?\d{0,2}$');

  // @override
  // TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
  //   final String digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
  //   if (digitsOnly.isEmpty) {
  //     return newValue.copyWith(text: '');
  //   }
  //   final String formatted = _formatter.format(int.parse(digitsOnly));
  //   return TextEditingValue(
  //     text: formatted,
  //     selection: TextSelection.collapsed(offset: formatted.length),
  //   );
  // }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (_decimalRegex.hasMatch(newValue.text)) {
      return newValue;
    }
    return oldValue;
  }
}