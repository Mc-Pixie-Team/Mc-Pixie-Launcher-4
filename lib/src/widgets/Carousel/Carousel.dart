import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/widgets/carousel/carousel_item.dart';
import 'package:transparent_image/transparent_image.dart';



class Carousel extends StatefulWidget {
  List<Map> items;
  Carousel({Key? key, required this.items}) : super(key: key);

  @override
  _CarouselState createState() => _CarouselState();
}

class _CarouselState extends State<Carousel> {
  int currentindex = 1;
  bool isdisposed = false;
  late Timer timer;
  @override
  void dispose() {
    isdisposed = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    isdisposed = false;
   timer = Timer.periodic(Duration(seconds: 6), (timer) {
      if (currentindex >= widget.items.length - 1) {
        currentindex = 0;
      } else {
        currentindex++;
      }
      if (isdisposed) return;
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
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
                            child: AnimatedContainer(
                               clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
                              curve: Curves.easeOutExpo,
                              duration: Duration(milliseconds: 800),
                           
                              height:  double.infinity,
                              width: currentindex == index ? 600 : 63,
                              child: Stack(
                                
                                children: [
                            
                                      SizedBox(
                                              width: double.infinity,
                                              height: double.infinity,
                                              child:     FadeInImage.memoryNetwork(
                                          
                                    fit: BoxFit.cover,
                                    placeholder: kTransparentImage,
                                    image:
                                        widget.items[index]['pictureId'])),
                                Positioned(
                                  child: AnimatedOpacity(
                                    duration: Duration(milliseconds: 250),
                                  
                                    opacity: currentindex == index ? 1 : 0,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.items[index]['name'],
                                            style: Theme.of(context)
                                                .typography
                                                .black
                                                .headlineMedium!
                                                .copyWith(
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          SizedBox(
                                              width: 300,
                                              child: Text(
                                                widget.items[index]
                                                    ['description'],
                                                style: Theme.of(context)
                                                    .typography
                                                    .black
                                                    .bodySmall!
                                                    .copyWith(
                                                        fontWeight:
                                                            FontWeight.w600),
                                              ))
                                        ]),
                                  ),
                                  bottom: 40,
                                  left: 20,
                                ),
                              ]),
                            ))),
                  )))),
      SizedBox(
        height: 11,
      ),
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
                      color: currentindex == index
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.secondary.withOpacity(0.3)),
                )),
      )
    ]));
  }
}
