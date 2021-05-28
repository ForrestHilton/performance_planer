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
        pew.rows
        = value;
    });
  }

  void addVertex(Point p) {
    editRoom(() {
      this.room.vertices.add(p);
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
    // put vertesies in clockwize order
    final Point center =
        room.center(selectedVertices.map((i) => room.vertices[i]).toList());
    selectedVertices.sort((a, b) => room
        .angle(center, room.vertices[a], 1, 1)
        .compareTo(room.angle(center, room.vertices[b], 1, 1)));

    // add edges if needed
    for (int indexInSelection = 0; indexInSelection < 4; indexInSelection++) {
      room.addEdge(Edge(
          a: selectedVertices[indexInSelection],
          b: selectedVertices[(indexInSelection + 1) % 4]));
    }
    // add pew
    room.pews.add(Pew(
        name: 'Test',
        width: 20,
        rows: 12,
        fl: selectedVertices[2],
        fr: selectedVertices[3],
        bl: selectedVertices[1],
        br: selectedVertices[0]));
    notifyListeners();
  }

  void moveUp() {
    editRoom(() {
      // TODO: bounding box
      for (int index in selectedVertices) {
        room.vertices[index].y += 0.002;
      }
    });
  }

  void moveDown() {
    editRoom(() {
      for (int index in selectedVertices) {
        room.vertices[index].y -= 0.002;
      }
    });
  }

  void moveRight() {
    editRoom(() {
      for (int index in selectedVertices) {
        room.vertices[index].x += 0.002;
      }
    });
  }

  void moveLeft() {
    editRoom(() {
      for (int index in selectedVertices) {
        room.vertices[index].x -= 0.002;
      }
    });
  }

  void undo() {
    this.room = Room.fromRawJson(histrory.last);
    notifyListeners();
    histrory.removeLast();
  }

  @override
  RoomEditorState() {
    roomFile = RoomFile(notifyListeners, onLoadOfAnotaitions);
    roomFile.promptUserForPathAndCreate();
  }

}
