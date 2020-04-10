import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './radioButtons.dart';
import 'package:calcnote/Model/note.dart';
import 'package:calcnote/Database/database.dart';

class FormAdd extends StatefulWidget {
  final int groupValue;
  final bool atualizing;
  final Anotation edittingNote;
  final scaffoldKey;
  final Function() atualizar;
  final String tema;

  FormAdd({
    @required this.groupValue,
    this.atualizing,
    this.edittingNote,
    this.scaffoldKey,
    this.atualizar,
    this.tema,
  });

  @override
  _FormAddState createState() => _FormAddState();
}

class _FormAddState extends State<FormAdd> {
  final formStateKey = GlobalKey<FormState>();
  int _groupValue; // type 1 = Crédito
  TextEditingController _tituloEvent = TextEditingController();
  TextEditingController _valueEvent = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  DateTime hoje = DateTime.now();

  final db = DataBaseHandler.instance;

  bool compareDates() {
    var hojeDia = hoje.day;
    var hojeMes = hoje.month;
    var hojeAno = hoje.year;

    var selectDia = _selectedDate.day;
    var selectMes = _selectedDate.month;
    var selectAno = _selectedDate.year;

    if ((hojeDia == selectDia) &&
        (hojeMes == selectMes) &&
        (hojeAno == selectAno)) {
      return true;
    }

    return false;
  }

  _openCalendar() {
    showDatePicker(
      locale: const Locale('pt'),
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(Duration(days: 730)), // 2 anos
    ).then((datePicker) {
      if (datePicker == null) {
        return;
      }
      setState(() {
        _selectedDate = datePicker;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _groupValue = widget.groupValue;
    if (widget.atualizing) {
      _tituloEvent.text = widget.edittingNote.title;
      _valueEvent.text = widget.edittingNote.value.toString();
      _selectedDate = DateTime.parse(widget.edittingNote.date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      child: Form(
        key: formStateKey,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 12,
              ),
              Align(
                alignment: Alignment(-0.91, 1),
                child: Text('Tipo de Anotação',
                    style: Theme.of(context).textTheme.title),
              ),
              Row(
                children: <Widget>[
                  RadioButton(
                      value: 1,
                      groupValue: _groupValue,
                      onChanged: (newValue) {
                        setState(() {
                          _groupValue = newValue;
                        });
                      }),
                  InkWell(
                      child: Text(
                        "Crédito",
                        style: Theme.of(context).textTheme.caption,
                      ),
                      onTap: () {
                        setState(() {
                          _groupValue = 1;
                        });
                      }),
                  RadioButton(
                      value: 2,
                      groupValue: _groupValue,
                      onChanged: (newValue) {
                        setState(() {
                          _groupValue = newValue;
                        });
                      }),
                  InkWell(
                      child: Text(
                        "Dívida",
                        style: Theme.of(context).textTheme.caption,
                      ),
                      onTap: () {
                        setState(() {
                          _groupValue = 2;
                        });
                      }),
                ],
              ),
              TextFormField(
                validator: (String value) {
                  if (value.isEmpty) {
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
                        borderSide: BorderSide(style: BorderStyle.solid)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(style: BorderStyle.solid)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(style: BorderStyle.solid)),
                    labelText: 'Nome da nota',
                    labelStyle: TextStyle(fontWeight: FontWeight.w600)),
              ),
              TextFormField(
                validator: (String value) {
                  if (value.isEmpty) {
                    return 'Insira um valor monetário';
                  } else if (value.contains(',')) {
                    return 'Não use vírgula, use ponto.';
                  } else {
                    return null;
                  }
                },
                controller: _valueEvent,
                keyboardType: TextInputType.numberWithOptions(
                    decimal: true, signed: true),
                decoration: InputDecoration(
                    errorStyle: TextStyle(fontSize: 16),
                    disabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(style: BorderStyle.solid)),
                    enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(style: BorderStyle.solid)),
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(style: BorderStyle.solid)),
                    prefix: Text("R\$   "),
                    labelText: 'Valor',
                    labelStyle: TextStyle(fontWeight: FontWeight.w600)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(
                      "${compareDates() ? 'Hoje' : 'Data'}: ${_selectedDate == null ? '' : DateFormat('dd/MM/y').format(_selectedDate)}",
                      style: Theme.of(context).textTheme.headline,
                    )),
                    FlatButton(
                      child: Text(
                        _selectedDate == null
                            ? 'Selecionar Data'
                            : "Alterar data",
                        style: Theme.of(context).textTheme.button,
                      ),
                      onPressed: _openCalendar,
                    )
                  ],
                ),
              ),
              ButtonBar(
                children: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _valueEvent.clear();
                      _tituloEvent.clear();
                    },
                    child: Text("Fechar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        )),
                  ),
                  RaisedButton(
                    onPressed: () {
                      if (formStateKey.currentState.validate()) {
                        if (widget.atualizing) {
                          final note = Anotation(
                            id: widget.edittingNote.id,
                            value: double.tryParse(_valueEvent.text),
                            title: _tituloEvent.text,
                            tema: widget.edittingNote.tema,
                            date: _selectedDate.toString(),
                            type: _groupValue,
                          );
                          db.update(note, 'Anotation').then((atualized) {
                            _valueEvent.clear();
                            _tituloEvent.clear();
                            Navigator.pop(context);
                          });
                        } else {
                          final note = Anotation(
                            value: double.tryParse(_valueEvent.text),
                            title: _tituloEvent.text,
                            date: _selectedDate.toString(),
                            type: _groupValue,
                            tema: widget.tema,
                          );
                          db.insert(note, 'Anotation').then((done) {
                            _valueEvent.clear();
                            _tituloEvent.clear();
                            Navigator.pop(context);
                          }).catchError((erro) {
                            widget.scaffoldKey.currentState.showSnackBar(SnackBar(
                                content: Text(
                                    "Valor numérico deve usar '.' e não ','")));
                          });
                        }
                        widget.atualizar();
                      }
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    color: Theme.of(context).primaryColor,
                    child: Text(widget.atualizing ? 'Atualizar' : "Adicionar",
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
    );
  }
}
