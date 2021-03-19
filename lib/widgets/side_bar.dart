import 'package:flutter/material.dart';
import 'package:notesy/constants.dart';
import 'package:notesy/services/note_service.dart';
import 'package:notesy/widgets/note_card.dart';
import 'package:provider/provider.dart';
import 'package:notesy/services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

late NoteService _noteService;

class SideBarDrawer extends StatelessWidget {
  const SideBarDrawer({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    String? label;
    return StreamProvider<List<ListTile>?>.value(
      value: _createLabelStream(context),
      initialData: null,
      child: Consumer<List<ListTile>?>(
        builder: (context, listTiles, _) {
          _noteService = Provider.of<NoteService>(context);
          return Drawer(
            child: SafeArea(
              child: ListView(
                // Important: Remove any padding from the ListView.
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: Text(
                      'Notesy User',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: const Color(0xFFFEFEFE),
                      ),
                    ),
                    accountEmail: Text(
                      context.read<AuthenticationService>().currentUser.email!,
                      style: TextStyle(
                        color: const Color(0xFFFEFEFE),
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                    leading: Icon(Icons.note_outlined),
                    selectedTileColor: Colors.deepPurpleAccent,
                    title: Text(
                      "All Notes",
                      style: TextStyle(
                        color: brighten(Colors.deepPurpleAccent, 20),
                      ),
                    ),
                    onTap: () {
                      _noteService.removeLabel();
                      Navigator.pop(context);
                    },
                  ),
                  // ...?snapshot?.docs
                  //     .map((e) => ListTile(
                  //           title: e.data()?['name'],
                  //         ))
                  //     .toList(),
                  ...?listTiles,
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
                    title: Text("Add Labels", style: TextStyle(color: Colors.grey)),
                    onTap: () {
                      showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return Column(
                              children: [
                                SizedBox(
                                  height: 50.0,
                                ),
                                TextField(
                                  onChanged: (value) {
                                    label = value;
                                  },
                                ),
                                SizedBox(
                                  height: 20.0,
                                ),
                                ElevatedButton(
                                    onPressed: () {
                                      print(label);
                                      Navigator.pop(context);
                                    },
                                    child: Text("Add"))
                              ],
                            );
                          });
                    },
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
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
          );
        },
      ),
    );
  }

  // List<ListTile>? _buildLabelListTiles(BuildContext context) => (
  //   builder: (context, tile, _){
  //     return
  //   },
  // )

  // Stream<QuerySnapshot> _createS(BuildContext context) {
  //   final uid = Provider.of<User?>(context)?.uid;
  //   return FirebaseFirestore.instance
  //       .collection("notes-$uid")
  //       .doc("labels")
  //       .collection("notes-collection")
  //       .snapshots();
  // }

  Stream<List<ListTile>?> _createLabelStream(BuildContext context) {
    final uid = Provider.of<User?>(context)?.uid;
    return FirebaseFirestore.instance
        .collection("notes-$uid")
        .doc("labels")
        .collection("notes-collection")
        .snapshots()
        .map((snapshot) => _toListTileList(context, snapshot));
  }

  List<ListTile>? _toListTileList(BuildContext context, QuerySnapshot snapshot) {
    //print(snapshot.docs.toString());
    return snapshot.docs.map((e) => _toListTile(context, e)).toList();
  }

  ListTile _toListTile(BuildContext context, QueryDocumentSnapshot label) {
    return ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12.0),
        leading: Icon(
          Icons.label,
          color: (label.data()?['color'] == null)
              ? null
              : brighten(HexColor(hexColor: label.data()?['color']), 20),
        ),
        // tileColor: (label.data()?['color'] == null)
        //     ? null
        //     : darken(HexColor(hexColor: label.data()?['color']), 20),
        title: Text(
          label.data()?['name'],
          style: TextStyle(
            fontFamily: 'Roboto',
            color: (label.data()?['color'] == null)
                ? Colors.grey.shade200
                : brighten(HexColor(hexColor: label.data()?['color']), 20),
          ),
        ),
        onTap: () {
          print("${label.data()?['name']} label");
          // Provider.of<NoteService>(context).updateLabel(label.data()?['name']);
          _noteService.updateLabel(label: label.data()?['name'], color: label.data()?['color']);
          Navigator.pop(context);
        });
  }
}
