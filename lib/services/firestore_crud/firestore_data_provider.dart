import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/ticket_service.dart';

import '../auth/auth_service.dart';
import '../auth/auth_user.dart';

class FirestoreDataProvider extends ChangeNotifier {
  FirestoreDataProvider._sharedInstance() {
    _user = AuthService.firebase().currentUser!;
    initializeData(_user);
  }
  static final FirestoreDataProvider _shared =
      FirestoreDataProvider._sharedInstance();
  factory FirestoreDataProvider() => _shared;

  late AuthUser _user;
  final FirestoreTicketService _ticketService = FirestoreTicketService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<QuerySnapshot<Map<String, dynamic>>>? _snapshots;
  List<QuerySnapshot<Map<String, dynamic>>>? get snapshots => _snapshots;
  bool get hasData => _snapshots != null && _snapshots!.isNotEmpty;

  void initializeData(AuthUser authUser) async {
    _isLoading = true;
    await _ticketService.fetchUserFirestoreDataAsStaff(authUser).then((value) {
      notifyListeners();
      _ticketService.firestoreStreams.listen((snapshots) {
        _snapshots = snapshots;
        notifyListeners();
      });
    }).whenComplete(() {
      _isLoading = false;
      notifyListeners();
    });
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

  List<String> getAllHousesForCity(String city) {
    final List<String> houses = [];
    if (_snapshots != null) {
      for (final snapshot in _snapshots!) {
        for (final doc in snapshot.docs) {
          final data = doc.data();
          final String houseCity = data['Ort'];
          if (houseCity == city) {
            final String houseStreet = data['Strasse'];
            final int houseNumber = data['Hausnummer'];
            houses.add('$houseStreet ${houseNumber.toString()}');
          }
        }
      }
    }
    houses.sort((a, b) {
      final int streetComparison = a
          .substring(0, a.indexOf(' '))
          .compareTo(b.substring(0, b.indexOf(' ')));
      if (streetComparison != 0) {
        return streetComparison;
      }

      final int numberA = int.parse(a.substring(a.indexOf(' ') + 1));
      final int numberB = int.parse(b.substring(b.indexOf(' ') + 1));
      return numberA.compareTo(numberB);
    });

    return houses;
  }
}
