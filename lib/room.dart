// Copyright 2021 Forrest Hilton; licensed under GPL-3.0-or-later; See COPYING.txt
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:file_picker/file_picker.dart';

import 'gen_room.dart';
import 'keyboard_shortcuts.dart';

class Action {
  Action(
      {this.name,
      required this.description,
      this.nullCondition,
      required this.function,
      required this.shortcut});
  final String? name;
  final String description;
  final bool Function()? nullCondition;
  final VoidCallback function;
  final Set<LogicalKeyboardKey> shortcut;
}

class RoomEditor extends StatefulWidget {
  @override
  _RoomEditorState createState() => _RoomEditorState();
}

class _RoomEditorState extends State<RoomEditor> {
  late String path;
  Room room = Room.fromRawJson(
      """ {"vertices":[{"x":0.5,"y":0.3},{"x":0.5,"y":0.2}],"edges":[{"a":0,"b":1}],"pews":[]} """);
  List<String> histrory = [];

  String imagePath =
      '/home/forresthilton/Projects/flutter/stager_shell/user_files/Room Image.png';

  late File file;
  double? aspectratio;

  List<int> selectedVertices = [];

  void editRoom(void Function() action) {
    histrory.add(room.toRawJson());
    setState(() {
      action();
    });
  }

  @override
  Widget build(BuildContext context) {
    loadImage();
    List<Action> ribbonActions = [
      Action(
        name: "Import",
        description: "Import your image or a zip file saving your edit",
        shortcut: {LogicalKeyboardKey.control, LogicalKeyboardKey.keyO},
        function: () {
          setState(() {
            // show a dialog to open a file
            FilePicker.platform.pickFiles(type: FileType.any).then((value) {
              if (value == null) {
                return;
              }
              this.path = value.paths[0]!;
              this.room = Room.fromRawJson(File(path).readAsStringSync());
            });
          });
        },
      ),
      Action(
        name: "Remove",
        description: "Remove all selected vertices and there nodes",
        shortcut: {LogicalKeyboardKey.backspace},
        function: () {
          selectedVertices.sort((a, b) => b.compareTo(a));
          List<Edge> newEdges = [];
          OUTER:
          for (final edge in room.edges) {
            List<int> newEdgeIndices = [];
            for (int endIndex in [edge.a, edge.b]) {
              if (selectedVertices.contains(endIndex)) {
                continue OUTER;
              }
              int decrementBy = 0;
              for (int selected in selectedVertices) {
                if (selected < endIndex) {
                  decrementBy += 1;
                } else {
                  break;
                }
              }
              print(decrementBy);
              endIndex -= decrementBy;
              newEdgeIndices.add(endIndex);
            }
            newEdges.add(Edge(a: newEdgeIndices[0], b: newEdgeIndices[1]));
          }
          editRoom(() {
            room.edges = newEdges;

            for (final index in selectedVertices) {
              room.vertices.removeAt(index);
            }
            print(room.toRawJson());
            selectedVertices = [];
          });
        },
      ),
      Action(
        name: "Connect",
        description: "Connect two edges",
        shortcut: {LogicalKeyboardKey.space, LogicalKeyboardKey.control},
        nullCondition: () => selectedVertices.length != 2,
        function: () {
          editRoom(() {
            if (selectedVertices.length == 2) {
              room.edges
                  .add(Edge(a: selectedVertices[0], b: selectedVertices[1]));
            }
          });
        },
      ),
      Action(
        description: "Move all selected vertices",
        shortcut: {LogicalKeyboardKey.arrowUp},
        nullCondition: () => selectedVertices == [],
        function: () {
          editRoom(() {
            // TODO: bounding box
            for (int index in selectedVertices) {
              room.vertices[index].y += 0.002;
            }
          });
        },
      ),
      Action(
        description: "Move all selected vertices",
        shortcut: {LogicalKeyboardKey.arrowDown},
        nullCondition: () => selectedVertices == [],
        function: () {
          editRoom(() {
            for (int index in selectedVertices) {
              room.vertices[index].y -= 0.002;
            }
          });
        },
      ),
      Action(
        description: "Move all selected vertices",
        shortcut: {LogicalKeyboardKey.arrowRight},
        nullCondition: () => selectedVertices == [],
        function: () {
          editRoom(() {
            for (int index in selectedVertices) {
              room.vertices[index].x += 0.002;
            }
          });
        },
      ),
      Action(
        description: "Move all selected vertices",
        shortcut: {LogicalKeyboardKey.arrowLeft},
        nullCondition: () => selectedVertices == [],
        function: () {
          editRoom(() {
            for (int index in selectedVertices) {
              room.vertices[index].x -= 0.002;
            }
          });
        },
      ),
      Action(
        name: "Undo",
        description: "Undo the last change",
        shortcut: {LogicalKeyboardKey.keyZ, LogicalKeyboardKey.control},
        function: () {
          setState(() {
            this.room = Room.fromRawJson(histrory.last);
          });
          histrory.removeLast();
        },
      ),
    ];
    final shortcuts = ribbonActions
        .map((actionDescription) => KeyBoardShortcut(
            onKeysPressed: actionDescription.function,
            keysToPress: actionDescription.shortcut,
            helpLabel: actionDescription.description))
        .toList();
    ribbonActions.removeWhere((description) => description.name == null);
    final buttons = ribbonActions
        .map((description) => ElevatedButton(
            onPressed: (description.nullCondition != null && description.nullCondition!()) ? null : description.function, child: Text(description.name!)))
        .toList();

    return Scaffold(
        appBar: AppBar(
            title: Text("Room Editor"),
            backgroundColor: Colors.green,
            actions: buttons),
        body: KeyBoardShortcuts(
            shortcuts: shortcuts,
            child: LayoutBuilder(builder: this._pageBody)));
  }

  void loadImage() async {
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

    if (cnts.maxHeight > aspectratio! * cnts.maxWidth) {
      // room on top
      height = aspectratio! * cnts.maxWidth;
      width = cnts.maxWidth;
      bottomPading = (cnts.maxHeight - height) / 2;
      leftPading = 0;
    } else {
      //room on sides
      height = cnts.maxHeight;
      width = cnts.maxHeight / aspectratio!;
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
    final double dashSizeInPixels = width / 220;

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
        color: Colors.green,
        border: null,
      ),
    );

    List<Positioned> edge(Edge info) {
      final a = room.vertices[info.a];
      final b = room.vertices[info.b];
      final dx = a.x - b.x;
      final dy = a.y - b.y;
      final distance = sqrt(dx * dx + dy * dy);
      final numberOfDots = (distance * 1000).ceil();
      final stepx = dx / numberOfDots;
      final stepy = dy / numberOfDots;
      //hear a Vertex represents the position of a dot representing part of an edge
      final List<Vertex> positions = List.generate(numberOfDots, (j) {
        int i = j + 1;
        return Vertex(x: b.x + stepx * i, y: b.y + stepy * i);
      });
      return positions.map((r) {
        return Positioned(
            bottom: r.y * height + bottomPading - dashSizeInPixels / 2,
            left: r.x * width + leftPading - dashSizeInPixels / 2,
            child: dash);
      }).toList();
    }

    final ret = Stack(
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
          // the next line maps the edge data to a list of dots then combines
          // these lists only if there are edges.
          (room.edges == []
              ? []
              : (room.edges.map((e) {
                  return edge(e);
                }).reduce((a, b) => a + b))) +
          room.vertices.map((r) {
            final i = room.vertices.indexOf(r);
            //TODO Dragable
            return Positioned(
                bottom: r.y * height + bottomPading - vertexSizeInPixels / 2,
                left: r.x * width + leftPading - vertexSizeInPixels / 2,
                child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (selectedVertices.contains(i)) {
                          selectedVertices.remove(i);
                        } else {
                          selectedVertices.add(i);
                        }
                      });
                    },
                    child: selectedVertices.contains(i)
                        ? highlightedVertex
                        : vertex));
          }).toList(),
    );
    return ret;
  }
}
