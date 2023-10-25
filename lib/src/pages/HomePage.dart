import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mclauncher4/src/pages/installedModpacks.dart';
import 'package:mclauncher4/src/tasks/auth/microsoft.dart';
import 'package:mclauncher4/src/widgets/Buttons/SvgButton.dart';
import 'package:mclauncher4/src/widgets/Carousel/Carousel.dart';
import 'package:mclauncher4/src/widgets/InstalledCard.dart';
import 'package:mclauncher4/src/widgets/Providers/BrowseCard.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:transparent_image/transparent_image.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map> items = [
    {'name': 'Fabulously Optimized', 'description': 'Improve your workflow'},
    {'name': 'Cobllemon', 'description': 'fast for more'},
    {
      'name': 'The Revenge',
      'description': 'the big new recomming of something bad'
    },
    {
      'name': 'The Earea ATM',
      'description': 'something bad is about to happen'
    },
  ];

  bool get isEmpty => Modpacks.globalinstallContollers.value.length < 1;


bool checkforDouble(Widget widget){
  
                        for(Widget tempWidgets in Modpacks.globalinstallContollers.value){
                          if(widget.key == tempWidgets.key){
                            return false;
                          }

                        }
                        return true;
 }

  @override
  Widget build(BuildContext context) {
    return Container(
        clipBehavior: Clip.antiAlias,
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(alignment: Alignment.center, children: [
          Positioned.fill(
            child: FutureBuilder(
                future: Modpacks.getPacksformManifest(),
                builder: (context, snapshot) {
                   
                  if (snapshot.hasData) {
                    
               
                      for (Widget widget in snapshot.data!){

                       if(checkforDouble(widget)) {
                        print(widget.toString() + ' is allowed');
                        Modpacks.globalinstallContollers.value.add(widget);
                       }
                      
                     }
                 
                    return DynMouseScroll(
                        animationCurve: Curves.easeOutExpo,
                        scrollSpeed: 1.0,
                        durationMS: 650,
                        builder: (context, _scrollController, physics) =>
                            SingleChildScrollView(
                                physics: physics,
                                controller: _scrollController,
                                child: SizedBox(
                                  width: 800,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: isEmpty ? 100 : 71,
                                      ),
                                      Carousel(items: items),
                                      ValueListenableBuilder(
                                          valueListenable:
                                              Modpacks.globalinstallContollers,
                                          builder: (context, value, child) =>
                                              isEmpty
                                                  ? Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 200),
                                                      child: Center(
                                                          child: Text(
                                                        'Nothing found :(',
                                                        style: Theme.of(context)
                                                            .typography
                                                            .black
                                                            .bodyLarge,
                                                      )),
                                                    )
                                                  : Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                          Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 40,
                                                                    top: 30),
                                                            child: Text(
                                                              'Installed :',
                                                              style: Theme.of(
                                                                      context)
                                                                  .typography
                                                                  .black
                                                                  .headlineSmall,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 15,
                                                          ),
                                                          Padding(
                                                              padding:
                                                                  EdgeInsets.all(
                                                                      38),
                                                              child: Align(
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Wrap(
                                                                    
                                                                      alignment:
                                                                          WrapAlignment
                                                                              .start,
                                                                      spacing:
                                                                          40.0, // gap between adjacent chips
                                                                      runSpacing:
                                                                          60.0,
                                                                      children:
                                                                          value)))
                                                        ]))
                                    ],
                                  ),
                                )));
                  } else {
                    return Container();
                  }
                }),
          ),
          Positioned.fill(
              child: Align(
                  alignment: Alignment.topLeft,
                  child: ClipRect(
                    child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceVariant
                              .withOpacity(0.4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              Transform.rotate(
                                  angle: 1.6,
                                  child: SvgButton.asset(
                                    'assets/svg/dropdown-icon.svg',
                                    onpressed: () {},
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  )),
                              Padding(
                                  padding: EdgeInsets.only(left: 14, bottom: 3),
                                  child: Text(
                                    'HomePage',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: 'Roboto',
                                      fontWeight: FontWeight.w600,
                                      height: 0,
                                    ),
                                  )),
                              Expanded(child: Container()),
                              Container(
                                clipBehavior: Clip.antiAlias,
                                height: 40,
                                width: 40,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        Theme.of(context).colorScheme.surface),
                                child: GestureDetector(
                                  onTap: () => Microsoft().authenticate(),
                                  child: FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image:
                                        'https://lh3.googleusercontent.com/a/ACg8ocLlOn3NroVB-AMQehydBqWLd8IaWRozFcPEm2_lcw3fkw=s288-c-no'),
                              )),
                              SizedBox(
                                width: 15,
                              )
                            ],
                          ),
                        )),
                  )))
        ]));
  }
}
