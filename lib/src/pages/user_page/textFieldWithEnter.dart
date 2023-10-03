import 'package:flutter/material.dart';

class TextFieldWithEnter extends StatefulWidget {
  TextFieldWithEnter({Key? key, this.presetValue = "", required this.onSubmit, required this.onError, this.minLenght = 0, this.maxLenght = 999999})
      : super(key: key);
  String presetValue;
  VoidCallback onSubmit;
  VoidCallback onError;
  int minLenght;
  int maxLenght;

  @override
  _TextFieldWithEnterState createState() => _TextFieldWithEnterState();
}

class _TextFieldWithEnterState extends State<TextFieldWithEnter> {
  late FocusNode _focusNode;
  late final TextEditingController _textController;
  late String setValue = widget.presetValue;
  @override
  void initState() {
    bool _focusEventOverride = false;
    _textController = TextEditingController(text: widget.presetValue);

    _focusNode = FocusNode(
      onKeyEvent: (node, event) {
        if (event.logicalKey.debugName == "Enter" &&
            widget.maxLenght >= _textController.text.length &&
            widget.minLenght <= _textController.text.length) {
          _focusEventOverride = true;
          setValue = _textController.text;
          Function.apply(widget.onSubmit, []);
        } else if (event.logicalKey.debugName == "Enter") {
          Function.apply(widget.onError, []);

          return KeyEventResult.handled;
        } else {}
        return KeyEventResult.ignored;
      },
    );
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _focusEventOverride == false) {
        /* if (widget.maxLenght >= _textController.text.length && widget.minLenght <= _textController.text.length) {
          _focusEventOverride = true;
          Function.apply(widget.onSubmit, []);
        } else {
          Function.apply(widget.onError, []);
        } */
        _textController.text = setValue;
        _focusEventOverride = true;
      }
      if (_focusNode.hasFocus && _focusEventOverride == true) {
        _focusEventOverride = false;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 200,
        child: EditableText(
          selectionColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          cursorHeight: 15,
          cursorOffset: Offset(0, 2),
          controller: _textController,
          backgroundCursorColor: Color.fromARGB(0, 168, 14, 14),
          focusNode: _focusNode,
          cursorColor: Theme.of(context).colorScheme.primary,
          style: Theme.of(context).typography.black.bodyMedium!.merge(TextStyle(color: Color.fromARGB(112, 255, 255, 255))),
          textAlign: TextAlign.center,
        ));
  }
}
