import 'package:flutter/material.dart';

import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/widgets/buttons/svg_button.dart';
import 'package:mclauncher4/src/widgets/cards/browse_card.dart';

class DownloadButton extends StatefulWidget {
  InstallState state;
  double mainprogress;
  VoidCallback onOpen;
  VoidCallback onCancel;
  VoidCallback onDownload;
  DownloadButton(
      {Key? key,
      required this.state,
      required this.mainprogress,
      required this.onOpen,
      required this.onCancel,
      required this.onDownload})
      : super(key: key);

  @override
  _DownloadButtonState createState() => _DownloadButtonState();
}

class _DownloadButtonState extends State<DownloadButton> {
  bool get _isInstalled => widget.state == InstallState.installed;
  bool get _isRunning => widget.state  == InstallState.running;
  bool get _isNotInstalled => widget.state  == InstallState.notInstalled;
  bool get _isDownloading => widget.state  == InstallState.installing;
 
  bool get _isFetching => widget.state  == InstallState.fetching;
  double get downloadProgress => widget.mainprogress;

  void _onPressed() {
    if (_isDownloading) widget.onCancel();
    if (_isFetching) return;
    if (widget.state == InstallState.running) widget.onCancel();
    if (widget.state ==  InstallState.installed) widget.onOpen();
    if (widget.state ==  InstallState.notInstalled) widget.onDownload();
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
                child: SvgButton.asset('assets/svg/play-icon.svg', onpressed: _onPressed)),
          ),
          Center(
            child: AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
                opacity: _isRunning ? 1.0 : 0.0,
                child: SvgButton.asset('assets/svg/cancel-icon.svg', onpressed: _onPressed)),
          ),
          Center(
            child: AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
                opacity: _isNotInstalled ? 1.0 : 0.0,
                child: SvgButton.asset('assets/svg/download-icon.svg', onpressed: _onPressed)),
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
