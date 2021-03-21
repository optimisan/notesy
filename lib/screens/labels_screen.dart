import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:notesy/services/note_service.dart';
import 'package:notesy/widgets/note_card.dart';
import 'package:provider/provider.dart';

class LabelScreen extends StatefulWidget {
  @override
  _LabelScreenState createState() => _LabelScreenState();
}

class _LabelScreenState extends State<LabelScreen> {
  var textController = TextEditingController();
  var colorController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<User?>(context)?.uid;
    return StreamProvider<List<Label?>?>.value(
      value: Provider.of<NoteService>(context).createLabelStream(context),
      initialData: [],
      child: Consumer<List<Label?>?>(
        builder: (_, labelList, __) {
          print("Building labels list");
          return Scaffold(
            appBar: AppBar(
              titleTextStyle: const TextStyle(
                fontSize: 20,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
              title: Text("Edit Labels"),
              leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // mainAxisAlignment: labelList != null && labelList.length > 14
                //     ? MainAxisAlignment.spaceBetween
                //     : MainAxisAlignment.start,
                children: [
                  // InkWell(
                  //   onTap: () {
                  //     _addNewLabelDialog(context);
                  //   },
                  //   child: Padding(
                  //     padding: const EdgeInsets.symmetric(vertical: 8.0),
                  //     child: Row(
                  //       mainAxisSize: MainAxisSize.max,
                  //       children: [
                  //         Icon(
                  //           Icons.add_rounded,
                  //           color: const Color(0xFFFEFEFE),
                  //         ),
                  //         SizedBox(width: 24.0),
                  //         Text(
                  //           "Add a label",
                  //           style: TextStyle(color: const Color(0xFFFEFEFE), fontSize: 20.0),
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                  ListTile(
                    leading: Icon(Icons.add),
                    onTap: () {
                      _addNewLabelDialog(context);
                    },
                    title: Text(
                      "Add a new Label",
                      style: TextStyle(color: const Color(0xFFFEFEFE), fontSize: 20.0),
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final label = labelList?[index];
                      print(index.toString());
                      return Dismissible(
                        background: Container(color: Colors.red),
                        key: Key(label!.id),
                        resizeDuration: Duration(milliseconds: 200),
                        onDismissed: (direction) {
                          setState(() {
                            labelList?.remove(label);
                          });
                          label.deleteLabelFromFireStore(context);
                        },
                        child: ListTile(
                          onTap: () {},
                          leading: Icon(
                            Icons.label,
                            color: label.color == null
                                ? const Color(0xFFFEFEFE)
                                : HexColor(hexColor: label.color!),
                          ),
                          title: Text(
                            label.name,
                            style: TextStyle(
                              color: label.color == null
                                  ? const Color(0xFFFEFEFE)
                                  : HexColor(hexColor: label.color!),
                            ),
                          ),
                          trailing: Icon(
                            Icons.create,
                          ),
                        ),
                      );
                    },
                    itemCount: labelList?.length,
                  ),
                  Center(
                    child: Text(
                      "Swipe to delete a label",
                      style: TextStyle(
                        color: const Color(0xFFFEFEFE),
                        fontSize: 16.0,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _addNewLabelDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            titleTextStyle: const TextStyle(color: const Color(0xFFFEFEFE), fontSize: 20.0),
            title: Text("Add Label"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20.0),
                  TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Label Name',
                      fillColor: Colors.grey,
                      focusColor: Colors.grey.shade600,
                      border: InputBorder.none,
                      counter: const SizedBox(),
                    ),
                    maxLines: 1,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      color: const Color(0xFFFEFEFE),
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  TextField(
                    controller: colorController,
                    decoration: InputDecoration(
                      hintText: 'Color in HEX. I\'m lazy to add a color picker',
                      fillColor: Colors.grey,
                      focusColor: Colors.grey.shade600,
                      border: InputBorder.none,
                      counter: const SizedBox(),
                    ),
                    maxLines: 1,
                    textCapitalization: TextCapitalization.words,
                    style: const TextStyle(
                      color: const Color(0xFFFEFEFE),
                      fontSize: 16.0,
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        var name = textController.text.trim();
                        var color = colorController.text.trim();
                        if (name != '') {
                          await Label.addNewLabelToFireStore(
                              context, name, color == '' ? null : color);
                          Navigator.pop(context);
                        }
                      },
                      child: Text("Save"))
                ],
              ),
            ));
      },
    );
  }
}
