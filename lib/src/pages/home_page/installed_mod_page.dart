import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/models/value_notifier_list.dart';

class InstalledModPage extends StatefulWidget {
  ValueNotifierList stdout;
  InstalledModPage({Key? key, required this.stdout}) : super(key: key);

  @override
  _InstalledModPageState createState() => _InstalledModPageState();
}

class _InstalledModPageState extends State<InstalledModPage> {
  List<String> commandline = [];

  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    widget.stdout.addListener(() {
      if (scrollController.hasClients) {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
      WidgetsBinding.instance
        .addPostFrameCallback((_) {
            if (scrollController.hasClients) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
        
      }
        });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Column(mainAxisSize: MainAxisSize.min, children: [ 
     LinearProgressIndicator(),
      Expanded(child:   Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Theme.of(context).colorScheme.surfaceVariant,
        ),
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Container(
            color: Colors.black,
            child: ValueListenableBuilder(
              valueListenable: widget.stdout,
              builder: (context, value, child) =>  ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child:  ListView.builder(
             
                  controller: scrollController,
                  itemCount: value.length,
                  itemBuilder: (context, index) => Text(value[index]))),
            ),
          ),
        ),
      )),])
    );
  }
}
