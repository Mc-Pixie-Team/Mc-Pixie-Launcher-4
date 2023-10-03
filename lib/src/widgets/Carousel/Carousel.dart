import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/widgets/Carousel/CarouselItem.dart';
import 'package:mclauncher4/src/widgets/components/sizetransitioncustom.dart';

class Carousel extends StatefulWidget {
  List<Map> items;
  Carousel({Key? key, required this.items}) : super(key: key);

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  int currentindex = 1;
  bool isdisposed = false;

  @override
  void dispose() {
     isdisposed = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    isdisposed = false;
    Timer.periodic(Duration(seconds: 5), (timer) {
      if (currentindex >= widget.items.length - 1) {
        currentindex = 0;
      } else {
        currentindex++;
      }
      if(isdisposed) return;
      setState(() {});
    });
  }

  void changeindex(int index) {
    setState(() {
      currentindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: Column(children: [
          SizedBox(
              height: 340,
              child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: List.generate(
                          widget.items.length,
                          (index) => Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: GestureDetector(
                                    onTap: () => changeindex(index),
                                    child: CarouselItem(
                                        onPressed: () {},
                                        name: widget.items[index]['name'],
                                        descripton:
                                            widget.items[index]['description'],
                                        isopened: currentindex == index)),
                              ))))),
                              SizedBox(height: 11,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                widget.items.length,
                (index) => AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  margin: EdgeInsets.all(2),
                      height: 6,
                      width: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                          color: currentindex == index ? Theme.of(context).colorScheme.secondary :Theme.of(context).colorScheme.secondary.withOpacity(0.3) ),
                    )),
          )
        ]));
  }
}
