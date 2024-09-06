import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mclauncher4/src/widgets/carousel/carousel_item.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Carousel extends StatefulWidget {
  List<Map> items;
  Carousel({Key? key, required this.items}) : super(key: key);

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  late Timer timer;
  late CarouselSliderController _controller;
  Curve _curve = Curves.fastOutSlowIn;
  Duration _duration = Duration(milliseconds: 460);

  @override
  void initState() {
    super.initState();

    _controller = CarouselSliderController();
  }
  ValueNotifier<int> currentindex = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    var isbig = MediaQuery.of(context).size.height > 1090.0;

    return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Listener(
  onPointerSignal: (pointerSignal){
    if(pointerSignal is PointerScrollEvent){
      //(_controller.offset + (pointerSignal.scrollDelta.dy * 2), curve: Curves.easeOutExpo, duration: Duration(milliseconds: 500));
        if(pointerSignal.scrollDelta.dy > 0) {
          _controller.nextPage(duration: Duration(milliseconds: 600), curve: Curves.easeOutExpo);
        }else {
          _controller.previousPage(duration: Duration(milliseconds: 600), curve: Curves.easeOutExpo);
        }
      
    
    }
  },
  child:  CarouselSlider(
            carouselController: _controller,
            options: CarouselOptions(
                initialPage: 0,
                autoPlayAnimationDuration: _duration,
                autoPlayCurve: _curve,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 4),
                viewportFraction: (isbig ? 900 : 660) /
                    (MediaQuery.of(context).size.width - 400),
                onPageChanged: (index, reason) {
                  currentindex.value = index;
                },
                scrollDirection: Axis.horizontal,
                height: isbig ? 450.0 : 330.0,
                ),
            items: List.generate(
                widget.items.length,
                (index) => ValueListenableBuilder(
                      valueListenable: currentindex,
                      builder: (BuildContext context, value, child) {
                        return Center(
                            child: Container(
                                color: const Color.fromARGB(0, 76, 175, 79),
                                child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16),
                                    child: CarouselItem(
                                        pictureId: widget.items[index]["pictureId"],
                                        isOpened: value == index,
                                        onPressed: () {
                                       
                                          _controller.animateToPage(index,
                                              curve: _curve,
                                              duration: _duration);
                                        },
                                        name: widget.items[index]["name"],
                                        descripton: widget.items[index]
                                            ['description']))));
                      },
                    )))));
  }
}
