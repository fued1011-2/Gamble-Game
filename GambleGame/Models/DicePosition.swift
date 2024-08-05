//
//  DicePosition.swift
//  GambleGame
//
//  Created by Edgar Fuchs on 24.07.24.
//

import Foundation

struct DicePosition: Codable {
    var x: Float
    var y: Float
    var z: Float
    
    init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }
}
