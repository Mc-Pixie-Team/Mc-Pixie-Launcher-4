import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mclauncher4/src/widgets/buttons/svg_button.dart';
import 'package:mclauncher4/src/widgets/components/size_transition_custom.dart';

class Dropdownmenu extends StatefulWidget {
  final Function(String text, String oldtext)? onchange;
  final Function(String text)? onremove;
  bool useOverlay;
  bool isRemovalIcon;
  Widget? child;
  List? registry;
  Dropdownmenu(
      {Key? key,
      this.child,
      this.onremove,
      this.isRemovalIcon = false,
      this.useOverlay = true,
      this.onchange,
      this.registry})
      : super(key: key);

  @override
  _DropdownmenuState createState() => _DropdownmenuState();
}

class _DropdownmenuState extends State<Dropdownmenu> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation _animation;
  late OverlayEntry? overlayEntry;
  late FocusNode _focusNode;
  late TextEditingController _textController;
  RenderBox? box;
  GlobalKey key = GlobalKey();
  double? gly;
  double? glx;
  double globalRadius = 20.0;
  Size? boxsize;
  bool iscompleted = false;
  bool isanimating = false;
  bool secmenu = false;
  String elementname = "";
  String elementnameOld = "";
  @override
  void initState() {
    overlayEntry = null;
    super.initState();

    _focusNode = FocusNode();
    _textController = TextEditingController();
    _controller = AnimationController(
        reverseDuration: Duration(milliseconds: 500), vsync: this, duration: Duration(milliseconds: 1300));
    _animation = CurvedAnimation(
        reverseCurve: Curves.easeInQuad,
        parent: Tween(begin: 1.0, end: 0.0).animate(_controller),
        curve: Curves.easeInExpo);

   

    _controller.addStatusListener((state) {
      if (state == AnimationStatus.forward) {
        isanimating = true;
        findButton();
        if (widget.useOverlay) {
          setoverlayEntry();
        } else {
          setState(() {
            secmenu = true;
          });
        }
      }
      if (state == AnimationStatus.reverse) {
        isanimating = true;
      }
      if (state == AnimationStatus.completed) {
        iscompleted = true;
        isanimating = false;
      }
      if (state == AnimationStatus.dismissed) {
        iscompleted = false;
        isanimating = false;
        removeEntry();
      }
    });

    _focusNode.addListener(() {
      startP();
    });
  }

  @override
  void dispose() {
    removeEntry();
    _controller.dispose();
    super.dispose();
  }

  void findButton() {
    this.box = key.currentContext!.findRenderObject() as RenderBox;
    if (box!.hasSize) {
      this.boxsize = box!.size;
    }

    Offset position = box!.localToGlobal(Offset.zero); //this is global position
    gly = position.dy + box!.size.height - 2;
    glx = position.dx;

    overlayEntry = _getoverlayEntry();
  }

  void setoverlayEntry() {
    if (overlayEntry!.mounted) return;
    if (overlayEntry == null) throw 'overlayEntry wasnt initialized';
    Overlay.of(context).insert(overlayEntry!);
  }

  void removeEntry() {
    if (overlayEntry != null && overlayEntry!.mounted) {
      overlayEntry?.remove();
      overlayEntry = null;
    }
  }

  void setElement(String element) {
    this.elementnameOld = this.elementname;
    this.elementname = element;
    widget.onchange!.call(element, this.elementnameOld);

    _textController.text = element;
  }

  void removeElement() {
    widget.onremove!.call(this.elementname);
  }

  Widget _getDropDownWidget() {
    if (this.box != null) {
      Offset position = box!.localToGlobal(Offset.zero); //this is global position
      gly = position.dy + box!.size.height - 2;
      glx = position.dx;
    }
    return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(color: const Color.fromARGB(78, 0, 0, 0), blurRadius: 20, offset: Offset(0, 20))
              ]),
              child: Sizetransitioncustom(
                  sizeFactor: (1.0 * (1 - _animation.value)),
                  child: Container(
                      clipBehavior: Clip.antiAlias,
                      height: 300,
                      width: boxsize!.width,
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.elliptical(20, 20), bottomRight: Radius.elliptical(20, 20))),
                      child: ListView.builder(
                          itemCount: widget.registry!.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                                onTap: () => setElement(widget.registry![index]),
                                child: Padding(
                                    padding: EdgeInsets.only(top: 14, left: 16, bottom: 5),
                                    child: Text(
                                      widget.registry![index],
                                      style: Theme.of(context).typography.black.labelLarge,
                                    )));
                          }))),
            ));
  }

  OverlayEntry _getoverlayEntry() {
    return OverlayEntry(
      builder: (context) {
        return Positioned(left: glx, top: gly, child: _getDropDownWidget());
      },
    );
  }

  @override
  void didUpdateWidget(covariant Dropdownmenu oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    _controller.reset();
    removeEntry();
  }

  void startP() {
    // if (isanimating) return;
    if (!_focusNode.hasFocus) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (this.box != null) {
      Offset position = box!.localToGlobal(Offset.zero); //this is global position
      gly = position.dy + box!.size.height - 2;
      glx = position.dx;
      overlayEntry = _getoverlayEntry();
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      InkWell(
          onTap: () {},
          child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                globalRadius = _animation.value < 1 ? 0 : 20;

                return Container(
                  key: key,
                  width: 235,
                  height: 41,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.elliptical(20, 20),
                          topRight: Radius.elliptical(20, 20),
                          bottomLeft: Radius.elliptical(globalRadius, globalRadius),
                          bottomRight: Radius.elliptical(globalRadius, globalRadius))),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 16,
                      ),
                      Transform.rotate(
                        angle: (-1.59 * _animation.value),
                        child: SvgPicture.asset(
                          'assets\\svg\\dropdown-icon.svg',
                          color: Color.fromARGB(255, 148, 148, 148),
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                     
                      Padding(
                          padding: EdgeInsets.only(bottom: 0),
                          child: SizedBox(
                              height: 25,
                              width: 135,
                              child: EditableText(
                                readOnly: true,
                                selectionColor: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                                cursorHeight: 20,
                                cursorOffset: Offset(0, 2),
                                controller: _textController,
                                backgroundCursorColor: Color.fromARGB(0, 168, 14, 14),
                                focusNode: _focusNode,
                                cursorColor: Theme.of(context).colorScheme.primary,
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Theme.of(context).typography.black.labelMedium!.color!.withOpacity(0.86)),
                              ))),
                      Expanded(
                        child: Container(),
                      ),
                      widget.isRemovalIcon
                          ? GestureDetector(
                              onTap: () => removeElement(),
                              child: widget.child ??
                                  SvgPicture.asset(
                                    'assets\\svg\\filter-icon.svg',
                                    color: Theme.of(context).textTheme.bodySmall!.color,
                                  ))
                          : widget.child ??
                              SvgPicture.asset(
                                'assets\\svg\\filter-icon.svg',
                                color: Theme.of(context).textTheme.bodySmall!.color,
                              ),
                      SizedBox(
                        width: 16,
                      ),
                    ],
                  ),
                );
              })),
      secmenu
          ? Transform.translate(
              offset: Offset(0, -2),
              child: _getDropDownWidget(),
            )
          : Container()
    ]);
  }
}
