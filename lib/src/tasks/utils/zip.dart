import 'dart:ffi' as ffi;
import 'dart:math';
import 'package:ffi/ffi.dart';
import 'dart:io' show Platform, Directory;
import 'package:path/path.dart' as path;

typedef ExtractZipFunc = ffi.Int32 Function(
    ffi.Pointer<Utf8> str1, ffi.Pointer<Utf8> str2);
typedef ExtractZip = int Function(
    ffi.Pointer<Utf8> str1, ffi.Pointer<Utf8> str2);

typedef ExtractSingleFileFunc = ffi.Int32 Function(
    ffi.Pointer<Utf8> str0, ffi.Pointer<Utf8> str1, ffi.Pointer<Utf8> str2);
typedef ExtractSingleFile = int Function(
    ffi.Pointer<Utf8> str0, ffi.Pointer<Utf8> str1, ffi.Pointer<Utf8> str2);

// Dart type definition for calling the C foreign function
//https://github.com/dart-lang/samples/blob/main/ffi/structs/structs.dart

class ZipFHandler {
  static String getDllPath() {
    if (Platform.isMacOS) {
      return path.join(Directory.current.path, 'bin', 'zip', 'pixie.dylib');
    }

    if (Platform.isWindows) {
      return path.join(
          Directory.current.path, 'bin', 'zip', 'Release', 'pixie.dll');
    }

    return path.join(Directory.current.path, 'bin', 'zip', 'pixie.so');
  }

  static unzipIntoDir({required String exportDir, required String zipFile}) {
    final dylib = ffi.DynamicLibrary.open(getDllPath());

    final zipext = dylib.lookupFunction<ExtractZipFunc, ExtractZip>('zipext');

    // Call the function
    final success = zipext(zipFile.toNativeUtf8(), exportDir.toNativeUtf8());

    //check if operation is succsess full
    if (success < 0) throw "Can't unzip file: $zipFile";

  }

  static unzipSingleFile({required String exportDir, required String zipFile, required String entryname}) {
    final dylib = ffi.DynamicLibrary.open(getDllPath());
    final fileext = dylib
        .lookupFunction<ExtractSingleFileFunc, ExtractSingleFile>('fileext');
        
    final success = fileext(
        zipFile.toNativeUtf8(),
        entryname.toNativeUtf8(),
         path.join(exportDir , path.basename(entryname)).toNativeUtf8());

    dylib.close();
    if (success < 0) throw "Can not extract or find single file: $entryname in $zipFile";
  }
}
