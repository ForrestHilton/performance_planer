// Copyright 2021 Forrest Hilton; licensed under GPL-3.0-or-later; See COPYING.txt
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'gen_room.dart';

class RoomFile {
  late final String path;
  late final File image;
  late final double aspectratio;
  late final Room room;
  final void Function(VoidCallback) parentSetState;
  final VoidCallback onLoadOfAnotaitions;

  bool isReady = false;

  RoomFile(this.parentSetState, this.onLoadOfAnotaitions);

  void create(String selectedPath) async {
    if (selectedPath.endsWith(".zip")) {
      path = selectedPath;
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      final bytes = File(path).readAsBytesSync();
      final archive = ZipDecoder().decodeBytes(bytes);
      assert(archive.length == 2);
      for (final archivedFile in archive) {
        final filename = archivedFile.name;
        assert(archivedFile.isFile);
        final data = archivedFile.content as List<int>;
        final file = File(tempPath +"/" + filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
        if (filename.endsWith(".json")) {
          room = Room.fromRawJson(file.readAsStringSync());
        } else {
          _loadImage(file);
        }
      }
    } else {
      // assuming its an image path
      _loadImage(File(selectedPath));
      this.room = Room.fromRawJson(
          """ {"vertices":[{"x":0.5,"y":0.3},{"x":0.5,"y":0.2}],
      "edges":[{"a":0,"b":1}],"pews":[]} """);
      path = "./user_files/out.zip";
    }
    onLoadOfAnotaitions();
  }

  Future<void> save() async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File(tempPath + "/annotations.json")
      ..createSync()
      ..writeAsStringSync(room.toRawJson());

    var encoder = ZipFileEncoder();
    encoder.create(path);
    encoder.addFile(File(tempPath + "/annotations.json"));
    encoder.addFile(image);
    encoder.close();
  }

  void _loadImage(File image) async {
    if (isReady) return;
    this.image = image;
    final decoded = await decodeImageFromList(image.readAsBytesSync());

    parentSetState(() {
      aspectratio = decoded.height / decoded.width;
      isReady = true;
    });
  }
}
