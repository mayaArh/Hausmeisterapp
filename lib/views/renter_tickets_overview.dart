import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_service.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/registration_service.dart';

import '../constants/routes.dart';
import '../enums/menu_entries.dart';
import '../utilities/show_error_dialog.dart';

class RenterTicketOverview extends StatefulWidget {
  const RenterTicketOverview({super.key});

  @override
  State<RenterTicketOverview> createState() => _RenterTicketOverviewState();
}

class _RenterTicketOverviewState extends State<RenterTicketOverview> {
  late final TicketService _ticketService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _ticketService = TicketService();
    super.initState();
  }

  @override
  void dispose() {
    _ticketService.close();
    super.dispose();
  }

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
        body: FutureBuilder(
            future: _ticketService.getOrCreateUser(email: userEmail),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return StreamBuilder(
                      stream: _ticketService.allTickets,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return const Text('Ticketansicht wird geladen...');
                          default:
                            return const CircularProgressIndicator();
                        }
                      });
                default:
                  return const CircularProgressIndicator();
              }
            }));
  }
}
