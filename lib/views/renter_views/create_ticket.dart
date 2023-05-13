import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class TicketCreationView extends StatefulWidget {
  const TicketCreationView({super.key});

  @override
  State<TicketCreationView> createState() => _TicketCreationViewState();
}

class _TicketCreationViewState extends State<TicketCreationView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Neues Ticket')),
    );
  }
}
