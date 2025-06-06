import UIKit
import SocketIO

class GameClient {
    private var manager: SocketManager!
    private var socket: SocketIOClient!
    weak var delegate: GameClientDelegate?

    init() {
        manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
        socket = manager.defaultSocket
        setupSocket()
    }

    private func setupSocket() {
        socket.on(clientEvent: .connect) { data, ack in
            print("Socket connected")
        }

        socket.on("gameCreated") { [weak self] data, ack in
                    if let gameData = data[0] as? [String: Any] {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: gameData)
                            let game = try JSONDecoder().decode(GameState.self, from: jsonData)
                            self?.delegate?.didCreateGame(game)
                        } catch {
                            print("Error decoding game state: \(error)")
                        }
                    }
                }

        socket.on("gameJoined") { [weak self] data, ack in
            if let gameData = data[0] as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: gameData)
                    let game = try JSONDecoder().decode(GameState.self, from: jsonData)
                    self?.delegate?.didUpdateGame(game)
                } catch {
                    print("Error decoding game state: \(error)")
                }
            }
        }
        
        socket.on("gameIdChecked") {data, ack in
            if let gameExists = data[0] as? Bool {
                self.delegate?.didCheckIfGameExists(gameExists)
                print("Game ID checked: \(gameExists)")
            }
        }
        
        socket.on("playerJoined") { [weak self] data, ack in
            if let gameData = data[0] as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: gameData)
                    let game = try JSONDecoder().decode(GameState.self, from: jsonData)
                    self?.delegate?.didUpdateGame(game)
                } catch {
                    print("Error decoding game state: \(error)")
                }
            }
        }
        
        socket.on("usernameChanged") { [weak self] data, ack in
            if let gameData = data[0] as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: gameData)
                    let game = try JSONDecoder().decode(GameState.self, from: jsonData)
                    self?.delegate?.didUpdateGame(game)
                } catch {
                    print("Error decoding game state: \(error)")
                }
            }
        }
        
        socket.on("playerRemoved") { [weak self] data, ack in
            print("playerRemoved")
            
            // Check if data contains at least one element
            guard let firstElement = data.first else {
                print("No data received")
                return
            }
            
            print("Received data: \(String(describing: data))");
            
            // Attempt to cast the first element to [String: Any]
            if let gameData = firstElement as? [String: Any] {
                // Check if "updatedGame" and "removedUsername" keys exist in gameData
                guard let updatedGameData = gameData["game"] as? [String: Any],
                      let removedUsername = gameData["removedUsername"] as? String else {
                    print("Missing required data")
                    return
                }
                
                do {
                    print("Updated Game: \(updatedGameData)")
                    print("Removed Username: \(removedUsername)")
                    
                    // Convert updatedGameData to Data
                    let jsonData = try JSONSerialization.data(withJSONObject: updatedGameData)
                    
                    // Decode the jsonData into GameState
                    let game = try JSONDecoder().decode(GameState.self, from: jsonData)
                    
                    DispatchQueue.main.async {
                        self?.delegate?.didRemovePlayer(game: game, removedUsername: removedUsername)
                    }
                } catch {
                    print("Error decoding game state: \(error)")
                }
            } else {
                print("Could not cast data to [String: Any]")
            }
        }
        
        socket.on("gameStarted") {_,_ in
            self.delegate?.didStartGame()
        }
        
        socket.on("lastRound") { [weak self] data, ack in
            if let gameData = data[0] as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: gameData)
                    let game = try JSONDecoder().decode(GameState.self, from: jsonData)
                    self?.delegate?.didStartFinalRounds(game)
                } catch {
                    print("Error decoding game state: \(error)")
                }
            }
        }
        
        socket.on("diceRolled") { [weak self] data, ack in
                    if let gameData = data[0] as? [String: Any] {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: gameData)
                            let game = try JSONDecoder().decode(GameState.self, from: jsonData)
                            self?.delegate?.didRollDice(game)
                        } catch {
                            print("Error decoding game state: \(error)")
                        }
                    }
                }

        socket.on("diceSelectionChanged") { [weak self] data, ack in
                    guard let data = data[0] as? [String: Any],
                          let index = data["index"] as? Int,
                          let gameData = data["game"] as? [String: Any],
                          let jsonData = try? JSONSerialization.data(withJSONObject: gameData),
                          let game = try? JSONDecoder().decode(GameState.self, from: jsonData) else {
                              print("Error: Could not parse data from diceSelectionChanged event")
                              return
                          }
                    
                    self?.delegate?.didSelectDice(index: index, game: game)
                }

        socket.on("roundScoreCalculated") { [weak self] data, ack in
            if let gameData = data[0] as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: gameData)
                    let game = try JSONDecoder().decode(GameState.self, from: jsonData)
                    self?.delegate?.didCalculateRoundScore(game)
                } catch {
                    print("Error decoding game state: \(error)")
                }
            }
        }
        
        socket.on("throwScoreCalculated") { [weak self] data, ack in
            if let gameData = data[0] as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: gameData)
                    let game = try JSONDecoder().decode(GameState.self, from: jsonData)
                    self?.delegate?.didUpdateGame(game)
                } catch {
                    print("Error decoding game state: \(error)")
                }
            }
        }

        socket.on("roundEnded") { [weak self] data, ack in
            if let gameData = data[0] as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: gameData)
                    let game = try JSONDecoder().decode(GameState.self, from: jsonData)
                    self?.delegate?.didEndRound(game)
                } catch {
                    print("Error decoding game state: \(error)")
                }
            }
        }

        socket.on("zeroed") { [weak self] data, ack in
            if let gameData = data[0] as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: gameData)
                    let game = try JSONDecoder().decode(GameState.self, from: jsonData)
                    self?.delegate?.didEndRound(game)
                } catch {
                    print("Error decoding game state: \(error)")
                }
            }
        }

        socket.on("selectedDiceChecked") { data, ack in
            if let isValid = data[0] as? Bool {
                self.delegate?.didReceiveValidation(isValid)
                print("Selected dice checked: \(isValid)")
            }
        }
        
        socket.on("thrownDiceChecked") { data, ack in
            if let isValid = data[0] as? Bool {
                self.delegate?.didReceiveValidation(isValid)
                print("Thrown dice checked: \(isValid)")
            }
        }
        
        socket.on("receivedDiceValues") { data, ack in
            guard let diceData = data[0] as? [[String: Any]] else {
                print("Failed to parse received dice data")
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: diceData, options: [])
                let diceValues = try decoder.decode([DiceValue].self, from: jsonData)
                self.delegate?.didReceiveFinalDiceValues(diceValues)
                print("Received DiceValues: \(diceValues)")
            } catch {
                print("Failed to decode dice values: \(error.localizedDescription)")
            }
        }
        
        socket.on("playerDidLeave") {data, ack in
            print("recievedPlayerDidLeave")
            if let username = data[0] as? String {
                print("Username: \(username)")
                self.delegate?.didLeaveGame(username)
            }
        }
        
        socket.on("creatorChanged") { [weak self] data, ack in
            print("creatorChanged")
            if let gameData = data[0] as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: gameData)
                    let game = try JSONDecoder().decode(GameState.self, from: jsonData)
                    self?.delegate?.didChangeCreator(game)
                } catch {
                    print("Error decoding game state: \(error)")
                }
            }
        }
        
        socket.on("deductedPointsFromPlayer") { [weak self] data, ack in
            print("deductedPointsFromPlayer")
            if let gameData = data[0] as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: gameData)
                    let game = try JSONDecoder().decode(GameState.self, from: jsonData)
                    self?.delegate?.didUpdateGame(game)
                } catch {
                    print("Error decoding game state: \(error)")
                }
            }
        }
        
        socket.on("gameWon") {data, ack in
            if let playerId = data[0] as? Int {
                print("gameWon: \(playerId)")
                self.delegate?.didWinGame(playerId)
            }
        }
    }

    func connect() {
        socket.connect()
    }

    func createGame(gameId: String, username: String) {
        socket.emit("createGame", ["gameId": gameId, "username": username])
    }

    func joinGame(gameId: String, username: String) {
        socket.emit("joinGame", ["gameId": gameId, "username": username])
    }
    
    func checkIfGameExists(gameId: String) {
        socket.emit("checkIfGameExists", gameId)
    }
    
    func changeUsername(gameId: String, index: Int, newUsername: String) {
        socket.emit("changeUsername", ["gameId": gameId, "index": index, "newUsername": newUsername])
    }
    
    func removePlayerFromGame(gameId: String, index: Int) {
        socket.emit("removePlayer", ["gameId": gameId, "index": index])
    }
    
    func startGame(gameId: String) {
        socket.emit("startGame", gameId)
    }

    func rollDice(gameId: String) {
        socket.emit("rollDice", gameId)
    }

    func diceSelected(gameId: String, index: Int, value: Int) {
        socket.emit("diceSelected", ["gameId": gameId, "index": index, "value": value])
    }

    func unselectDice(gameId: String, index: Int) {
        socket.emit("unselectDice", ["gameId": gameId, "index": index])
    }
    
    func valuesRecognized(gameId: String, dice: [Dice]) {
        print("Recognize values")
        let payload: [String: Any] = ["gameId": gameId, "dice": dice.map { ["value": $0.value] }]
        socket.emit("valuesRecognized", payload)
        print("Values Recognized: \(payload)")
    }

    func calculateRoundScore(gameId: String) {
        socket.emit("calculateRoundScore", gameId)
    }
    
    func calculateThrowScore(gameId: String) {
        socket.emit("calculateThrowScore", gameId)
    }

    func endRound(gameId: String) {
        socket.emit("endRound", gameId)
    }

    func zero(gameId: String) {
        socket.emit("zero", gameId)
    }

    func checkSelectedDice(gameId: String) {
        socket.emit("checkSelectedDice", gameId)
    }
    
    func checkThrownDiceValues(gameId: String) {
        socket.emit("checkThrownDiceValues", gameId)
    }
    
    func deductPointsFromPlayer(gameId: String, selectedPlayer: Player) {
        socket.emit("deductPointsFromPlayer", ["gameId": gameId, "username": selectedPlayer.username])
    }
    
    func leaveGame(gameId: String, username: String) {
        socket.emit("playerLeft", ["gameId": gameId, "username": username])
    }

    func disconnect() {
        socket.disconnect()
    }
    
    func syncDice(gameId: String, diceValues: [DiceValue]) {
        let encoder = JSONEncoder()
        do {
            let diceData = try encoder.encode(diceValues)
            if let diceArray = try JSONSerialization.jsonObject(with: diceData, options: []) as? [[String: Any]] {
                let payload: [String: Any] = ["gameId": gameId, "diceValues": diceArray]
                socket.emit("syncDice", payload)
            } else {
                print("Failed to serialize JSON")
            }
        } catch {
            print("Failed to encode dice values: \(error.localizedDescription)")
        }
    }
}
