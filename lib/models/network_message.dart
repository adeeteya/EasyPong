class PaddleInput {
  PaddleInput(this.dy);
  double dy;

  Map<String, dynamic> toJson() => {'dy': dy};
  static PaddleInput fromJson(Map<String, dynamic> json) =>
      PaddleInput(json['dy'] as double);
}

class GameStateMessage {
  GameStateMessage({
    required this.leftPaddleY,
    required this.rightPaddleY,
    required this.ballX,
    required this.ballY,
    required this.leftScore,
    required this.rightScore,
  });

  double leftPaddleY;
  double rightPaddleY;
  double ballX;
  double ballY;
  int leftScore;
  int rightScore;

  Map<String, dynamic> toJson() => {
    'leftPaddleY': leftPaddleY,
    'rightPaddleY': rightPaddleY,
    'ballX': ballX,
    'ballY': ballY,
    'leftScore': leftScore,
    'rightScore': rightScore,
  };

  static GameStateMessage fromJson(Map<String, dynamic> json) {
    return GameStateMessage(
      leftPaddleY: (json['leftPaddleY'] as num).toDouble(),
      rightPaddleY: (json['rightPaddleY'] as num).toDouble(),
      ballX: (json['ballX'] as num).toDouble(),
      ballY: (json['ballY'] as num).toDouble(),
      leftScore: json['leftScore'] as int,
      rightScore: json['rightScore'] as int,
    );
  }
}
