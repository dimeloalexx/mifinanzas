import 'package:flutter/material.dart';

class PinKeypad extends StatelessWidget {
  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  const PinKeypad({super.key, required this.onDigit, required this.onBackspace});

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) {
              return const SizedBox(width: 72, height: 64);
            }
            return SizedBox(
              width: 72,
              height: 64,
              child: TextButton(
                onPressed: () {
                  if (key == '⌫') {
                    onBackspace();
                  } else {
                    onDigit(key);
                  }
                },
                child: key == '⌫'
                    ? const Icon(Icons.backspace_outlined)
                    : Text(key, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}
