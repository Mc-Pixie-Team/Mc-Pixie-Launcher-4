// ignore_for_file: sort_child_properties_last, prefer_const_constructors

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mclauncher4/src/widgets/components/size_transition_custom.dart';
import 'package:transparent_image/transparent_image.dart';

class CarouselItem extends StatefulWidget {
  VoidCallback onPressed;
  String name;
  String descripton;
  String pictureId;
  bool isOpened;

  CarouselItem(
      {Key? key,
      required this.isOpened,
      required this.onPressed,
      required this.name,
      required this.descripton,
      required this.pictureId,
      })
      : super(key: key);

  @override
  _CarouselItemState createState() => _CarouselItemState();
}

class _CarouselItemState extends State<CarouselItem>
    with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapUp: (details) => widget.onPressed(),
      child:  Container(
              height: double.infinity,
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child:   Stack(children: [
                  Positioned.fill(child: 
        
        
          FadeInImage.memoryNetwork(
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        placeholder: kTransparentImage,
                        image:
                           widget.pictureId)),
                        Positioned.fill(child: AnimatedOpacity(
                        duration: Duration(milliseconds: 400),
                        opacity: widget.isOpened ? 1.0 : 0.0,
                        child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            tileMode: TileMode.decal,
            colors: [
              Colors.transparent,
              Colors.transparent,
              Colors.transparent,
              Color.fromARGB(183, 0, 0, 0)
            ],
            stops: [
              0.0,
              0.0,
              0.54,
              1.0
            ], // 10% purple, 80% transparent, 10% purple
          ))), )),   
                   Positioned(
                      child: AnimatedOpacity(
                        duration: Duration(milliseconds: 400),
                        opacity: widget.isOpened ? 1.0 : 0.0,
                        child:  Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: 430,
                                  child:
                              Text(
                                overflow: TextOverflow.ellipsis,
                                widget.name,
                                style: Theme.of(context)
                                    .typography
                                    .black
                                    .headlineMedium!
                                    .copyWith(fontWeight: FontWeight.w600),
                              )),
                              SizedBox(
                                height: 5,
                              ),
                              SizedBox(
                                  width: 400,
                                  child: Text(
                                    widget.descripton,
                                    style: Theme.of(context)
                                        .typography
                                        .black
                                        .bodySmall!
                                        .copyWith(fontWeight: FontWeight.w600),
                                  ))
                            ])),
                      
                      bottom: 40,
                      left: 20,
                    ),
                  ],
            )));
  }
}
