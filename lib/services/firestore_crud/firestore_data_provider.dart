import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/ticket_service.dart';
import '../../model_classes.dart/house.dart';
import '../../model_classes.dart/staff.dart';
import '../auth/auth_user.dart';

class FirestoreDataProvider extends ChangeNotifier {
  FirestoreDataProvider._sharedInstance();
  static final FirestoreDataProvider _shared =
      FirestoreDataProvider._sharedInstance();
  factory FirestoreDataProvider() => _shared;

  final FirestoreTicketService _ticketService = FirestoreTicketService();
  late Staff _staffUser;
  get staffUser => _staffUser;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<QuerySnapshot<Map<String, dynamic>>>? _snapshots;
  List<QuerySnapshot<Map<String, dynamic>>>? get snapshots => _snapshots;
  bool get hasData => _snapshots != null && _snapshots!.isNotEmpty;

  void initializeData(AuthUser authUser) async {
    _isLoading = true;
    Staff user = await _ticketService.fetchUserFirestoreDataAsStaff(authUser);

    notifyListeners();

    _ticketService.firestoreStreams.listen((snapshots) {
      _snapshots = snapshots;
      notifyListeners();
    });

    _staffUser = user;
    _isLoading = false;
    notifyListeners();
  }

  SplayTreeSet<String> getAllCities() {
    final cities = SplayTreeSet<String>();
    if (_snapshots != null) {
      for (final snapshot in _snapshots!) {
        for (final doc in snapshot.docs) {
          final city = doc.get('Ort') as String?;
          if (city != null) {
            cities.add(city);
          }
        }
      }
    }
    return cities;
  }

  List<House> getAllHousesForCity(String city) {
    final List<House> houses = [];
    if (_snapshots != null) {
      for (final snapshot in _snapshots!) {
        for (final doc in snapshot.docs) {
          final house = House.fromFirestore(doc);
          houses.add(house);
        }
      }
    }

    houses.sort((houseA, houseB) {
      int streetComparison = houseA.street.compareTo(houseB.street);
      if (streetComparison != 0) {
        return streetComparison;
      } else {
        return houseA.houseNumber.compareTo(houseB.houseNumber);
      }
    });

    return houses;
  }
}
