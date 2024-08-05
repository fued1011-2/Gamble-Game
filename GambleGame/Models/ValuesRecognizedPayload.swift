import Foundation

struct ValuesRecognizedPayload: Codable {
    let gameId: String
    let dice: [Dice]
}
