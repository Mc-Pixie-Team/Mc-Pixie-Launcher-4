import 'package:flutter/material.dart';

class InstallModel with ChangeNotifier {
  String _state = "";
  String get state => _state;

  double _progress = 0.0;
  double get progress => _progress;

  InstallState _installState = InstallState.notInstalled;
  InstallState get installState => _installState;

  setState(String state, {bool notify = true}) {
    _state = state;
    _progress = 0.0;
    notifyListeners();
  }

  setProgress(double progress, {bool notify = true}) {
    _progress = progress;
    notifyListeners();
  }

  setInstallState(InstallState installState, {bool notify = true}) {
    _installState = installState;
    notifyListeners();
  }

  setAll(InstallState installState, String state, double progress) {
    _installState = installState;
    _state = state;
    _progress = progress;
    notifyListeners();
  }
}

enum InstallState {
  installing,
  installed,
  notInstalled,
  fetching,
  running,
}
