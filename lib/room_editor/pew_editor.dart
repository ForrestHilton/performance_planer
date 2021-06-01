// Copyright 2021 Forrest Hilton; licensed under GPL-3.0-or-later; See COPYING.txt
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../models/room_graph.dart';
import 'room_editor_state.dart';

export 'package:flutter/rendering.dart';

/// this will build to a un-positioned floating editor iff the pew is selected, otherwize
/// it will build to a static display of the pews data
class PewDisplayAndEditor extends StatelessWidget {
  final pew;

  /// the parents aspect ratio
  final width;
  final height;

  const PewDisplayAndEditor({Key? key, this.pew, this.width, this.height})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final room = context.watch<RoomEditorState>().room;
    final state = context.watch<RoomEditorState>();

    Point centerP = center([
      pew.bl,
      pew.fl,
      pew.br,
      pew.fr
    ].map((i) => room.vertices[i]).toList());
    Point frontOfPew = 
        center([room.vertices[pew.fr], room.vertices[pew.fl]]);
    final style = TextStyle(
      fontWeight: FontWeight.bold,
      color: Colors.red,
    );

    if (state.selectedPew != null &&
        room.pews[state.selectedPew!] == pew) {
      return Container(
        color: Colors.white.withOpacity(1.0),
        width: 145,
        height: 175,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              child: Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        child: Text("pew name:"),
                        width: 60,
                      ),
                      Flexible(
                        child: TextFormField(
                          initialValue: pew.name,
                          onChanged: (text) {
                            state.changePewName(pew, text);
                          },
                          autovalidateMode: AutovalidateMode.always,
                          validator: (text) {
                            if (text == null || text.isEmpty)
                              return "please give the seating area a name";
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        child: Text("width (feet):"),
                        width: 60,
                      ),
                      Flexible(
                        child: TextFormField(
                          initialValue: pew.width.toStringAsFixed(1),
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.always,
                          onChanged: (text) {
                            final value = double.tryParse(text);
                            if (value != null) {
                              state.changePewWidth(pew, value);
                            }
                          },
                          validator: (text) {
                            if (text == null || text.isEmpty)
                              return "please give the seating area a width";
                            if (double.tryParse(text) == null)
                              return "please give a number of feet";
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(
                        child: Text("depth (pews):"),
                        width: 60,
                      ),
                      Flexible(
                        child: TextFormField(
                          initialValue: pew.rows.toStringAsFixed(0),
                          keyboardType: TextInputType.number,
                          autovalidateMode: AutovalidateMode.always,
                          onChanged: (text) {
                            final value = int.tryParse(text);
                            if (value != null) {
                              state.changePewNRows(pew, value);
                            }
                          },
                          validator: (text) {
                            if (text == null || text.isEmpty)
                              return "please give the seating area a depth";
                            if (int.tryParse(text) == null)
                              return "please give an integer number of feet";
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Text(
                  "Facing:",
                ),
                Transform.rotate(
                  angle: angle(
                      centerP, frontOfPew, width, height),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.red,
                    size: 25.0,
                  ),
                ),
                Text("rotate:"),
                Container(
                  width: 27,
                  height: 27,
                  child: FloatingActionButton(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.rotate_90_degrees_ccw,
                      color: Colors.red,
                      size: 25.0,
                    ),
                    onPressed: () => state.counterClockwiseShuffle(pew)
                  ),
                )
              ],
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: () => context.read<RoomEditorState>().selectPew(pew),
      child: Container(
        color: Colors.white.withOpacity(.6),
        width: 100,
        height: 81,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("""\"${pew.name}\"
Width:${pew.width.toStringAsFixed(1)} ft
Rows:${pew.rows.toStringAsFixed(0)} """, style: style),
            Row(
              children: [
                Text(
                  "Facing:",
                  style: style,
                ),
                Transform.rotate(
                  angle: angle(
                      centerP, frontOfPew, width, height),
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
  }
}
