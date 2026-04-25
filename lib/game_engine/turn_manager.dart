class TurnManager {
  bool isPlayerTurn = true;

  void toggleTurn() {
    isPlayerTurn = !isPlayerTurn;
  }
}
