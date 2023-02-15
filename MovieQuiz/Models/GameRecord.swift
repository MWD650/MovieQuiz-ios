//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Alex on /152/23.
//

import Foundation

struct GameRecord: Codable, Comparable {
    let correct: Int
    let total: Int
    let date: Date
    
    static func < (previousRecord: GameRecord, currentRecord: GameRecord) -> Bool {
        return previousRecord.correct < currentRecord.correct
    }
}
