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
  late String path;
  Room room = Room.fromRawJson(""" {"vertices":[{"x":0.5,"y":0.3},{"x":0.5,"y":0.2}],"edges":[{"a":0,"b":1}],"pews":[]} """);
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
    load();
    return Scaffold(
        appBar: AppBar(
            title: Text("Room Editor"),
            backgroundColor: Colors.green,
            actions: <Widget>[
              ElevatedButton(
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
              ElevatedButton(
                child: Text('Remove'),
                onPressed: selectedVertices == []
                    ? null
                    : () {
                        editRoom(() {
                          print("check point 1");
                          for (final edge in room.edges) {
                            if (selectedVertices.contains(edge.a) |
                                selectedVertices.contains(edge.b)) {
                              room.edges.remove(edge);
                            }
                          }
                          for (final index in selectedVertices) {
                            room.vertices.remove(index);
                          }
                          selectedVertices = [];
                          print("check point 2");
                        });
                      },
              ),
              ElevatedButton(
                child: Text('Connect'),
                onPressed: selectedVertices == []
                    ? null
                    : () {
                        editRoom(() {
                          if (selectedVertices.length == 2) {
                            room.edges.add(Edge(
                                a: selectedVertices[0],
                                b: selectedVertices[1]));
                          }
                        });
                      },
              )
            ]),
        body: KeyBoardShortcuts(shortcuts: [
          KeyBoardShortcut(
            keysToPress: {LogicalKeyboardKey.arrowUp},
            onKeysPressed: () {
              editRoom(() {
                // TODO: bounding box
                for (int index in selectedVertices) {
                  room.vertices[index].y += 0.002;
                }
              });
            },
            helpLabel: "move selected vertex by height/500",
          ),
          KeyBoardShortcut(
            keysToPress: {LogicalKeyboardKey.arrowDown},
            onKeysPressed: () {
              editRoom(() {
                for (int index in selectedVertices) {
                  room.vertices[index].y -= 0.002;
                }
              });
            },
            helpLabel: "move selected vertex by height/500",
          ),
          KeyBoardShortcut(
            keysToPress: {LogicalKeyboardKey.arrowRight},
            onKeysPressed: () {
              editRoom(() {
                for (int index in selectedVertices) {
                  room.vertices[index].x += 0.002;
                }
              });
            },
            helpLabel: "move selected vertex by height/500",
          ),
          KeyBoardShortcut(
            keysToPress: {LogicalKeyboardKey.arrowLeft},
            onKeysPressed: () {
              editRoom(() {
                for (int index in selectedVertices) {
                  room.vertices[index].x -= 0.002;
                }
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
      final a = room.vertices[info.a!];
      final b = room.vertices[info.b!];
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

    print("checkpoint 3");
    print(room.toRawJson());
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
              : room.edges.map((e) {
                  return edge(e);
                }).reduce((a, b) => a + b)) +
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
    print("checkpoint 4");
    return ret;
  }
}
