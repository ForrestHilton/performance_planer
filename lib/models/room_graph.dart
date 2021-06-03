// Copyright 2021 Forrest Hilton; licensed under GPL-3.0-or-later; See COPYING.txt
// This file initially generated 29 Nov 2020
// using https://app.quicktype.io/, room.json, and encoder+decoder and require all.

import 'dart:math' ;
import 'dart:convert';
export 'dart:math' show Point;

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
            List<Point>.from(json["vertices"].map((x) => pointFromJson(x))),
        edges: List<Edge>.from(json["edges"].map((x) => Edge.fromJson(x))),
        pews: List<Pew>.from(json["pews"].map((x) => Pew.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "vertices": List<dynamic>.from(vertices.map((x) => pointToJson(x))),
        "edges": List<dynamic>.from(edges.map((x) => x.toJson())),
        "pews": List<dynamic>.from(pews.map((x) => x.toJson())),
      };

  bool hasEdge(Edge edge) {
    return edges.contains(edge) || edges.contains(Edge(b: edge.a, a: edge.b));
  }

  /// appends the edge if it dose not already exist
  void addEdge(Edge edge) {
    if (!hasEdge(edge)) edges.add(edge);
  }
}

/// average position of listed Points
Point center(List<Point> list) {
  Point ret = Point(0, 0);
  for (Point p in list) {
    ret += p;
  }
  return ret * (1/list.length);
}

Line line(Point a, Point b) {
  final m = (b.y - a.y) / (b.x - a.x);
  final _b = a.y - a.x * m;
  return Line(m, _b);
}

/// the angle in CW radians from +x to the lane from a to b.
/// Note that since the origin is top left,
/// this angle is flipped internally not by the user.
double angle(Point a, Point b, double width, double height) {
  bool faceingLeft = b.x < a.x;
  var ret = atan(- line(a, b).m / width * height) + (faceingLeft ? pi : 0);
  ret = -ret;
  if (ret < 0) {
    ret += 2 * pi;
  }

  return ret;
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
    required this.corners,
    required this.name,
    required this.rows,
    required this.width,
  });

  /// a CCW list starting at from right
  List<int> corners;

  int get fr => corners[0];
  set fr(int fr) => corners[0] = fr;

  int get fl => corners[1];
  set fl(int fl) => corners[1] = fl;

  int get br => corners[3];
  set br(int br) => corners[3] = br;

  int get bl => corners[2];
  set bl(int bl) => corners[2] = bl;

  String name;
  int rows;

  /// feet
  double width;

  factory Pew.fromRawJson(String str) => Pew.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Pew.fromJson(Map<String, dynamic> json) => Pew(
        corners: json["corners"],
        name: json["name"],
        rows: json["rows"],
        width: json["width"],
      );

  Map<String, dynamic> toJson() =>
      {"corners": corners, "name": name, "rows": rows, "width": width};
}


Point pointFromRawJson(String str) => pointFromJson(json.decode(str));

String pointToRawJson(Point p) => json.encode(pointToJson(p));

Point pointFromJson(Map<String, dynamic> json) => Point(json["x"], json["y"],);

Map<String, dynamic> pointToJson(Point p) => {
  "x": p.x,
  "y": p.y,
};
