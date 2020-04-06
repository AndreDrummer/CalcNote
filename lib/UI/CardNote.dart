import 'package:calcnote/Model/note.dart';
import 'package:flutter/material.dart';
import 'package:calcnote/Database/database.dart';

final db = DataBaseHandler.instance;

class CardNote extends StatefulWidget {
  final Function() setIsInserting;
  final void Function() getNotes;  

  CardNote(
      {this.getNotes,      
      this.setIsInserting,
      });

  @override
  _CardNoteState createState() => _CardNoteState();
}

class _CardNoteState extends State<CardNote> {
  TextEditingController _newNote = TextEditingController(text: 'Título');

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
              child: Container(
          height: MediaQuery.of(context).size.height * 0.420,
          width: MediaQuery.of(context).size.width * 0.600,
          child: Card(
              elevation: 7.0,
              color: Theme.of(context).primaryColor,
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height <= 600 ? 80 : 110,
                    color: Colors.white60,
                    child: Center(
                      child: Image.asset('assets/note.png', color: Colors.black26),
                    ),
                  ),
                  SizedBox(
                      height: MediaQuery.of(context).size.height <= 400 ? 20 : 15),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _newNote,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                          enabledBorder:
                              UnderlineInputBorder(borderSide: BorderSide.none),
                          focusedBorder:
                              UnderlineInputBorder(borderSide: BorderSide.none),
                          disabledBorder:
                              UnderlineInputBorder(borderSide: BorderSide.none)),
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        FlatButton(
                          child: Icon(Icons.cancel, color: Colors.white, size: 30),
                          onPressed: widget.setIsInserting,
                        ),
                        FlatButton(
                          child: Icon(Icons.done, color: Colors.white, size: 30),
                          onPressed: () {
                            print(_newNote.text);

                            final data =
                                CalcNote(cardColor: 'green', tema: _newNote.text);
                            db.insert(data, 'CalcNotes').then((added) {
                              widget.setIsInserting();
                              widget.getNotes();
                              _newNote.text = 'Tema';
                            });
                          },
                        )
                      ],
                    ),
                  )
                ],
              )),
        ),
      ),
    );
  }
}
