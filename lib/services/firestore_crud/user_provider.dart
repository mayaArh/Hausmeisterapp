import 'package:flutter/foundation.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/registration_service.dart';

class UserProvider with ChangeNotifier {
  late final Renter renter;
  late final Map<String, dynamic> renterAddress;
}
