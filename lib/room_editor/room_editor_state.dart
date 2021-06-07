// Copyright 2021 Forrest Hilton; licensed under GPL-3.0-or-later; See COPYING.txt

import '../models/room_graph.dart';
import '../services/room_file.dart';
import 'package:flutter/foundation.dart';

class RoomEditorState with ChangeNotifier, DiagnosticableTreeMixin {
  late Room room;
  late RoomFile roomFile;
  List<String> histrory = [];
  List<int> selectedVertices = [];
  int? selectedPew;
  int? dragedVertex;

  @override
  RoomEditorState() {
    roomFile = RoomFile(notifyListeners, onLoadOfAnotaitions);
    roomFile.promptUserForPathAndCreate();
  }

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

  void completeDragOfVertex(Point p) {
    editRoom(() {
      room.vertices[dragedVertex!] = p;
    });
    dragedVertex = null;
  }

  void selectPew(Pew pew) {
    selectedPew = room.pews.indexOf(pew);
    notifyListeners();
  }

  void changePewName(Pew pew, String text) {
    editRoom(() {
      pew.name = text;
    });
  }

  void changePewWidth(Pew pew, double value) {
    editRoom(() {
      pew.width = value;
    });
  }

  void changePewNRows(pew, int value) {
    editRoom(() {
      pew.rows = value;
    });
  }

  void counterClockwiseShuffle(Pew pew) {
    editRoom(() {
      final first = pew.corners.first;
      pew.corners.removeAt(0);
      pew.corners.add(first);
    });
  }

  /// either add a vertex or move the dragged vertex
  void onClickUp(Point p) {
    editRoom(() {
      if (dragedVertex != null) {
        room.vertices[dragedVertex!] = p;
      } else {
        this.room.vertices.add(p);
      }
    });
  }

  void clearSelection() {
    selectedVertices = [];
    selectedPew = null;
    notifyListeners();
  }

  void remove() {
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
  }

  void connect() {
    editRoom(() {
      if (selectedVertices.length == 2) {
        room.addEdge(Edge(a: selectedVertices[0], b: selectedVertices[1]));
      }
    });
  }

  void formPew() {
    // put vertesies in counter clockwize order starting with 1st quadrant
    final Point centerP =
        center(selectedVertices.map((i) => room.vertices[i]).toList());
    selectedVertices.sort((a, b) => angle(centerP, room.vertices[b], 1, 1)
        .compareTo(angle(centerP, room.vertices[a], 1, 1)));

    // add edges if needed
    for (int indexInSelection = 0; indexInSelection < 4; indexInSelection++) {
      room.addEdge(Edge(
          a: selectedVertices[indexInSelection],
          b: selectedVertices[(indexInSelection + 1) % 4]));
    }
    // add pew
    room.pews
        .add(Pew(name: 'Test', width: 20, rows: 12, corners: selectedVertices));
    notifyListeners();
  }

  void undo() {
    this.room = Room.fromRawJson(histrory.last);
    notifyListeners();
    histrory.removeLast();
  }
}
