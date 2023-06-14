import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_service.dart';

import '../../constants/routes.dart';
import '../../enums/menu_entries.dart';
import '../../services/auth/auth_user.dart';
import '../../services/firestore_crud/ticket_service.dart';
import '../../utilities/show_error_dialog.dart';

class TicketOverview extends StatefulWidget {
  const TicketOverview({super.key});

  @override
  State<TicketOverview> createState() => _TicketOverviewState();
}

class _TicketOverviewState extends State<TicketOverview> {
  late final FirestoreTicketService _ticketService;
  AuthUser get user => AuthService.firebase().currentUser!;

  @override
  void initState() {
    _ticketService = FirestoreTicketService();
    super.initState();
  }

  @override
  void dispose() {
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
            future: _ticketService.fetchUserFirestoreDataAsStaff(user),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.done:
                  return StreamBuilder<
                          List<QuerySnapshot<Map<String, dynamic>>>>(
                      stream: _ticketService.firestoreStreams,
                      builder: (BuildContext context,
                          AsyncSnapshot<
                                  List<QuerySnapshot<Map<String, dynamic>>>>
                              snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                          case ConnectionState.active:
                            if (snapshot.hasData) {
                              List<QuerySnapshot<Map<String, dynamic>>>
                                  querySnapshots = snapshot.data!.toList();
                              List<String> streetnames = [];
                              return ListView(
                                  children: querySnapshots.first.docs.map(
                                      (DocumentSnapshot<Map<String, dynamic>>
                                          doc) {
                                final data = doc.data()!;
                                int city = data['Hausnummer'];
                                return ListTile(
                                  title: Text(city.toString()),
                                );
                              }).toList());
                            } else {
                              return const CircularProgressIndicator();
                            }
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
