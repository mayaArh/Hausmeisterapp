import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_service.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_provider.dart';
import 'package:provider/provider.dart';

import '../../constants/routes.dart';
import '../../enums/menu_entries.dart';
import '../../utilities/show_error_dialog.dart';

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
    return Scaffold(
        appBar: AppBar(
          title: const Text('Städte'),
          actions: [
            PopupMenuButton<MenuEntry>(
              onSelected: (value) async {
                switch (value) {
                  case MenuEntry.logout:
                    final shouldLogout = await showLogoutDialog(context);
                    if (shouldLogout) {
                      await AuthService.firebase().logOut();
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(loginRoute, (_) => false);
                    }
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem<MenuEntry>(
                      value: MenuEntry.logout, child: Text('Log out'))
                ];
              },
            )
          ],
        ),
        body: Consumer<FirestoreDataProvider>(builder: (context, provider, _) {
          if (provider.hasData) {
            final cities = provider.getAllCities();
            return ListView(
                children: cities
                    .map((String city) => OutlinedButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(housesOverviewRoute, arguments: city);
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100.0),
                        ))),
                        child: Text(city)))
                    .toList());
          } else {
            return const CircularProgressIndicator();
          }
        }));
  }
}
