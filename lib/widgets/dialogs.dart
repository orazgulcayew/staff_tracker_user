import 'package:flutter/material.dart';

class YesNoDialog extends StatefulWidget {
  const YesNoDialog({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  State<YesNoDialog> createState() => _YesNoDialogState();
}

class _YesNoDialogState extends State<YesNoDialog> {
  bool _answer = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Text(widget.title),
      content: Text(widget.message),
      actions: <Widget>[
        TextButton(
          child: const Text('Hawa'),
          onPressed: () {
            setState(() {
              _answer = true;
            });
            Navigator.of(context).pop(_answer);
          },
        ),
        TextButton(
          child: const Text('Ýok'),
          onPressed: () {
            setState(() {
              _answer = false;
            });
            Navigator.of(context).pop(_answer);
          },
        ),
      ],
    );
  }
}

Future<bool?> showYesNoDialog(BuildContext context,
    {required String title, required String message}) async {
  bool? answer = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return YesNoDialog(
        message: message,
        title: title,
      );
    },
  );
  return answer;
}
