import 'package:flutter/material.dart';

class RadioButton extends StatelessWidget {
  final int value;
  final int groupValue;
  final void Function(int) onChanged;

  RadioButton({
    @required this.value,
    @required this.onChanged,
    @required this.groupValue,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
          unselectedWidgetColor: Theme.of(context).primaryColor,
        ),
        child: Radio(
          onChanged: onChanged,
          value: value,
          groupValue: groupValue,
          activeColor: Theme.of(context).primaryColor,
        ));
  }
}
