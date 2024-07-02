import 'dart:io';

import 'package:mclauncher4/src/tasks/installs/install_model.dart';

abstract class ProviderInstaller {

Future<Process> start(String processId, InstallModel installModel);

Future install({required Map modpackData, required String instanceName, required InstallModel installModel});


}