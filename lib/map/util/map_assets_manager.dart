import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:bonfire/bonfire.dart';
import 'package:bonfire/map/util/ex_images.dart';
import 'package:bonfire/util/controlled_update_animation.dart';
import 'package:flame/cache.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
var cacheManager = DefaultCacheManager();
Images exImages=Images(prefix: '');

class MapAssetsManager {
  static final Map<String, Sprite> spriteCache = {};
  static final Map<String, Image> _imageCache = {};
  static final Map<String, ControlledUpdateAnimation> spriteAnimationCache = {};

  static Sprite getSprite(
    String image,
    Vector2 position,
    Vector2 size,
  ) {
    String pathCache = '$image/${position.x}/${position.y}';
    if (spriteCache.containsKey(pathCache)) {
      return spriteCache[pathCache]!;
    }

    Image? spriteSheetImg = getImageCache(image);

    return spriteCache[pathCache] = spriteSheetImg!.getSprite(
      position: Vector2(position.x * size.x, position.y * size.y),
      size: Vector2(
        size.x == 0.0 ? spriteSheetImg.width.toDouble() : size.x,
        size.y == 0.0 ? spriteSheetImg.height.toDouble() : size.y,
      ),
    );
  }

  static Future<Sprite> getFutureSprite(
    String image, {
    Vector2? position,
    Vector2? size,
  }) async {
    String pathCache = '$image/${position?.x ?? 0}/${position?.y ?? 0}';

    if (spriteCache.containsKey(pathCache)) {
      return Future.value(spriteCache[pathCache]);
    }

    Image spriteSheetImg = await loadImage(
      image,
    );

    return spriteCache[pathCache] = spriteSheetImg.getSprite(
      position: Vector2(
        ((position?.x ?? 0.0) * (size?.x ?? 0.0)),
        ((position?.y ?? 0.0) * (size?.y ?? 0.0)),
      ),
      size: Vector2(
        (size?.x ?? 0.0) == 0.0 ? spriteSheetImg.width.toDouble() : size!.x,
        (size?.y ?? 0.0) == 0.0 ? spriteSheetImg.height.toDouble() : size!.y,
      ),
    );
  }

  static Future<SpriteAnimation> getFutureSpriteAnimation(
    List<TileModelSprite> frames,
    double stepTime,
  ) async {
    List<Sprite> spriteList = [];

    for (var frame in frames) {
      Sprite sprite = await MapAssetsManager.getFutureSprite(
        frame.path,
        position: frame.position,
        size: frame.size,
      );
      spriteList.add(sprite);
    }

    return Future.value(SpriteAnimation.spriteList(
      spriteList,
      stepTime: stepTime,
    ));
  }

  static ControlledUpdateAnimation getSpriteAnimation(
    List<TileModelSprite> frames,
    double stepTime,
  ) {
    String key = '';
    List<Sprite> spriteList = [];

    for (var frame in frames) {
      Sprite sprite = MapAssetsManager.getSprite(
        frame.path,
        frame.position,
        frame.size,
      );
      key += '${frame.path}${frame.position.x}${frame.position.y}';
      spriteList.add(sprite);
    }

    if (spriteAnimationCache.containsKey(key)) {
      return spriteAnimationCache[key]!;
    }

    return spriteAnimationCache[key] = ControlledUpdateAnimation.fromInstance(
      SpriteAnimation.spriteList(
        spriteList,
        stepTime: stepTime,
      ),
    );
  }

  static Future<Image> loadImage(
    String image,
  ) async {


    ///如果是网络资源，则进行
    final fromServer = image.contains('http');
    if (_imageCache.containsKey(image)) {
      return Future.value(_imageCache[image]);
    }
    if (fromServer) {
      return _imageCache[image] = await exImages.loadS3Image(image);
    } else {
      return _imageCache[image] = await Flame.images.load(image);
    }
  }

  static Image? getImageCache(String image) {
    try {
      return _imageCache[image];
    } catch (e) {
      return null;
    }
  }
}
