import Foundation

struct GameState: Codable {
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
    var disconnectedPlayers: [Player]
    var currentPlayerIndex: Int
    var creator: Player
    var isLastRound: Bool;
    var lastRoundCounter: Int;
    var winnerIndex: Int;
    
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
        disconnectedPlayers = []
        currentPlayerIndex = 0;
        creator = Player()
        isLastRound = false
        lastRoundCounter = 0
        winnerIndex = -1
    }
}
