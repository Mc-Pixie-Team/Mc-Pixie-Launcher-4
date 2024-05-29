// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mclauncher4/src/widgets/side_panel/side_panel.dart';


void main() {

  testWidgets('MyWidget asserts invalid bounds', (WidgetTester tester) async {
    SidePanelController controller = SidePanelController();
    assert(controller != null);
      print("test" + DateTime.now().second.toString());
  await tester.pumpWidget(SidePanel(controller: controller), Duration(seconds: 2),);

  print("test" + DateTime.now().second.toString());

  
  expect(tester.takeException(),isFlutterError); // or isNull, as appropriate.
});
}
