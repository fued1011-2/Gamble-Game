import Foundation

struct LocalGameState: Codable {
    var gameId: String
    var thrownDiceValues: [DiceValue]
    var selectedDice: [Dice]
    var takenDice: [Dice]
    var diceRotations: [DicePosition]
    var roundScore: Int
    var throwScore: Int
    var thrown: Bool
    var win: Bool
    var players: [Player]
    var currentPlayerIndex: Int
    var isLastRound: Bool
    var lastRoundCounter: Int
    var winnerIndex: Int
    
    mutating func reset() {
        gameId = "0";
        thrownDiceValues = [];
        selectedDice = [];
        takenDice = [];
        diceRotations = [];
        roundScore = 0;
        throwScore = 0;
        thrown = false;
        win = false;
        players = [];
        currentPlayerIndex = 0;
        isLastRound = false;
        lastRoundCounter = 0;
        winnerIndex = -1;
    }
}
