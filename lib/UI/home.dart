import 'package:calcnote/UI/CardNote.dart';
import 'package:calcnote/UI/writting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:calcnote/Database/database.dart';
import '../Model/note.dart';

final db = DataBaseHandler.instance;

class DrummerNote extends StatefulWidget {
  @override
  _DrummerNoteState createState() => _DrummerNoteState();
}

class _DrummerNoteState extends State<DrummerNote> {
  bool floatingOpen = false;
  bool isAdding = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  int state = 0;

  List calcs = List();

  isInserting() {
    setState(() {
      isAdding = !isAdding;
    });
  }

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
   await db.initDB();
  }

  @override
  void initState() {
    Future.delayed(Duration(seconds: 5), () {
      setState(() {
        state = 1;
      });
    });
    super.initState();
    start().then((done) {
      getNotes();
    });
  }

  _delete(CalcNote calc) {
    db.deleteAll(calc.tema, 'CalcNotes').then((deleted) {
      db.deleteAll(calc.tema, 'Anotation');
      setState(() {
        getNotes().then((reloaded) {
          _scaffoldKey.currentState.showSnackBar(SnackBar(
              content: Text('Nota Excluída!',
                  style: TextStyle(fontWeight: FontWeight.w600),),),);
        });
      });
    });
  }

  _update(CalcNote calc, String oldName) async {
    List toAtualize = [];
   
    await db.queryParams(oldName, 'Anotation').then((done) {
      done.forEach((note) {
        setState(() {
          note = Anotation(
            date: note.date,
            id: note.id,
            title: note.title,
            type: note.type,
            value: note.value,
            tema: calc.tema
          );
          toAtualize.add(note);
        });
      });
    });


    db.updateAll('Anotation', toAtualize, oldName).then((updated) {
      db.update(calc, 'CalcNotes');
    });
  }

  List<Widget> _buildCardsView(List calc, int count, context) {
    List<Widget> cards = List.generate(
        count,
        (int index) => InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            Writting(tema: calc[index].tema)));
              },
              child: CardNote(
                label: calc[index].tema,
                alterDB: () => _delete(calc[index]),
                updateDB: (newName) {
                  String oldName = calc[index].tema;
                  calc[index] = CalcNote(
                    cardColor: calc[index].cardColor,
                    id: calc[index].id,
                    tema: newName
                  );
                  print(calc[index].tema); 
                  print(oldName); 
                   _update(calc[index], oldName);
                },
              ),
            ));
    return cards;
  }

  bool showFloatingButton () {
    if(MediaQuery.of(context).orientation == Orientation.portrait && !isAdding && state == 1) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title:
              Text('CalcNotes ${DateTime.now().year}'),
        ),
        body: state == 0
            ? Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 100,
                        child: ClipOval(                          
                          child: Image.asset('assets/asas.png',
                              width: 1000, height: 1000),
                        ),
                      ),
                      SizedBox(height: 10),
                      FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Desenvolvido por ",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 18)),
                            Text("Anja Solutions",
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontStyle: FontStyle.italic))
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                onRefresh: getNotes,
                child: Stack(
                  children: <Widget>[
                    InkWell(
                      child: SizedBox(
                        child: GridView.count(
                          crossAxisCount: MediaQuery.of(context).orientation == Orientation.landscape ? 4 : 2,
                          padding: const EdgeInsets.all(4.0),
                          childAspectRatio: MediaQuery.of(context).orientation == Orientation.landscape ? 1.0 / 2.0 : 10.0 / 18,
                          children:
                              _buildCardsView(calcs, calcs.length, context),
                        ),
                      ),
                    ),
                    isAdding
                        ? Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                          )
                        : SizedBox(),
                    isAdding
                        ? CardNote(
                            alterDB: getNotes,
                            setIsInserting: isInserting,
                            label: null,
                          )
                        : calcs.isEmpty
                            ? Center(
                                child: Text(
                                  "${MediaQuery.of(context).orientation == Orientation.portrait ? 'Inicie uma nova nota' : 'Não há notas.' }",
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                              )
                            : SizedBox()
                  ],
                ),
              ),
        floatingActionButton: showFloatingButton()
            ? FloatingActionButton(
                     onPressed: () {
                  setState(() {
                    isAdding = !isAdding;
                  });
                },
                child: Icon(Icons.add),
              )
            : Text(''),
      ),
    );
  }
}
