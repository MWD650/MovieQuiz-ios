//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Alex on /142/23.
//

import Foundation
protocol StatisticService {
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}



