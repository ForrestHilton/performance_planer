// Copyright 2021 Forrest Hilton; licensed under GPL-3.0-or-later; See COPYING.txt
import 'dart:core';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:provider/provider.dart';

import 'room_graph.dart';
import 'keyboard_shortcuts.dart';
import 'room_file.dart';

class Editor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Room Editor"),
            backgroundColor: Colors.green,
            actions: buttons(context.read<RoomEditorState>().ribbonActions())),
        body: KeyBoardShortcuts(
            shortcuts: context.read<RoomEditorState>().ribbonActions(),
            child: LayoutBuilder(builder: (context, cnts) {
              final roomFile = context.watch<RoomEditorState>().roomFile;

              if (!roomFile.isReady) return Text('');

              double height;
              double width;

              if (cnts.maxHeight > roomFile.aspectratio * cnts.maxWidth) {
                // room on top
                height = roomFile.aspectratio * cnts.maxWidth;
                width = cnts.maxWidth;
              } else {
                //room on sides
                height = cnts.maxHeight;
                width = cnts.maxHeight / roomFile.aspectratio;
              }

              return Center(
                  child: Container(
                      child: EditingRoomDisplay(width, height),
                      width: width,
                      height: height));
            })));
  }
}

class EditingRoomDisplay extends StatelessWidget {
  final double height;
  final double width;
  EditingRoomDisplay(this.width, this.height);

  @override
  Widget build(BuildContext context) {
    final image = Image.file(context.read<RoomEditorState>().roomFile.image,
        width: width, height: height, key: Key('Forrest Hilton 2020 Dec 27'));
    final room = context.watch<RoomEditorState>().room;
    final selectedVertices = context.watch<RoomEditorState>().selectedVertices;

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

    Positioned edge(Edge info) {
      final a = room.vertices[info.a];
      final b = room.vertices[info.b];
      final dx = width * (a.x - b.x);
      final dy = height * (a.y - b.y);
      final r = room.center([a, b]); // midpoint
      final distance = sqrt(dx * dx + dy * dy);
      final line = Transform.rotate(
        angle: room.angle(a, b, width, height),
        alignment: Alignment.center,
        child: Container(
            width: distance, color: Colors.green, height: dashSizeInPixels),
      );
      return Positioned(
        bottom: height * r.y - dashSizeInPixels/2, left: width * r.x - distance / 2, child: line);
    }

    final ret = Stack(
      children: [
            Positioned(
                child: GestureDetector(
                    onTapDown: (details) {
                      context.read<RoomEditorState>().addVertex(Point(
                          x: details.localPosition.dx / width,
                          y: 1 - details.localPosition.dy / height));
                    },
                    child: image))
          ] +
          // the next line maps the edge data to a list of dots then combines
          // these lists only if there are edges.
          room.edges.map(edge).toList() +
          room.vertices.map((r) {
            final i = room.vertices.indexOf(r);
            //TODO Dragable
            return Positioned(
                bottom: r.y * height - vertexSizeInPixels / 2,
                left: r.x * width - vertexSizeInPixels / 2,
                child: GestureDetector(
                    onTap: () {
                      context.read<RoomEditorState>().onClickVertex(i);
                    },
                    child: selectedVertices.contains(i)
                        ? highlightedVertex
                        : vertex));
          }).toList() +
          room.pews.map((pew) {
            Point center = room.center([pew.bl, pew.fl, pew.br, pew.fr]
                .map((i) => room.vertices[i])
                .toList());
            Point frontOfPew =
                room.center([room.vertices[pew.fr], room.vertices[pew.fr]]);
            final style = TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            );

            return Positioned(
              left: center.x * width - 100 / 2,
              bottom: center.y * height - 81 / 2,
              child: SizedBox(
                child: SizedBox(
                  child: Container(
                    color: Colors.white.withOpacity(.6),
                    width: 100,
                    height: 81,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("""\"${pew.name}\"
Width:${pew.width.toStringAsFixed(0)} ft
Rows:${pew.rows.toStringAsFixed(0)} """, style: style),
                        Row(
                          children: [
                            Text(
                              "Facing:",
                              style: style,
                            ),
                            Transform.rotate(
                              angle: room.angle(center, frontOfPew, width, height),
                              child: Icon(
                                Icons.arrow_forward,
                                color: Colors.red,
                                size: 18.0,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
    return ret;
  }
}

class RoomEditorState with ChangeNotifier, DiagnosticableTreeMixin {
  late Room room;
  late RoomFile roomFile;
  List<String> histrory = [];
  List<int> selectedVertices = [];

  void editRoom(void Function() action) {
    histrory.add(room.toRawJson());
    action();
    notifyListeners();
  }

  void onLoadOfAnotaitions() {
    room = roomFile.room;
    notifyListeners();
  }

  void onClickVertex(i) {
    if (selectedVertices.contains(i)) {
      selectedVertices.remove(i);
    } else {
      selectedVertices.add(i);
    }
    notifyListeners();
  }

  void addVertex(Point p) {
    editRoom(() {
      this.room.vertices.add(p);
    });
  }

  List<ActionDescription> ribbonActions() => [
        ActionDescription(
          name: "Save",
          helpDescription: "",
          keyBoardShortcut: {
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.keyS
          },
          function: roomFile.save,
        ),
        ActionDescription(
          name: "Import",
          helpDescription:
              "Import your image to annotate or a zip file save of an existing annotation",
          keyBoardShortcut: {
            LogicalKeyboardKey.control,
            LogicalKeyboardKey.keyO
          },
          function: roomFile.promptUserForPathAndCreate,
        ),
        ActionDescription(
            name: "Unselect",
            helpDescription: "clear the sellection",
            keyBoardShortcut: {LogicalKeyboardKey.escape},
            nullCondition: () => selectedVertices == [],
            function: () {
              selectedVertices = [];
              notifyListeners();
            }),
        ActionDescription(
          name: "Remove",
          helpDescription:
              "Remove all selected vertices and there edges and pews",
          keyBoardShortcut: {LogicalKeyboardKey.backspace},
          function: () {
            selectedVertices.sort((a, b) => b.compareTo(a));
            for (int index in selectedVertices) {
              room.pews.removeWhere(
                  (pew) => [pew.bl, pew.br, pew.fr, pew.fl].contains(index));
            }
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
              selectedVertices = [];
            });
          },
        ),
        ActionDescription(
          name: "Connect",
          helpDescription: "Connect two edges",
          keyBoardShortcut: {
            LogicalKeyboardKey.space,
            LogicalKeyboardKey.control
          },
          nullCondition: () => selectedVertices.length != 2,
          function: () {
            editRoom(() {
              if (selectedVertices.length == 2) {
                room.addEdge(
                    Edge(a: selectedVertices[0], b: selectedVertices[1]));
              }
            });
          },
        ),
        ActionDescription(
            name: "Form Pew",
            helpDescription: "",
            keyBoardShortcut: {
              LogicalKeyboardKey.control,
              LogicalKeyboardKey.keyP
            },
            nullCondition: () => selectedVertices.length != 4,
            function: () {
              // TODO: make corners appropriate order
              for (int indexInSelection = 0;
                  indexInSelection < 4;
                  indexInSelection++) {
                room.addEdge(Edge(
                    a: selectedVertices[indexInSelection],
                    b: selectedVertices[(indexInSelection + 1) % 4]));
              }
              room.pews.add(Pew(
                  name: 'Test',
                  width: 20,
                  rows: 12,
                  fl: selectedVertices[0],
                  fr: selectedVertices[1],
                  bl: selectedVertices[3],
                  br: selectedVertices[2]));
              notifyListeners();
            }),
        ActionDescription(
          helpDescription: "Move all selected vertices",
          keyBoardShortcut: {LogicalKeyboardKey.arrowUp},
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
        ActionDescription(
          helpDescription: "Move all selected vertices",
          keyBoardShortcut: {LogicalKeyboardKey.arrowDown},
          nullCondition: () => selectedVertices == [],
          function: () {
            editRoom(() {
              for (int index in selectedVertices) {
                room.vertices[index].y -= 0.002;
              }
            });
          },
        ),
        ActionDescription(
          helpDescription: "Move all selected vertices",
          keyBoardShortcut: {LogicalKeyboardKey.arrowRight},
          nullCondition: () => selectedVertices == [],
          function: () {
            editRoom(() {
              for (int index in selectedVertices) {
                room.vertices[index].x += 0.002;
              }
            });
          },
        ),
        ActionDescription(
          helpDescription: "Move all selected vertices",
          keyBoardShortcut: {LogicalKeyboardKey.arrowLeft},
          nullCondition: () => selectedVertices == [],
          function: () {
            editRoom(() {
              for (int index in selectedVertices) {
                room.vertices[index].x -= 0.002;
              }
            });
          },
        ),
        ActionDescription(
          name: "Undo",
          helpDescription: "Undo the last change",
          keyBoardShortcut: {
            LogicalKeyboardKey.keyZ,
            LogicalKeyboardKey.control
          },
          function: () {
            this.room = Room.fromRawJson(histrory.last);
            notifyListeners();
            histrory.removeLast();
          },
        ),
      ];

  @override
  RoomEditorState() {
    roomFile = RoomFile(notifyListeners, onLoadOfAnotaitions);
    roomFile.promptUserForPathAndCreate();
  }
}
