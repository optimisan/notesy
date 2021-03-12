import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum NoteState {
  unspecified,
  pinned,
  archived,
  deleted,
}

class Note with ChangeNotifier {
  /// Instantiates a [Note].
  Note({
    this.id,
    this.title,
    this.content,
    this.color,
    DateTime? createdAt,
    DateTime? modifiedAt,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.modifiedAt = modifiedAt ?? DateTime.now();
  final String? id;
  String? title;
  String? content;
  String? color;
  final DateTime? createdAt;
  DateTime? modifiedAt;

  static List<Note?>? fromQuery(QuerySnapshot? snapshot) =>
      snapshot != null ? toNotes(snapshot) : [];

  void update(Note? other, {bool updateTimestamp = true}) {
    title = other?.title;
    content = other?.content;
    color = other?.color;

    if (updateTimestamp || other?.modifiedAt == null) {
      modifiedAt = DateTime.now();
    } else {
      modifiedAt = other?.modifiedAt;
    }
    notifyListeners();
  }

  String get strLastModified => DateFormat.MMMd().format(modifiedAt!);
  bool get isNotEmpty => title?.isNotEmpty == true || content?.isNotEmpty == true;

  /// Update this note with specified properties.
  ///
  /// If [updateTimestamp] is `true`, which is the default,
  /// `modifiedAt` will be updated to `DateTime.now()`.
  Note updateWith({
    String? title,
    String? content,
    String? color,
    bool updateTimestamp = true,
  }) {
    if (title != null) this.title = title;
    if (content != null) this.content = content;
    if (color != null) this.color = color;
    if (updateTimestamp) modifiedAt = DateTime.now();
    notifyListeners();
    return this;
  }

  Note copy({bool updateTimestamp = false}) => Note(
        id: id,
        createdAt: (updateTimestamp || createdAt == null) ? DateTime.now() : createdAt,
      )..update(this, updateTimestamp: updateTimestamp);

  Map<String, dynamic> toJson() => {
        'title': title,
        'content': content,
        'color': color,
        'createdAt': (createdAt ?? DateTime.now()).millisecondsSinceEpoch,
        'modifiedAt': (modifiedAt ?? DateTime.now()).millisecondsSinceEpoch,
      };

  @override
  bool operator ==(other) =>
      other is Note &&
      (other.id ?? '') == (id ?? '') &&
      (other.title ?? '') == (title ?? '') &&
      (other.content ?? '') == (content ?? '') &&
      (other.color ?? 0) == (color ?? 0);

  @override
  int get hashCode => id.hashCode;
  // Widget build() {
  //   return NoteCard(
  //     title: this.title,
  //     content: this.content,
  //     color: this.color,
  //     note: this,
  //     onTap: (note){},
  //   );
  // }
}

/// Transforms the query result into a list of notes.
List<Note?>? toNotes(QuerySnapshot? query) =>
    query?.docs.map((d) => toNote(d)).where((n) => n != null).toList();

Note? toNote(DocumentSnapshot doc) => doc.exists
    ? Note(
        id: doc.id,
        title: doc.data()?['title'],
        content: doc.data()?['content'],
        color: doc.data()?['color'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(doc.data()?['createdAt'] ?? 0),
        modifiedAt: DateTime.fromMillisecondsSinceEpoch(doc.data()?['modifiedAt'] ?? 0),
      )
    : null;
//Todo: Default color of each note at creation
Color _parseColor(num colorInt) => Color(colorInt.toInt());
