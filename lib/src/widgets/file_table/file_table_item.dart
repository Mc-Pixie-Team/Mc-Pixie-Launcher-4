import 'package:flutter/material.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mclauncher4/src/get_api_handler.dart';
import 'package:mclauncher4/src/tasks/apis/modrinth.api.dart';
import 'package:mclauncher4/src/tasks/install_controller.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';
import 'package:transparent_image/transparent_image.dart';

class FileTableItem extends StatefulWidget {
  int index;
  UMF umf;
  String providerString;
  FileTableItem({Key? key, required this.index, required this.umf, required this.providerString})
      : super(key: key);

  @override
  _FileTableItemState createState() => _FileTableItemState();
}

class _FileTableItemState extends State<FileTableItem> {
  void ondownload() {
    InstallController installController = InstallController(
      handler: ApiHandler().getApi(widget.providerString),
      modpackData: widget.umf,
    );
    installController.install();
  }

  @override
  Widget build(BuildContext context) {
    return Container(

      height: 52,
      width: double.infinity,
      margin: EdgeInsets.only(left: 28, right: 28, top: widget.index == 0? 20 : 0),
      decoration: ShapeDecoration(
        color:
            widget.index.isOdd ? null : Theme.of(context).colorScheme.surface,
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 7,
            cornerSmoothing: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
          ),
          GestureDetector(
              onTap: () => ondownload(),
              child: Container(
                width: 33,
                height: 33,
                
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(4)),
                child: Center(child: SizedBox(height: 16, width: 16, child: SvgPicture.asset('assets/svg/download-icon.svg', color: Colors.white,),),),
              )),
        const  SizedBox(
            width: 10,
          ),
          SizedBox(width: 230, child: 
          Text(widget.umf.name!)),
       const SizedBox(
            width: 10,
          ),
         SizedBox(width: 120, child:  Text(widget.umf.MCVersion!, style: Theme.of(context).typography.black.bodyMedium,)),
        const SizedBox(
            width: 10,
          ),
         Text(widget.umf.downloads! > 999
                                          ? (((widget.umf.downloads! /
                                                          1000) as double)
                                                      .round())
                                                  .toString() +
                                              'k'
                                          : widget.umf.downloads!
                                              .toString(), style: Theme.of(context).typography.black.bodyMedium),
        ],
      ),
    );
  }
}
