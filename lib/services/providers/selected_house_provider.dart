import 'package:flutter/material.dart';

import '../../model_classes/house.dart';

class SelectedHouseProvider with ChangeNotifier {
  House? _selectedHouse;

  House? get selectedHouse => _selectedHouse;

  set selectedHouse(House? house) {
    _selectedHouse = house;
    notifyListeners();
  }
}
