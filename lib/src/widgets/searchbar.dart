import 'package:flutter/material.dart';



class Searchbar extends StatefulWidget {
  final Function(String text)? onchange;
  final Function? onsubmit;
   Searchbar({Key? key, this.onchange, this.onsubmit}) : super(key: key);

  @override
  _SearchbarState createState() => _SearchbarState();
}

class _SearchbarState extends State<Searchbar>
    with SingleTickerProviderStateMixin {

  
  late AnimationController _controller;
  late Animation<double> animation;
  late FocusNode _focusNode;
  late final TextEditingController _textController;
  bool isfocused = false;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        isfocused = true;
      }
      if (status == AnimationStatus.reverse) {
        isfocused = false;
      }
    });
    _controller.addListener(() {
      setState(() {});
    });

    animation = _controller
        .drive(CurveTween(curve: Curves.easeInOutQuart))
        .drive(Tween(begin: 40, end: 200));

    _textController = TextEditingController();
    if(widget.onchange != null) {
      _textController.addListener(() { 
        widget.onchange!.call(_textController.text);
      });
    }
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setSelectedState();
       if(widget.onchange != null) {
        widget.onsubmit!.call();
       }
      }
    });
    super.initState();
  }

  void setSelectedState() {
    if (_controller.isAnimating) return;

    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _focusNode.requestFocus();
      _controller.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(45)),
        height: 39,
        width: animation.value,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            isfocused
                ? Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: SizedBox(
                        height: 25,
                        width: 135,
                        child: EditableText(
                        selectionColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          cursorHeight: 20,
                          cursorOffset: Offset(0, 2),
                          controller: _textController,
                          
                          backgroundCursorColor:
                              Color.fromARGB(0, 168, 14, 14),
                          focusNode: _focusNode,
                          cursorColor: Theme.of(context).colorScheme.primary,
                          style: TextStyle(
                              fontSize: 17,
                              color: Theme.of(context)
                                  .typography
                                  .black
                                  .labelMedium!
                                  .color!.withOpacity(0.86)),
                        )))
                : Container(),
            GestureDetector(
              onTapUp: (details) => setSelectedState(),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.search,
                  color: Theme.of(context).textTheme.bodySmall!.color,
                  size: 20,
                ),
              ),
            )
          ],
        ));
  }
}
