import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:calcnote/Database/database.dart';
import 'package:calcnote/Model/note.dart';

final db = DataBaseHandler.instance;

class Writting extends StatefulWidget {

  Writting({this.tema});
  final tema;

  @override
  _WrittingState createState() => _WrittingState();
}

class _WrittingState extends State<Writting> {
  final dbHandler = DataBaseHandler.instance;
  bool inserting = false;
  bool atualizing = false;
  AnimationController _controller;
  int _groupValue = 1; // type = Crédito
  List notes = List();
  List valuesAgregado = List();
  List valuesCredito = List();
  List valuesDividas = List();
  var totalAgregado = 0.0;
  var totalCredito = 0.0;
  var totalDividas = 0.0;

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _tituloEvent = TextEditingController();
  TextEditingController _valueEvent = TextEditingController();

  Widget RadioButton({int value, Function onChanged}) {
    return Theme(
        data: Theme.of(context).copyWith(
          unselectedWidgetColor: Colors.black,
        ),
        child: Radio(
          onChanged: onChanged,
          value: value,
          groupValue: _groupValue,
          activeColor: Colors.black,
        ));
  }

  String currencyPattern(String price) {
    var reais;
    var centavos;

    if (price.indexOf('.') != -1) {
      reais = price.split('.')[0];
      centavos = price.split('.')[1].substring(0, 1);
      if(centavos.toString().length == 1) {
        centavos = centavos + '0';
      }
    } else if(price.indexOf(',') != -1) {
      reais = price.split(',')[0];
      centavos = price.split(',')[1];
      if(centavos.toString().length == 1) {
        centavos = centavos + '0';
      }
    } else {
      reais = price;
      centavos = '00';
    }

    return "$reais,$centavos";
  }

  combineReducer(valueA, valueB) {
    return valueA + valueB;
  }

  arrayValues() {
    notes.forEach((note) {
      if(note['type'] == 'Crédito') {
        valuesAgregado.add(note['value']);
        valuesCredito.add(note['value']);
      } else {
        valuesAgregado.add(note['value'] * (-1));
        valuesDividas.add(note['value']);
      }
    });
    print("Values $valuesAgregado");
    totalAgregado = valuesAgregado.reduce(combineReducer);
    totalCredito = valuesCredito.reduce(combineReducer);
    totalDividas = valuesDividas.reduce(combineReducer);
  }

  Future<Null> getRegisters() async {
    notes.clear();
    await db.queryParams(widget.tema, 'Anotation').then((done) {
      done.forEach((note) {
        setState(() {
          notes.add(note);
        });
      });
    });
    return null;
  }

  atualize() {
    setState(() {
      totalAgregado = 0;
      totalDividas = 0;
      totalCredito = 0;
      valuesAgregado.clear();
      valuesCredito.clear();
      valuesDividas.clear();
    });
    getRegisters().then((done) {
      arrayValues();
    });
  }

  @override
  void initState() {
    super.initState();
    print(widget.tema);
    getRegisters().then((done) {
      if(notes.isNotEmpty) {
        arrayValues();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> divided = List<Widget>();

    Iterable<Widget> tiles = notes.map((item) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: item['type'] == 'Crédito' ? Color(0xFFA5D6A7) : Color(0xFFef9a9a), // verde
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Text("${item['title']}",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                    Expanded(child: Divider(color: Colors.transparent)),
                    Text("R\$ ${currencyPattern(item['value'].toString())} |",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Row(
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.edit, size: 22, color: Colors.black),
                    onPressed: () {
                      print(item);
                      setState(() {
                        _tituloEvent.text = item['title'];
                        _valueEvent.text = item['value'].toString();
                        _groupValue = item['type'] == 'Crédito' ? 1 : 2;
                        inserting = !inserting;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 22, color: Colors.black),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext contexto) {
                          return AlertDialog(
                            title: Text('Excluir'),
                            content: Text('Deseja deletar essa anotação?'),
                            actions: <Widget>[
                              ButtonBar(
                               children: <Widget>[
                                 FlatButton(
                                   child: Text("Sim"),
                                   onPressed: () {
                                     Navigator.pop(contexto);
                                     db.delete(item['id'], 'Anotation').then((deleted) {
                                       _scaffoldKey.currentState.showSnackBar(SnackBar(
                                           content: Text('Nota Excluída!',
                                               style: TextStyle(fontWeight: FontWeight.w600))
                                       ));
                                       atualize();
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
      );
    });

    divided = ListTile.divideTiles(tiles: tiles, context: context).toList();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('${widget.tema}'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.white12,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Stack(
            children: <Widget>[
              SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.32,
                          child: notes.isEmpty ? Center(
                            child: Text("Nenhuma nota registrada!",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20)),
                          ) : ListView(children: divided),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Total Dívidas: R\$ ${currencyPattern(totalDividas.toString())}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,  color: Colors.white,  fontSize: 22))
                          ],
                        ),
                        Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Total Crédito: R\$ ${currencyPattern(totalCredito.toString())}",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,  color: Colors.white,  fontSize: 22)),
                          ],
                        ),
                        SizedBox(height: 30),
                        Container(
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: totalAgregado > 0 ? Colors.green : totalAgregado == 0 ? Colors.blue : Colors.red, // verde
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text("Agregado: R\$ ${currencyPattern(totalAgregado.toString())}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Colors.white))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              inserting ? Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.black26,
              ) : SizedBox(),
              inserting ?  Center(
                child: Container(
                  height: 300,
                  padding: const EdgeInsets.all(8.0),
                  margin: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Align(
                          alignment: Alignment(-0.91, 1),
                          child: Text('Tipo de Nota'),
                        ),
                        Row(
                          children: <Widget>[
                            RadioButton(
                                value: 1,
                                onChanged: (newValue) {
                                  setState(() {
                                    _groupValue = newValue;
                                  });
                                }),
                            Text("Crédito", style: TextStyle()),
                            RadioButton(
                                value: 2,
                                onChanged: (newValue) {
                                  setState(() {
                                    _groupValue = newValue;
                                  });
                                }),
                            Text("Dívida", style: TextStyle()),
                          ],
                        ),
                        TextField(
                          controller: _tituloEvent,
                          cursorColor: Colors.black,
                          decoration: InputDecoration(
                              errorStyle: TextStyle(fontSize: 16),
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black,
                                      style: BorderStyle.solid)),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black,
                                      style: BorderStyle.solid)),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black,
                                      style: BorderStyle.solid)),
                              labelText: 'Título',
                              labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600)),
                        ),
                        TextField(
                          controller: _valueEvent,
                          decoration: InputDecoration(
                              errorStyle: TextStyle(fontSize: 16),
                              disabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black,
                                      style: BorderStyle.solid)),
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black,
                                      style: BorderStyle.solid)),
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.black,
                                      style: BorderStyle.solid)),
                              prefix: Text("R\$   "),
                              labelText: 'Valor',
                              labelStyle: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600)),
                        ),
                        Divider(),
                        ButtonBar(
                          children: <Widget>[
                            FlatButton(
                              onPressed: () {
                                setState(() {
                                  inserting = !inserting;
                                });
                              },
                              child: Text("Fechar",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Colors.red)),
                            ),
                            RaisedButton(
                              onPressed: () {
                                setState(() {
                                  inserting = !inserting;
                                });

                                if(atualizing) {
                                  final note = Anotation(
                                      value: double.parse(_valueEvent.text),
                                      title:  _tituloEvent.text,
                                      type: _groupValue == 1 ? 'Crédito' : 'Dívida'
                                  );

                                  db.update(note, 'Anotation');
                                } else {
                                  final note = Anotation(
                                      value: double.parse(_valueEvent.text),
                                      title:  _tituloEvent.text,
                                      day: DateTime.now().day.toString(),
                                      month: DateTime.now().month.toString(),
                                      year: DateTime.now().year.toString(),
                                      type: _groupValue == 1 ? 'Crédito' : 'Dívida',
                                      tema: widget.tema
                                  );

                                  db.insert(note, 'Anotation').then((done) {
                                    _valueEvent.clear();
                                    _tituloEvent.clear();
                                  });
                                }

                                atualize();

                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(12))),
                              color: Colors.blue,
                              child: Text("Adicionar",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 22,
                                      color: Colors.white)),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ) : SizedBox(),
            ],
          );
        },
      ),
      floatingActionButton: SpeedDial(
        // both default to 16
        marginRight: 18,
        marginBottom: 20,
//        child: Icon(floatingOpen ? Icons.close : Icons.add),
        animatedIcon: AnimatedIcons.add_event,
        animatedIconTheme: IconThemeData(size: 22.0),
        // this is ignored if animatedIcon is non null
        // child: Icon(Icons.add),
        visible: !inserting,
        // If true user is forced to close dial manually
        // by tapping main button and overlay is not rendered.
        closeManually: false,
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        onOpen: () {
          print('OPENING DIAL');
        },
        onClose: () {
          print('DIAL CLOSED');
        },
        tooltip: 'Adicionar Nota',
        heroTag: 'speed-dial-hero-tag',
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
              child: Icon(Icons.money_off),
              backgroundColor: Colors.red,
              label: 'Dívida',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () {
                setState(() {
                  inserting = !inserting;
                  _groupValue = 2;
                });
                print('Dívidas');
              }
              ),
          SpeedDialChild(
            child: Icon(Icons.attach_money),
            backgroundColor: Colors.green,
            label: 'Crédito',
            labelStyle: TextStyle(fontSize: 18.0),
            onTap: () {
              setState(() {
                inserting = !inserting;
                _groupValue = 1;
              });
              print('Crédito');
            }
          ),
        ],
      ),
    );
  }
}
