import 'package:flutter/material.dart';
import 'package:notesy/models/home_model.dart';
import 'package:provider/provider.dart';

class TextFieldWidget extends StatelessWidget {
  TextFieldWidget(
      {required this.hintText,
      required this.obscureText,
      required this.onChanged,
      required this.prefixIconData,
      this.suffixIconData});
  final String hintText;
  final IconData prefixIconData;
  final IconData? suffixIconData;
  final bool obscureText;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    final emailModel = Provider.of<HomeModel>(context);
    return TextField(
      onChanged: onChanged,
      style: TextStyle(
        color: Colors.blue,
        fontSize: 14.0,
      ),
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: hintText,
        filled: true,
        fillColor: Colors.grey.shade100,
        prefixIcon: Icon(
          prefixIconData,
          size: 18.0,
          color: Colors.blueAccent,
        ),
        suffixIcon: suffixIconData == null
            ? null
            : GestureDetector(
                onTap: () {
                  emailModel.isVisible = !emailModel.ifVisible;
                },
                child: Icon(
                  suffixIconData,
                  size: 18.0,
                  color: Colors.blueAccent,
                ),
              ),
        labelStyle: TextStyle(color: Colors.blue),
        focusColor: Colors.blueAccent,
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blueAccent),
        ),
      ),
    );
  }
}
