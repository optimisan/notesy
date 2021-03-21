import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:notesy/models/note_model.dart';
import 'package:notesy/services/notifications_service.dart';
import 'package:notesy/services/text_editor_service.dart';
import 'package:notesy/widgets/note_card.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notesy/services/add_note.dart';
import 'package:notesy/widgets/time_picker.dart';
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
  late bool showDelete;
  late Color noteColor;
  _NoteEditorState(Note? note) {
    print('In edit page constructor: color: ${note?.color}');
    this.showDelete = note != null;
    this._note = note ?? Note();
    this._originalNote = note?.copy() ?? Note();
    this.noteColor = _note?.color == null ? Color(0xFF1f1d2a) : HexColor(hexColor: _note!.color!);
    print(
        "In edit page constructor: originalNoteId: ${this._originalNote?.id} and contentOrig = ${this._originalNote?.content}");
    // this._titleTextController = TextEditingController(text: note?.title);
    this._titleTextController = TextFieldColorizer(colorControlMap, text: note?.title);
    this._contentTextController = TextFieldColorizer(colorControlMap, text: note?.content);
    print("In edit page constructor: ${this._originalNote?.color}");
  }
  // _NoteEditorState(Note? note)
  //     : this._note = note ?? Note(),
  //       _originalNote = note?.copy() ?? Note(),
  //       this._titleTextController = TextEditingController(text: note?.title),
  //       this._contentTextController = TextEditingController(text: note?.content);

  Color get _noteColor => _note?.color == null || _note?.color == "ff272636"
      ? Color(0xFF1f1d2a)
      : HexColor(hexColor: _note!.color!);

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
    _contentTextController.addListener(() {
      _note!.content = _contentTextController.text;
      _note?.getWordCount();
    });
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
          child: Theme(
            data: Theme.of(context).copyWith(
              primaryColor: _noteColor,
              appBarTheme: Theme.of(context).appBarTheme.copyWith(
                    elevation: 0,
                  ),
              scaffoldBackgroundColor: _noteColor,
              bottomAppBarColor: _noteColor,
            ),
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: _noteColor,
                systemNavigationBarColor: _noteColor,
                systemNavigationBarIconBrightness: Brightness.light,
              ),
              child: WillPopScope(
                onWillPop: () => _onPop(uid!),
                child: Scaffold(
                  key: _scaffoldKey,
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    leading: IconButton(
                      onPressed: () {
                        _onPop(uid!);
                        Navigator.pop(context);
                      },
                      icon: _isDirty ? Icon(Icons.check) : Icon(Icons.arrow_back),
                      tooltip: _isDirty ? "Save and exit" : "Exit",
                    ),
                    title: Text(
                      // _note == null || _note?.title == null ? '' : _note!.title!,
                      'Note',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    actions: _noteActions(context, uid),
                    bottom: const PreferredSize(
                      preferredSize: Size(0, 18),
                      child: SizedBox(),
                    ),
                  ),
                  body: _buildBody(context, uid!),
                  // bottomNavigationBar: _buildBottomAppBar(context),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, String uid) => DefaultTextStyle(
        style: TextStyle(),
        child: Container(
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: _buildNoteDetail(uid: uid),
          ),
        ),
      );

  Future<bool> _onPop(String uid) {
    print(
        "Inside saveFunction: $_isDirty ${_note?.labels?.length}, ${_originalNote?.labels?.length}");
    if (_isDirty && (_note?.id != null || _note!.isNotEmpty)) {
      print("Saving, color is ${this._note?.color}");
      _note!
        ..modifiedAt = DateTime.now()
        ..saveToFireStore(uid);
    }
    return Future.value(true);
  }

  Future<bool> _deleteNote(String? uid) async {
    await _note!.deleteFromFireStore(uid!);
    return Future.value(true);
  }

  List<Widget> _noteActions(BuildContext context, String? uid) {
    if (uid == null)
      return [Text('Error')];
    else
      return [
        TimePicker(this._note, uid),
        IconButton(
          icon: Icon(Icons.color_lens_outlined),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  contentTextStyle: const TextStyle(color: const Color(0xFFFEFEFE)),
                  title: Text(
                    'Select a color',
                    style: TextStyle(color: const Color(0xFFFEFEFE), fontWeight: FontWeight.w300),
                  ),
                  content: SingleChildScrollView(
                    child: BlockPicker(
                      availableColors: kNoteColors.toList(),
                      pickerColor: _noteColor,
                      onColorChanged: (color) {
                        // if (color.value.toRadixString(16) == "ff272636")
                        //   this._note?.updateWith(color: null);
                        // else
                        this._note?.updateWith(color: color.value.toRadixString(16));
                      },
                    ),
                  ),
                );
              },
            );
          },
          tooltip: "Color",
        ),
        if (showDelete)
          IconButton(
            tooltip: "Undo",
            icon: Icon(
              Icons.undo,
              color: Colors.grey.shade200,
            ),
            onPressed: _undoAllChanges,
          ),
        if (showDelete)
          IconButton(
              tooltip: "Delete",
              icon: Icon(
                Icons.delete,
                color: Colors.red.shade400,
              ),
              onPressed: () {
                _deleteNote(uid).then((value) => print("Note deleted"));
                Navigator.pop(context);
              }),
      ];
  }

  Widget _buildNoteDetail({String? uid}) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            // onChanged: (value) {
            //   print(
            //       "_isDirty = $_isDirty and note==origNote is ${_note!.title == _originalNote!.title}");
            //   print("orig title = ${_originalNote!.title}");
            // },
            controller: _titleTextController,
            style: TextStyle(color: Colors.white, fontSize: 22.0), //kNoteTitleLight,
            decoration: const InputDecoration(
              hintText: 'Title',
              border: InputBorder.none,
              counter: const SizedBox(),
            ),
            maxLines: null,
            maxLength: 1024,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),
          Wrap(children: [
            Text(
              "${_note?.strLastModified}. ${_note?.strLastModifiedHM} ${_note?.strLastModifiedDay.substring(0, 3)} | ${WordCount.wordCount(_note?.content)} words",
              style: TextStyle(
                // color: const Color(0xFF9a9aaa),
                color: Colors.grey.shade400,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          if (_note?.strRemindAtHM != null)
            Wrap(
              children: [
                InkWell(
                  onTap: () async {
                    await NotificationHelper.cancelNotification(_note.hashCode);
                    if (uid != null) await this._note?.deleteReminder(uid);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                    margin: EdgeInsets.only(right: 5.0, top: 8.0),
                    decoration: BoxDecoration(
                      color: _note!.reminderExists ? Colors.green.shade700 : Colors.transparent,
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.alarm_rounded, size: 24.0),
                        const SizedBox(width: 8.0),
                        Text(
                          "${_note?.strRemindAtDate} ${_note?.strRemindAtHM}",
                          style: TextStyle(
                            color: const Color(0xCCFAFAFA),
                            fontSize: 13.2,
                            decoration: !_note!.reminderExists ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Icon(Icons.close_rounded),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: _note!.reminderExists ? 20 : 16),
          TextField(
            onChanged: (value) {
              AddLabel.withThis(value, _note!);
            },
            keyboardType: TextInputType.multiline,
            controller: _contentTextController,
            style: TextStyle(
              color: Colors.grey.shade300,
              height: 1.5,
            ), //kNoteTextLargeLight,
            decoration: const InputDecoration.collapsed(hintText: 'Take your note...'),
            maxLines: null,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),
          Wrap(
            // children: [...?_note?.labelsToShow(showLabels: true)],
            children: [...?_note?.labelsHereFunction(uid)],
          )
        ],
      );

  Widget _buildBottomAppBar(BuildContext context) => BottomAppBar(
        child: Container(
          height: kBottomBarSize,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.add_box),
                color: kIconTintLight,
                onPressed: () {},
              ),
              // Text(
              //   'Edited ${_note?.strLastModified}',
              //   style: TextStyle(
              //     color: Color(0xAAFEFEFE),
              //     fontSize: 12.0,
              //   ),
              // ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                color: kIconTintLight,
                onPressed: () => _showNoteBottomSheet(context),
              ),
            ],
          ),
        ),
      );

  void _showNoteBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: noteColor,
      builder: (context) => ChangeNotifierProvider.value(
        value: _note,
        child: Consumer<Note?>(
          builder: (_, note, __) => Container(
            // color: note?.color == null ? kDefaultNoteColor : HexColor(hexColor: note!.color!),
            padding: const EdgeInsets.symmetric(vertical: 19),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // NoteActions(),
                const SizedBox(height: 16),
                // LinearColorPicker(),
                Text("Colors picker here"),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
    // if (command != null) {
    //   if (command.dismiss) {
    //     Navigator.pop(context, command);
    //   } else {
    //     processNoteCommand(_scaffoldKey.currentState, command);
    //   }
    // }
  }

  void _undoAllChanges() {
    print("modified: ${_note?.strLastModified} created: ${_note?.strCreatedAt}");
    _note?.update(_originalNote, updateTimestamp: false);
    _titleTextController.text = _note?.title ?? '';
    _contentTextController.text = _note?.content ?? '';
  }

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
        //_onCloudNoteUpdated(note);
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
