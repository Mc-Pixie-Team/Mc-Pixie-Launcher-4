import 'package:flutter/material.dart';

class ValueNotifierList<Widget> extends ValueNotifier<List<Widget>> {
  ValueNotifierList(List<Widget> value) : super(value);

  void add(Widget valueToAdd) {
    
    value = [...value, valueToAdd];
    notifyListeners();
    print("added something");
  }

  void insert(int index, Widget element ) {
    value.insert(index, element);
    notifyListeners();
  }

  void addAll(List<Widget> valuetoAddall) {
    value.addAll(valuetoAddall);
    notifyListeners();
     print("added something to all");
  }

  void removeLast() {
    value.removeLast();
    notifyListeners();
    print("added something at the end");
  }

  void remove(Widget valueToRemove) {
    value = value.where((value) => value != valueToRemove).toList();
    notifyListeners();
    print("remove something");
  }

  void removeKeyFromAnimatedBuilder(String key) {
    value = value.where((value) {
      if (value is AnimatedBuilder) {
        AnimatedBuilder builder = value as AnimatedBuilder;

        return builder.key != Key(key);
      }
      return false;
    }).toList();
    notifyListeners();
     print("remove from animated builder");
  }
}