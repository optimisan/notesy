import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:notesy/models/note_model.dart';

final Color darkBlue = const Color.fromARGB(255, 18, 32, 47);

class TextFieldColorizer extends TextEditingController {
  final Map<String, TextStyle> map;
  final Pattern pattern;

  TextFieldColorizer(this.map, {String? text})
      : pattern = RegExp(
            map.keys.map((key) {
              return key;
            }).join('|'),
            multiLine: true),
        super(text: text);

  @override
  set text(String newText) {
    value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
      composing: TextRange.empty,
    );
  }

  @override
  TextSpan buildTextSpan({TextStyle? style, bool? withComposing}) {
    final List<InlineSpan> children = [];
    String? patternMatched;
    String? formatText;
    TextStyle? myStyle;
    text.splitMapJoin(
      pattern,
      onMatch: (Match match) {
        myStyle = map[match[0]] ??
            map[map.keys.firstWhere(
              (e) {
                bool ret = false;
                RegExp(e).allMatches(text)
                  ..forEach((element) {
                    if (element.group(0) == match[0]) {
                      patternMatched = e;
                      ret = true;
                      // return true;
                    }
                  });
                return ret;
              },
            )];
        if (patternMatched == r"#.\w+") {
          formatText = match[0];
        } else if (patternMatched == r"_(.*?)\_") {
          formatText = match[0]?.replaceAll("_", " ");
        } else if (patternMatched == r'\*(.*?)\*') {
          formatText = match[0]?.replaceAll("*", " ");
        } else if (patternMatched == "~(.*?)~") {
          formatText = match[0]?.replaceAll("~", " ");
        } else if (patternMatched == r'```(.*?)```') {
          formatText = match[0]?.replaceAll("```", "   ");
        } else if (patternMatched == r'@big.\w+') {
          formatText = match[0]?.replaceAll("@big", "");
        } else {
          formatText = match[0];
        }
        children.add(TextSpan(
          text: formatText,
          style: style?.merge(myStyle),
        ));
        return "";
      },
      onNonMatch: (String text) {
        children.add(TextSpan(text: text, style: style));
        return "";
      },
    );

    return TextSpan(style: style, children: children);
  }
}

class AddLabel {
  static void withThis(String name, Note note) {
    RegExp regExp = RegExp(
      r"#.\w+ ",
      caseSensitive: false,
      multiLine: false,
    );
    print("${note.foundLabels}");
    final match = regExp.allMatches(name).last.group(0);
    // final match = regExp.firstMatch(name)?[note.foundLabels];
    print(match);
    if (match != null) note.addToLabels(match);
  }
}

final Map<String, TextStyle> colorControlMap = {
  r"#.\w+": TextStyle(color: Colors.blue, shadows: kElevationToShadow[2]),
  r'\bred\b': const TextStyle(color: Colors.red),
  'green': TextStyle(color: Colors.green, shadows: kElevationToShadow[2]),
  'purple': TextStyle(color: Colors.purple, shadows: kElevationToShadow[2]),
  r'_(.*?)\_': TextStyle(fontStyle: FontStyle.italic, shadows: kElevationToShadow[2]),
  '~(.*?)~': TextStyle(decoration: TextDecoration.lineThrough, shadows: kElevationToShadow[2]),
  r'\*(.*?)\*': TextStyle(fontWeight: FontWeight.bold, shadows: kElevationToShadow[2]),
  r'```(.*?)```': TextStyle(
      color: Colors.yellow,
      fontFeatures: [const FontFeature.tabularFigures()],
      shadows: kElevationToShadow[2]),
  r'@big.\w+': TextStyle(fontSize: 20.0),
};
//
// final TextEditingController coloredController = TextFieldColorizer(
//   {
//     r"@.\w+": TextStyle(color: Colors.blue, shadows: kElevationToShadow[2]),
//     'red': const TextStyle(color: Colors.red, decoration: TextDecoration.underline),
//     'green': TextStyle(color: Colors.green, shadows: kElevationToShadow[2]),
//     'purple': TextStyle(color: Colors.purple, shadows: kElevationToShadow[2]),
//     r'_(.*?)\_': TextStyle(fontStyle: FontStyle.italic, shadows: kElevationToShadow[2]),
//     '~(.*?)~': TextStyle(decoration: TextDecoration.lineThrough, shadows: kElevationToShadow[2]),
//     r'\*(.*?)\*': TextStyle(fontWeight: FontWeight.bold, shadows: kElevationToShadow[2]),
//     r'```(.*?)```': TextStyle(
//         color: Colors.yellow,
//         fontFeatures: [const FontFeature.tabularFigures()],
//         shadows: kElevationToShadow[2]),
//   },
// );
