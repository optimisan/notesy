import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:notesy/models/note_model.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notesy/services/add_note.dart';

import '../constants.dart';

class NoteEditor extends StatefulWidget {
  const NoteEditor({Key? key, this.note}) : super(key: key);
  final Note? note;
  @override
  _NoteEditorState createState() => _NoteEditorState(note);
}

class _NoteEditorState extends State<NoteEditor> {
  late final Note? _note;
  late final Note? _originalNote;
  _NoteEditorState(Note? note) {
    print('In edit page constructor: id: ${note?.id}');
    this._note = note ?? Note();
    this._originalNote = note?.copy() ?? Note();
    print("In edit page constructor: originalNoteId: ${this._originalNote?.id}");
    this._titleTextController = TextEditingController(text: note?.title);
    this._contentTextController = TextEditingController(text: note?.content);
    print("In edit page constructor: ${this._note == null}");
  }
  // _NoteEditorState(Note? note)
  //     : this._note = note ?? Note(),
  //       _originalNote = note?.copy() ?? Note(),
  //       this._titleTextController = TextEditingController(text: note?.title),
  //       this._contentTextController = TextEditingController(text: note?.content);

  //Color get _noteColor => HexColor(hexColor: _note!.color!);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamSubscription<Note?>? _noteSubscription;
  // final TextEditingController _titleTextController;
  // final TextEditingController _contentTextController;
  late TextEditingController _titleTextController;
  late TextEditingController _contentTextController;

  /// If the note is modified.
  bool get _isDirty => _note != _originalNote;

  @override
  void initState() {
    super.initState();
    _titleTextController.addListener(() => _note!.title = _titleTextController.text);
    _contentTextController.addListener(() => _note!.content = _contentTextController.text);
  }

  @override
  void dispose() {
    _noteSubscription?.cancel();
    _titleTextController.dispose();
    _contentTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<User?>(context)?.uid;
    _watchNoteDocument(uid);
    return ChangeNotifierProvider.value(
      value: _note,
      child: Consumer<Note?>(
        builder: (_, __, ___) => Hero(
          tag: 'NoteItem${_note?.id}',
          child: Scaffold(
            key: _scaffoldKey,
            appBar: AppBar(
              title: Text("Note Editor"),
            ),
            body: _buildBody(context, uid!),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, String uid) => DefaultTextStyle(
        style: TextStyle(),
        child: WillPopScope(
          onWillPop: () => _onPop(uid),
          child: Container(
            height: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SingleChildScrollView(
              child: _buildNoteDetail(),
            ),
          ),
        ),
      );

  Future<bool> _onPop(String uid) {
    print("Save function ${_note?.id}");
    if (_isDirty && (_note?.id != null || _note!.isNotEmpty)) {
      _note!
        ..modifiedAt = DateTime.now()
        ..saveToFireStore(uid);
    }
    return Future.value(true);
  }

  Widget _buildNoteDetail() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            onChanged: (value) {
              print(
                  "_isDirty = $_isDirty and note==origNote is ${_note!.title == _originalNote!.title}");
              print("orig title = ${_originalNote!.title}");
            },
            controller: _titleTextController,
            style: TextStyle(
              color: Colors.white,
            ), //kNoteTitleLight,
            decoration: const InputDecoration(
              hintText: 'Title',
              border: InputBorder.none,
              counter: const SizedBox(),
            ),
            maxLines: null,
            maxLength: 1024,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _contentTextController,
            style: TextStyle(
              color: Colors.white,
            ), //kNoteTextLargeLight,
            decoration: const InputDecoration.collapsed(hintText: 'Take your note...'),
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      );

  void _watchNoteDocument(String? uid) {
    if (_noteSubscription == null && uid != null && _note?.id != null) {
      print("Watching note ${_note?.id}");
      _noteSubscription = FirebaseFirestore.instance
          .collection(uid)
          .doc(_note?.id)
          .snapshots(includeMetadataChanges: true)
          .map((snapshot) {
        print("In snapshot");
        return snapshot.exists ? snapshot.toNote() : null;
      }).listen((note) {
        print(note?.title);
      });
    }
  }

  /// Callback when the FireStore copy of this note updated.
  void _onCloudNoteUpdated(Note? note) {
    print("Updated on cloud ${!mounted} || ${note?.isNotEmpty != true} || ${_note == note}");
    if (!mounted || note?.isNotEmpty == true || _note == note) {
      return;
    }
    print("Beyond");
    final refresh = () {
      _titleTextController.text = _note?.title ?? '';
      _contentTextController.text = _note?.content ?? '';
      _originalNote?.update(note, updateTimestamp: false);
      _note?.update(note, updateTimestamp: false);
    };

    if (_isDirty) {
      print("Edited on cloud alert!");
      _scaffoldKey.currentState?.showSnackBar(SnackBar(
        content: const Text('The note is updated on cloud.'),
        action: SnackBarAction(
          label: 'Refresh',
          onPressed: refresh,
        ),
        duration: const Duration(days: 1),
      ));
    } else {
      refresh();
    }
  }
}
// class NotesAddPage extends StatefulWidget {
//   @override
//   _NotesAddPageState createState() => _NotesAddPageState();
// }
//
// class _NotesAddPageState extends State<NotesAddPage> {
//   String title = "";
//   String content = "";
//   String color = "444444";
//   AddNoteService addNoteService = AddNoteService();
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               SizedBox(
//                 height: 20.0,
//               ),
//               TextField(
//                 onChanged: (val) {
//                   title = val;
//                 },
//                 decoration: InputDecoration(
//                   hintText: "Title",
//                 ),
//               ),
//               SizedBox(height: 20.0),
//               TextField(
//                 onChanged: (val) {
//                   content = val;
//                 },
//                 minLines: 10,
//                 maxLines: 100,
//                 decoration: InputDecoration(
//                   hintText: "Content",
//                 ),
//               ),
//               SizedBox(height: 20.0),
//               TextField(
//                 onChanged: (val) {
//                   color = val;
//                 },
//                 decoration: InputDecoration(
//                   hintText: "Color",
//                 ),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   print("Adding...");
//                   AddNoteService().addNote(context, title: title, content: content, color: color);
//                 },
//                 child: Text("Save"),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
