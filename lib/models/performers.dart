// Copyright 2021 Forrest Hilton; licensed under GPL-3.0-or-later; See COPYING.txt
// To parse this JSON data, do
//
//     final choir = choirFromJson(jsonString);

import 'dart:io';
import 'dart:convert';

List<Choir> performersFromJsonFile(String path) {
  final rawList = json.decode(File(path).readAsStringSync());
  return List<Choir>.from(rawList.map((x) => Choir.fromJson(x)));
}

class Choir {
  Choir({
    required this.name,
    required this.size,
    required this.underlap,
    required this.overlap,
  });

  String name;
  int size;
  bool underlap;
  bool overlap;

  factory Choir.fromRawJson(String str) => Choir.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Choir.fromJson(Map<String, dynamic> json) => Choir(
        name: json["name"],
        size: json["size"],
        underlap: json["underlap"],
        overlap: json["overlap"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "size": size,
        "underlap": underlap,
        "overlap": overlap,
      };
}
