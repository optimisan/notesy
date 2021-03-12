import 'package:flutter/material.dart';
import 'package:notesy/models/note_model.dart';

class NoteViewPage extends StatelessWidget {
  final Note? note;
  NoteViewPage({required this.note});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text(note?.title ?? ""),
          Text(note?.content ?? "Dummy content"),
        ],
      ),
    );
  }
}
