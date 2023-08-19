import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class RepaintHelper {
  static Future<File> capturedWidgetAsImage({
    required GlobalKey globalKey,
    required String filename,
    double pixelRatio = 1.0,
  }) async {
    // convert image to bytes
    final ByteData byteData = await (capturedWidgetAsByteData(
      globalKey,
      pixelRatio: pixelRatio,
    ) as FutureOr<ByteData>);

    // convert bytes to file
    final File file =
        await convertByteDataToFile(data: byteData, name: filename);

    return file;
  }

  // static
  static Future<ByteData?> capturedWidgetAsByteData(
    GlobalKey globalKey, {
    double pixelRatio = 1.0,
  }) async {
    // get pixel
    final RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    // convert pixel to image
    final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    // convert image to bytes
    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData;
  }

  static Future<File> convertByteDataToFile({
    required ByteData data,
    required String name,
  }) async {
    final buffer = data.buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath = tempPath + name;
    return File(filePath).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }
}
