// This file generated 05:01:18 PM 28 11 (November) 2020
// using https://app.quicktype.io/ , the room.json, and the options, encoder+decoder and require all.
// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

class Welcome {
    Welcome({
        @required this.vertices,
        @required this.edges,
        @required this.pews,
    });

    List<Vertex> vertices;
    List<Edge> edges;
    Pews pews;

    factory Welcome.fromRawJson(String str) => Welcome.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        vertices: List<Vertex>.from(json["vertices"].map((x) => Vertex.fromJson(x))),
        edges: List<Edge>.from(json["edges"].map((x) => Edge.fromJson(x))),
        pews: Pews.fromJson(json["pews"]),
    );

    Map<String, dynamic> toJson() => {
        "vertices": List<dynamic>.from(vertices.map((x) => x.toJson())),
        "edges": List<dynamic>.from(edges.map((x) => x.toJson())),
        "pews": pews.toJson(),
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

class Pews {
    Pews({
        @required this.a,
    });

    A a;

    factory Pews.fromRawJson(String str) => Pews.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Pews.fromJson(Map<String, dynamic> json) => Pews(
        a: A.fromJson(json["A"]),
    );

    Map<String, dynamic> toJson() => {
        "A": a.toJson(),
    };
}

class A {
    A({
        @required this.fr,
        @required this.fl,
        @required this.br,
        @required this.bl,
    });

    int fr;
    int fl;
    int br;
    int bl;

    factory A.fromRawJson(String str) => A.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory A.fromJson(Map<String, dynamic> json) => A(
        fr: json["fr"],
        fl: json["fl"],
        br: json["br"],
        bl: json["bl"],
    );

    Map<String, dynamic> toJson() => {
        "fr": fr,
        "fl": fl,
        "br": br,
        "bl": bl,
    };
}

class Vertex {
    Vertex({
        @required this.x,
        @required this.y,
    });

    int x;
    int y;

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
