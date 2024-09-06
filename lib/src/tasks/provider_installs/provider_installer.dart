import 'dart:io';

import 'package:mclauncher4/src/tasks/installs/install_model.dart';
import 'package:mclauncher4/src/tasks/models/umf_model.dart';

abstract class ProviderInstaller {
Future install({required UMF umfData, required String instanceName, required InstallModel installModel});

Future installFile({required UMF umfData, required String instanceName, required InstallModel installModel});


}