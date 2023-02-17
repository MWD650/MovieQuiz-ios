//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Alex on /132/23.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion:() -> Void?
}
