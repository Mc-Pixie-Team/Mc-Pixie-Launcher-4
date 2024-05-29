import 'package:flutter/material.dart';

class TestWidget extends StatefulWidget {
  const TestWidget({Key? key}) : super(key: key);

  @override
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState extends State<TestWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(9.0),
      decoration: BoxDecoration(color: Color.fromARGB(1, 1, 1, 1)),
      child: Container(
        height: double.infinity,
        width: double.infinity,
      ),
    );
  }
}
