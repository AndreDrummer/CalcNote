import 'package:flutter/material.dart';

class DialogMessage extends StatelessWidget {
  final String title;
  final String enfase;
  final String message;
  final String confirmAction;
  final String denyAction;
  final Function() onConfirm;

  DialogMessage({
    this.title,
    this.enfase,
    this.message,
    this.confirmAction,
    this.denyAction,
    this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return  AlertDialog(
      title: FittedBox(
        child: Row(
          children: <Widget>[
            Text(title),
            enfase == null ? Text('') : Text(" $enfase", style: TextStyle(fontWeight: FontWeight.bold))
          ],
        ),
      ),
      content: Text(message),
      actions: <Widget>[
        ButtonBar(
          children: <Widget>[
            FlatButton(
                child: Text(confirmAction),
                onPressed: () {
                  onConfirm();
                  Navigator.pop(context);
                },
                color: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12))),
            FlatButton(
                child: Text(denyAction),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.green,
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12)))
          ],
        )
      ],
    );
  }
}
