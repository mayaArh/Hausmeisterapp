import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/colors.dart';
import 'package:mein_digitaler_hausmeister/services/auth/firebase_auth_provider.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_service.dart';
import 'package:provider/provider.dart'; // Import this for the GridView

import '../constants/routes.dart';
import '../enums/menu_entries.dart';
import '../services/providers/selected_city_provider.dart';
import '../utilities/show_dialog.dart';

/// This class is responsible for displaying all the cities
/// in which are houses the user has access to.
class CitiesOverview extends StatefulWidget {
  const CitiesOverview({super.key});

  @override
  State<CitiesOverview> createState() => _CitiesOverviewState();
}

class _CitiesOverviewState extends State<CitiesOverview> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<String>>(
      create: (_) => FirestoreDataService().streamCities(),
      initialData: const [],
      builder: (context, child) {
        return Scaffold(
            appBar: AppBar(
              title: const Text('Städte'),
              actions: [
                PopupMenuButton<MenuEntry>(
                  onSelected: (value) async {
                    switch (value) {
                      case MenuEntry.logout:
                        final shouldLogout =
                            await DialogDisplay.showLogoutDialog(context);
                        if (shouldLogout) {
                          await FirebaseAuthProvider().logOut();
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              loginRoute, (_) => false);
                        }
                    }
                  },
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem<MenuEntry>(
                          value: MenuEntry.logout, child: Text('Abmelden'))
                    ];
                  },
                )
              ],
            ),
            body: Consumer<List<String>>(builder: (context, cities, _) {
              if (cities.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio:
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? MediaQuery.of(context).size.width /
                              (MediaQuery.of(context).size.height / 5)
                          : MediaQuery.of(context).size.width /
                              (MediaQuery.of(context).size.height / 3),
                  children: Provider.of<List<String>>(context)
                      .map((String city) => OutlinedButton(
                            onPressed: () {
                              final cityProvider =
                                  Provider.of<SelectedCityProvider>(context,
                                      listen: false);
                              cityProvider.selectedCity = city;
                              Navigator.of(context)
                                  .pushNamed(housesOverviewRoute);
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: lightBlack,
                            ),
                            child: Text(
                              city,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: darkBlueGrey),
                            ),
                          ))
                      .toList(),
                );
              }
            }));
      },
    );
  }
}
