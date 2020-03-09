import 'package:calcnote/UI/writting.dart';
import 'package:flutter/cupertino.dart';
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
  int state = 0;

  Future<Null> getNotes() async {
    calcs.clear();
    await db.getCalcNotes().then((done) {
      if (done.isNotEmpty) {
        done.forEach((note) {
          setState(() {
            calcs.add(note);
          });
        });
      }
    });
    return null;
  }

  start() async {
    await dbHandler.initDB();
    await getNotes();
  }

  @override
  void initState() {
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        state = 1;
      });
    });
    super.initState();
    start();
  }

  List<Card> _buildCardsView(List calc, int count) {
    List<Card> cards = List.generate(
        count,
        (int index) => Card(
              elevation: 7.0,
              color: Colors.black,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              Writting(tema: calc[index].tema)));
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                        height: MediaQuery.of(context).size.height <= 600
                            ? 80
                            : 110,
                        color: Colors.white60,
                      child: Center(
                        child: Image.asset('assets/note.png', color: Colors.black26),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height <= 400
                        ? 20
                        : 15),
                    Container(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                            child: Text(calc[index].tema.toString().length > 9 ? "${calc[index].tema.toString().substring(0, 9)}..." : calc[index].tema,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontSize:
                                  MediaQuery.of(context).size.height <= 400
                                      ? 18
                                      : 22,
                                )),
                          ),
                          InkWell(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext contexto) {
                                    return AlertDialog(
                                      title: Text('Excluir'),
                                      content: Text(
                                          'Deseja deletar a  nota ${calc[index].tema}?'),
                                      actions: <Widget>[
                                        ButtonBar(
                                          children: <Widget>[
                                            FlatButton(
                                                child: Text("Sim"),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  db
                                                      .delete(calc[index].id,
                                                          'CalcNotes')
                                                      .then((deleted) {
                                                    setState(() {
                                                      getNotes()
                                                          .then((reloaded) {
                                                        _scaffoldKey
                                                            .currentState
                                                            .showSnackBar(SnackBar(
                                                                content: Text(
                                                                    'Nota Excluída!',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.w600))));
                                                      });
                                                    });
                                                  });
                                                },
                                                color: Colors.red,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12))),
                                            FlatButton(
                                                child: Text("Não"),
                                                onPressed: () {
                                                  Navigator.pop(contexto);
                                                },
                                                color: Colors.green,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12)))
                                          ],
                                        )
                                      ],
                                    );
                                  });
                            },
                            child: Icon(Icons.delete,
                                size: MediaQuery.of(context).size.height <= 400
                                    ? 25
                                    : 30,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ));
    return cards;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: state == 0 ? Text('') : Text('CalcNotes ${DateTime.now().year}'),
          backgroundColor: Colors.black,
        ),
        backgroundColor: Colors.white38,
        body: state == 0 ?  Center(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  radius: 30,
                  child: ClipOval(
                    child: Image.asset('assets/andre.jpg', width: 1000, height: 1000),
                  ),
                ),
                SizedBox(height: 10),
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text("Desenvolvido por ", style: TextStyle(color: Colors.white, fontSize: 18)),
                      Text("André Drummer", style: TextStyle(color: Colors.white, fontStyle: FontStyle.italic))
                    ],
                  ),
                )
              ],
            ),
          ),
        ) : RefreshIndicator(
          onRefresh: getNotes,
          child: Stack(
            children: <Widget>[
              SizedBox(
//           height: MediaQuery.of(context).size.height * 0.7,
                child: GridView.count(
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
                        height: 280,
                        width: 225,
                        child: SingleChildScrollView(
                          child: Card(
                            elevation: 7.0,
                            color: Colors.black,
                            clipBehavior: Clip.antiAlias,
                            child:
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  height: MediaQuery.of(context).size.height <= 400
                                      ? 50
                                      : 150,
                                  color: Colors.white60,
                                  child: Center(
                                    child: Image.asset('assets/note.png', color: Colors.black26),
                                  ),
                                ),
                                SizedBox(height: MediaQuery.of(context).size.height <= 400
                                    ? 20
                                    : 15),
                                Container(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Flexible(
                                            child: Padding(
                                              padding: EdgeInsets.fromLTRB(
                                                  15.0, 0.0, 8.0, 4.0),
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
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
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

                                              final data = CalcNote(
                                                  cardColor: 'green',
                                                  tema: _newNote.text);
                                              db
                                                  .insert(data, 'CalcNotes')
                                                  .then((added) {
                                                getNotes();
                                                _newNote.text = 'Tema';
                                              });
                                            },
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                          ),
                        ),
                      ),
                    )
                  : calcs.isEmpty
                      ? Center(
                          child: Text("Clique em  + ",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontSize: 20)),
                        )
                      : SizedBox()
            ],
          ),
        ),
        floatingActionButton: !isAdding && state == 1
            ? FloatingActionButton(
                onPressed: () {
                  setState(() {
                    isAdding = !isAdding;
                  });
                },
                child: Icon(Icons.add),
                backgroundColor: Colors.orange,
              )
            : Text(''),
      ),
    );
  }
}
