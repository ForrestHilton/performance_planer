import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';

import 'room_graph.dart';
import 'room_file.dart';

class RoomRender extends StatefulWidget {
  final late List<int> highlightedVertices;
  RoomRender({required this.highlightedVertices});

  @override
  _RoomRenderState createState() => _RoomRenderState();
}

class _RoomRenderState extends State<RoomRender> {
  late Room room;
  late RoomFile roomFile;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return LayoutBuilder(builder: this._pageBody);
  }

  Widget _pageBody(BuildContext cxt, BoxConstraints cnts) {
    if (!roomFile.isReady) return Text('');
    final image = Image.file(roomFile.image,
        height: cnts.maxHeight,
        width: cnts.maxWidth,
        key: Key('Forrest Hilton 2020 Dec 27'));

    double height;
    double width;
    double leftPading;
    double bottomPading;

    if (cnts.maxHeight > roomFile.aspectratio * cnts.maxWidth) {
      // room on top
      height = roomFile.aspectratio * cnts.maxWidth;
      width = cnts.maxWidth;
      bottomPading = (cnts.maxHeight - height) / 2;
      leftPading = 0;
    } else {
      //room on sides
      height = cnts.maxHeight;
      width = cnts.maxHeight / roomFile.aspectratio;
      leftPading = (cnts.maxWidth - width) / 2;
      bottomPading = 0;
    }

    Point offsetToVertex(Offset position) {
      return Point(
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
      final List<Point> positions = List.generate(numberOfDots, (j) {
        int i = j + 1;
        return Point(x: b.x + stepx * i, y: b.y + stepy * i);
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
          (room.edges.isEmpty
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
          }).toList() +
          room.pews.map((pew) {
            Point center = room.center(pew);
            Line frontRow = room.line(Edge(a: pew.fl, b: pew.fr));
            double mPerpendicular = -1 / frontRow.m;
            bool faceingLeft =
                (room.vertices[pew.fl].x + room.vertices[pew.fr].x) / 2 <
                    center.x;
            final style = TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            );

            return Positioned(
              left: center.x * width + leftPading - 100 / 2,
              bottom: center.y * height + bottomPading - 81 / 2,
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
                              angle: -atan(mPerpendicular) +
                                  (faceingLeft ? pi : 0),
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
