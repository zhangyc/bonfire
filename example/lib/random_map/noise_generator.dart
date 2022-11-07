import 'package:example/random_map/map_generator.dart';
import 'package:fast_noise/fast_noise.dart';

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
/// 产生噪音
List<List<double>> generateNoise(Map<String, dynamic> data) {
  ///获取隔离main方法中传递的参数
  final original = noise2(
    data['w'],
    data['h'],
    seed: data['seed'],
    frequency: data['frequency'],
    noiseType: data['noiseType'],
    cellularDistanceFunction: data['cellularDistanceFunction'],
  );
  ///实例化为宽高
  int width = original.length;
  int height = original.first.length;
  ///自动生成新的矩阵，根据地图的宽和高
  List<List<double>> newMatrix = List<List<double>>.generate(
    width,
    (_) => List<double>.generate(height, (_) => .0),
  );

  /// Normalises the matrix creating 3 categories: Water,Earth and Grass
  ///  标准化矩阵创建 3 个类别：水、地球和草
  for (var x = 0; x < width; x++) {
    for (var y = 0; y < height; y++) {
      double newValue = 0;
      if (original[x][y] > -0.35) {
        newValue = MapGenerator.TILE_WATER;  ///当某行某列的一个值大于-0.35那么这个值设置为水
      }

      if (original[x][y] > -0.1) {
        newValue = MapGenerator.TILE_SAND; ///当某行某列的一个值大于-0.1那么这个值设置为沙
      }

      if (original[x][y] > 0.1) {
        newValue = MapGenerator.TILE_GRASS;///当某行某列的一个值大于0.1那么这个值设置为草
      }
      newMatrix[x][y] = newValue;  ///不满足三个条件的初始化为0
    }
  }
  return newMatrix;
}
