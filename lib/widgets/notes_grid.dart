import 'package:flutter/material.dart';
import 'package:notesy/models/note_model.dart';
// import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notesy/widgets/note_card.dart';

class DebugGrid extends StatelessWidget {
  // final length;
  // final List<Note?>? notes;
  // DebugGrid(this.length, this.notes);
  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      sliver: SliverGrid.count(
        crossAxisCount: 2,
        children: [
          Card(
            child: Text("Notesy "), //$length"),
          )
        ],
      ),
      // sliver: SliverGrid(
      //   delegate: SliverChildBuilderDelegate(
      //     (BuildContext context, int index) {
      //       return Card(
      //         child: Column(
      //           children: [
      //             Text(
      //                 "Notesy length: ${notes!.length} index: $index title: ${notes![index]!.title} Color: ${notes![index]!.color}"),
      //             NotesGrid._debugNoteItem(context, notes![index]),
      //           ],
      //         ),
      //       );
      //     },
      //     childCount: length,
      //   ),
      //   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
      //     maxCrossAxisExtent: 200.0,
      //     mainAxisSpacing: 10.0,
      //     crossAxisSpacing: 10.0,
      //     childAspectRatio: 1 / 1.2,
      //   ),
      // ),
    );
  }
}

class NotesGrid extends StatelessWidget {
  final List<Note?>? notes;
  final void Function(Note?) onTap;
  final int length;
  NotesGrid({required this.notes, required this.onTap, required this.length});

  @override
  Widget build(BuildContext context) => SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200.0,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
            childAspectRatio: 1 / 1.2,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) => _noteItem(context, notes![index]),
            childCount: length, //notes!.length,
          ),
        ),
      );
  static Widget _debugNoteItem(BuildContext context, Note? note) => InkWell(
        child: NoteItem(note: note!),
      );
  Widget _noteItem(BuildContext context, Note? note) => InkWell(
        onTap: () => onTap.call(note),
        child: NoteItem(note: note!),
      );
  //
  // @override
  // Widget build(BuildContext context) {
  //   return GridView.count(
  //     crossAxisCount: 2,
  //     children: notes
  //             ?.map<Widget>((e) => NoteCard(
  //                 note: e, title: e?.title, content: e?.content, color: e?.color, onTap: onTap))
  //             .toList() ??
  //         [Text("Add Notes here")],
  //   );
  // }
}
