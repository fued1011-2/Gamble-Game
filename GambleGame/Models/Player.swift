import Foundation

struct Player: Codable, Identifiable {
    var id = UUID()
    var username: String
    var score: Int
    var zeroCount = 0;
    var scoreHistory: [Int] = []
    
    init() {
        self.username = ""
        self.score = 0
    }
}
