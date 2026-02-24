import '../screens/wordle_game_screen.dart';

class ReplayData {
  final String targetWord;
  final List<CellData> hintRow;

  const ReplayData({
    required this.targetWord,
    required this.hintRow,
  });
}
