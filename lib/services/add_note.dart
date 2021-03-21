import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notesy/models/note_model.dart';

class OldNoteService with ChangeNotifier {
  final _userId = FirebaseAuth.instance.currentUser?.uid;

  late var _collection; //FirebaseFirestore.instance.collection(_userId!);
  OldNoteService() {
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

  Future<dynamic> deleteFromFireStore(String uid) async {
    final collection = FirebaseFirestore.instance.collection('notes-$uid');
    return id == null ? Future.value(null) : collection.doc(id).delete();
  }

  Future<dynamic> addReminder(String? uid) async {
    if (uid != null) {
      final collection = FirebaseFirestore.instance.collection('notes-$uid');
      return id == null
          ? Future.value(null)
          : collection.doc(id).update({'remindAt': remindAt?.millisecondsSinceEpoch});
    } else
      return Future.value(false);
  }

  Future<dynamic> deleteReminder(String? uid) async {
    if (uid != null) {
      this.deleteLocalReminder();
      final collection = FirebaseFirestore.instance.collection('notes-$uid');
      return id == null ? Future.value(null) : collection.doc(id).update({'remindAt': 0});
    } else
      return Future.value(false);
  }
}

class LoggedInUser {
  static var _userId = FirebaseAuth.instance.currentUser?.uid;

  static final collection = FirebaseFirestore.instance.collection(_userId!);
}
