import 'package:calcnote/UI/writting.dart';
import 'package:flutter/material.dart';
import 'package:calcnote/Database/database.dart';
import 'package:calcnote/Model/note.dart';

final db = DataBaseHandler.instance;

class DrummerNote extends StatefulWidget {
  @override
  _DrummerNoteState createState() => _DrummerNoteState();
}

class _DrummerNoteState extends State<DrummerNote> {
  final dbHandler = DataBaseHandler.instance;
  bool floatingOpen = false;
  TextEditingController _newNote = TextEditingController(text: 'Tema');
  bool isAdding = false;
  List calcs = List();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<Null> getNotes() async {
    calcs.clear();
    await db.getCalcNotes().then((done) {
      done.forEach((note) {
        setState(() {
          calcs.add(note);
        });
      });
    });
    return null;
  }

  start() async {
    dbHandler.initDB();
    await getNotes();
  }

  @override
  void initState() {
    super.initState();
    start();
  }

  @override
  Widget build(BuildContext context) {
    List<Card> _buildCardsView(List calc, int count) {
      List<Card> cards = List.generate(
          count,
          (int index) => Card(
                elevation: 7.0,
                color: Colors.black,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Writting(tema: calc[index].tema)));
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AspectRatio(
                          aspectRatio: 19.0 / 11.0,
                          child: Container(
                            color: Colors.white60,
                            child: Icon(Icons.calendar_today,
                                size: 90, color: Colors.black12),
                          )),
                      Padding(
                          padding: EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 0.0),
                          child: Center(
                            child: Text("${calc[index].tema}",
                                style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontSize: 25)),
                          )),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.delete, size: 22, color: Colors.white),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext contexto) {
                                    return AlertDialog(
                                      title: Text('Excluir'),
                                      content: Text('Deseja deletar a  nota ${calc[index].tema}?'),
                                      actions: <Widget>[
                                        ButtonBar(
                                          children: <Widget>[
                                            FlatButton(
                                                child: Text("Sim"),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  db.delete(calc[index].id, 'CalcNotes').then((deleted) {
                                                    _scaffoldKey.currentState.showSnackBar(SnackBar(
                                                        content: Text('Nota Excluída!',
                                                            style: TextStyle(fontWeight: FontWeight.w600))
                                                    ));

                                                    getNotes();
                                                  });
                                                },
                                                color: Colors.red,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12)
                                                )
                                            ),
                                            FlatButton(
                                                child: Text("Não"),
                                                onPressed: () {
                                                  Navigator.pop(contexto);
                                                },
                                                color: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12)
                                                )
                                            )
                                          ],
                                        )
                                      ],
                                    );
                                  }
                              );
                            },
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ));
      return cards;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('CalcNotes ${DateTime.now().year}'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.white38,
      body: RefreshIndicator(
        onRefresh: getNotes,
        child: Stack(
          children: <Widget>[
           SizedBox(
//           height: MediaQuery.of(context).size.height * 0.7,
             child:  GridView.count(
               crossAxisCount: 2,
               padding: const EdgeInsets.all(4.0),
               childAspectRatio: 8.0 / 9.0,
               children: _buildCardsView(calcs, calcs.length),
             ),
           ),
            isAdding
                ? Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black26,
                  )
                : SizedBox(),
            isAdding
                ? Center(
                    child: Container(
                      height: 250,
                      width: 185,
                      child: SingleChildScrollView(
                        child: Card(
                          elevation: 7.0,
                          color: Colors.black,
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              AspectRatio(
                                  aspectRatio: 18.0 / 12.0,
                                  child: Container(
                                    color: Colors.white60,
                                    child: Icon(Icons.calendar_today,
                                        size: 90, color: Colors.black12),
                                  )),
                              Center(
                                  child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        EdgeInsets.fromLTRB(15.0, 0.0, 8.0, 4.0),
                                    child: TextField(
                                      cursorColor: Colors.white,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          fontSize: 25),
                                      controller: _newNote,
                                      decoration: InputDecoration(
                                          enabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide.none),
                                          focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide.none),
                                          disabledBorder: UnderlineInputBorder(
                                              borderSide: BorderSide.none)),
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
                                      FlatButton(
                                        child: Icon(Icons.cancel,
                                            color: Colors.white, size: 30),
                                        onPressed: () {
                                          setState(() {
                                            isAdding = !isAdding;
                                          });
                                        },
                                      ),
                                      FlatButton(
                                        child: Icon(Icons.done,
                                            color: Colors.white, size: 30),
                                        onPressed: () {
                                          setState(() {
                                            isAdding = !isAdding;
                                          });

                                          print(_newNote.text);

                                          final data = CalcNote(cardColor: 'green', tema: _newNote.text);
                                          db.insert(data, 'CalcNotes').then((added) {
                                            getNotes();
                                            _newNote.text = 'Tema';
                                          });

                                        },
                                      )
                                    ],
                                  ),
                                ],
                              )),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : calcs.isEmpty ? Center(
              child: Text("Clique em  + ",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white ,fontSize: 20)),
            ) : SizedBox()
          ],
        ),
      ),
      floatingActionButton: !isAdding ?  FloatingActionButton(

        onPressed: () {
          setState(() {
            isAdding = !isAdding;
          });
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ) : Text(''),
    );
  }
}
