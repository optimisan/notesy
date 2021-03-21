import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    this.labels,
    DateTime? remindAt,
    DateTime? createdAt,
    DateTime? modifiedAt,
  })  : this.createdAt = createdAt ?? DateTime.now(),
        this.modifiedAt = modifiedAt ?? DateTime.now(),
        this.foundLabels = labels == null ? 0 : labels.length,
        this.remindAt = remindAt ?? DateTime.fromMillisecondsSinceEpoch(0);

  final String? id;
  String? title;
  String? content;
  String? color;
  int foundLabels;
  List<dynamic>? labels;
  DateTime? remindAt;
  final DateTime? createdAt;
  DateTime? modifiedAt;
  int wordCount = 0;

  static List<Note?>? fromQuery(QuerySnapshot? snapshot) =>
      snapshot != null ? toNotes(snapshot) : [];

  void update(Note? other, {bool updateTimestamp = true}) {
    title = other?.title;
    content = other?.content;
    color = other?.color;
    labels = other?.labels;

    if (updateTimestamp || other?.modifiedAt == null) {
      modifiedAt = DateTime.now();
    } else {
      modifiedAt = other?.modifiedAt;
    }
    notifyListeners();
  }

  void addToLabels(String? name) {
    print("Adding $name");
    if (name != null) {
      if (this.labels == null) {
        labels = [name.replaceAll("#", "").trim()];
      } else if (!this.labels!.contains(name.replaceAll("#", "").trim()))
        this.labels?.add(name.replaceAll("#", "").trim());
      foundLabels = labels!.length;
      // this.saveToFireStore(uid);
      print(labels);
      notifyListeners();
    }
  }

  void removeLabel(String name, {String? uid}) async {
    print("UID is $uid");
    if (this.labels != null) {
      this.labels?.remove(name);
      this.content?.replaceAll("a", ".");
      notifyListeners();
      final collection = FirebaseFirestore.instance.collection('notes-$uid');
      this.content = this.content?.replaceAll("#$name ", "");
      if (uid != null) await collection.doc(this.id).update(this.toJson());
      Fluttertoast.showToast(
          msg: "Delete the \"#$name\" from the note or press the Check Icon.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blueGrey,
          textColor: Colors.white,
          fontSize: 14.0);
    }
    print(listEquals(this.labels, ['Flutter', 'Flutter', 'Flutter']));
  }

  Future<bool> setReminder(DateTime dateTime) async {
    this.remindAt = dateTime;
    notifyListeners();
    return Future.value(true);
  }

  void deleteLocalReminder() {
    this.remindAt = DateTime.fromMillisecondsSinceEpoch(0);
    Fluttertoast.showToast(
            msg: "Reminder deleted",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.blueGrey,
            textColor: Colors.white,
            fontSize: 16.0)
        .then((value) => null);
    notifyListeners();
  }

  bool get reminderExists =>
      remindAt!.millisecondsSinceEpoch > DateTime.now().millisecondsSinceEpoch;
  String get strLastModified => DateFormat.yMMMMd().format(modifiedAt!);
  String get strLastModifiedHM => DateFormat.jm().format(modifiedAt!);
  String get strLastModifiedDay => DateFormat.EEEE().format(modifiedAt!);
  String get strCreatedAt => DateFormat.MMMd().format(createdAt!);
  String? get strRemindAtDate =>
      remindAt!.millisecondsSinceEpoch == 0 ? null : DateFormat.MMMMd().format(remindAt!);
  String? get strRemindAtHM =>
      remindAt!.millisecondsSinceEpoch == 0 ? null : DateFormat.jm().format(remindAt!);

  bool get isNotEmpty => title?.isNotEmpty == true || content?.isNotEmpty == true;
  List<Widget>? labelsToShow({required bool showLabels}) {
    //return this.labels?.map((e) => labelToWidget(e, insideEditor: true)).toList();
    if (showLabels)
      return this.labels?.map((e) => labelToWidget(e)).toList();
    else
      return null;
  }

  List<Widget>? get labelsHere {
    return this.labels?.map((e) => labelToWidget(e, insideEditor: true)).toList();
  }

  List<Widget>? labelsHereFunction(String? uid) {
    return this.labels?.map((e) => labelToWidget(e, insideEditor: true, uid: uid)).toList();
  }

  Widget labelToWidget(dynamic labelText, {bool insideEditor = false, String? uid}) {
    return GestureDetector(
      onTap: insideEditor
          ? () {
              print("Hi");
              this.removeLabel(labelText.toString(), uid: uid);
            }
          : null,
      child: Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              labelText.toString(),
              style: const TextStyle(color: const Color(0xCCFAFAFA), fontSize: 13.2),
            ),
            if (insideEditor) Icon(Icons.close_rounded),
          ],
        ),
        padding: EdgeInsets.symmetric(horizontal: 7.0, vertical: 2.0),
        margin: EdgeInsets.only(right: 5.0, bottom: 5.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: const Color(0xCCFAFAFA)),
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
        ),
      ),
    );
  }

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
        'labels': labels,
        'remindAt': (remindAt ?? DateTime.fromMillisecondsSinceEpoch(0)).millisecondsSinceEpoch
      };

  @override
  bool operator ==(other) =>
      other is Note &&
      (other.id ?? '') == (id ?? '') &&
      (other.title ?? '') == (title ?? '') &&
      (other.content ?? '') == (content ?? '') &&
      (other.color ?? 0) == (color ?? 0) &&
      listEquals(labels ?? [], other.labels ?? []);

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
  void getWordCount() {
    this.wordCount = WordCount.wordCount(this.content);
    notifyListeners();
  }
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
        labels: doc.data()?['labels'],
        remindAt: DateTime.fromMillisecondsSinceEpoch(doc.data()?['remindAt'] ?? 0),
        createdAt: DateTime.fromMillisecondsSinceEpoch(doc.data()?['createdAt'] ?? 0),
        modifiedAt: DateTime.fromMillisecondsSinceEpoch(doc.data()?['modifiedAt'] ?? 0),
      )
    : null;
//Todo: Default color of each note at creation
// Color _parseColor(num colorInt) => Color(colorInt.toInt());

class WordCount {
  static int wordCount(String? text) {
    RegExp exp = RegExp(r"(\w+)");
    // String str = "Parse my string";
    Iterable<Match> matches = exp.allMatches(text ?? '');
    return matches.length;
  }
  // Map<String, int> countWords(String sentence) {
  //   var words = new RegExp(r"\w+('\w+)?");
  //
  //   return words
  //       .allMatches(sentence)
  //       .map((item) => item.group(0)!.toLowerCase())
  //       .fold(new Map<String, int>(), (Map<String, int> wordCounts, String word) {
  //     if (wordCounts.containsKey(word)) {
  //       wordCounts[word] = wordCounts[word] ?? wordCounts[word] + 1;
  //     } else {
  //       wordCounts[word] = 1;
  //     }
  //     return wordCounts;
  //   });
  // }
}
