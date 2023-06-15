import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_service.dart';

import '../../constants/routes.dart';
import '../../enums/menu_entries.dart';
import '../../services/auth/auth_user.dart';
import '../../services/firestore_crud/ticket_service.dart';
import '../../utilities/show_error_dialog.dart';
import 'dart:developer' as developer;

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
    super.initState();
    _ticketService = FirestoreTicketService();
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
        body: FutureBuilder<Staff>(
          future: _ticketService.fetchUserFirestoreDataAsStaff(user),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }

            return StreamBuilder<List<QuerySnapshot<Map<String, dynamic>>>>(
              stream: _ticketService.firestoreStreams,
              builder: (BuildContext context,
                  AsyncSnapshot<List<QuerySnapshot<Map<String, dynamic>>>>
                      snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (snapshot.hasData) {
                  List<QuerySnapshot<Map<String, dynamic>>> querySnapshots =
                      snapshot.data!;
                  return ListView(
                    children: querySnapshots.first.docs
                        .map((DocumentSnapshot<Map<String, dynamic>> doc) {
                      final data = doc.data()!;
                      int city = data['Hausnummer'];
                      return ListTile(
                        title: Text(city.toString()),
                      );
                    }).toList(),
                  );
                } else {
                  return const Text('Snapshot has no Data');
                }
              },
            );
          },
        ));
  }
}
