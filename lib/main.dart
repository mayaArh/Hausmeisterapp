import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/auth/firebase_auth_provider.dart';
import 'package:mein_digitaler_hausmeister/views/houses_overview.dart';
import 'package:mein_digitaler_hausmeister/views/authentication_views.dart/login_view.dart';
import 'package:mein_digitaler_hausmeister/views/authentication_views.dart/register_view.dart';
import 'package:mein_digitaler_hausmeister/views/cities_overview.dart';
import 'package:mein_digitaler_hausmeister/views/ticket_views/single_ticket_view.dart';
import 'package:mein_digitaler_hausmeister/views/ticket_views/ticket_creation_view.dart';
import 'package:mein_digitaler_hausmeister/views/ticket_views/ticket_overview.dart';
import 'constants/routes.dart';
import 'views/authentication_views.dart/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blueGrey,
        ),
        home: const HomePage(),
        routes: {
          loginRoute: (context) => const LoginView(),
          registerRoute: (context) => const RegisterView(),
          verifyEmailRoute: (context) => const VerifyEmailView(),
          citiesOverviewRoute: (context) => const CitiesOverview(),
          housesOverviewRoute: (context) => const HousesOverview(),
          ticketsOverviewRoute: (context) => const TicketViewChanger(),
          ticketCreationRoute: (context) => const TicketCreationView(),
          singleTicketRoute: (context) => const SingleTicketView(),
        }),
  );
}

//This class is responsible for displaying the correct view
//depending on the user's authentication status.
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: FirebaseAuthProvider().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = FirebaseAuthProvider().currentUser;
              if (user != null) {
                if (user.isEmailVerified) {
                  return const LoginView();
                } else {
                  return const VerifyEmailView();
                }
              } else {
                return const RegisterView();
              }
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}
