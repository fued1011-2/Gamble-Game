import Foundation

class LocalGameController {
    
    func createRandomDiceRotations() -> [DicePosition] {
        func randomFloat(min: Float, max: Float) -> Float {
            return Float.random(in: min...max)
        }
        
        var rotations: [DicePosition] = []
        for _ in 0..<6 {
            let rotation = DicePosition(
                x: randomFloat(min: -Float.pi, max: Float.pi),
                y: randomFloat(min: -Float.pi, max: Float.pi),
                z: randomFloat(min: -Float.pi, max: Float.pi)
            )
            rotations.append(rotation)
        }
        return rotations
    }
    
    func zero(game: LocalGameState) -> LocalGameState {
        var mutableGame  = game
        let playerIndex = mutableGame.currentPlayerIndex
        
        mutableGame.players[playerIndex].zeroCount += 1

        if mutableGame.players[playerIndex].zeroCount == 3 {
            if mutableGame.players[playerIndex].score > 0 {
                mutableGame.players[playerIndex].score -= 500
                if mutableGame.players[playerIndex].score < 0 {
                    mutableGame.players[playerIndex].score = 0
                }
            }
            mutableGame.players[playerIndex].zeroCount = 0
        }

        mutableGame.players[playerIndex].scoreHistory.append(mutableGame.players[playerIndex].score)
        mutableGame.takenDice.removeAll()
        mutableGame.selectedDice.removeAll()
        mutableGame.roundScore = 0
        mutableGame.throwScore = 0
        mutableGame.thrown = false
        mutableGame.currentPlayerIndex = (playerIndex + 1) % mutableGame.players.count
        
        return mutableGame
    }
    
    func calculateThrowScore(game: inout LocalGameState) {
        game.throwScore = 0
        let diceValues = game.selectedDice.map { $0.value }
        print(diceValues)
        let diceCount = game.selectedDice.count
        print("DiceCount: \(diceCount)")

        if diceCount < 3 {
            calculateSingleDiceScores(game: &game)
        } else if diceCount == 3 {
            calculateTripleScores(game: &game, diceValues: diceValues)
        } else if diceCount == 4 {
            calculateQuadrupleScores(game: &game, diceValues: diceValues)
        } else if diceCount == 5 {
            calculateQuintupleScores(game: &game, diceValues: diceValues)
        } else if diceCount == 6 {
            calculateSextupleScores(game: &game, diceValues: diceValues)
        }

        print("Throw score: \(game.throwScore)")
    }

    private func calculateSingleDiceScores(game: inout LocalGameState) {
        print("calculateSingleDiceScores")
        game.selectedDice.forEach { die in
            if die.value == 1 {
                game.throwScore += 100
            } else if die.value == 5 {
                game.throwScore += 50
            }
        }
    }

    private func calculateTripleScores(game: inout LocalGameState, diceValues: [Int]) {
        if diceValues.allSatisfy({ $0 == diceValues[0] }) {
            game.throwScore += diceValues[0] == 1 ? 1000 : diceValues[0] * 100
        } else {
            calculateSingleDiceScores(game: &game)
        }
    }

    private func calculateQuadrupleScores(game: inout LocalGameState, diceValues: [Int]) {
        if diceValues.allSatisfy({ $0 == diceValues[0] }) {
            game.throwScore += diceValues[0] == 1 ? 2000 : diceValues[0] * 200
        } else {
            calculateMixedQuadrupleScores(game: &game, diceValues: diceValues)
        }
    }

    private func calculateMixedQuadrupleScores(game: inout LocalGameState, diceValues: [Int]) {
        let numberWithThreeOccurrences = findNumberWithOccurrences(diceValues, count: 3)
        let numberWithOneOccurrence = diceValues.first { $0 != numberWithThreeOccurrences }

        if numberWithThreeOccurrences != 0 {
            game.throwScore += numberWithThreeOccurrences == 1 ? 1000 : numberWithThreeOccurrences * 100

            if numberWithOneOccurrence == 1 {
                game.throwScore += 100
            } else if numberWithOneOccurrence == 5 {
                game.throwScore += 50
            }
        } else {
            calculateSingleDiceScores(game: &game)
        }
    }

    private func calculateQuintupleScores(game: inout LocalGameState, diceValues: [Int]) {
        if diceValues.allSatisfy({ $0 == diceValues[0] }) {
            game.throwScore += diceValues[0] == 1 ? 4000 : diceValues[0] * 400
        } else {
            calculateMixedQuintupleScores(game: &game, diceValues: diceValues)
        }
    }

    private func calculateMixedQuintupleScores(game: inout LocalGameState, diceValues: [Int]) {
        let numberWithFourOccurrences = findNumberWithOccurrences(diceValues, count: 4)
        let numberWithOneOccurrence = diceValues.first { $0 != numberWithFourOccurrences }

        if numberWithFourOccurrences != 0 {
            game.throwScore += numberWithFourOccurrences == 1 ? 2000 : numberWithFourOccurrences * 200

            if numberWithOneOccurrence == 1 {
                game.throwScore += 100
            } else if numberWithOneOccurrence == 5 {
                game.throwScore += 50
            }
        } else {
            calculateMixedTripleFromQuintupleScores(game: &game, diceValues: diceValues)
        }
    }

    private func calculateMixedTripleFromQuintupleScores(game: inout LocalGameState, diceValues: [Int]) {
        let numberWithThreeOccurrences = findNumberWithOccurrences(diceValues, count: 3)
        let otherNumbers = diceValues.filter { $0 != numberWithThreeOccurrences }

        if numberWithThreeOccurrences != 0 {
            game.throwScore += numberWithThreeOccurrences == 1 ? 1000 : numberWithThreeOccurrences * 100

            otherNumbers.forEach { number in
                if number == 1 {
                    game.throwScore += 100
                } else if number == 5 {
                    game.throwScore += 50
                }
            }
        } else {
            calculateSingleDiceScores(game: &game)
        }
    }

    private func calculateSextupleScores(game: inout LocalGameState, diceValues: [Int]) {
        print("calculateSextupleScores")
        if diceValues.allSatisfy({ $0 == diceValues[0] }) {
            game.throwScore += diceValues[0] == 1 ? 8000 : diceValues[0] * 800
        } else if isThreePairs(diceValues.map {(diceValue: Int) -> DiceValue in
            return DiceValue(value: diceValue, diceName: "")
        }) {
            game.throwScore += 750
        } else if isStreet(diceValues.map {(diceValue: Int) -> DiceValue in
            return DiceValue(value: diceValue, diceName: "")
        }) {
            game.throwScore += 1500
        } else {
            calculateMixedSextupleScores(game: &game, diceValues: diceValues)
        }
    }

    private func calculateMixedSextupleScores(game: inout LocalGameState, diceValues: [Int]) {
        print("calculateMixedSextupleScores")
        let numberWithFiveOccurrences = findNumberWithOccurrences(diceValues, count: 5)
        let numberWithOneOccurrence = diceValues.first { $0 != numberWithFiveOccurrences }

        if numberWithFiveOccurrences != 0 {
            print(numberWithFiveOccurrences)
            game.throwScore += numberWithFiveOccurrences == 1 ? 4000 : numberWithFiveOccurrences * 400

            if numberWithOneOccurrence == 1 {
                game.throwScore += 100
            } else if numberWithOneOccurrence == 5 {
                game.throwScore += 50
            }
        } else {
            calculateMixedQuadrupleScoresFromSextuple(game: &game, diceValues: diceValues)
        }
    }

    private func calculateMixedQuadrupleScoresFromSextuple(game: inout LocalGameState, diceValues: [Int]) {
        print("calculateMixedQuadrupleScoresFromSextuple")

        let numberWithFourOccurrences = findNumberWithOccurrences(diceValues, count: 4)
        let otherNumbers = diceValues.filter { $0 != numberWithFourOccurrences }

        if numberWithFourOccurrences != 0 {
            game.throwScore += numberWithFourOccurrences == 1 ? 2000 : numberWithFourOccurrences * 200

            otherNumbers.forEach { number in
                if number == 1 {
                    game.throwScore += 100
                } else if number == 5 {
                    game.throwScore += 50
                }
            }
        } else {
            calculateMixedTriplesScoresFromSextuple(game: &game, diceValues: diceValues)
        }
    }

    private func calculateMixedTriplesScoresFromSextuple(game: inout LocalGameState, diceValues: [Int]) {
        print("calculateMixedTriplesScoresFromSextuple")
        let numbersWithThreeOccurrences = findNumbersWithOccurrences(diceValues, count: 3)
        let otherNumbers = diceValues.filter { $0 != numbersWithThreeOccurrences[0] }

        if numbersWithThreeOccurrences.count == 2 {
            print("numbersWithThreeOccurrences == 2")
            numbersWithThreeOccurrences.forEach { key in
                calculateTripleScores(game: &game, diceValues: Array(repeating: key, count: 3))
            }
        } else if numbersWithThreeOccurrences.count == 1 {
            print("numbersWithThreeOccurrences == 1")
            print("Other numbers \(otherNumbers)")
            game.throwScore += numbersWithThreeOccurrences[0] == 1 ? 2000 : numbersWithThreeOccurrences[0] * 100

            otherNumbers.forEach { number in
                if number == 1 {
                    game.throwScore += 100
                } else if number == 5 {
                    game.throwScore += 50
                }
            }
        } else {
            calculateSingleDiceScores(game: &game)
        }
    }
    
    private func findNumberWithOccurrences(_ array: [Int], count: Int) -> Int {
        let frequencyDictionary = array.reduce(into: [:]) { counts, number in
            counts[number, default: 0] += 1
        }
        
        if let entry = frequencyDictionary.first(where: { $0.value == count }) {
            return entry.key
        }
        
        return 0
    }

    private func findNumbersWithOccurrences(_ array: [Int], count: Int) -> [Int] {
        let frequencyDictionary = array.reduce(into: [:]) { counts, number in
            counts[number, default: 0] += 1
        }
        
        return frequencyDictionary
            .filter { $0.value == count }
            .map { $0.key }
    }
    
    func isThreePairs(_ array: [DiceValue]) -> Bool {
        let values = array.map { $0.value }
        let frequencyDictionary = findAllNumbersWithCount(values)
        return frequencyDictionary.values.filter { $0 == 2 }.count == 3
    }

    func isStreet(_ array: [DiceValue]) -> Bool {
        let values = array.map { $0.value }
        let uniqueValues = Set(values)
        return uniqueValues.count == array.count && uniqueValues.count == 6
    }

    func findAllNumbersWithCount(_ array: [Int]) -> [Int: Int] {
        var frequencyDictionary: [Int: Int] = [:]
        for number in array {
            frequencyDictionary[number, default: 0] += 1
        }
        return frequencyDictionary
    }
}
