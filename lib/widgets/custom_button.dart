import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  CustomButton({required this.text, required this.hasBorders, required this.onPressed});
  final String text;
  final bool hasBorders;
  final void Function() onPressed;
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(10),
      child: Ink(
        decoration: BoxDecoration(
          color: hasBorders ? Colors.white : Colors.blueAccent,
          borderRadius: BorderRadius.circular(10),
          border: hasBorders
              ? Border.all(color: Colors.blueAccent, width: 1.0)
              : Border.fromBorderSide(BorderSide.none),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(10),
            child: Center(
              child: Container(
                child: Text(
                  text,
                  style: TextStyle(
                    color: hasBorders ? Colors.blueAccent : Colors.white,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
