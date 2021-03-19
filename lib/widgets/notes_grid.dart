import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notesy/models/note_model.dart';
import 'package:notesy/widgets/note_card.dart';

class NotesStagGrid extends StatelessWidget {
  final List<Note?>? notes;
  final void Function(Note?) onTap;
  final int length;
  final int fit;
  final double padding;
  NotesStagGrid(
      {required this.notes,
      required this.onTap,
      required this.length,
      this.fit = 1,
      this.padding = 12});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      sliver: SliverStaggeredGrid.countBuilder(
          mainAxisSpacing: 20.0,
          crossAxisSpacing: 15.0,
          crossAxisCount: 2,
          staggeredTileBuilder: (index) => StaggeredTile.fit(fit),
          itemBuilder: (context, index) => InkWell(
                onTap: () => onTap.call(notes?[index]),
                child: NoteItem(note: notes![index]!),
              ),
          itemCount: length),
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
