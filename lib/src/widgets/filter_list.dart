import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mclauncher4/src/widgets/buttons/circular_button.dart';
import 'package:mclauncher4/src/widgets/providers_widget/dropdown_menu.dart';

class FilterList extends StatefulWidget {
  List<String> categories;
  Function(String category) addCategory;
  Function(String category) removeCategory;
  FilterList({Key? key, required this.categories, required this.addCategory, required this.removeCategory})
      : super(key: key);

  @override
  _FilterListState createState() => _FilterListState();
}

class _FilterListState extends State<FilterList> {

  List<Widget> filterWidgets = [];

  void addFilterWidget() {
    var id = filterWidgets.length.toString();
    filterWidgets.add( 
                  Padding(
                    key: Key(id),
                padding: EdgeInsets.only(left: 5, right: 10),
                child: Dropdownmenu(
                  isRemovalIcon: true,
                  child: SvgPicture.asset(
                    'assets/svg/cancel-icon.svg',
                    color: Theme.of(context).textTheme.bodySmall!.color,
                  ),
                  onremove: (text) {
                      removeFilterWidget(id);
                      if(!text.isEmpty) {
                          widget.removeCategory(text);
                      }
                      
                  },
                  registry: widget.categories,
                  onchange: (text, oldtext) {
                  if(text == oldtext) return;
                  widget.addCategory(text);
                  widget.removeCategory(oldtext);
                  },
                ))
    );
    setState(() {
      
    });
  }

  void removeFilterWidget(String id) {
    filterWidgets.removeWhere((element) => element.key! == Key(id));
    
    
    setState(() {
      
    });
  } 

  @override
  Widget build(BuildContext context) {
    print(widget.categories);
    return Container(
      child: SingleChildScrollView(
          reverse: true,
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ...filterWidgets,
              CircularButton(
      child: Icon(
        Icons.add,
        color: Colors.grey,
      ),
      height: 40,
      width: 40,
      onClick: () {
     //   int index = filters.length - 1;
     addFilterWidget();
      },
    ),
    

            ],
          )),
    );
  }
}
