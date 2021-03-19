import 'package:flutter/material.dart';
import 'package:notesy/screens/note_editor_page.dart';

class GenerateRoute {
  static Route? generateRoute(RouteSettings settings) {
    try {
      return _doGenerateRoute(settings);
    } catch (e, s) {
      debugPrint("failed to generate route for $settings: $e $s");
      return null;
    }
  }

  static Route? _doGenerateRoute(RouteSettings settings) {
    if (settings.name?.isNotEmpty != true) return null;

    final uri = Uri.parse(settings.name!);
    final path = uri.path;
    // final q = uri.queryParameters ?? <String, String>{};
    switch (path) {
      case '/note':
        {
          try {
            final note = (settings.arguments as Map)['note'];
            return _buildRoute(settings, (_) => NoteEditor(note: note));
          } catch (e) {
            return _buildRoute(settings, (_) => NoteEditor());
          }
        }
      default:
        return null;
    }
  }

  static Route _buildRoute(RouteSettings settings, WidgetBuilder builder) =>
      MaterialPageRoute<void>(
        settings: settings,
        builder: builder,
      );
}
