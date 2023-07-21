import 'package:cloud_firestore/cloud_firestore.dart';

import '../../model_classes/house.dart';
import '../../model_classes/staff.dart';
import '../../utilities/sort.dart';
import '../auth/auth_service.dart';
import 'crud_exceptions.dart';

mixin FirestoreHouseService {
  //returns a stream of all houses that are specified for the
  //current user at the given city
  Stream<List<House>> streamHousesForCity(String city) async* {
    Staff? staff = await AuthService.firebase().currentStaff;
    if (staff != null) {
      DocumentReference<Map<String, dynamic>> userDoc = staff.firestoreRef;
      try {
        await for (DocumentSnapshot<Map<String, dynamic>> userSnapshot
            in userDoc.snapshots()) {
          final userData = userSnapshot.data();
          List<House> houseList = [];
          if (userData != null) {
            Map<String, dynamic> houseMap = userData['Houses'];

            if (houseMap.containsKey(city)) {
              List<dynamic> houseDocs = houseMap[city];

              for (DocumentReference<Map<String, dynamic>> houseDoc in houseDocs
                  .cast<DocumentReference<Map<String, dynamic>>>()) {
                final houseSnapshot = await houseDoc.get();

                houseList.add(House.fromFirestore(houseSnapshot));
              }
            }
            Sort.sortHouses(houseList);
          }
          yield houseList;
        }
      } catch (e) {
        throw CouldNotFindUserData();
      }
    } else {
      throw CouldNotFindUser();
    }
  }
}
