


import 'package:flutter/material.dart';
import 'package:mclauncher4/src/widgets/InstalledCard.dart';

class Modpacks {
  static  ValueNotifierList<Widget> globalinstallContollers =ValueNotifierList([]);
  getInstalledPacks() {
  
  }
}


class ValueNotifierList<T> extends ValueNotifier<List<T>> {
  ValueNotifierList(List<T> value) : super(value);

  void add(T valueToAdd) {
    value = [...value, valueToAdd];
    notifyListeners();
  }

  void removeLast(){
    value.removeLast();
    notifyListeners();
  }

  void remove(T valueToRemove) {
    value = value.where((value) => value != valueToRemove).toList();
     notifyListeners();
  }

}