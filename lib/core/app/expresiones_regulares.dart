
import 'package:flutter/services.dart';

class TextInputFormatters{
  TextInputFormatter int = TextInputFormatter.withFunction((oldValue, newValue) => RegExp(r'^(-?\d{0,10})?$').hasMatch(newValue.text) ? newValue : oldValue);
  // TextInputFormatter double = TextInputFormatter.withFunction((oldValue, newValue) => RegExp(r'^(\d{0,10}\.?\d{0,3})?$').hasMatch(newValue.text) ? newValue : oldValue);
  TextInputFormatter double = TextInputFormatter.withFunction((oldValue, newValue) => RegExp(r'^(-?\d{0,10}(?:\.\d{0,3})?)?$').hasMatch(newValue.text) ? newValue : oldValue);
  TextInputFormatter textWithSpacing = TextInputFormatter.withFunction((oldValue, newValue) => RegExp(r'^([a-zA-ZñÑ]+[a-zA-ZñÑ ]*)?$').hasMatch(newValue.text) ? newValue : oldValue);
  TextInputFormatter textWithSpacingWithNumbers = TextInputFormatter.withFunction((oldValue, newValue) => RegExp(r'^([a-zñA-ZÑ0-9\s]+)?$').hasMatch(newValue.text) ? newValue : oldValue);
  TextInputFormatter textWithNumbers = TextInputFormatter.withFunction((oldValue, newValue) => RegExp(r'^([a-zA-Z0-9]+[a-zA-Z0-9]*)?$').hasMatch(newValue.text) ? newValue : oldValue);
  TextInputFormatter textWithSpacingWithComma = TextInputFormatter.withFunction((oldValue, newValue) => RegExp(r'^[a-zA-Z,\s]*?').hasMatch(newValue.text) ? newValue : oldValue);
  TextInputFormatter cellPhoneNumber = TextInputFormatter.withFunction((oldValue, newValue) => RegExp(r'^\d{0,10}$').hasMatch(newValue.text) ? newValue : oldValue);
  TextInputFormatter email = TextInputFormatter.withFunction((oldValue, newValue) => RegExp(r'^[a-zA-Z0-9_.+-]*?@?[a-zA-Z0-9-]*?.?[a-zA-Z0-9-.]*?$').hasMatch(newValue.text) ? newValue : oldValue);
}

// (r'^([a-zA-Z]+[a-zA-Z ]*)?$')
// (r'^([a-zA-Z]+[a-zA-Z ]*)?$')