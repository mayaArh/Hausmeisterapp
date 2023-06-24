import 'package:flutter/material.dart';

class SingleTicketView extends StatefulWidget {
  final int selectedTicketIndex;

  const SingleTicketView({super.key, required this.selectedTicketIndex});

  @override
  State<SingleTicketView> createState() => _SingleTicketViewState();
}

class _SingleTicketViewState extends State<SingleTicketView> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Text(
            'Detail View for item ${widget.selectedTicketIndex}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Text(_isExpanded ? 'Collapse' : 'Expand'),
          ),
          if (_isExpanded) ...[
            // Additional content to show when expanded
            const Text('Additional content'),
          ],
        ],
      ),
    );
  }
}
