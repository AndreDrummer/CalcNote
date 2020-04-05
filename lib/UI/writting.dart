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
        if (note.type == 'Crédito') {
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
    showDialog(
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

  @override
  void initState() {
    super.initState(); 
    getRegisters().then((done) {
      if (notes.isNotEmpty) {
        arrayValues();
      }
    });
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
                            borderRadius: BorderRadius.circular(8.0)
                        ),
                        elevation: 20,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                          "Créditos: R\$ ${currencyPattern(totalCredito.toString())}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <=
                                                    400
                                                ? 18
                                                : 25,
                                          )),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                          "Dívidas:   R\$ ${currencyPattern(totalDividas.toString())}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <=
                                                    400
                                                ? 18
                                                : 25,
                                          ))
                                    ],
                                  ),
                                  Divider(
                                      color: Theme.of(context).primaryColor),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Saldo: ",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 25,
                                          color: totalAgregado > 0
                                              ? Colors.green : totalAgregado == 0 ?  Colors.amber
                                              : Colors.red,
                                          )),
                                      Text(
                                          " R\$ ${currencyPattern(totalAgregado.toString())}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: totalAgregado > 0
                                                ? Colors.green : totalAgregado == 0 ?  Colors.amber
                                                : Colors.red,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <=
                                                    400
                                                ? 18
                                                : 25,
                                          ))
                                    ],
                                  )
                                ],
                              ),
                              Container(
                                height: 80,
                                width: 80,
                                child: Image.asset(
                                  'assets/cifrao.png',
                                  color: totalAgregado > 0
                                      ? Colors.green : totalAgregado == 0 ?  Colors.amber
                                      : Colors.red,
                                  fit: BoxFit.cover,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height <= 600
                            ? 290
                            : MediaQuery.of(context).size.height * 0.59,
                        child: RefreshIndicator(
                            onRefresh: getRegisters,
                            child: notes.isEmpty
                                ? Column(
                                    children: <Widget>[
                                      SizedBox(height: 50),
                                      Center(
                                        child: Text("Nenhuma nota registrada!",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20,
                                            )),
                                      ),
                                      SizedBox(height: 50),
                                      Container(
                                        height: 200,
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
        visible: true,        
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
              onTap: () => openModalForm(2, widget.tema)
              ),
          SpeedDialChild(
              child: Icon(Icons.attach_money),
              backgroundColor: Colors.green,
              label: 'Crédito',
              labelStyle: TextStyle(fontSize: 18.0),
              onTap: () => openModalForm(1, widget.tema)
              ),
        ],
      ),
    );
  }
}
