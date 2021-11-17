import 'package:brew_controller_client/row_widget.dart';
import 'package:flutter/material.dart';


class ParameterRowValueStateful extends StatefulWidget {
  final String name;
  final String description;
  Icon icon;
  String valueText;

  ParameterRowValueStateful(this.name, this.description, this.icon, this.valueText, {Key? key }) : super(key: key);

  @override
  State<ParameterRowValueStateful> createState() => _ParameterRowValueStatefulState(name, description, icon, valueText);
}

class _ParameterRowValueStatefulState extends State<ParameterRowValueStateful> {
  final String name;
  final String description;
  Icon icon;
  late String valueText;
  _ParameterRowValueStatefulState(this.name, this.description, this.icon, this.valueText) : super();

  @override
  Widget build(BuildContext context) {
      return RowWidget.buildParameterRow(
        name, description, icon, valueText, null, null);
    }

  @override
  void didUpdateWidget(ParameterRowValueStateful oldWidget) {
    if(valueText != widget.valueText) {
      setState((){
        valueText = widget.valueText;
      });
    }
    super.didUpdateWidget(oldWidget);
  }
}

class ParameterRowValue extends RowWidget {
  final String name;
  final String description;
  Icon icon;
  String valueText;
  ParameterRowValue(this.name, this.description, this.icon, this.valueText) : super(name);

  @override
  Widget build(BuildContext context) {
    return ParameterRowValueStateful(name, description, icon, valueText);
  }
}