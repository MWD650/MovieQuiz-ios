//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Alex on /2611/22.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {                   // Создаём протокол QuestionFactoryDelegate, который будем использовать в фабрике как делегата. Мы ограничиваем наш протокол классами, используя class. Это нам понадобится дальше при создании слабых ссылок на делегат.
    func didRecieveNextQuestion(question: QuizQuestion?)   // Объявляем метод, который должен быть у делегата фабрики.
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
