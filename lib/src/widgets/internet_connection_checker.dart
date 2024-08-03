import 'dart:async';

import 'package:flutter/material.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class InternetConnectionCheckerHelper {
  bool hasConnection = true;
  StreamSubscription<InternetConnectionStatus>? listener;
  static final InternetConnectionCheckerHelper _checkerHelper =
      InternetConnectionCheckerHelper.internal();
  factory InternetConnectionCheckerHelper() {
    return _checkerHelper;
  }
  Future<void> initListener() async {
    if (this.listener != null) {
      throw "initListener was already called!";
    }
    this.hasConnection = await InternetConnectionChecker().hasConnection;
    this.listener = InternetConnectionChecker().onStatusChange.listen((status) {
      switch (status) {
        case InternetConnectionStatus.connected:
          print('Data connection is available.');
          this.hasConnection = true;
          break;
        case InternetConnectionStatus.disconnected:
          print('You are disconnected from the internet.');
          this.hasConnection = false;
          break;
      }
    });
  }

  InternetConnectionCheckerHelper.internal();
}
