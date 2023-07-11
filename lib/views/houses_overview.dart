import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/routes.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_service.dart';
import 'package:provider/provider.dart';

import '../model_classes/house.dart';

/// Displays all houses for a city the user has access to.
class HousesOverview extends StatefulWidget {
  const HousesOverview({super.key});

  @override
  State<HousesOverview> createState() => _HousesOverviewState();
}

class _HousesOverviewState extends State<HousesOverview> {
  @override
  Widget build(BuildContext context) {
    final String city = ModalRoute.of(context)!.settings.arguments as String;

    return StreamProvider<List<House>>(
        create: (_) => FirestoreDataService().streamHousesForCity(city),
        initialData: const [],
        builder: (context, child) {
          return Scaffold(
              appBar: AppBar(title: Text(city)),
              body: StreamProvider<List<House>>.value(
                  value: FirestoreDataService().streamHousesForCity(city),
                  initialData: const [],
                  child: ListView(
                      children: Provider.of<List<House>>(context)
                          .map((House house) => OutlinedButton(
                              onPressed: () async {
                                await Navigator.of(context).pushNamed(
                                    ticketsOverviewRoute,
                                    arguments: house);
                              },
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100.0),
                              ))),
                              child: Text(house.shortAddress)))
                          .toList())));
        });
  }
}
