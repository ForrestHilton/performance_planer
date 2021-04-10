// Copyright 2021 Forrest Hilton; licensed under GPL-3.0-or-later; See COPYING.txt
/*
this is the JSON used to initially generate this file
{
  "pewSlots":[[{"rowsLong":4,"choir":4}]],
  "aisleSlots":[{"nodes":[23,3],"choir":3}]
}
*/

import 'dart:convert';

class SeatingState {
    SeatingState({
        required this.pewSlots,
        required this.aisleSlots,
    });

    List<List<PewSlot>> pewSlots;
    List<AisleSlot> aisleSlots;

    factory SeatingState.fromRawJson(String str) => SeatingState.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory SeatingState.fromJson(Map<String, dynamic> json) => SeatingState(
        pewSlots: List<List<PewSlot>>.from(json["pewSlots"].map((x) => List<PewSlot>.from(x.map((x) => PewSlot.fromJson(x))))),
        aisleSlots: List<AisleSlot>.from(json["aisleSlots"].map((x) => AisleSlot.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "pewSlots": List<dynamic>.from(pewSlots.map((x) => List<dynamic>.from(x.map((x) => x.toJson())))),
        "aisleSlots": List<dynamic>.from(aisleSlots.map((x) => x.toJson())),
    };
}

class AisleSlot {
    AisleSlot({
        required this.nodes,
        this.choir,
    });

    List<int> nodes;
    int? choir;

    factory AisleSlot.fromRawJson(String str) => AisleSlot.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory AisleSlot.fromJson(Map<String, dynamic> json) => AisleSlot(
        nodes: List<int>.from(json["nodes"].map((x) => x)),
        choir: json["choir"],
    );

    Map<String, dynamic> toJson() => {
        "nodes": List<dynamic>.from(nodes.map((x) => x)),
        "choir": choir,
    };
}

class PewSlot {
    PewSlot({
        required this.rowsLong,
        this.choir,
    });

    int rowsLong;
    int? choir;

    factory PewSlot.fromRawJson(String str) => PewSlot.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory PewSlot.fromJson(Map<String, dynamic> json) => PewSlot(
        rowsLong: json["rowsLong"],
        choir: json["choir"],
    );

    Map<String, dynamic> toJson() => {
        "rowsLong": rowsLong,
        "choir": choir,
    };
}

