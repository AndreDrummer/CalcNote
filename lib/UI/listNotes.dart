import 'package:calcnote/Model/note.dart';
import 'package:calcnote/UI/dialog.dart';
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
  _delete(int id) {
    db.delete(id, 'Anotation').then((deleted) {
      widget.scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(
        'Nota Excluída!',
        style: TextStyle(fontWeight: FontWeight.w600),
      )));
      widget.atualizar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
            shrinkWrap: true,
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
                            groupValue: note.type,
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
                        note.type == 1 ? Colors.green : Colors.red,
                        radius: 30,
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Container(
                              height: 20,
                              child: FittedBox(
                                  child: Center(
                                    child: Text(
                                      "R\$ ${note.value.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ))),
                        ),
                      ),
                      title: Text(
                        note.title,
                        style: Theme.of(context).textTheme.display1,
                      ),
                      subtitle: Text(
                        "${DateFormat('dd/MM/y').format(DateTime.parse(note.date))}",
                        style: Theme.of(context).textTheme.subtitle,
                      ),
                      trailing: MediaQuery.of(context).size.width >= 480
                          ? FlatButton.icon(
                        textColor: Theme.of(context).errorColor,
                        icon: Icon(Icons.delete, size: 40),
                        label: Text("Excluir"),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (_) => DialogMessage(
                                title: 'Excluir',
                                confirmAction: 'Sim',
                                denyAction: 'Não',
                                message:
                                'Deseja realmente excluir esta nota',
                                onConfirm: () => _delete(note.id),
                              ));
                        },
                      )
                          : IconButton(
                        icon: Icon(Icons.delete, size: 40),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (_) => DialogMessage(
                                title: 'Excluir',
                                confirmAction: 'Sim',
                                denyAction: 'Não',
                                message:
                                'Deseja realmente excluir esta nota',
                                onConfirm: () => _delete(note.id),
                              ));
                        },
                        color: Theme.of(context).errorColor,
                      ),
                    ),
                  ),
                ),
              );
            });
  }
}
