// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mclauncher4/src/widgets/components/size_transition_custom.dart';
import 'package:transparent_image/transparent_image.dart';

class CarouselItem extends StatefulWidget {
  VoidCallback onPressed;
  String name;
  String descripton;
  bool isopened;

  CarouselItem(
      {Key? key, required this.onPressed, required this.name, required this.descripton, required this.isopened})
      : super(key: key);

  @override
  _CarouselItemState createState() => _CarouselItemState();
}

class _CarouselItemState extends State<CarouselItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation ani;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 700));
    ani = Tween(begin: 0.12, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isopened) {
      _controller.forward();
    } else if (_controller.status != AnimationStatus.dismissed) {
      _controller.reverse();
    }
    return AnimatedBuilder(
        animation: ani,
        builder: (context, child) => Container(
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Sizetransitioncustom(
                  axis: Axis.horizontal,
                  axisAlignment: 0.0,
                  sizeFactor: 1.0 * ani.value,
                  child: Stack(children: [
                    FadeInImage.memoryNetwork(
                        fit: BoxFit.fill,
                        placeholder: kTransparentImage,
                        image:
                            'https://images.unsplash.com/photo-1622737133809-d95047b9e673?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1932&q=80'),
                    Positioned(
                      child: Opacity(
                        opacity: _controller.value,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            widget.name,
                            style: Theme.of(context)
                                .typography
                                .black
                                .headlineMedium!
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          SizedBox(
                              width: 300,
                              child: Text(
                                widget.descripton,
                                style:
                                    Theme.of(context).typography.black.bodySmall!.copyWith(fontWeight: FontWeight.w600),
                              ))
                        ]),
                      ),
                      bottom: 40,
                      left: 20,
                    ),
                  ])),
            ));
  }
}
