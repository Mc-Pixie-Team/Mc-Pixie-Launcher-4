// ignore_for_file: sort_child_properties_last

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart' as apple;
import 'package:mclauncher4/src/getApiHandler.dart';
import 'package:mclauncher4/src/pages/modpacklist.dart';
import 'package:mclauncher4/src/tasks/apis/api.dart';
import 'package:mclauncher4/src/tasks/downloadState.dart';
import 'package:mclauncher4/src/tasks/forge/forge.dart';
import 'package:mclauncher4/src/tasks/forgeversion.dart';
import 'package:mclauncher4/src/tasks/installController.dart';
import 'package:mclauncher4/src/tasks/version.dart';
import 'package:mclauncher4/src/widgets/BrowseCard.dart';
import 'package:mclauncher4/src/widgets/SvgButton.dart';
import 'package:mclauncher4/src/widgets/components/slideInAnimation.dart';
import '../widgets/searchbar.dart' as Searchbar;
import 'package:flutter/material.dart';
import '../widgets/divider.dart' as Divider;
import '../theme/scrollphysics.dart';
import 'package:smooth_scroll_multiplatform/smooth_scroll_multiplatform.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:transparent_image/transparent_image.dart';

class ModListPage extends StatefulWidget {
  const ModListPage({Key? key}) : super(key: key);

  @override
  _ModListPageState createState() => _ModListPageState();
}

class _ModListPageState extends State<ModListPage> {
  late ScrollController _scrollController;
  Api _handler = ApiHandler().getApi("modrinth");
  List modpacklist = [];
  Future<List> get modpacklistfuture async => await _handler.getModpackList(23);
  bool iscalled = false;

  getMoreData() async {
    if (iscalled) return;
    iscalled = true;
    print('getmore data');
    modpacklist.addAll(await _handler.getMoreModpacks());
    print(modpacklist);
    setState(() {});
    iscalled = false;
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      _scrollController.addListener(() async {
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          await getMoreData();
        }
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(18)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              heightFactor: 1.4,
              widthFactor: double.infinity,
              alignment: Alignment(0.98, 1),
              child: Searchbar.Searchbar(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, left: 30, bottom: 9),
              child: SlideInAnimation(
                  duration: Duration(milliseconds: 1000),
                  child: Text(
                    'Modpacks provided:',
                    style: Theme.of(context).typography.black.bodySmall,
                  )),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30, bottom: 28),
              child: SlideInAnimation(
                  child: Text(
                _handler.getTitlename(),
                style: Theme.of(context).typography.black.displaySmall,
              )),
            ),
            Divider.Divider(
              size: 14,
            ),
            SizedBox(
              height: 15,
            ),
            Expanded(
                child: DynMouseScroll(
              animationCurve: Curves.easeOutExpo,
              scrollSpeed: 1.0,
              durationMS: 650,
              builder: (context, controller, physics) {
                _scrollController = controller;
                return FutureBuilder(
                    future: modpacklistfuture,
                    builder: (context, snapshot) {
                      print('look up');
                      if (!snapshot.hasData) {
                        return Container();
                      }

                      if (snapshot.hasData) {
                        if (modpacklist.toString() == "[]") {
                          modpacklist = snapshot.data ?? [];
                          print('Ä');
                        }

                        return ListView.builder(
                            physics: physics,
                            controller: controller,
                            itemCount: modpacklist.length,
                            itemBuilder: ((context, index) {
                              return BrowseCard(
                                modpacklist: modpacklist[index],
                                onCancel: () {},
                                onDownload: () async {
                                  Map modpackproject =
                                      await _handler.getModpack(
                                          modpacklist[index]["project_id"]);
                                  Map modpackversion =
                                      await _handler.getModpackVersion(
                                          (modpackproject["versions"] as List)
                                              .last);
                                InstallController().install( _handler,  modpackversion);
                                },
                                onOpen: () {},
                                state: DownloadState.notDownloaded,
                                progress: 0.0,
                              );
                            }));
                      }
                      return Container();
                    });
              },
            ))
          ],
        ));
  }
}
