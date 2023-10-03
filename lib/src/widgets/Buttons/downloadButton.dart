
import 'package:flutter/material.dart';
import 'package:mclauncher4/src/tasks/downloadState.dart';
import 'package:mclauncher4/src/widgets/Buttons/SvgButton.dart';
import 'package:mclauncher4/src/widgets/Providers/BrowseCard.dart';

class DownloadButton extends StatefulWidget {
  MainState mainState;
  double mainprogress;
  VoidCallback onOpen;
  VoidCallback onCancel;
  VoidCallback onDownload;
  DownloadButton(
      {Key? key, required this.mainState, required this.mainprogress, required this.onOpen, required this.onCancel, required this.onDownload})
      : super(key: key);

  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool get _isInstalled => widget.mainState == MainState.installed;
  bool get _isRunning => widget.mainState == MainState.running;
  bool get _isDownloading =>
      widget.mainState == MainState.downloadingMinecraft ||
      widget.mainState == MainState.downloadingML ||
      widget.mainState == MainState.downloadingMods;
  bool get _isFetching => false;
  double get downloadProgress => widget.mainprogress;




    void _onPressed() {
    if (_isDownloading) widget.onCancel();
    if (_isFetching) widget.onCancel();
    if (widget.mainState == MainState.running) widget.onCancel();
    if (widget.mainState == MainState.installed) widget.onOpen();
    if (widget.mainState == MainState.notinstalled) widget.onDownload();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 22,
      width: 22,
      child: Stack(
        children: [

          Center(
            child: AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
                opacity: _isInstalled ? 1.0 : 0.0,
                child: SvgButton.asset('assets\\svg\\play-icon.svg',
                    onpressed: _onPressed)),
          ),
          Center(
            child: AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
                opacity: _isRunning ? 1.0 :0.0,
                child: SvgButton.asset('assets\\svg\\cancel-icon.svg',
                    onpressed: _onPressed)),
          ),
          Center(
            child: AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
                opacity: _isDownloading || _isFetching
                    ? 0.0
                    : _isInstalled
                        ? 0.0
                        : _isRunning ? 0.0 : 1.0,
                child: SvgButton.asset('assets\\svg\\download-icon.svg',
                    onpressed: _onPressed)),
          ),
          Positioned.fill(
            child: AnimatedOpacity(
              duration: Duration(milliseconds: 300),
              opacity: _isDownloading || _isFetching ? 1.0 : 0.0,
              curve: Curves.easeOut,
              child: GestureDetector(
                onTap: _onPressed,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ProgressIndicatorWidget(
                      downloadProgress: downloadProgress,
                      isDownloading: _isDownloading,
                      isFetching: _isFetching,
                    ),
                    if (_isDownloading)
                      Padding(
                        padding: EdgeInsets.only(
                          right: 0.5,
                        ),
                        child: Icon(
                          Icons.stop,
                          size: 12,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
