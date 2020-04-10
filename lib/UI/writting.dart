import 'package:calcnote/UI/formAdd.dart';
import 'package:calcnote/UI/listNotes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:calcnote/Database/database.dart';

final db = DataBaseHandler.instance;

class Writting extends StatefulWidget {
  Writting({this.tema});

  final tema;

  @override
  _WrittingState createState() => _WrittingState();
}

class _WrittingState extends State<Writting> {
  List notes = List();
  List valuesAgregado = List();
  List valuesCredito = List();
  List valuesDividas = List();
  double totalAgregado = 0.0;
  double totalCredito = 0.0;
  double totalDividas = 0.0;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool atualizing = false;
  int idAtualize;

  String currencyPattern(String price) {
    var reais;
    var centavos;

    if (price.indexOf('.') != -1) {
      reais = price.split('.')[0];
      centavos = price.split('.')[1];
      if (centavos.toString().length == 1) {
        centavos = centavos + '0';
      }
    } else if (price.indexOf(',') != -1) {
      reais = price.split(',')[0];
      centavos = price.split(',')[1];
      if (centavos.toString().length == 1) {
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
    print("Limpar lista");
    if (notes.isNotEmpty) {
      notes.forEach((note) {
        if (note.type == 1) {
          valuesAgregado.add(note.value);
          valuesCredito.add(note.value);
        } else {
          valuesAgregado.add(note.value * (-1));
          valuesDividas.add(note.value);
        }
      });
      print("Values $valuesAgregado");
      totalAgregado = valuesAgregado.reduce(combineReducer);
      if (valuesCredito.isNotEmpty) {
        totalCredito = valuesCredito.reduce(combineReducer);
      }
      if (valuesDividas.isNotEmpty) {
        totalDividas = valuesDividas.reduce(combineReducer);
      }
    }
  }

  openModalForm(int groupValue, String tema) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (_) {
        return FormAdd(
          groupValue: groupValue,
          atualizing: atualizing,
          scaffoldKey: _scaffoldKey,
          atualizar: atualize,
          tema: tema,
        );
      },
    );
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

  List<String> orderItens = [
    'Data mais recente',
    'Data mais antiga',
    'Maior valor',
    'Menor valor',
    'Dívida primeiro',
    'Crédito primeiro'
  ];
  String dropValue = 'Data mais recente';

  int _sort(item1, item2) {
    if (dropValue == 'Data mais antiga') {
      if (DateTime.parse(item1.date).millisecondsSinceEpoch >
          DateTime.parse(item2.date).millisecondsSinceEpoch) {
        return 1;
      } else {
        return -1;
      }
    } else if (dropValue == 'Data mais recente') {
      if (DateTime.parse(item2.date).millisecondsSinceEpoch >
          DateTime.parse(item1.date).millisecondsSinceEpoch) {
        return 1;
      } else {
        return -1;
      }
    } else if (dropValue == 'Maior valor') {
      if (item2.value > item1.value) {
        return 1;
      } else {
        return -1;
      }
    } else if (dropValue == 'Menor valor') {
      if (item1.value > item2.value) {
        return 1;
      } else {
        return -1;
      }
    } else if (dropValue == 'Dívida primeiro') {
      if (item2.type > item1.type) {
        return 1;
      } else {
        return -1;
      }
    } else {
      if (item1.type > item2.type) {
        return 1;
      } else {
        return -1;
      }
    }
  }

  _orderList() {
    notes.sort(_sort);
  }

  @override
  void initState() {
    super.initState();
    getRegisters().then((done) {
      if (notes.isNotEmpty) {
        arrayValues();
      }
    });
    _orderList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('${widget.tema}'),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                        elevation: 20,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
//                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    "Créditos: R\$ ${currencyPattern(totalCredito.toString())}",
                                    style: Theme.of(context).textTheme.display1,
                                  ),
                                  Text(
                                    "Dívidas: R\$ ${currencyPattern(totalDividas.toString())}",
                                    style: Theme.of(context).textTheme.display1,
                                  ),
                                  Divider(color: Theme.of(context).accentColor),
                                  Text(
                                      "Saldo: R\$ ${currencyPattern(totalAgregado.toString())}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: totalAgregado > 0
                                            ? Colors.green
                                            : totalAgregado == 0
                                                ? Colors.amber
                                                : Colors.red,
                                        fontSize:
                                            MediaQuery.of(context).size.width <=
                                                    400
                                                ? 18
                                                : 25,
                                      )),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width <= 400 ? 40 : 320,
                                ),
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  child: Image.asset(
                                    'assets/cifrao.png',
                                    color: totalAgregado > 0
                                        ? Colors.green
                                        : totalAgregado == 0
                                            ? Colors.amber
                                            : Colors.red,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      notes.length > 0 ?
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          width: double.infinity,
                          child: DropdownButton<String>(
                              value: dropValue,
                              onChanged: (newValue) {
                                setState(() {
                                  dropValue = newValue;
                                  _orderList();
                                });
                              },
                              isExpanded: true,
                              items: orderItens
                                  .map<DropdownMenuItem<String>>((item) {
                                return DropdownMenuItem<String>(
                                  child: Text(item),
                                  value: item,
                                );
                              }).toList()),
                        ),
                      ) : Container(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height <= 600
                            ? 290
                            : MediaQuery.of(context).size.height * 0.59,
                        child: RefreshIndicator(
                            onRefresh: getRegisters,
                            child: notes.isEmpty
                                ? Column(
                                    children: <Widget>[
                                      SizedBox(height: 30),
                                      Center(
                                        child: Text("Nenhuma nota registrada!",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            )),
                                      ),
                                      SizedBox(height: 30),
                                      Container(
                                        height: 190,
                                        child: Image.asset('assets/waiting.png',
                                            fit: BoxFit.cover),
                                      )
                                    ],
                                  )
                                : ListNote(
                                    scaffoldKey: _scaffoldKey,
                                    notas: notes,
                                    atualizar: atualize,
                                  )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: SpeedDial(
        marginRight: 18,
        marginBottom: 20,
        animatedIcon: AnimatedIcons.add_event,
        animatedIconTheme: IconThemeData(size: 22.0),
        visible: MediaQuery.of(context).orientation == Orientation.portrait,
        closeManually: false,
        curve: Curves.bounceIn,
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
              onTap: () => openModalForm(2, widget.tema)),
          SpeedDialChild(
              child: Icon(Icons.attach_money),
              backgroundColor: Colors.green,
              label: 'Crédito',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => openModalForm(1, widget.tema)),
        ],
      ),
    );
  }
}
