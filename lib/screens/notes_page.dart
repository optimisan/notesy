import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notesy/widgets/note_card.dart' show HexColor;
import 'package:notesy/models/note_model.dart';
import 'package:notesy/services/note_service.dart';
import 'package:notesy/widgets/notes_grid.dart';
import 'package:notesy/widgets/side_bar.dart';
import 'package:provider/provider.dart';
import 'package:notesy/services/notifications_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../constants.dart';

const MethodChannel platform = MethodChannel('dexterx.dev/flutter_local_notifications_ex');

Future<void> _configureLocalTimeZone() async {
  tz.initializeTimeZones();
  final String timeZoneName = await platform.invokeMethod('getTimeZoneName');
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  bool _listView = false;
  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    var androidInit = AndroidInitializationSettings('ic_launcher');
    var initSetting = InitializationSettings(android: androidInit);
    flutterLocalNotificationsPlugin.initialize(initSetting,
        onSelectNotification: NotificationHelper.notificationSelected);
  }

  Future<dynamic>? _showNotification() async {
    var androidDetails = AndroidNotificationDetails(
        "channelId", "channelName", "channelDescription",
        importance: Importance.high);
    var generalNotificationDetails = NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(0, "title", "body", generalNotificationDetails);
  }

  @override
  Widget build(BuildContext context) {
    try {
      //return StreamProvider<List<Note?>?>.value(
      return MultiProvider(
        providers: [
          StreamProvider<List<Note?>?>.value(
              value: Provider.of<NoteService>(context).createNoteStream(context), initialData: []),
          // ChangeNotifierProvider<NoteService>(create: (context) => NoteService()),
        ],
        //   child: StreamProvider<List<Note?>?>.value(
        // value: Provider.of<NoteService>(context).createNoteStream(context),
        // initialData: [],
        child: Consumer<NoteService>(
          builder: (_, noteService, __) {
            return Scaffold(
              backgroundColor: Color(0xFF1f1d2b),
              key: _scaffoldKey,
              drawer: SideBarDrawer(),
              // appBar: _customAppBar(noteService),
              floatingActionButton: FloatingActionButton(
                backgroundColor: (noteService.labelColor == null)
                    ? Color(0xFF6f6fc8)
                    : HexColor(hexColor: noteService.labelColor!),
                child: const Icon(
                  Icons.add,
                  size: 30,
                  color: kBorderColorLight,
                ),
                onPressed: () {
                  NotificationHelper.showNotification(flutterLocalNotificationsPlugin);
                  // _showNotification();
                  Navigator.pushNamed(context, '/note');
                },
              ),
              //body: _buildNotesView(context),
              body: CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: <Widget>[
                  // a floating appbar
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    backgroundColor: (noteService.labelColor == null)
                        ? null
                        : HexColor(hexColor: noteService.labelColor!),
                    // title: _topActions(context),
                    title: _topAppBar(context, noteService),
                    automaticallyImplyLeading: false,
                    centerTitle: true,
                    titleSpacing: 0,
                    // backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
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
            );
          },
        ),
      );
    } catch (e) {
      print(e);
      return Scaffold();
    }
  }

  Widget _topAppBar(BuildContext context, NoteService noteService) => Row(
        children: [
          SizedBox(width: 20.0),
          InkWell(
            child: const Icon(
              Icons.menu,
              size: 30.0,
            ),
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              noteService.labelInUse ?? 'Notesy',
              softWrap: false,
              style: GoogleFonts.ubuntu(
                color: noteService.labelInUse == null ? Color(0xFFb0b0B0) : Color(0xFFFEFEFE),
                fontSize: 22,
              ),
            ),
          ),
          const SizedBox(width: 16),
          InkWell(
            child: Icon(Icons.search),
          ),
          const SizedBox(width: 16),
          InkWell(
            child: Icon(_listView ? Icons.view_agenda : Icons.grid_view),
            onTap: () => setState(() {
              _listView = !_listView;
            }),
          ),
          const SizedBox(width: 16),
        ],
      );

  Consumer<List<Note?>?> _buildNotesView(BuildContext context) => Consumer<List<Note?>?>(
        builder: (context, notes, _) {
          print("building notes view");

          if (notes!.isNotEmpty != true) {
            //return DebugGrid(notes?.length, notes);
          }
          if (!_listView) {
            return NotesStagGrid(
              notes: notes,
              onTap: _onNoteTap,
              length: notes.length,
              // onTap: (note) async {
              //   Navigator.of(context).push(
              //     MaterialPageRoute(
              //       builder: (context) => NoteViewPage(note: note),
              //     ),
              //   );
              // },
            );
          } else
            return NotesStagGrid(
              notes: notes,
              onTap: _onNoteTap,
              length: notes.length,
              fit: 2,
              padding: 18,
              // onTap: (note) async {
              //   Navigator.of(context).push(
              //     MaterialPageRoute(
              //       builder: (context) => NoteViewPage(note: note),
              //     ),
              //   );
              // },
            );
          //final widget = !_listView ? NotesGrid() : NotesViewList();
          //return widget(notes: notes, onTap: (_) {});
        },
      );

  void _onNoteTap(Note? note) async {
    Navigator.pushNamed(context, '/note', arguments: {'note': note});
  }

  AppBar _customAppBar(NoteService noteService) {
    return AppBar(
      title: Text(noteService.labelInUse ?? 'Notesy'),
    );
  }
}

//.collection("notes-2U9ZKxo3VAbtqVVCVTtT4nmPWfa2")
// .orderBy("modifiedAt", "asc")
/// Creates the notes query
Stream<List<Note?>?> _createNoteStream(BuildContext context) {
  final uid = context.watch<User?>()?.uid; //Provider.of<User?>(context)?.data?.uid;
  //sample hello2@gmail.com is "2U9ZKxo3VAbtqVVCVTtT4nmPWfa2";

  return FirebaseFirestore.instance
      .collection('notes-$uid')
      .orderBy("createdAt", descending: true)
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
