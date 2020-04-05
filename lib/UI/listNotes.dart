import 'package:calcnote/Model/note.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Database/database.dart';
import './formAdd.dart';

final db = DataBaseHandler.instance;

class ListNote extends StatefulWidget {
  final List<dynamic> notas;
  final Function() atualizar;
  final scaffoldKey;

  ListNote(
      {@required this.notas,
      @required this.scaffoldKey,
      @required this.atualizar});

  @override
  _ListNoteState createState() => _ListNoteState();
}

class _ListNoteState extends State<ListNote> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: widget.notas.length,
        itemBuilder: (context, index) {
          final note = widget.notas[index];
          return Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 5,
            child: InkWell(
              onTap: () {
                final edition = Anotation(
                    id: note.id,
                    title: note.title,
                    date: note.date,
                    tema: note.tema,
                    type: note.type,
                    value: note.value);
                showDialog(
                    context: context,
                    builder: (_) {
                      return FormAdd(
                        groupValue: note.type == 'Crédito' ? 1 : 2,
                        atualizar: widget.atualizar,
                        atualizing: true,
                        edittingNote: edition,
                      );
                    });
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        note.type == 'Crédito' ? Colors.green : Colors.red,
                    radius: 30,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: 
                      FittedBox(
                          child: 
                          Center(
                            child: Text(
                        "R\$ ${note.value.toStringAsFixed(2)}",
                        style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                      ),
                          )
                      ),
                    ),
                  ),
                  title: Text(
                    note.title,
                    style: Theme.of(context).textTheme.title,
                  ),
                  subtitle: Text(
                    "${DateFormat('dd/MM/y').format(DateTime.parse(note.date))}",
                    style: Theme.of(context).textTheme.subtitle,
                  ),
                  trailing: IconButton(
                      icon: Icon(Icons.delete, size: 40),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return AlertDialog(
                                title: Text("Excluir"),
                                content: Text('Deseja deletar essa anotação?'),
                                actions: <Widget>[
                                  ButtonBar(
                                    children: <Widget>[
                                      FlatButton(
                                          child: Text("Sim"),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            db
                                                .delete(note.id, 'Anotation')
                                                .then((deleted) {
                                              widget.scaffoldKey.currentState
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          'Nota Excluída!',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600))));
                                              widget.atualizar();
                                            });
                                          },
                                          color: Colors.red,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12))),
                                      FlatButton(
                                          child: Text("Não"),
                                          onPressed: () {
                                            Navigator.pop(context);
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
                      color: Theme.of(context).errorColor),
                ),
              ),
            ),
          );
        });
  }
}
