import 'package:brew_controller_client/row_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class ParameterRowFieldStateful extends StatefulWidget {
  final String name;
  final String description;
  Icon icon;
  String hintText;
  ValueSetter<String> onValueChanged;

  ParameterRowFieldStateful(this.name, this.description, this.icon, this.hintText, this.onValueChanged, {Key? key }) : super(key: key);

  @override
  State<ParameterRowFieldStateful> createState() => _ParameterRowFieldStatefulState(name, description, icon, hintText, onValueChanged);
}

class _ParameterRowFieldStatefulState extends State<ParameterRowFieldStateful> {
  final String name;
  final String description;
  Icon icon;
  late String hintText;
  ValueSetter<String> onValueChanged;

  final TextEditingController _controller = TextEditingController();

  _ParameterRowFieldStatefulState(this.name, this.description, this.icon, this.hintText, this.onValueChanged) : super();

  @override
  Widget build(BuildContext context) {
    void _onSetPointSelected() {
      setState((){
        hintText = _controller.text;
      });
      _controller.clear();
    }
    TextField textField = TextField(
      controller: _controller,
      decoration: InputDecoration(hintText: hintText),
      keyboardType: TextInputType.number,
      onSubmitted: onValueChanged,
      onTap: _onSetPointSelected,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ], // Only numbers can be entered
    );
    return RowWidget.buildParameterRow(
        name, description, icon, hintText, textField, null);
  }
}

class ParameterRowField extends RowWidget {
  final String name;
  final String description;
  Icon icon;
  String hintText;
  ValueSetter<String> onValueChanged;
  ParameterRowField(this.name, this.description, this.icon, this.hintText, this.onValueChanged) : super(name);

  @override
  Widget build(BuildContext context) {
    return ParameterRowFieldStateful(name, description, icon, hintText, onValueChanged);
  }
}