import 'package:flutter/material.dart';

abstract class RowWidget {
  final String _name;

  RowWidget(this._name);

  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.red),
      child: Text(_name),
    );
  }

  static Widget buildParameterRow(String title, String description, Icon icon, final String? text, TextField? textField, Switch? toggleSwitch) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),

          (null != textField) ? Row(
              children:[
                SizedBox(width: 20, height: 51, child : textField),
                const Text(" °C"),
              ]
          ) : (null != toggleSwitch) ? toggleSwitch : Text("$text °C"),
        ],
      ),
    );
  }
}

