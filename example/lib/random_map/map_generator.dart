import 'dart:async';
import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:example/random_map/decoration/tree.dart';
import 'package:example/random_map/noise_generator.dart';
import 'package:example/random_map/player/pirate.dart';
import 'package:fast_noise/fast_noise.dart';
import 'package:flutter/foundation.dart';

///
/// Created by
///
/// ─▄▀─▄▀
/// ──▀──▀
/// █▀▀▀▀▀█▄
/// █░░░░░█─█
/// ▀▄▄▄▄▄▀▀
///
/// Rafaelbarbosatec
/// on 02/06/22
/// 地图生成
class MapGenerated {
  final GameMap map; ///地图
  final Player player; ///用户
  final List<GameComponent> components; ///游戏组件

  MapGenerated(this.map, this.player, this.components);
}
///地图生成器
class MapGenerator {
  static const double TILE_WATER = 0;  ///水
  static const double TILE_SAND = 1; ///沙子
  static const double TILE_GRASS = 2; ///草
  final double tileSize; ///瓦片大小
  final Vector2 size;  ///大小
  List<GameComponent> _compList = []; ///游戏组件集合
  Vector2 _playerPosition = Vector2.zero();  ///玩家位置

  MapGenerator(this.size, this.tileSize); ///构造函数


  ///构建地图
  Future<MapGenerated> buildMap() async {
    ///通过隔离来产生一个矩阵
    final matrix = await compute(
      generateNoise,
      {
        'h': size.y.toInt(),
        'w': size.x.toInt(),
        'seed': Random().nextInt(2000),  ///种子
        'frequency': 0.02,  ///频率
        'noiseType': NoiseType.PerlinFractal,  ///噪音类型
        'cellularDistanceFunction': CellularDistanceFunction.Natural, ///蜂窝距离函数
      },
    );
    ///上一步通过噪音算法，得到基本的地图架构
    _createTreesAndPlayerPosition(matrix);
    ///根据噪音地图，生成能用的地图对象，就是tileMode
    final map = MatrixMapGenerator.generate(
      matrix: matrix,
      // axisInverted: true,
      // matrix: [
      //   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 1, 1, 1, 2, 1, 1, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 1, 1, 2, 2, 1, 1, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 1, 1, 2, 2, 1, 1, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 1, 1, 2, 1, 1, 1, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      //   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      // ],
      builder: _buildTerrainBuilder().build,
    );
     ///返回一个构建地图的实例
    return MapGenerated(
      map,
      Pirate(position: _playerPosition),
      _compList,
    );
  }
  ///地形构建器
  TerrainBuilder _buildTerrainBuilder() {
    return TerrainBuilder(
      tileSize: tileSize,
      ///地形集合
      terrainList: [
        ///水
        MapTerrain(
          value: TILE_WATER,
          collisionOnlyCloseCorners: true,
          collisions: [CollisionArea.rectangle(size: Vector2.all(tileSize))],
          sprites: [
            TileModelSprite(
              path: 'tile_random/tile_types.png',
              size: Vector2.all(16),
              position: Vector2(0, 1),
            ),
          ],
        ),
        ///沙子
        MapTerrain(
          value: TILE_SAND,
          sprites: [
            TileModelSprite(
              path: 'tile_random/tile_types.png',
              size: Vector2.all(16),
              position: Vector2(0, 2),
            ),
          ],
        ),
        ///草
        MapTerrain(
          value: TILE_GRASS,
          spritesProportion: [0.93, 0.05, 0.02],
          sprites: [
            TileModelSprite(
              path: 'tile_random/tile_types.png',
              size: Vector2.all(16),
            ),
            TileModelSprite(
              path: 'tile_random/tile_types.png',
              size: Vector2.all(16),
              position: Vector2(1, 0),
            ),
            TileModelSprite(
              path: 'tile_random/tile_types.png',
              size: Vector2.all(16),
              position: Vector2(2, 0),
            ),
          ],
        ),
        ///沙子到水的弟兄
        MapTerrainCorners(
          value: TILE_SAND,
          to: TILE_WATER,
          spriteSheet: TerrainSpriteSheet.create(
            path: 'tile_random/earth_to_water.png',
            tileSize: Vector2.all(16),
          ),
        ),
        ///沙子到草
        MapTerrainCorners(
          value: TILE_SAND,
          to: TILE_GRASS,
          spriteSheet: TerrainSpriteSheet.create(
            path: 'tile_random/earth_to_grass.png',
            tileSize: Vector2.all(16),
          ),
        ),
      ],
    );
  }
  ///创建树和玩家的位置
  void _createTreesAndPlayerPosition(List<List<double>> matrix) {
    int width = matrix.length;
    int height = matrix.first.length;
    for (var x = 0; x < width; x++) {
      for (var y = 0; y < height; y++) {
        if (_playerPosition == Vector2.zero() &&
            x > width / 2 &&
            matrix[x][y] == TILE_GRASS) {
          _playerPosition = Vector2(x * tileSize, y * tileSize);   ///在有草的地方出生
        }
        ///组件列表中添加树
        if (verifyIfAddTree(x, y, matrix)) {
          _compList.add(Tree(Vector2(x * tileSize, y * tileSize)));
        }
      }
    }
  }

  bool verifyIfAddTree(int x, int y, List<List<double>> matrix) {
    bool terrainIsGrass =
        ((x % 5 == 0 && y % 3 == 0) || (x % 7 == 0 && y % 5 == 0)) &&
            matrix[x][y] == TILE_GRASS;

    bool baseTreeInGrass = false;
    try {
      baseTreeInGrass = matrix[x + 3][y + 3] == TILE_GRASS;
    } catch (e) {}

    bool randomFactor = Random().nextDouble() > 0.5;
    return terrainIsGrass && baseTreeInGrass && randomFactor;
  }
}
