import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'room_editor_state.dart';
import '../models/room_graph.dart';

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
          bottom: height * r.y - dashSizeInPixels / 2,
          left: width * r.x - distance / 2,
          child: line);
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
                room.center([room.vertices[pew.fr], room.vertices[pew.fl]]);
            final style = TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            );

            return Positioned(
              left: center.x * width - 100 / 2,
              bottom: center.y * height - 81 / 2,
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
            );
          }).toList(),
    );
    return ret;
  }
}