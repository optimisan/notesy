import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notesy/services/add_note.dart';
import 'note_card.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// class NotesList1 extends StatelessWidget {
//   Widget build(BuildContext context) {
//     return StreamBuilder<QuerySnapshot>(
//       stream: LoggedInUser.collection.snapshots(),
//       builder: (_, snapshot) {
//         try {
//           if (!snapshot.hasData) {
//             return CircularProgressIndicator();
//           }
//           final noteDataList = snapshot.data?.docs;
//           List<NoteCard> notes = [];
//           for (var noteData in noteDataList!) {
//             final theData = noteData.data();
//             // notes.add(NoteCard(
//             //   title: theData?['title'],
//             //   content: theData?['content'],
//             //   color: theData?['color'],
//             // ),
//             //);
//           }
//           return GridView.count(
//             crossAxisCount: 2,
//             children: notes,
//           );
//         } catch (e) {
//           print(e);
//           return CircularProgressIndicator(
//             backgroundColor: Colors.lightBlueAccent,
//           );
//         }
//       },
//     );
//   }
// }
