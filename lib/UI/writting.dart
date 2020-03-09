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
  int _groupValue = 1; // type = Crédito
  List notes = List();
  List valuesAgregado = List();
  List valuesCredito = List();
  List valuesDividas = List();
  var totalAgregado = 0.0;
  var totalCredito = 0.0;
  var totalDividas = 0.0;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final formStateKey = GlobalKey<FormState>();

  TextEditingController _tituloEvent = TextEditingController();
  TextEditingController _valueEvent = TextEditingController();
  int idAtualize;

  Widget radioButton({int value, Function onChanged}) {
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
      centavos = price.split('.')[1];
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

    return "$reais,${centavos.substring(0, 2)}";
  }

  combineReducer(valueA, valueB) {
    return valueA + valueB;
  }

  arrayValues() {
    if (notes.isNotEmpty) {
      notes.forEach((note) {
        if (note.type == 'Crédito') {
          valuesAgregado.add(double.parse(note.value));
          valuesCredito.add(double.parse(note.value));
        } else {
          valuesAgregado.add(double.parse(note.value) * (-1));
          valuesDividas.add(double.parse(note.value));
        }
      });
      print("Values $valuesAgregado");
      totalAgregado = valuesAgregado.reduce(combineReducer);
      if(valuesCredito.isNotEmpty) {
        totalCredito = valuesCredito.reduce(combineReducer);
      }
      if(valuesDividas.isNotEmpty) {
        totalDividas = valuesDividas.reduce(combineReducer);
      }
    }
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
      if (notes.isNotEmpty) {
        arrayValues();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print(MediaQuery.of(context).size.height);
    List<Widget> divided = List<Widget>();

    Iterable<Widget> tiles = notes.map((item) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: InkWell(
          onTap: () {
            setState(() {
              _tituloEvent.text = item.title;
              _valueEvent.text = item.value.toString();
              _groupValue = item.type == 'Crédito' ? 1 : 2;
              inserting = !inserting;
              atualizing = !atualizing;
              idAtualize = item.id;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(6.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: item.type == 'Crédito'
                  ? Color(0xFFA5D6A7)
                  : Color(0xFFef9a9a), // verde
            ),
            child: Row(
              children: <Widget>[
                SizedBox(
                  width: MediaQuery.of(context).size.width <= 400
                      ? 250
                      : 16,
                  child: Row(
                    children: <Widget>[
                      Text("${item.title}",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.width <= 400
                                  ? 14
                                  : 16,
                              fontWeight: FontWeight.w600)),
                      Expanded(child: Divider(color: Colors.transparent)),
                      Text("R\$ ${currencyPattern(item.value.toString())}",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.width <= 400
                              ? 14
                              : 16,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Expanded(child: Divider(color: Colors.transparent)),
                SizedBox(
                  width: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      InkWell(
                        child: Icon(Icons.delete, size: MediaQuery.of(context).size.width <= 400
                                    ? 18
                                    : 22, color: Colors.black),
                        onTap: () {
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
                                              db
                                                  .delete(item.id, 'Anotation')
                                                  .then((deleted) {
                                                _scaffoldKey.currentState
                                                    .showSnackBar(SnackBar(
                                                        content: Text(
                                                            'Nota Excluída!',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600))));
                                                atualize();
                                              });
                                            },
                                            color: Colors.red,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12))),
                                        FlatButton(
                                            child: Text("Não"),
                                            onPressed: () {
                                              Navigator.pop(contexto);
                                            },
                                            color: Colors.green,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12)))
                                      ],
                                    )
                                  ],
                                );
                              });
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
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
              Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: MediaQuery.of(context).size.height <= 600
                                ? 290
                                : MediaQuery.of(context).size.height * 0.59,
                            child: notes.isEmpty
                                ? Center(
                                    child: Text("Nenhuma nota registrada!",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 20)),
                                  )
                                : RefreshIndicator(
                                    onRefresh: getRegisters,
                                    child: ListView(children: divided)),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            height: MediaQuery.of(context).size.height * 0.22,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white60,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                        "Total Créditos: R\$ ${currencyPattern(totalCredito.toString())}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.greenAccent,
                                            fontSize: MediaQuery.of(context).size.width <= 400
                                                ? 18
                                                : 25,)),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                        "Total Dívidas:   R\$ ${currencyPattern(totalDividas.toString())}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.deepOrange,
                                            fontSize: MediaQuery.of(context).size.width <= 400
                                                ? 18
                                                : 25,))
                                  ],
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text("Saldo: ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                            color: Colors.white)),
                                    Text(
                                        " R\$ ${currencyPattern(totalAgregado.toString())}",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context).size.width <= 400
                                                ? 18
                                                : 25,
                                            color: totalAgregado == 0
                                                ? Colors.white
                                                : totalAgregado >= 0
                                                    ? Colors.greenAccent
                                                    : Colors.red))
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              inserting
                  ? Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black26,
                    )
                  : SizedBox(),
              inserting
                  ? Center(
                      child: Container(
                        height: 300,
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.all(16.0),
                        color: Colors.white,
                        child: SingleChildScrollView(
                          child: Form(
                            key: formStateKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment(-0.91, 1),
                                  child: Text('Tipo de Nota'),
                                ),
                                Row(
                                  children: <Widget>[
                                    radioButton(
                                        value: 1,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _groupValue = newValue;
                                          });
                                        }),
                                    InkWell(
                                        child:
                                            Text("Crédito", style: TextStyle()),
                                        onTap: () {
                                          setState(() {
                                            _groupValue = 1;
                                          });
                                        }),
                                    radioButton(
                                        value: 2,
                                        onChanged: (newValue) {
                                          setState(() {
                                            _groupValue = newValue;
                                          });
                                        }),
                                    InkWell(
                                        child: Text("Dívida", style: TextStyle()),
                                        onTap: () {
                                          setState(() {
                                            _groupValue = 2;
                                          });
                                        }),
                                  ],
                                ),
                                TextFormField(
                                  validator: (String value) {
                                    if(value.isEmpty) {
                                      return 'Insira um título/nome para essa nota';
                                    } else {
                                      return null;
                                    }
                                  },
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
                                TextFormField(
                                  validator: (String value) {
                                    if(value.isEmpty) {
                                      return 'Insira um valor monetário';
                                    } else if (value.contains(',')) {
                                      return 'Não use vírgula, use ponto.';
                                    } else {
                                      return null;
                                    }
                                  },
                                  controller: _valueEvent,
                                  keyboardType: TextInputType.number,
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
                                        _valueEvent.clear();
                                        _tituloEvent.clear();
                                      },
                                      child: Text("Fechar",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Colors.red)),
                                    ),
                                    RaisedButton(
                                      onPressed: () {
                                        if(formStateKey.currentState.validate()) {
                                          if (atualizing) {
                                            print(_valueEvent.text);
                                            final note = Anotation(
                                                id: idAtualize,
                                                value: _valueEvent.text,
                                                title: _tituloEvent.text,
                                                tema: widget.tema,
                                                type: _groupValue == 1
                                                    ? 'Crédito'
                                                    : 'Dívida');


                                            db.update(note, 'Anotation').then((atualized) {
                                              _valueEvent.clear();
                                              _tituloEvent.clear();
                                              setState(() {
                                                atualizing = !atualizing;
                                                inserting = !inserting;
                                              });
                                            });
                                          } else {
                                            final note = Anotation(
                                                value: _valueEvent.text,
                                                title: _tituloEvent.text,
                                                day: "",
                                                month:
                                                "",
                                                year:
                                                "",
                                                type: _groupValue == 1
                                                    ? 'Crédito'
                                                    : 'Dívida',
                                                tema: widget.tema);

                                            db.insert(note, 'Anotation')
                                                .then((done) {
                                              _valueEvent.clear();
                                              _tituloEvent.clear();
                                            }).then((added) {
                                              setState(() {
                                                inserting = !inserting;
                                              });
                                            }).catchError((erro){
                                              _scaffoldKey.currentState.showSnackBar(SnackBar(
                                                  content: Text("Valor numérico deve usar '.' e não ','")
                                              ));
                                            });
                                          }

                                          atualize();
                                        }
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      color: _groupValue == 1
                                          ? Colors.green
                                          : Colors.redAccent,
                                      child: Text(atualizing ? 'Atualizar' : "Adicionar",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white)),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  : SizedBox(),
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
        backgroundColor: Colors.orange,
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
              }),
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
              }),
        ],
      ),
    );
  }
}
