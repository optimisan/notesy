import 'package:flutter/material.dart';
import 'package:notesy/models/note_model.dart';

import '../constants.dart';

/// A single item (preview of a Note) in the Notes list.
class NoteItem extends StatelessWidget {
  const NoteItem({
    Key? key,
    required this.note,
  }) : super(key: key);

  final Note note;

  @override
  Widget build(BuildContext context) => Hero(
        tag: 'NoteItem${note.id}',
        child: DefaultTextStyle(
          style: kNoteTextLight,
          child: Container(
            decoration: BoxDecoration(
              color: note.color == null ? kDefaultNoteColor : HexColor(hexColor: note.color!),
              borderRadius: BorderRadius.all(Radius.circular(8)),
              // border: note.color.value == 0xFFFFFFFF ? Border.all(color: kBorderColorLight) : null,
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (note.title?.isNotEmpty == true)
                  Text(
                    note.title!,
                    style: kCardTitleLight,
                    maxLines: 1,
                  ),
                if (note.title?.isNotEmpty == true) const SizedBox(height: 14),
                Flexible(
                  flex: 1,
                  child: Text(note.content ?? ''), // wrapping using a Flexible to avoid overflow
                ),
              ],
            ),
          ),
        ),
      );
}
// class NoteCard extends StatelessWidget {
//   final Note? note;
//   final String? title, content;
//   final String? color;
//   final void Function(Note?) onTap;
//   const NoteCard(
//       {Key? key,
//       this.title,
//       this.content,
//       this.color = "NULL",
//       required this.onTap,
//       required this.note})
//       : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: () => onTap.call(note),
//       child: Card(
//         color: color == "NULL" ? null : HexColor(hexColor: color!),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             if (title != null)
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   title!,
//                   style: const TextStyle(
//                     fontSize: 24.0,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             if (content != null)
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   content!,
//                   style: const TextStyle(
//                     fontSize: 16.0,
//                   ),
//                 ),
//               )
//           ],
//         ),
//       ),
//     );
//   }
// }

class HexColor extends Color {
  static int _getColorFromHex(String? hexColor) {
    if (hexColor == null) {
      return int.parse("444444", radix: 16);
    }
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor({final String hexColor = "F28C82"}) : super(_getColorFromHex(hexColor));
}
