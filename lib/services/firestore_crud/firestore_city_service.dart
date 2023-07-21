import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model_classes/staff.dart';
import '../auth/auth_service.dart';
import 'crud_exceptions.dart';

mixin FirestoreCityService {
  //returns a stream of all the cities that are specified for the
  //current user
  Stream<List<String>> streamCities() async* {
    Staff? staff = await AuthService.firebase().currentStaff;
    if (staff != null) {
      DocumentReference<Map<String, dynamic>> userDoc = staff.firestoreRef;
      try {
        yield* userDoc.snapshots().map((userSnapshot) {
          final userData = userSnapshot.data();
          List<String> cityNames = [];

          if (userData != null) {
            final cityList = userData['Houses'];
            cityNames = cityList.keys.toList() ?? [];
            cityNames.sort((elemA, elemB) => elemA.compareTo(elemB));
          }
          return cityNames;
        });
      } catch (e) {
        throw CouldNotFindUserData();
      }
    } else {
      throw CouldNotFindUser();
    }
  }
}
