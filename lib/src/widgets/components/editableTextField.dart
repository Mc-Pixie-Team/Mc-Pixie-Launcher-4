import 'package:flutter/material.dart';

// ignore: must_be_immutable
class EditableTextField extends StatefulWidget {
  TextEditingController? textController = TextEditingController();
  FocusNode? focusNode = FocusNode();

  double height;
  double width;
  


  EditableTextField({Key? key, this.textController, this.focusNode, this.width = 135, this.height = 25})
      : super(key: key);

  @override
  _EditableTextFieldState createState() => _EditableTextFieldState();
}

class _EditableTextFieldState extends State<EditableTextField> {


  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Theme.of(context).colorScheme.surface),
        height: widget.height,
        width: widget.width,
        child: Padding(padding: EdgeInsets.only(left: 10), child:  Center(child: EditableText(
          selectionColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.3),
          cursorHeight: 18,
          cursorOffset: Offset(0, 2),
          controller: widget.textController ?? TextEditingController(),
          backgroundCursorColor: Color.fromARGB(0, 168, 14, 14),
          focusNode: widget.focusNode ?? FocusNode(),
          cursorColor: Theme.of(context).colorScheme.primary,
          style: TextStyle(
              fontSize: 18,
              color: Theme.of(context)
                  .typography
                  .black
                  .labelMedium!
                  .color!
                  .withOpacity(0.86)),
        ))));
  }
}
