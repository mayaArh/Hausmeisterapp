import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/constants/colors.dart';
import 'package:mein_digitaler_hausmeister/constants/routes.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_service.dart';
import 'package:mein_digitaler_hausmeister/services/providers/selected_city_provider.dart';
import 'package:provider/provider.dart';

import '../enums/menu_entries.dart';
import '../model_classes/house.dart';
import '../services/auth/firebase_auth_provider.dart';
import '../services/providers/selected_house_provider.dart';
import '../utilities/show_dialog.dart';

/// Displays all houses for a city the user has access to.
class HousesOverview extends StatefulWidget {
  const HousesOverview({super.key});

  @override
  State<HousesOverview> createState() => _HousesOverviewState();
}

class _HousesOverviewState extends State<HousesOverview> {
  @override
  Widget build(BuildContext context) {
    final cityProvider = Provider.of<SelectedCityProvider>(context);
    final selectedCity = cityProvider.selectedCity!;

    return StreamProvider<List<House>>(
        create: (_) => FirestoreDataService().streamHousesForCity(selectedCity),
        initialData: const [],
        builder: (context, child) {
          return Scaffold(
              appBar: AppBar(
                title: Text(selectedCity),
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
              body: Consumer<List<House>>(builder: (context, houses, _) {
                if (houses.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: MediaQuery.of(context).orientation ==
                            Orientation.portrait
                        ? MediaQuery.of(context).size.width /
                            (MediaQuery.of(context).size.height / 5)
                        : MediaQuery.of(context).size.width /
                            (MediaQuery.of(context).size.height / 3),
                    children: Provider.of<List<House>>(context)
                        .map((House house) => OutlinedButton(
                              onPressed: () async {
                                final houseProvider =
                                    Provider.of<SelectedHouseProvider>(context,
                                        listen: false);
                                houseProvider.selectedHouse = house;
                                await Navigator.of(context).pushNamed(
                                  ticketsOverviewRoute,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: lightBlack,
                              ),
                              child: Text(
                                house.shortAddress,
                                style: const TextStyle(
                                    fontSize: 16, color: darkBlueGrey),
                              ),
                            ))
                        .toList(),
                  );
                }
              }));
        });
  }
}
