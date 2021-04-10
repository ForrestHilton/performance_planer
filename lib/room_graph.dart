// Copyright 2021 Forrest Hilton; licensed under GPL-3.0-or-later; See COPYING.txt
// This file initially generated 08:46:37 PM 29 11 (November) 2020
// using https://app.quicktype.io/, room.json, and encoder+decoder and require all.

import 'dart:convert';

class Room {
  Room({
    required this.vertices,
    required this.edges,
    required this.pews,
  });

  List<Point> vertices;
  List<Edge> edges;
  List<Pew> pews;

  factory Room.fromRawJson(String str) => Room.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Room.fromJson(Map<String, dynamic> json) => Room(
        vertices:
            List<Point>.from(json["vertices"].map((x) => Point.fromJson(x))),
        edges: List<Edge>.from(json["edges"].map((x) => Edge.fromJson(x))),
        pews: List<Pew>.from(json["pews"].map((x) => Pew.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "vertices": List<dynamic>.from(vertices.map((x) => x.toJson())),
        "edges": List<dynamic>.from(edges.map((x) => x.toJson())),
        "pews": List<dynamic>.from(pews.map((x) => x.toJson())),
      };

  /// takes the average of the positions of the corners
  Point center(Pew pew) {
    List<double> ret = [];
    for (final direction in [(point) => point.x, (point) => point.y]) {
      ret.add([pew.bl, pew.fl, pew.br, pew.fr]
              .map((vertexIndex) => direction(vertices[vertexIndex]))
              .reduce((a, b) => a + b) /
          4);
    }
    return Point(x: ret[0], y: ret[1]);
  }

  bool hasEdge(Edge edge) {
    return edges.contains(edge) || edges.contains(Edge(b: edge.a, a: edge.b));
  }

  /// appends the edge if it dose not already exist
  void addEdge(Edge edge) {
    if (!hasEdge(edge)) edges.add(edge);
  }

  Line line(Edge edge) {
    final a = vertices[edge.a];
    final b = vertices[edge.b];
    final m = (b.y - a.y) / (b.x - a.x);
    final _b = a.y - a.x * m;
    return Line(m, _b);
  }
}

class Line {
  double m;
  double b;
  Line(this.m, this.b);
}

class Edge {
  Edge({
    required this.a,
    required this.b,
  });

  int a;
  int b;

  factory Edge.fromRawJson(String str) => Edge.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Edge.fromJson(Map<String, dynamic> json) => Edge(
        a: json["a"],
        b: json["b"],
      );

  Map<String, dynamic> toJson() => {
        "a": a,
        "b": b,
      };
}

/// An object containing the vertex indices of the corners of a pew among other things
class Pew {
  Pew({
    required this.fr,
    required this.fl,
    required this.br,
    required this.bl,
    required this.name,
    required this.rows,
    required this.width,
  });
  
  int fr;
  int fl;
  int br;
  int bl;
  String name;
  int rows;
  /// feet
  double width;

  factory Pew.fromRawJson(String str) => Pew.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Pew.fromJson(Map<String, dynamic> json) => Pew(
        fr: json["fr"],
        fl: json["fl"],
        br: json["br"],
        bl: json["bl"],
        name: json["name"],
        rows: json["rows"],
        width: json["width"],
      );

  Map<String, dynamic> toJson() => {
        "fr": fr,
        "fl": fl,
        "br": br,
        "bl": bl,
        "name": name,
        "rows": rows,
        "width": width
      };
}

class Point {
  Point({
    required this.x,
    required this.y,
  });

  double x;
  double y;

  factory Point.fromRawJson(String str) => Point.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Point.fromJson(Map<String, dynamic> json) => Point(
        x: json["x"],
        y: json["y"],
      );

  Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
      };
}
