import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key, required this.dropDownValue});
  final int dropDownValue;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late int _value;

  @override
  void initState() {
    _value = widget.dropDownValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Text('Choisir la longueur des mots'),
            DropdownButton(
              value: _value,
              items: const [
                DropdownMenuItem(value: 5, child: Text('5')),
                DropdownMenuItem(value: 6, child: Text('6')),
                DropdownMenuItem(value: 7, child: Text('7')),
                DropdownMenuItem(value: 8, child: Text('8')),
                DropdownMenuItem(value: 9, child: Text('9')),
                DropdownMenuItem(value: 10, child: Text('10')),
              ],
              onChanged: (value) async {
                int newVal = widget.dropDownValue;
                SharedPreferences prefs = await SharedPreferences.getInstance();
                if (newVal > 0) {
                  await prefs.setInt('wordLength', newVal);
                  setState(() {
                    if (value != null) _value = value;
                  });
                }
              },
            ),
            IconButton(
                onPressed: () {
                  Navigator.pop(context, _value);
                },
                icon: const Icon(Icons.send))
          ],
        ),
      ),
    );
  }
}
