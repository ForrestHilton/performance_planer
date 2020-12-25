import 'dart:core';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:file_picker_cross/file_picker_cross.dart';

import 'gen_room.dart';

class RoomEditor extends StatefulWidget {
  @override
  _RoomEditorState createState() => _RoomEditorState();
}

class _RoomEditorState extends State<RoomEditor> {
  Room room = Room.fromRawJson(
      """ {"vertices":[{"x":1.0,"y":0.0},{"x":1.0,"y":1.0},{"x":0.0,"y":1.0},{"x":0.0,"y":0.0}],"edges":[],"pews":[]} """);
  String path;

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
            ]),
        body: LayoutBuilder(builder: this._pageBody));
  }

  String imagePath = '/home/forrest/Projects/stager/Room Image.png';
  File file;
  double aspectratio;

  void load() async {
    file = File(imagePath);
    final decoded = await decodeImageFromList(file.readAsBytesSync());

    this.setState(() {
      aspectratio = decoded.height / decoded.width;
    });
  }

  // rendering generally
  Widget _pageBody(BuildContext cxt, BoxConstraints cnts) {
    if (aspectratio == null) return Text('');
    final image =
        Image.file(file, height: cnts.maxHeight, width: cnts.maxWidth);

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

    return Stack(
      children: [
        Positioned(
          child: GestureDetector(
            onTapUp: (details) {
              this
              .room
              .vertices
              .add(offsetToVertex(details.localPosition));
            },
            child: image))
      ] +
      room.vertices.map((r) {
          return Positioned(
            bottom: r.y * height + bottomPading - 5,
            left: r.x * width + leftPading - 5,
            child: GestureDetector(
/*              onTap: () {
                setState(() {
//                    selectedVertex = room.vertices.indexOf(r);
                });
              }, */
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  border: r == room.vertices[selectedVertex] ? null : Border.all(),
                ),
          )));
      }).toList(),
    );
  }
    
  int selectedVertex;
}
