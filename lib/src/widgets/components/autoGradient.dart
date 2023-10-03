import 'package:flutter/material.dart';
import 'package:mclauncher4/src/widgets/components/gradiantText.dart';

class GradientTextWidget extends StatelessWidget {
  final String text;
  final Gradient gradient; // Specify the color for bold text
  final TextStyle textStyle;

  GradientTextWidget({
    required this.text,
    required this.gradient,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final pattern = RegExp(r'\|\|.*?\|\|'); // Match the text between **

    final widgets = <Widget>[];
    var currentIndex = 0;
    final matches = pattern.allMatches(text);

    for (final match in matches) {
      if (match.start > currentIndex) {
        widgets.add(
          Text(
            text.substring(currentIndex, match.start),
            style: textStyle,
          ),
        );
      }

      final boldText = text.substring(match.start + 2, match.end - 2);
      widgets.add(
        GradientText(
          boldText,
          style: textStyle,
          gradient: LinearGradient(
              //stops: [0, 1],
              begin: Alignment.topLeft,
              end: Alignment(0.8, 1),
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.tertiary,
              ]),
        ),
      );
      currentIndex = match.end;
    }

    if (currentIndex < text.length) {
      widgets.add(
        Text(
          text.substring(currentIndex),
          style: textStyle,
        ),
      );
    }

    return Row(
      children: widgets,
    );
  }
}
