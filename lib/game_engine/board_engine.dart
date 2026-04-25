import '../data/models/tile_model.dart';

class BoardEngine {
  List<TileModel> buildBoard(int size) {
    return List.generate(
      size * size,
      (index) => TileModel(row: index ~/ size, col: index % size),
    );
  }
}
