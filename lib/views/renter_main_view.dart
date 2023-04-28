import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_service.dart';

import '../constants/routes.dart';
import '../enums/menu_entries.dart';
import '../utilities/show_error_dialog.dart';

class RenterMainView extends StatefulWidget {
  const RenterMainView({super.key});

  @override
  State<RenterMainView> createState() => _RenterMainViewState();
}

class _RenterMainViewState extends State<RenterMainView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main UI'),
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
    );
  }
}
