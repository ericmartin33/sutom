import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class ListWordsDialog extends StatelessWidget {
  const ListWordsDialog({super.key, required this.words});

  final List<String> words;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      actions: [
        IconButton(
          onPressed: (() => Navigator.pop(context)),
          icon: Icon(Icons.exit_to_app),
        )
      ],
      content: ListView.builder(
        itemCount: words.length,
        itemBuilder: (context, index) => Text(words[index]),
      ),
    );
  }
}
