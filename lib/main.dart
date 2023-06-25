import 'package:flutter/material.dart';
import 'package:mein_digitaler_hausmeister/services/auth/auth_service.dart';
import 'package:mein_digitaler_hausmeister/services/firestore_crud/firestore_data_provider.dart';
import 'package:mein_digitaler_hausmeister/views/administration_views/houses_overview.dart';
import 'package:mein_digitaler_hausmeister/views/administration_views/login_view.dart';
import 'package:mein_digitaler_hausmeister/views/administration_views/register_view.dart';
import 'package:mein_digitaler_hausmeister/views/administration_views/cities_overview.dart';
import 'package:mein_digitaler_hausmeister/views/administration_views/ticket_overview.dart';
import 'package:provider/provider.dart';
import 'constants/routes.dart';
import 'views/administration_views/verify_email_view.dart';
import 'dart:developer' as developer;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ChangeNotifierProvider(
    create: (_) => FirestoreDataProvider(),
    child: MaterialApp(
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
          ticketsOverviewRoute: (context) => const TicketOverview(),
        }),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initialize(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final user = AuthService.firebase().currentUser;
              developer.log(user.toString());
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
