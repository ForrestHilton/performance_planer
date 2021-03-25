// Copyright 2021 Forrest Hilton; licensed under GPL-3.0-or-later; See COPYING.txt
import 'package:flutter/material.dart';
import 'package:stager_shell/room.dart';

void main() {
  runApp(MaterialApp(
    initialRoute: '/',
    routes: {
      '/': (context) => HomeRoute(),
      '/room_editor': (context) => RoomEditor(),
    },
  ));
}

class HomeRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Procession Planing'),
        backgroundColor: Colors.green,
      ),
      body: Center(
          child: Column(
        children: <Widget>[
          RaisedButton(
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
