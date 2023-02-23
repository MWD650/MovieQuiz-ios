//
//  MovieQuizPresenter.swift
//  MovieQuiz
//
//  Created by Alex on /232/23.
//

import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10   // Переменная отвечающаяя за количество вопросов
    private var currentQuestionIndex: Int = 0 // переменная отвечающая за индекс текущего вопроса
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func isLastQuestion() -> Bool {
            currentQuestionIndex == questionsAmount - 1
        }
        
        func resetQuestionIndex() {
            currentQuestionIndex = 0
        }
        
        func switchToNextQuestion() {
            currentQuestionIndex += 1
        }
    
//    func didRecieveNextQuestion(question: QuizQuestion?) {
//        guard let question = question else {
//            return
//        }
//
//        currentQuestion = question
//        let viewModel = convert(model: question)
//        DispatchQueue.main.async { [weak self] in
//            self?.viewController?.show(quiz: viewModel)
//        }
//    }
//
//    func didLoadDataFromServer() {
//        viewController?.hideLoadingIndicator()
//        questionFactory?.requestNextQuestion()
//    }
//
//    func didFailToLoadData(with error: Error) {
//        let message = error.localizedDescription
//        viewController?.showNetworkError(message: message)
//    }
    
    // MARK: - Func from MovieQuizController

    func convert(model: QuizQuestion) -> QuizStepViewModel { //Функция конвертации
        return QuizStepViewModel(
            image: UIImage (data: model.image) ?? UIImage(), //распаковываем картинку
            question: model.text, //берем текст вопроса
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)") //вычисляем номер вопроса
    }

    // MARK: - Actions
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
       
        viewController?.showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)

    }

}
