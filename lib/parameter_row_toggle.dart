import 'package:brew_controller_client/row_widget.dart';
import 'package:flutter/material.dart';


class ParameterRowToggleStateful extends StatefulWidget {
  final String name;
  final String description;
  Icon icon;
  ValueSetter<bool> onSwitched;

  ParameterRowToggleStateful(this.name, this.description, this.icon, this.onSwitched, {Key? key }) : super(key: key);

  @override
  State<ParameterRowToggleStateful> createState() => _ParameterRowToggleStatefulState(name, description, icon, onSwitched);
}

class _ParameterRowToggleStatefulState extends State<ParameterRowToggleStateful> {
  final String name;
  final String description;
  Icon icon;
  ValueSetter<bool> onSwitched;
  _ParameterRowToggleStatefulState(this.name, this.description, this.icon, this.onSwitched) : super();

  void onToggled(bool newState) {
    newState = newState;
    setState(() {
      toggled = newState;
    });
    onSwitched(newState);
  }
  bool toggled = false;

  @override
  Widget build(BuildContext context) {
    Switch toggleSwitch = Switch(
      value: toggled,
      onChanged: onToggled,
      activeTrackColor: Colors.lightGreenAccent,
      activeColor: Colors.green,
    );

    return RowWidget.buildParameterRow(
      name, description, icon, null, null, toggleSwitch);
  }
}

class ParameterRowToggle extends RowWidget {
  final String name;
  final String description;
  Icon icon;
  ValueSetter<bool> onSwitched;
  ParameterRowToggle(this.name, this.description, this.icon, this.onSwitched) : super(name);

  @override
  Widget build(BuildContext context) {
    return ParameterRowToggleStateful(name, description, icon, onSwitched);
  }
}