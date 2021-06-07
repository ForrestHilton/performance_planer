// Copyright 2021 Forrest Hilton; licensed under GPL-3.0-or-later; See COPYING.txt
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import '../services/keyboard_shortcuts.dart';
import 'room_editor_state.dart';
import 'room_editing_display.dart';

// full page widget
class Editor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<RoomEditorState>();
    List<ActionDescription> ribbonActions = [
      ActionDescription(
        name: "Save",
        helpDescription: "",
        keyBoardShortcut: {LogicalKeyboardKey.control, LogicalKeyboardKey.keyS},
        function: state.roomFile.save,
      ),
      ActionDescription(
        name: "Import",
        helpDescription:
            "Import your image to annotate or a zip file save of an existing annotation",
        keyBoardShortcut: {LogicalKeyboardKey.control, LogicalKeyboardKey.keyO},
        function: state.roomFile.promptUserForPathAndCreate,
      ),
      ActionDescription(
          name: "Unselect",
          helpDescription: "clear the sellection",
          keyBoardShortcut: {LogicalKeyboardKey.escape},
          nullCondition: () => state.selectedVertices == [],
          function: state.clearSelection),
      ActionDescription(
        name: "Remove",
        helpDescription:
            "Remove all selected vertices and there edges and pews",
        keyBoardShortcut: {LogicalKeyboardKey.backspace},
        function: state.remove,
      ),
      ActionDescription(
        name: "Connect",
        helpDescription: "Connect two edges",
        keyBoardShortcut: {
          LogicalKeyboardKey.space,
          LogicalKeyboardKey.control
        },
        nullCondition: () => state.selectedVertices.length != 2,
        function: state.connect,
      ),
      ActionDescription(
          name: "Form Pew",
          helpDescription: "",
          keyBoardShortcut: {
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.keyP
          },
          nullCondition: () => state.selectedVertices.length != 4,
          function: state.formPew),
      ActionDescription(
        name: "Undo",
        helpDescription: "Undo the last change",
        keyBoardShortcut: {LogicalKeyboardKey.keyZ, LogicalKeyboardKey.control},
        function: state.undo,
      ),
    ];

    final appBar = AppBar(
      title: Text("Room Editor"),
      backgroundColor: Colors.green,
      actions: buttons(ribbonActions));

    return Scaffold(
        appBar: appBar,
        body: KeyBoardShortcuts(
            shortcuts: ribbonActions,
            child: LayoutBuilder(builder: (context, cnts) {
              final roomFile = context.watch<RoomEditorState>().roomFile;

              if (!roomFile.isReady) return Text('');

              // manual padding and sizing of the room display based on its images aspect ratio
              double height;
              double width;

              if (cnts.maxHeight > roomFile.aspectRatio * cnts.maxWidth) {
                // room on top
                height = roomFile.aspectRatio * cnts.maxWidth;
                width = cnts.maxWidth;
              } else {
                //room on sides
                height = cnts.maxHeight;
                width = cnts.maxHeight / roomFile.aspectRatio;
              }

              return Center(
                  child: Container(
                    child: EditingRoomDisplay(width, height),
                      width: width,
                      height: height));
            })));
  }
}
