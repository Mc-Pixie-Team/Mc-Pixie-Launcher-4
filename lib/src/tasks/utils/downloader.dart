import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:async_zip/async_zip.dart';

class Downloader {
  final String downloadUrl;
  String savedDir;
  bool isDownloading = false;
  double progress = 0.0;
  String fileName = '';

  Downloader(this.downloadUrl, this.savedDir);

  Future<void> startDownload(
      {Function(double)? onProgress, bool shoulduseRawCallback = false}) async {

    final url = Uri.parse(downloadUrl);
    isDownloading = true;

    String parentDirectory = path.dirname(savedDir);
    await Directory(parentDirectory).create(recursive: true);


    final client = http.Client();
    final request = http.Request('GET', url);
    final response = await client.send(request);

    final file = File(savedDir);
    final saveStream = file.openWrite();

    double downloadedBytes = 0;
    final int? totalBytes = response.contentLength;
    var oldprogress = 0.0;


    await for (final data in response.stream) {
      saveStream.add(data);
      downloadedBytes += data.length;


      if (onProgress != null && totalBytes != null) {
        final progress = (downloadedBytes / totalBytes * 100);

        if (!shoulduseRawCallback) {
          if (progress - 0.9 > oldprogress) {
            oldprogress = progress;
            onProgress.call(progress);
          }
        } else {
          oldprogress = progress;
          onProgress.call(progress);
        }
      }
    }

    await saveStream.close();
    client.close();
  }

  Future unzip({bool deleteOld = false, String? unzipPath, Function(double)? onZipProgress}) async {
    
    if (!File(savedDir).existsSync())
      throw Exception("File ${savedDir} cannot be found!");

    final exportDir = unzipPath ?? path.join(path.dirname(savedDir));

    
   

var copied = 0.0;
var percentage = 0.0;
await extractZipArchive(File(savedDir), Directory(exportDir), callback: (entry, totalEntries) {
  if(onZipProgress == null) return;

  copied++;
  final newPercentage = (copied * 100 / totalEntries);
  if ((newPercentage - percentage) > 0.9) {
    percentage = newPercentage;
    onZipProgress.call(percentage);
  }
});



    if (deleteOld) File(savedDir).delete();
  }


  // Future<void> unzipSingleFile({bool deleteOld = false, required entryname}) async{
  //   final exportDir = path.join(path.dirname(savedDir));

  //   ZipFHandler.unzipSingleFile(exportDir: exportDir, zipFile: savedDir, entryname: entryname);
  //   if (deleteOld) File(savedDir).delete();
  // }

  String getDir() {
    return Directory.current.path.toString();
  }
}
