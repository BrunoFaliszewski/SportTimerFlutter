import 'package:dynamic_themes/dynamic_themes.dart';
import 'package:flutter/material.dart';

import '../themes.dart';

class ThemeDialog extends StatefulWidget {
  const ThemeDialog({ Key? key }) : super(key: key);

  @override
  _ThemeDialogState createState() => _ThemeDialogState();
}

class _ThemeDialogState extends State<ThemeDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Change Theme"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  DynamicTheme.of(context)!.setTheme(Themes.blue);
                },
                icon: const Icon(
                  Icons.circle,
                  color: Colors.blue,
                )
              ),
              IconButton(
                onPressed: () {
                  DynamicTheme.of(context)!.setTheme(Themes.red);
                },
                icon: const Icon(
                  Icons.circle,
                  color: Colors.red,
                )
              ),
              IconButton(
                onPressed: () {
                  DynamicTheme.of(context)!.setTheme(Themes.green);
                },
                icon: const Icon(
                  Icons.circle,
                  color: Colors.green,
                )
              ),
              IconButton(
                onPressed: () {
                  DynamicTheme.of(context)!.setTheme(Themes.yellow);
                },
                icon: const Icon(
                  Icons.circle,
                  color: Colors.yellow,
                )
              ),
              IconButton(
                onPressed: () {
                  DynamicTheme.of(context)!.setTheme(Themes.pink);
                },
                icon: const Icon(
                  Icons.circle,
                  color: Colors.pink,
                )
              )
            ]
          ),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  DynamicTheme.of(context)!.setTheme(Themes.purple);
                },
                icon: const Icon(
                  Icons.circle,
                  color: Colors.purple,
                )
              )
            ]
          )
        ]
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        )
      ],
      elevation: 24.0,
    );
  }
}