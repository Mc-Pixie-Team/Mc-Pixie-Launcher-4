import 'dart:io';

import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';

abstract class ProviderInstaller {
  Future<Process> start(String processId, InstallModel installModel);

Future install({required UMF umfData, required String instanceName, required InstallModel installModel});

Future installFile({required UMF umfData, required String instanceName, required InstallModel installModel});


}