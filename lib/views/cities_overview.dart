import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/auth/firebase_auth_provider.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_service.dart';
import 'package:provider/provider.dart';

import '../constants/routes.dart';
import '../enums/menu_entries.dart';
import '../utilities/show_error_dialog.dart';

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
                            await ErrorDialog.showLogoutDialog(context);
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
                          value: MenuEntry.logout, child: Text('Log out'))
                    ];
                  },
                )
              ],
            ),
            body: ListView(
                children: Provider.of<List<String>>(context)
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
                    .toList()));
      },
    );
  }
}
