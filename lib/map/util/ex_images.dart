import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/cache.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

extension ImagesEx on Images{


  Future<Image> loadS3Image(String imageName) async{

    ///读取文件，获取文件句柄
    File _file=await getS3File(imageName);
    ///把问价转为u8类型来保存
    Uint8List _image= await _file.readAsBytes();
    ///u8转为能使用的ui.Image.
    return _loadBytes(_image);
  }
}
Future<File> getS3File(String url) async{
  return await DefaultCacheManager().getSingleFile(url);
}
Future<Image> _loadBytes(Uint8List bytes) {
  final completer = Completer<Image>();
  decodeImageFromList(bytes, completer.complete);
  return completer.future;
}