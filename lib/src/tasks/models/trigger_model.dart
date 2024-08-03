import 'package:flutter/material.dart';

class Trigger with ChangeNotifier {
  void trigger() {
    notifyListeners();
  }
}