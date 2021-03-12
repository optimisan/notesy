import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notesy/models/note_model.dart';

class NoteService {
  final _userId = FirebaseAuth.instance.currentUser?.uid;

  late var _collection; //FirebaseFirestore.instance.collection(_userId!);
  NoteService() {
    _collection = FirebaseFirestore.instance.collection(_userId!);
    LoggedInUser._userId = _userId;
  }
  void addNote(BuildContext context, {String? title, String? content, String? color}) async {
    if (title == null && content == null) {
      return;
    }
    await _collection.add({'title': title, 'content': content, 'color': color ?? "NULL"});
    Navigator.pop(context);
  }
}

extension NoteDocument on DocumentSnapshot {
  Note? toNote() => exists
      ? Note(
          id: id,
          title: data()?['title'],
          content: data()?['content'],
          color: data()?['color'],
          createdAt: DateTime.fromMillisecondsSinceEpoch(data()?['createdAt'] ?? 0),
          modifiedAt: DateTime.fromMillisecondsSinceEpoch(data()?['modifiedAt'] ?? 0),
        )
      : null;
}

extension NoteStore on Note {
  Future<dynamic> saveToFireStore(String uid) async {
    final collection = FirebaseFirestore.instance.collection('notes-$uid');
    return id == null ? collection.add(toJson()) : collection.doc(id).update(toJson());
  }
}

class LoggedInUser {
  static var _userId = FirebaseAuth.instance.currentUser?.uid;

  static final collection = FirebaseFirestore.instance.collection(_userId!);
}