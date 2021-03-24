import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:file_picker_cross/file_picker_cross.dart';

import 'gen_room.dart';
import 'keyboard_shortcuts.dart';

class RoomEditor extends StatefulWidget {
  @override
  _RoomEditorState createState() => _RoomEditorState();
}

class _RoomEditorState extends State<RoomEditor> {
  String path;
  Room room = Room.fromRawJson(""" {"vertices":[],"edges":[],"pews":[]} """);
  List<String> histrory = [];

  String imagePath =
      '/home/forresthilton/Projects/flutter/stager_shell/user_files/Room Image.png';

  File file;
  double aspectratio;

  int selectedVertex;

  void editRoom(void Function() action) {
    histrory.add(room.toRawJson());
    setState(() {
      action();
    });
  }

  @override
  Widget build(BuildContext context) {
    load();
    return Scaffold(
        appBar: AppBar(
            title: Text("Room Editor"),
            backgroundColor: Colors.green,
            actions: <Widget>[
              RaisedButton(
                child: Text('Import'),
                onPressed: () {
                  setState(() {
                    // show a dialog to open a file
                    FilePickerCross.importFromStorage(type: FileTypeCross.any)
                        .then((value) {
                      this.path = value.path;
                      this.room =
                          Room.fromRawJson(File(path).readAsStringSync());
                    });
                  });
                },
              ),
              RaisedButton(
                child: Text('Remove'),
                onPressed: selectedVertex == null
                    ? null
                    : () {
                        editRoom(() {
                          room.vertices.removeAt(selectedVertex);
                          selectedVertex = null;
                        });
                      },
              )
            ]),
        body: KeyBoardShortcuts(shortcuts: [
          KeyBoardShortcut(
            keysToPress: {LogicalKeyboardKey.backspace},
            onKeysPressed: () {
              if (selectedVertex == null) {
                // TODO: Bell Sound
                return;
              }
              editRoom(() {
                room.vertices.removeAt(selectedVertex);
                selectedVertex = null;
              });
            },
            helpLabel: "Remove Selected Vertex",
          ),
          KeyBoardShortcut(
            keysToPress: {LogicalKeyboardKey.arrowUp},
            onKeysPressed: () {
              if (selectedVertex == null) return;
              editRoom(() {
                // TODO: bounding box
                // TODO: switch to pixel based
                room.vertices[selectedVertex].y += 0.002;
              });
            },
            helpLabel: "move selected vertex by height/500",
          ),
          KeyBoardShortcut(
            keysToPress: {LogicalKeyboardKey.arrowDown},
            onKeysPressed: () {
              if (selectedVertex == null) return;
              editRoom(() {
                room.vertices[selectedVertex].y -= 0.002;
              });
            },
            helpLabel: "move selected vertex by height/500",
          ),
          KeyBoardShortcut(
            keysToPress: {LogicalKeyboardKey.arrowRight},
            onKeysPressed: () {
              if (selectedVertex == null) return;
              editRoom(() {
                room.vertices[selectedVertex].x += 0.002;
              });
            },
            helpLabel: "move selected vertex by height/500",
          ),
          KeyBoardShortcut(
            keysToPress: {LogicalKeyboardKey.arrowLeft},
            onKeysPressed: () {
              if (selectedVertex == null) return;
              editRoom(() {
                room.vertices[selectedVertex].x -= 0.002;
              });
            },
            helpLabel: "move selected vertex by height/500",
          ),
          KeyBoardShortcut(
              keysToPress: {
                LogicalKeyboardKey.keyZ,
                LogicalKeyboardKey.control
              },
              onKeysPressed: () {
                setState(() {
                  //TODO: fix with sound null safety
                  this.room = Room.fromRawJson(histrory.last);
                });
                histrory.removeLast();
              },
              helpLabel: "undo (there is no redo)"),
        ], child: LayoutBuilder(builder: this._pageBody)));
  }

  void load() async {
    if (aspectratio != null) return;
    file = File(imagePath);
    final decoded = await decodeImageFromList(file.readAsBytesSync());

    this.setState(() {
      aspectratio = decoded.height / decoded.width;
    });
  }

  // rendering generally
  Widget _pageBody(BuildContext cxt, BoxConstraints cnts) {
    if (aspectratio == null) return Text('');
    final image = Image.file(file,
        height: cnts.maxHeight,
        width: cnts.maxWidth,
        key: Key('Forrest Hilton 2020 Dec 27'));

    double height;
    double width;
    double leftPading;
    double bottomPading;

    if (cnts.maxHeight > aspectratio * cnts.maxWidth) {
      // room on top
      height = aspectratio * cnts.maxWidth;
      width = cnts.maxWidth;
      bottomPading = (cnts.maxHeight - height) / 2;
      leftPading = 0;
    } else {
      //room on sides
      height = cnts.maxHeight;
      width = cnts.maxHeight / aspectratio;
      leftPading = (cnts.maxWidth - width) / 2;
      bottomPading = 0;
    }

    Vertex offsetToVertex(Offset position) {
      return Vertex(
        x: (position.dx - leftPading) / width,
        y: 1 - (position.dy - bottomPading) / height,
      );
    }

    final double vertexSizeInPixels = width / 80;
    final double dashSizeInPixels = width / 160;

    final vertex = Container(
      // TODO: change size to be screen dependent
      // TODO: fix colors
      width: vertexSizeInPixels,
      height: vertexSizeInPixels,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
        border: null,
      ),
    );

    final highlightedVertex = Container(
      // TODO: change size to be screen dependent
      // TODO: fix colors
      width: vertexSizeInPixels,
      height: vertexSizeInPixels,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
        border: Border.all(width: vertexSizeInPixels / 4, color: Colors.blue),
      ),
    );
    
    final dash = Container(
      // TODO: change size to be screen dependent
      // TODO: fix colors
      width: dashSizeInPixels,
      height: dashSizeInPixels,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
        border: null,
      ),
    );

    List<Positioned> edge(Edge info) {
      final a = room.vertices[info.a];
      final b = room.vertices[info.b];
      final dx = a.x - b.x;
      final dy = a.y - b.y;
      final distance = sqrt(dx * dx + dy * dy);
      final numberOfDots = (distance * 50).ceil();
      final stepx = dx / numberOfDots;
      final stepy = dy / numberOfDots;
      //hear a Vertex represents the position of a dot representing part of an edge
      final List<Vertex> positions = List.generate(numberOfDots, (i) => 1 + i)
          .map((i) => Vertex(x: b.x + stepx * i, y: b.y + stepy * i));
      return positions.map((r) {
        return Positioned(
            bottom: r.y * height + bottomPading - dashSizeInPixels / 2,
            left: r.x * width + leftPading - dashSizeInPixels / 2,
            child: 
            selectedVertex != null && r == room.vertices[selectedVertex]
            ? highlightedVertex
            : vertex);
      }).toList();
    }

    return Stack(
      children: [
            Positioned(
                child: GestureDetector(
                    onTapDown: (details) {
                      editRoom(() {
                        this
                            .room
                            .vertices
                            .add(offsetToVertex(details.localPosition));
                      });
                    },
                    child: image))
          ] +
          //TODO :edges
          room.vertices.map((r) {
            //TODO :Dragable
            return Positioned(
                bottom: r.y * height + bottomPading - vertexSizeInPixels / 2,
                left: r.x * width + leftPading - vertexSizeInPixels / 2,
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedVertex = room.vertices.indexOf(r);
                      });
                    },
                    child: selectedVertex != null &&
                            r == room.vertices[selectedVertex]
                        ? highlightedVertex
                        : vertex));
          }).toList(),
    );
  }
}
