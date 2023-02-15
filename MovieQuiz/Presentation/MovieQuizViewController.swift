import UIKit
extension UIColor {
    static var ypGreen: UIColor {
        UIColor(named: "YP Green" ) ?? UIColor.green
    }
    static var ypRed: UIColor {
        UIColor(named: "YP Red" ) ?? UIColor.red
    }
}

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    
    private let questionsAmount: Int = 10   // Переменная отвечающаяя за количество вопросов
    private var currentQuestionIndex: Int = 0 // переменная отвечающая за индекс текущего вопроса
    private var correctAnswers: Int = 0  // переменная отвечающая за количество правельных ответов
   
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    
   
    // MARK: - Lifecycle
    override func viewDidLoad() {
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(delegate: self)
        questionFactory?.requestNextQuestion()
        statisticService = StatisticServiceImplementation()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
                return
            }
            
            currentQuestion = question
            let viewModel = convert(model: question)
           
        DispatchQueue.main.async { [weak self] in
                    self?.show(quiz: viewModel)
                }
    }
    
    // MARK: - Private functions
    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel { //Функция конвертации
        return QuizStepViewModel(
            image: UIImage (named: model.image) ?? UIImage(), //распаковываем картинку
            question: model.text, //берем текст вопроса
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)") //вычисляем номер вопроса
    }
    
    private func showAnswerResult(isCorrect: Bool) {
      
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        if isCorrect {
            correctAnswers += 1
        }
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.showNextQuestionOrResults()
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }
    
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questionsAmount - 1 { // - 1 потому что индекс
            //начинается с 0, а длинна массива — с 1 показать результат квиза
            guard let statisticService = statisticService else { return }
                      statisticService.store(correct: correctAnswers, total: questionsAmount)
            
            let text = correctAnswers == questionsAmount ? """
            Поздравляем, Вы ответили на \(questionsAmount) из \(questionsAmount)!
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """ : """
            Вы ответили на \(correctAnswers) из \(questionsAmount), попробуйте ещё раз!
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
           
            alertPresenter = AlertPresenter(modelShowAlert: AlertModel.init(title: "Этот раунд окончен!", message: text, buttonText: "Сыграть еще раз", completion: {self.currentQuestionIndex = 0
               
                self.correctAnswers = 0
                self.questionFactory?.requestNextQuestion()
                     
            }))
            alertPresenter?.viewController = self
                   showAlert()
                   imageView.layer.borderColor = nil
                   imageView.layer.borderWidth = 0
            
        } else {
            currentQuestionIndex += 1 // увеличиваем индекс текущего вопроса на 1;
            //таким образом мы сможем получить следующий вопрос
            // показать следующий вопрос
            questionFactory?.requestNextQuestion()
            imageView.layer.borderWidth = 0
            }
    }
    
    private func showAlert(){
          guard let alertPresenter = alertPresenter else { return }
          alertPresenter.showAlert()
      }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
       
        showAnswerResult(isCorrect: currentQuestion.correctAnswer)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)

    }
}
