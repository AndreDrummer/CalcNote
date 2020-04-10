import 'package:calcnote/Model/note.dart';
import 'package:calcnote/UI/dialog.dart';
import 'package:flutter/material.dart';
import 'package:calcnote/Database/database.dart';

final db = DataBaseHandler.instance;

class CardNote extends StatefulWidget {
  final Function() setIsInserting;
  final void Function() alterDB;
  final Widget button;
  final String label;

  CardNote({this.alterDB, this.setIsInserting, this.button, this.label});

  @override
  _CardNoteState createState() => _CardNoteState();
}

class _CardNoteState extends State<CardNote> {
  TextEditingController _newNote = TextEditingController(text: 'Título');

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    _getSizes(String size, constraints) {
      bool deviceMode = mediaQuery.orientation == Orientation.landscape;

      if (deviceMode) {
        if (size == 'width') {
          return widget.label == null
              ? constraints.maxWidth * 0.4
              : constraints.maxWidth;
        } else {
          return constraints.maxHeight * 0.8;
        }
      } else {
        if (size == 'width') {
          return widget.label == null
              ? constraints.maxWidth * 0.6
              : constraints.maxWidth;
        } else {
          return widget.label == null
              ? constraints.maxHeight
              : constraints.maxHeight;
        }
      }
    }

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: _getSizes('height', constraints),
            width: _getSizes('width', constraints),
            child: SingleChildScrollView(
              child: Card(
                  elevation: 6.0,
                  color: widget.label == null
                      ? Theme.of(context).accentColor
                      : Theme.of(context).primaryColor,
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        height: mediaQuery.size.height <= 600 ? 100 : 140,
                        color: Colors.white60,
                        child: Center(
                          child: Image.asset('assets/note.png',
                              color: Colors.black26),
                        ),
                      ),
//                      SizedBox(height: mediaQuery.size.height <= 400 ? 20 : 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: widget.label == null
                            ? TextField(
                                controller: _newNote,
                                onSubmitted: (_) => widget.alterDB(),
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none),
                                    disabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide.none)),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                ),
                              )
                            : Text(
                                '',
                              ),
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: widget.label == null
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    FlatButton(
                                      child: Icon(Icons.cancel,
                                          color: Colors.white, size: 30),
                                      onPressed: widget.setIsInserting,
                                    ),
                                    FlatButton(
                                      child: Icon(Icons.done,
                                          color: Colors.white, size: 30),
                                      onPressed: () {
                                        final data = CalcNote(
                                            cardColor: 'green',
                                            tema: _newNote.text);
                                        db
                                            .queryParams(
                                                _newNote.text, 'CalcNotes')
                                            .then((itens) {
                                          if (itens.length > 0) {
                                            showDialog(
                                                context: context,
                                                builder: (_) {
                                                  return AlertDialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    backgroundColor:
                                                        Color(0xFFef9a9a),
                                                    content: Text(
                                                      "Anotação já existe.",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors.white),
                                                    ),
//                                          actions: <Widget>[
//                                            FlatButton(
//                                              child: Text('OK'),
//                                              onPressed: (){ Navigator.pop(context); },
//                                            )
//                                          ],
                                                  );
                                                });
                                          } else {
                                            db
                                                .insert(data, 'CalcNotes')
                                                .then((added) {
                                              widget.setIsInserting();
                                              widget.alterDB();
                                            });
                                          }
                                        });
                                      },
                                    )
                                  ],
                                )
                              : Column(
                                  children: <Widget>[
                                    Container(
                                      height: constraints.maxHeight * 0.27,
                                      child: Text(widget.label,
                                          style: Theme.of(context)
                                              .textTheme
                                              .display2),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder: (_) => DialogMessage(
                                                      onConfirm: widget.alterDB,
                                                      message:
                                                          'Deletar esse bloco e todas suas anotações',
                                                      confirmAction: 'Sim',
                                                      denyAction: 'Não',
                                                      enfase: widget.label,
                                                      title:
                                                          'Excluir',
                                                    ));
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                            size: 40,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 8.0),
                                  ],
                                ))
                    ],
                  )),
            ),
          );
        },
      ),
    );
  }
}
