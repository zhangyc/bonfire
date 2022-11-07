import 'package:bonfire/bonfire.dart';
import 'package:flutter/foundation.dart';

export 'map_terrain.dart';
export 'terrain_builder.dart';

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
/// on 30/05/22
///
///项矩阵属性
class ItemMatrixProperties {
  final double value;
  final double? valueTop;
  final double? valueTopLeft;
  final double? valueTopRight;
  final double? valueBottom;
  final double? valueBottomLeft;
  final double? valueBottomRight;
  final double? valueLeft;
  final double? valueRight;
  final Vector2 position;

  ItemMatrixProperties(
    this.value,
    this.position, {
    this.valueTop,
    this.valueTopLeft,
    this.valueTopRight,
    this.valueBottom,
    this.valueBottomLeft,
    this.valueBottomRight,
    this.valueLeft,
    this.valueRight,
  });
  ///判断是否为中心瓦片，有一个瓦片的值，等于上下左右，左上坐下，右上右下，八个方向的值。这个值就是中心瓦片
  bool get isCenterTile {
    return valueLeft == value &&
        valueRight == value &&
        valueTop == value &&
        valueBottom == value &&
        valueBottomLeft == value &&
        valueBottomRight == value &&
        valueTopLeft == value &&
        valueTopRight == value;
  }

  @override
  String toString() {
    return 'NoiseProperties{value: $value, valueTop: $valueTop, valueTopLeft: $valueTopLeft, valueTopRight: $valueTopRight, valueBottom: $valueBottom, valueBottomLeft: $valueBottomLeft, valueBottomRight: $valueBottomRight, valueLeft: $valueLeft, valueRight: $valueRight, position: $position}';
  }
}

typedef TileModelBuilder = TileModel Function(ItemMatrixProperties properties);  ///把矩阵的数据转为TileModel

/// Class useful to create radom map.
/// * [matrix], Matrix used to create the map.
/// * [build], Builder used to create the TileModel that represents each tile in the map.
/// * [axisInverted], used to invert axis of the matrix. Example: matrix[x,y] turn matrix[y,x]. It's useful to use an easier-to-see array in code.
/// /// 类对创建随机地图很有用。
// /// * [矩阵]，用于创建地图的矩阵。
// /// * [build], Builder用于创建代表地图中每个瓦片的TileModel。
// /// * [axisInverted]，用于反转矩阵的轴。 示例：matrix[x,y] 转 matrix[y,x]。 在代码中使用更易于查看的数组很有用。
class MatrixMapGenerator {
  static WorldMap generate({
    required List<List<double>> matrix, ///原始数据
    required TileModelBuilder builder, ///建造器
    bool axisInverted = false, ///是否反转
  }) {
    List<TileModel> tiles = [];

    if (axisInverted) {
      tiles = _buildInverted(matrix, builder);
    } else {
      tiles = _buildNormal(matrix, builder);
    }

    return WorldMap(tiles);
  }

  static double? _tryGetValue(double Function() getValue) {
    try {
      return getValue();
    } catch (e) {
      return null;
    }
  }

  static List<TileModel> _buildNormal(
    List<List<double>> matrix,
    TileModelBuilder builder,
  ) {
    List<TileModel> tiles = [];
    final h = matrix.first.length;
    final w = matrix.length;
    if (kDebugMode) {
      print(matrix);
    }
    for (var x = 0; x < w; x++) {
      for (var y = 0; y < h; y++) {
        tiles.add(
          ///参数为矩阵，返回值为model
          builder(
            ///ItemMatrixProperties矩阵周围的8个值
            ItemMatrixProperties(
              matrix[x][y], ///本身的值
              Vector2(x.toDouble(), y.toDouble()), ///位置
              valueTop: _tryGetValue(() => matrix[x][y - 1]), ///上
              valueBottom: _tryGetValue(() => matrix[x][y + 1]),///下
              valueLeft: _tryGetValue(() => matrix[x - 1][y]),///左
              valueRight: _tryGetValue(() => matrix[x + 1][y]),///右
              valueBottomLeft: _tryGetValue(() => matrix[x - 1][y + 1]), ///左下
              valueBottomRight: _tryGetValue(() => matrix[x + 1][y + 1]),///右下
              valueTopLeft: _tryGetValue(() => matrix[x - 1][y - 1]),///左上
              valueTopRight: _tryGetValue(() => matrix[x + 1][y - 1]),///右上
            ),
          ),
        );
      }
    }
    return tiles;
  }
  ///根据矩阵，生成地图
  static List<TileModel> _buildInverted(
    List<List<double>> matrix,
    TileModelBuilder builder,
  ) {
    List<TileModel> tiles = []; ///初始化地图瓦片集合
    final w = matrix.first.length; ///获取宽
    final h = matrix.length; ///获取高
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {

        tiles.add(
          builder(
            ItemMatrixProperties(
              matrix[y][x],
              Vector2(x.toDouble(), y.toDouble()),
              valueTop: _tryGetValue(() => matrix[y - 1][x]),
              valueBottom: _tryGetValue(() => matrix[y + 1][x]),
              valueLeft: _tryGetValue(() => matrix[y][x - 1]),
              valueRight: _tryGetValue(() => matrix[y][x + 1]),
              valueBottomLeft: _tryGetValue(() => matrix[y + 1][x - 1]),
              valueBottomRight: _tryGetValue(() => matrix[y + 1][x + 1]),
              valueTopLeft: _tryGetValue(() => matrix[y - 1][x - 1]),
              valueTopRight: _tryGetValue(() => matrix[y - 1][x + 1]),
            ),
          ),
        );
      }
    }
    return tiles;
  }
}
