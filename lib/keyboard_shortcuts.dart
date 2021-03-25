library keyboard_shortcuts;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuple/tuple.dart';
import 'package:visibility_detector/visibility_detector.dart';

String? _customTitle;
IconData? _customIcon;
bool _helperIsOpen = false;
List<Tuple3<Set<LogicalKeyboardKey>, Function(BuildContext context), String>>
    _newGlobal = [];

enum BasicShortCuts {
  creation,
  previousPage,
  nextPage,
  save,
}

void initShortCuts(
  Widget homePage, {
  Set<Set<LogicalKeyboardKey>>? keysToPress,
  Set<Function(BuildContext context)>? onKeysPressed,
  Set<String>? helpLabel,
  Widget? helpGlobal,
  String? helpTitle,
  IconData? helpIcon,
}) async {
  if (keysToPress != null &&
      onKeysPressed != null &&
      helpLabel != null &&
      keysToPress.length == onKeysPressed.length &&
      onKeysPressed.length == helpLabel.length) {
    _newGlobal = [];
    for (var i = 0; i < keysToPress.length; i++) {
      _newGlobal.add(Tuple3(keysToPress.elementAt(i),
          onKeysPressed.elementAt(i), helpLabel.elementAt(i)));
    }
  }
  _customTitle = helpTitle;
  _customIcon = helpIcon;
}

bool _isPressed(
    Set<LogicalKeyboardKey> keysPressed, Set<LogicalKeyboardKey> keysToPress) {
    keysToPress = LogicalKeyboardKey.collapseSynonyms(keysToPress);
    keysPressed = LogicalKeyboardKey.collapseSynonyms(keysPressed);

    return keysPressed.containsAll(keysToPress) &&
      keysPressed.length == keysToPress.length;
}

class KeyBoardShortcut {
  final Set<LogicalKeyboardKey>? keysToPress;
  final VoidCallback? onKeysPressed;
  final String? helpLabel;

  KeyBoardShortcut({
    this.keysToPress,
    this.onKeysPressed,
    this.helpLabel,
  });
}

class KeyBoardShortcuts extends StatefulWidget {
  final Widget child;

  final List<KeyBoardShortcut>? shortcuts;

  KeyBoardShortcuts({this.shortcuts, required this.child, Key? key})
      : super(key: key);

  @override
  _KeyBoardShortcuts createState() => _KeyBoardShortcuts();
}

class _KeyBoardShortcuts extends State<KeyBoardShortcuts> {
  FocusScopeNode? focusScopeNode;
  ScrollController _controller = ScrollController();
  bool controllerIsReady = false;
  bool listening = false;
  late Key key;
  @override
  void initState() {
    _controller.addListener(() {
      if (_controller.hasClients) setState(() => controllerIsReady = true);
    });
    _attachKeyboardIfDetached();
    key = widget.key ?? UniqueKey();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _detachKeyboardIfAttached();
  }

  void _attachKeyboardIfDetached() {
    if (listening) return;
    RawKeyboard.instance.addListener(listener);
    listening = true;
  }

  void _detachKeyboardIfAttached() {
    if (!listening) return;
    RawKeyboard.instance.removeListener(listener);
    listening = false;
  }

  void listener(RawKeyEvent v) async {
    if (!mounted || _helperIsOpen) return;

    Set<LogicalKeyboardKey> keysPressed = RawKeyboard.instance.keysPressed;
    if (v.runtimeType == RawKeyDownEvent) {
      // when user type keysToPress
      for (final action in widget.shortcuts!) {
        if (action.keysToPress != null &&
            action.onKeysPressed != null &&
            _isPressed(keysPressed, action.keysToPress!)) {
          action.onKeysPressed!();
          return;
        }
      }

      // when user request help menu
      if (_isPressed(keysPressed,
          {LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.keyH})) {
        List<Widget> activeHelp = [];

        widget.shortcuts!.forEach((element) {
          Widget? elementWidget = _helpWidget(element);
          if (elementWidget != null) activeHelp.add(elementWidget);
        }); // get all custom shortcuts

        if (!_helperIsOpen && (activeHelp.isNotEmpty)) {
          _helperIsOpen = true;

          await showDialog<void>(
            context: context,
            builder: (BuildContext context) => AlertDialog(
              key: UniqueKey(),
              title: Text(_customTitle ?? 'Keyboard Shortcuts'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    if (activeHelp.isNotEmpty)
                      ListBody(
                        children: [
                          for (final i in activeHelp) i,
                          Divider(),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ).then((value) => _helperIsOpen = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: key,
      child:
          PrimaryScrollController(controller: _controller, child: widget.child),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction == 1)
          _attachKeyboardIfDetached();
        else
          _detachKeyboardIfAttached();
      },
    );
  }
}

String _getKeysToPress(Set<LogicalKeyboardKey>? keysToPress) {
  String text = "";
  if (keysToPress != null) {
    for (final i in keysToPress) text += i.debugName! + " + ";
    text = text.substring(0, text.lastIndexOf(" + "));
  }
  return text;
}

Widget? _helpWidget(KeyBoardShortcut shortcut) {
  String text = _getKeysToPress(shortcut.keysToPress);
  if (shortcut.helpLabel != null && text != "")
    return ListTile(
      leading: Icon(_customIcon ?? Icons.settings),
      title: Text(shortcut.helpLabel!),
      subtitle: Text(text),
    );
  return null;
}

Set<LogicalKeyboardKey> shortCut(BasicShortCuts basicShortCuts) {
  switch (basicShortCuts) {
    case BasicShortCuts.creation:
      return {LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.keyN};
    case BasicShortCuts.previousPage:
      return {LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.arrowLeft};
    case BasicShortCuts.nextPage:
      return {LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.arrowRight};
    case BasicShortCuts.save:
      return {LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.keyS};
    default:
      return {};
  }
}
