import 'package:flutter/cupertino.dart' as apple;
import '../widgets/searchbar.dart' as Searchbar;
import 'package:flutter/material.dart';
import '../widgets/divider.dart' as Divider;

class ModListPage extends StatefulWidget {
  const ModListPage({Key? key}) : super(key: key);

  @override
  _ModListPageState createState() => _ModListPageState();
}

class _ModListPageState extends State<ModListPage> {
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
              child: Text(
                'Modpacks provided:',
                style: Theme.of(context).typography.black.bodySmall,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 30, bottom: 28),
              child: Text(
                'Modrinth',
                style: Theme.of(context).typography.black.displaySmall,
              ),
            ),
            Divider.Divider(
              size: 14,
            ),
            SizedBox(
              height: 45,
            ),
            // Expanded(child: ListView.builder(itemBuilder: (
            //   context,
            //   index,
            // ) {
            //   return Padding(
            //       padding: EdgeInsets.only(left: 35, right: 35),
            //       child: Container(
            //         decoration: BoxDecoration(
            //             color: Theme.of(context).colorScheme.surface),
            //         child: Row(),
            //       ));
            // }))
          ],
        ));
  }
}
