// Copyright 2021 Forrest Hilton; licensed under GPL-3.0-or-later; See COPYING.txt
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:performance_planer/room_editor/pew_editor.dart';
import 'package:provider/provider.dart';
import 'room_editor_state.dart';
import '../models/room_graph.dart';
import 'package:polygon_clipper/polygon_clipper.dart';


class EditingRoomDisplay extends StatelessWidget {
  final double height;
  final double width;
  EditingRoomDisplay(this.width, this.height);

  double get vertexSizeInPixels => width / 80;
  double get dashSizeInPixels => width / 220;

  Positioned lineSegment(Point a, Point b, Color color) {
    final dx = width * (a.x - b.x);
    final dy = height * (a.y - b.y);
    final r = center([a, b]); // midpoint
    final distance = sqrt(dx * dx + dy * dy);
    final line = Transform.rotate(
      angle: angle(a, b, width, height),
      alignment: Alignment.center,
      child: Container(width: distance, color: color, height: dashSizeInPixels),
    );
    return Positioned(
        bottom: height * r.y - dashSizeInPixels / 2,
        left: width * r.x - distance / 2,
        child: line);
  }

  Widget vertex([Color? border]) => Container(
        // TODO: change size to be screen dependent
        // TODO: fix colors
        width: vertexSizeInPixels,
        height: vertexSizeInPixels,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
          border: border == null
              ? null
              : Border.all(width: vertexSizeInPixels / 4, color: border),
        ),
      );

  List<Positioned> seatingSection(Pew pew, Room room) {
    // calculate the points along which a pew begins or ends.
    List<Point> leftPewEnds = [], rightPewEnds = [];
    for (final side in ["left", "right"]) {
      final Point a, b;
      if (side == "left") {
        a = room.vertices[pew.bl];
        b = room.vertices[pew.fl];
      } else {
        a = room.vertices[pew.br];
        b = room.vertices[pew.fr];
      }
      final dx = a.x - b.x;
      final dy = a.y - b.y;
      final stepx = dx / (pew.rows + 1);
      final stepy = dy / (pew.rows + 1);
      final List<Point> positions = List.generate(pew.rows, (j) {
        int i = j + 1;
        return Point(x: b.x + stepx * i, y: b.y + stepy * i);
      });
      if (side == "left") {
        leftPewEnds = positions;
      } else {
        rightPewEnds = positions;
      }
    }
    // generate the lines representing pews from the points
    final pews = [
      for (int i = 0; i < pew.rows; i++)
        lineSegment(leftPewEnds[i], rightPewEnds[i], Colors.brown)
    ];
    // background
    final double minX = pew.corners.map((i) => room.vertices[i].x).fold(double.infinity, (a, b) => min(a,b)),
    maxX = pew.corners.map((i) => room.vertices[i].x).fold(double.infinity, (a, b) => max(a,b)),
    minY = pew.corners.map((i) => room.vertices[i].y).fold(double.infinity, (a, b) => min(a,b)),
    maxY = pew.corners.map((i) => room.vertices[i].y).fold(double.infinity, (a, b) => max(a,b));

    final background = Positioned(
      left: width* minX,
      bottom: height * minY,
      child:ClipPolygon(child: Container(color: Colors.white, width: width*(maxX-minX), height: height * (maxY-minY), sides: sides) );
    return [background] + pews;
  }

  @override
  Widget build(BuildContext context) {
    final room = context.watch<RoomEditorState>().room;
    final selectedVertices = context.watch<RoomEditorState>().selectedVertices;

    final ret = Stack(
      children: [
            Positioned(
                child: GestureDetector(
                    onTapDown: (details) {
                      context.read<RoomEditorState>().addVertex(Point(
                          x: details.localPosition.dx / width,
                          y: 1 - details.localPosition.dy / height));
                    },
                    child: Image.file(
                        context.read<RoomEditorState>().roomFile.image,
                        width: width,
                        height: height)))
          ] +
          // the next line maps the edge data to a list of dots then combines
          // these lists only if there are edges.
          room.edges
              .map((info) => lineSegment(
                  room.vertices[info.a], room.vertices[info.b], Colors.green))
              .toList() +
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
                        ? vertex(Colors.blue)
                        : vertex()));
          }).toList() +
          // brown lines for the pews and a white transparent background
          (room.pews.isEmpty
              ? []
              : (room.pews
                  .map((pew) => seatingSection(pew, room))
                  .reduce((a, b) => a + b))) +
          room.pews.map((pew) {
            Point centerP = center([pew.bl, pew.fl, pew.br, pew.fr]
                .map((i) => room.vertices[i])
                .toList());
            return Positioned(
                left: centerP.x * width - 100 / 2,
                bottom: centerP.y * height - 81 / 2,
                child: PewDisplayAndEditor(
                    pew: pew, width: width, height: height));
          }).toList(),
    );
    return ret;
  }
}
