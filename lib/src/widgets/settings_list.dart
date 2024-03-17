import 'package:flutter/material.dart';

class SettingsList extends StatefulWidget {
  SettingsList({required this.names, required this.functions, Key? key}) : super(key: key);
  late final List<VoidCallback> functions;
  late final List names;
  @override
  _SettingsListState createState() => _SettingsListState();
}

class _SettingsListState extends State<SettingsList> {
  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: const BoxConstraints(
          minWidth: 0, // Minimum width
          maxWidth: double.infinity, // Maximum width
          minHeight: 0, // Minimum height
          maxHeight: double.infinity, // Maximum height
        ),
        //height: widget.height,
        decoration:
            BoxDecoration(borderRadius: BorderRadius.circular(10), color: Theme.of(context).colorScheme.surface),
        width: 500,
        child: Padding(
          padding: const EdgeInsets.all(15.0).subtract(EdgeInsets.only(top: 11.5, bottom: 11.5)),
          child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.names.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(children: [
                  ListTile(
                      trailing: InkWell(
                          onTap: widget.functions[index],
                          child: SizedBox(
                            height: 25,
                            width: 30,
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Theme.of(context).typography.black.bodySmall!.color,
                              size: 14,
                            ),
                          )),
                      title: Text(
                        widget.names[index],
                        style: Theme.of(context).typography.black.labelLarge
                        
                      )),
                  (index != widget.names.length - 1)
                      ? Padding(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Container(
                            width: 550.66,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 0.50,
                                  strokeAlign: BorderSide.strokeAlignCenter,
                                  color: Color(0x23A6A6A6),
                                ),
                              ),
                            ),
                          ),
                        )
                      : const SizedBox()
                ]);
              }),
        ));
  }
}
