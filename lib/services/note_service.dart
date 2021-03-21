import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notesy/models/note_model.dart';
import 'package:provider/provider.dart';

class NoteService with ChangeNotifier {
  String? _labelToFilterWith;
  String? _labelColorString;
  void updateLabel({String? label, String? color}) {
    _labelToFilterWith = label;
    _labelColorString = color;
    notifyListeners();
  }

  void removeLabel() {
    _labelToFilterWith = null;
    _labelColorString = null;
    notifyListeners();
  }

  String? get labelColor => _labelColorString;
  String? get labelInUse => _labelToFilterWith;

  Stream<List<Label?>?> createLabelStream(BuildContext context) {
    final uid = context.watch<User?>()?.uid;
    final collection = FirebaseFirestore.instance
        .collection('notes-$uid')
        .doc("user-data")
        .collection("labels-collection");
    return collection
        .snapshots()
        .handleError((e) => debugPrint('query labels failed: $e'))
        .map((snapshot) => toLabelList(snapshot));
  }

  List<Label?>? toLabelList(QuerySnapshot snapshot) {
    return snapshot.docs
        .map((e) => Label(
              id: e.id,
              name: e.data()?['name'],
              color: e.data()?['color'],
            ))
        .toList();
  }

  Stream<List<Note?>?> createNoteStream(BuildContext context) {
    final uid = context.watch<User?>()?.uid; //Provider.of<User?>(context)?.data?.uid;
    //sample hello2@gmail.com is "2U9ZKxo3VAbtqVVCVTtT4nmPWfa2";
    final collection =
        FirebaseFirestore.instance.collection('notes-$uid').orderBy("createdAt", descending: true);
    if (this._labelToFilterWith == null)
      return collection
          // .where('state', isEqualTo: 0)
          .snapshots()
          .handleError((e) => debugPrint('query notes failed: $e'))
          .map((snapshot) => Note.fromQuery(snapshot));
    else
      return collection
          .where("labels", arrayContains: this._labelToFilterWith)
          .snapshots()
          .handleError((e) => debugPrint('query notes failed: $e'))
          .map((snapshot) => Note.fromQuery(snapshot));
  }
}

class Label with ChangeNotifier {
  Label({required this.id, required this.name, this.color});
  String name;
  String? color;
  String id;
  void updateLabel({required String labelName, String? labelColor}) {
    this.name = labelName;
    this.color = labelColor;
    notifyListeners();
  }

  Future<void> saveLabelToFireStore(BuildContext context) {
    final uid = context.watch<User?>()?.uid;
    final collection = FirebaseFirestore.instance
        .collection('notes-$uid')
        .doc("user-data")
        .collection("labels-collection");
    return collection.doc(this.id).update({
      'name': this.name,
      'color': this.color,
    });
  }

  static Future<void> addNewLabelToFireStore(BuildContext context, String name, String? color) {
    final uid = context.read<User?>()?.uid;
    final collection = FirebaseFirestore.instance
        .collection('notes-$uid')
        .doc("user-data")
        .collection("labels-collection");
    return collection.add({'name': name, 'color': color});
  }

  Future<dynamic> deleteLabelFromFireStore(BuildContext context) async {
    print("Deleting");
    final uid = context.read<User?>()?.uid;
    final collection = FirebaseFirestore.instance
        .collection('notes-$uid')
        .doc("user-data")
        .collection("labels-collection");
    return collection.doc(id).delete();
  }
}
