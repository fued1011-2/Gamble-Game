import Foundation

struct DiceValue: Identifiable, Equatable, Codable, Hashable {
    var id = UUID()
    var value: Int
    var diceName: String
}
