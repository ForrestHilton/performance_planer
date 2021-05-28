// Copyright 2021 Forrest Hilton; licensed under GPL-3.0-or-later; See COPYING.txt
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'room_editor/room.dart';


void main() {
  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => RoomEditorState() )],
    child: MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => HomeRoute(),
          '/room_editor': (context) => Editor(),
        },
      ),
  ));
}

class HomeRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Performance Planer'),
        backgroundColor: Colors.green,
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          ElevatedButton(
            child: Text('Room Editor'),
            onPressed: () {
              Navigator.pushNamed(context, '/room_editor');
            },
          ),
        ],
      )),
    );
  }
}
