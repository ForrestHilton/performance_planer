// Copyright 2021 Forrest Hilton; licensed under GPL-3.0-or-later; See COPYING.txt
// This file initially generated 08:46:37 PM 29 11 (November) 2020
// using https://app.quicktype.io/, room.json, and encoder+decoder and require all.

import 'dart:math';
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

  /// average position of listed Points
  Point center(List<Point> list) {
    Point ret = Point(x: 0, y: 0);
    for (Point p in list) {
      ret.x += p.x;
      ret.y += p.y;
    }
    return Point(x: ret.x / list.length, y: ret.y / list.length);
  }

  bool hasEdge(Edge edge) {
    return edges.contains(edge) || edges.contains(Edge(b: edge.a, a: edge.b));
  }

  /// appends the edge if it dose not already exist
  void addEdge(Edge edge) {
    if (!hasEdge(edge)) edges.add(edge);
  }

  Line line(Point a, Point b) {
    final m = (b.y - a.y) / (b.x - a.x);
    final _b = a.y - a.x * m;
    return Line(m, _b);
  }

  /// the angle in CW radians from +x to the lane from a to b
  double angle(Point a, Point b, double width, double height) {
    bool faceingLeft = b.x < a.x;
    var ret = atan(line(a, b).m/width*height) + (faceingLeft ? pi : 0);
    ret = -ret;
    if (ret < 0) {
      ret += 2 * pi;
    }

    return ret;
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
