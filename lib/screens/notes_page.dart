import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notesy/models/note_model.dart';
import 'package:notesy/services/authentication.dart';
import 'package:notesy/widgets/notes_grid.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  bool _listView = false;
  @override
  Widget build(BuildContext context) {
    try {
      return StreamProvider<List<Note?>?>.value(
        value: _createNoteStream(context),
        initialData: [],
        child: Scaffold(
          drawer: Drawer(
            child: SafeArea(
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    title: Text(
                      context.read<AuthenticationService>().currentUser.email!,
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    onTap: () {
                      context.read<AuthenticationService>().signOut();
                    },
                  ),
                ],
              ),
            ),
          ),
          appBar: AppBar(
            title: Text("Notesy"),
          ),
          floatingActionButton: FloatingActionButton(
            child: const Icon(
              Icons.add,
              color: kBorderColorLight,
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/note');
            },
          ),
          //body: _buildNotesView(context),
          body: CustomScrollView(
            slivers: <Widget>[
              // a floating appbar
              const SliverToBoxAdapter(
                child: SizedBox(height: 24), // top spacing
              ),

              _buildNotesView(context),
              const SliverToBoxAdapter(
                child: SizedBox(
                    height:
                        80.0), // bottom spacing make sure the content can scroll above the bottom bar
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      print(e);
      return Scaffold();
    }
  }

  Consumer<List<Note?>?> _buildNotesView(BuildContext context) => Consumer<List<Note?>?>(
        builder: (context, notes, _) {
          print("building notes view");
          //print(notes?[0]!.title);
          //print("Printing and notes.isNotEmpty is ${notes?.isNotEmpty}");
          // if (notes!.isNotEmpty != true) {
          //   print("Wrong way");
          // } else {
          //   print("Right way!");
          // }

          //Try block was here

          // try {
          //   print('Current user id: ${context.read<User?>()?.uid}');
          //   return DebugGrid();
          // } catch (e) {
          //   print('Error: $e');
          //   return SliverGrid.count(
          //     crossAxisCount: 2,
          //     children: [
          //       Card(
          //         child: Text("Hello"),
          //       )
          //     ],
          //   );
          // }
          //return DebugGrid(notes?.length, notes);
          if (notes!.isNotEmpty != true) {
            //return DebugGrid(notes?.length, notes);
          }
          if (!_listView) {
            return NotesGrid(
              notes: notes,
              onTap: _onNoteTap,
              length: notes!.length,
              // onTap: (note) async {
              //   Navigator.of(context).push(
              //     MaterialPageRoute(
              //       builder: (context) => NoteViewPage(note: note),
              //     ),
              //   );
              // },
            );
          } else
            return NotesGrid(
              notes: notes,
              onTap: (_) {},
              length: notes!.length,
            );
          //final widget = !_listView ? NotesGrid() : NotesViewList();
          //return widget(notes: notes, onTap: (_) {});
        },
      );

  void _onNoteTap(Note? note) async {
    Navigator.pushNamed(context, '/note', arguments: {'note': note});
  }
}

/// Creates the notes query
Stream<List<Note?>?> _createNoteStream(BuildContext context) {
  final uid = context.watch<User?>()?.uid; //Provider.of<User?>(context)?.data?.uid;
  //sample hello2@gmail.com is "2U9ZKxo3VAbtqVVCVTtT4nmPWfa2";
  return FirebaseFirestore.instance
      .collection('notes-$uid')
      // .where('state', isEqualTo: 0)
      .snapshots()
      .handleError((e) => debugPrint('query notes failed: $e'))
      .map((snapshot) => Note.fromQuery(snapshot));
}

// class NotesPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       drawer: Drawer(
//         child: SafeArea(
//           child: ListView(
//             // Important: Remove any padding from the ListView.
//             padding: EdgeInsets.zero,
//             children: [
//               ListTile(
//                 title: Text(
//                   context.read<AuthenticationService>().currentUser.email!,
//                   style: TextStyle(
//                     fontSize: 18.0,
//                   ),
//                 ),
//               ),
//               ListTile(
//                 title: Text(
//                   'Sign Out',
//                   style: TextStyle(color: Colors.redAccent),
//                 ),
//                 onTap: () {
//                   context.read<AuthenticationService>().signOut();
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.teal.shade600,
//         onPressed: () {
//           Navigator.of(context).pushNamed('/notes_add');
//         },
//         child: Icon(
//           Icons.add,
//           color: Colors.white,
//         ),
//       ),
//       appBar: AppBar(
//         title: Text("Notesy"),
//       ),
//       body: SafeArea(
//         child: NotesList(),
//       ),
//     );
//   }
// }
