import "package:flutter/material.dart";
import "package:mclauncher4/src/tasks/models/download_states.dart";
import "package:mclauncher4/src/widgets/components/size_transition_custom.dart";

class PlayButton extends StatefulWidget {
  MainState state;
  VoidCallback onPressed;
  PlayButton({Key? key, required this.state, required this.onPressed}) : super(key: key);

  @override
  _PlayButtonState createState() => _PlayButtonState();
}

class _PlayButtonState extends State<PlayButton> with TickerProviderStateMixin {
  late AnimationController _controllerOpacity;
  late AnimationController _controllerScale;

  @override
  void initState() {
    _controllerOpacity =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    _controllerScale =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    super.initState();
  }

  bool get isRunning => widget.state == MainState.running;
  bool get isInstalling =>
      widget.state == MainState.unzipping ||
      widget.state == MainState.downloadingML ||
      widget.state == MainState.downloadingMinecraft ||
      widget.state == MainState.downloadingMods;
  bool get isFetching => widget.state == MainState.fetching;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap:  widget.onPressed,
        onTapDown: (details) => _controllerScale.forward(),
        onTapUp: (details) => _controllerScale.reverse(),
        child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (event) => _controllerOpacity.forward(),
            onExit: (event) {
              _controllerOpacity.reverse();
              _controllerScale.reverse();
            },
            child: ScaleTransition(
                filterQuality: FilterQuality.high,
                scale: Tween<double>(begin: 1, end: 0.94).animate(
                    CurvedAnimation(
                        parent: _controllerScale, curve: Curves.easeOutQuart)),
                child: FadeTransition(
                    opacity: Tween<double>(begin: 1, end: 0.6)
                        .animate(_controllerOpacity),
                    child: Container(
                      height: 34,
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Color(0xFF50EA5F),
                      ),
                      child: Center(
                        child: Text(
                          isFetching ? "Wait" : isRunning? "Cancel" : "Play",
                          style: Theme.of(context)
                              .typography
                              .black
                              .labelMedium!
                              .copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w600),
                        ),
                      ),
                    )))));
  }
}
