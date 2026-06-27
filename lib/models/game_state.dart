class GameState {
  int currentStage;
  int highScore;
  int totalScore;
  int bestMoves;
  int bestTime;

  GameState({
    this.currentStage = 1,
    this.highScore = 0,
    this.totalScore = 0,
    this.bestMoves = 0,
    this.bestTime = 0,
  });

  Map<String, dynamic> toJson() => {
        'currentStage': currentStage,
        'highScore': highScore,
        'totalScore': totalScore,
        'bestMoves': bestMoves,
        'bestTime': bestTime,
      };

  factory GameState.fromJson(Map<String, dynamic> json) => GameState(
        currentStage: json['currentStage'] as int? ?? 1,
        highScore: json['highScore'] as int? ?? 0,
        totalScore: json['totalScore'] as int? ?? 0,
        bestMoves: json['bestMoves'] as int? ?? 0,
        bestTime: json['bestTime'] as int? ?? 0,
      );
}
