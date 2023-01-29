import '../sutom.dart';
import 'package:flutter/material.dart';

class BoardTile extends StatelessWidget {
  const BoardTile({super.key, required this.letter, required this.wordLength});
  final Letter letter;
  final int wordLength;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      height: 48,
      width: (MediaQuery.of(context).size.width - (wordLength * 4) - 12) /
          (wordLength),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: letter.backgroundColor,
        border: Border.all(color: letter.borderColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        letter.val,
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
    );
  }
}
