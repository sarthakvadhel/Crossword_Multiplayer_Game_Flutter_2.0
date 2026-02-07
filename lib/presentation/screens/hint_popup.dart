import 'package:flutter/material.dart';

class HintPopup extends StatelessWidget {
  const HintPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Hint'),
      content: const Text('Valid tiles highlighted for your current hand.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
      ],
    );
  }
}
