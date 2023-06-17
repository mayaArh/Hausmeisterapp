import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/routes.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_provider.dart';
import 'package:provider/provider.dart';

class HousesOverview extends StatefulWidget {
  const HousesOverview({super.key});

  @override
  State<HousesOverview> createState() => _HousesOverviewState();
}

class _HousesOverviewState extends State<HousesOverview> {
  @override
  Widget build(BuildContext context) {
    final String city = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text(city),
      ),
      body: Consumer<FirestoreDataProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const CircularProgressIndicator();
          } else if (provider.hasData) {
            final houses = provider.getAllHousesForCity(city);
            return ListView(
                children: houses
                    .map((String street) => OutlinedButton(
                        onPressed: () {
                          final address = '$street $city';
                          Navigator.of(context).pushNamed(ticketsOverviewRoute,
                              arguments: address.split(' '));
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ))),
                        child: Text(city)))
                    .toList());
          } else {
            return const Text('Es sind noch keine Daten vorhanden');
          }
        },
      ),
    );
  }
}
