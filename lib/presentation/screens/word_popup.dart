import 'package:flutter/material.dart';

class WordPopup extends StatelessWidget {
  const WordPopup({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Remaining Words'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Bring into existence: C _ E A T E'),
          SizedBox(height: 8),
          Text('Round letter: _'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
