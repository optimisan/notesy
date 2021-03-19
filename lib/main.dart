import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notesy/models/home_model.dart';
import 'package:notesy/routes.dart';
import 'package:notesy/screens/notes_page.dart';
import 'package:notesy/services/authentication.dart';
import 'package:notesy/services/note_service.dart';
import 'package:provider/provider.dart';
import 'screens/home_page.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationService>(
          create: (_) => AuthenticationService(FirebaseAuth.instance),
        ),
        StreamProvider<User?>(
            create: (context) => context.read<AuthenticationService>().authStateChanges,
            initialData: null),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Notesy',
        // theme: ThemeData.dark(),
        theme: ThemeData(
          textTheme: GoogleFonts.ubuntuTextTheme(
            Theme.of(context).textTheme,
          ),
          brightness: Brightness.dark,
        ),
        initialRoute: '/',
        onGenerateRoute: GenerateRoute.generateRoute,
        routes: <String, WidgetBuilder>{
          '/': (BuildContext context) => ChangeNotifierProvider(
                create: (context) => HomeModel(),
                child: AuthenticationWrapper(),
              ),
        },
        // routes: <String, WidgetBuilder>{
        //   '/': (BuildContext context) => ChangeNotifierProvider(
        //         create: (context) => HomeModel(),
        //         child: AuthenticationWrapper(),
        //       ),
        //   '/note-editor': (BuildContext context) => NoteEditor(),
        //   //'/note-viewer': (BuildContext context) => NoteViewPage(),
        // },
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();
    if (firebaseUser != null) {
      try {
        return ChangeNotifierProvider(create: (context) => NoteService(), child: NotesPage());
      } catch (e) {
        print(e);
        return Scaffold(body: SafeArea(child: Text("Hello")));
      }
    } else
      return HomePage();
  }
}
