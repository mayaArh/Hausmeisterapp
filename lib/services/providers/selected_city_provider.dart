import 'package:flutter/material.dart';

class SelectedCityProvider with ChangeNotifier {
  String? _selectedCity;

  String? get selectedCity => _selectedCity;

  set selectedCity(String? city) {
    _selectedCity = city;
    notifyListeners();
  }
}
