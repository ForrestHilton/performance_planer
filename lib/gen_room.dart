// This file generated 08:46:37 PM 29 11 (November) 2020
// using https://app.quicktype.io/ , the room.json, and the options, encoder+decoder and require all.
// To parse this JSON data, do
//
//     final room = roomFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class Room {
    Room({
        @required this.vertices,
        @required this.edges,
        @required this.pews,
    });

    List<Vertex> vertices;
    List<Edge> edges;
    List<Pew> pews;

    factory Room.fromRawJson(String str) => Room.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Room.fromJson(Map<String, dynamic> json) => Room(
        vertices: List<Vertex>.from(json["vertices"].map((x) => Vertex.fromJson(x))),
        edges: List<Edge>.from(json["edges"].map((x) => Edge.fromJson(x))),
        pews: List<Pew>.from(json["pews"].map((x) => Pew.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "vertices": List<dynamic>.from(vertices.map((x) => x.toJson())),
        "edges": List<dynamic>.from(edges.map((x) => x.toJson())),
        "pews": List<dynamic>.from(pews.map((x) => x.toJson())),
    };
}

class Edge {
    Edge({
        @required this.a,
        @required this.b,
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

class Pew {
    Pew({
        @required this.fr,
        @required this.fl,
        @required this.br,
        @required this.bl,
        @required this.name,
    });

    int fr;
    int fl;
    int br;
    int bl;
    String name;

    factory Pew.fromRawJson(String str) => Pew.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Pew.fromJson(Map<String, dynamic> json) => Pew(
        fr: json["fr"],
        fl: json["fl"],
        br: json["br"],
        bl: json["bl"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
      "fr": fr,
        "fl": fl,
        "br": br,
        "bl": bl,
        "name": name,
    };
}

class Vertex {
    Vertex({
        @required this.x,
        @required this.y,
    });

    double x;
    double y;

    factory Vertex.fromRawJson(String str) => Vertex.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Vertex.fromJson(Map<String, dynamic> json) => Vertex(
        x: json["x"],
        y: json["y"],
    );

    Map<String, dynamic> toJson() => {
        "x": x,
        "y": y,
    };
}
