import 'package:brew_controller_client/row_widget.dart';
import 'package:flutter/material.dart';


class ParameterRowFieldStateful extends StatefulWidget {
  final String name;
  final String description;
  Icon icon;
  final String hintText;
  TextField? textField;

  ParameterRowFieldStateful(this.name, this.description, this.icon, this.hintText, this.textField, {Key? key }) : super(key: key);

  @override
  State<ParameterRowFieldStateful> createState() => _ParameterRowFieldStatefulState(name, description, icon, hintText, textField);
}

class _ParameterRowFieldStatefulState extends State<ParameterRowFieldStateful> {
  final String name;
  final String description;
  Icon icon;
  final String hintText;
  TextField? textField;
  _ParameterRowFieldStatefulState(this.name, this.description, this.icon, this.hintText, this.textField) : super();

  @override
  Widget build(BuildContext context) {
    return RowWidget.buildParameterRow(
        name, description, icon, hintText, textField, null);
  }

  @override
  void didUpdateWidget(ParameterRowFieldStateful oldWidget) {
    if(textField != widget.textField) {
      //TODO: send proper set point to the host
    }
    super.didUpdateWidget(oldWidget);
  }
}

class ParameterRowField extends RowWidget {
  final String name;
  final String description;
  Icon icon;
  final String hintText;
  TextField? textField;
  ParameterRowField(this.name, this.description, this.icon, this.hintText, this.textField) : super(name);

  @override
  Widget build(BuildContext context) {
    return ParameterRowFieldStateful(name, description, icon, hintText, textField);
  }
}