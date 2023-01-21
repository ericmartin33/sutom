import 'package:flutter/material.dart';

const _azerty = [
  ['A', 'Z', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
  ['Q', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M'],
  ['SUPP', 'W', 'X', 'C', 'V', 'B', 'N', 'ENTER']
];

class Keyboard extends StatelessWidget {
  const Keyboard(
      {super.key,
      required this.onKeyTap,
      required this.onDeleteTap,
      required this.onEnterTap});

  final void Function(String) onKeyTap;
  final VoidCallback onDeleteTap;
  final VoidCallback onEnterTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _azerty
          .map(
            (keyRow) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: keyRow.map((letter) {
                if (letter == 'SUPP') {
                  return _KeyboardButton.delete(onTap: onDeleteTap);
                } else if (letter == 'ENTER') {
                  return _KeyboardButton.enter(onTap: onEnterTap);
                } else {
                  return _KeyboardButton(
                    letter: letter,
                    backgroundColor: Colors.grey,
                    onTap: () => onKeyTap(letter),
                  );
                }
              }).toList(),
            ),
          )
          .toList(),
    );
  }
}

class _KeyboardButton extends StatelessWidget {
  const _KeyboardButton({
    super.key,
    this.height = 48,
    this.width = 28,
    required this.letter,
    required this.onTap,
    required this.backgroundColor,
  });

  final double height;
  final double width;
  final String letter;
  final VoidCallback onTap;
  final Color backgroundColor;

  factory _KeyboardButton.delete({required VoidCallback onTap}) =>
      _KeyboardButton(
        width: 56,
        letter: 'DEL',
        onTap: onTap,
        backgroundColor: Colors.grey,
      );

  factory _KeyboardButton.enter({required VoidCallback onTap}) =>
      _KeyboardButton(
        width: 56,
        letter: 'ENTER',
        onTap: onTap,
        backgroundColor: Colors.grey,
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 2.0,
        vertical: 3.0,
      ),
      child: Material(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            onTap: onTap,
            child: Container(
              height: height,
              width: width,
              alignment: Alignment.center,
              child: Text(
                letter,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          )),
    );
  }
}
