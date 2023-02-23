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
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
//    private let questionsAmount: Int = 10   // Переменная отвечающаяя за количество вопросов
//    private var currentQuestionIndex: Int = 0 // переменная отвечающая за индекс текущего вопроса
    private var correctAnswers: Int = 0  // переменная отвечающая за количество правельных ответов
   
    private let presenter = MovieQuizPresenter()
    
    private var questionFactory: QuestionFactoryProtocol?

    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticService?
    
   
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        
        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticServiceImplementation()
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    // MARK: - QuestionFactoryDelegate
    func didRecieveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
                return
            }
            
        presenter.currentQuestion = question
        let viewModel = presenter.convert(model: question)
           
        DispatchQueue.main.async { [weak self] in
                    self?.show(quiz: viewModel)
                }
    }
   
    func didLoadDataFromServer() {
           hideLoadingIndicator()
           questionFactory?.requestNextQuestion()
        }

        func didFailToLoadData(with error: Error) {
            showNetworkError(message: error.localizedDescription)
        }
    
    // MARK: - Private functions
    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    private func hideLoadingIndicator() {
           activityIndicator.isHidden = true
       }
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        alertPresenter = AlertPresenter(modelShowAlert:
                                                    AlertModel.init(
                                                        title: "Ошибка",
                                                        message: message,
                                                        buttonText: "Попробовать еще раз",
                                                        completion: {
                                                            self.showLoadingIndicator()
                                                            self.questionFactory?.loadData()
                                                            return self.questionFactory?.requestNextQuestion()
                                                        }))
        self.presenter.resetQuestionIndex()
        self.correctAnswers = 0
        alertPresenter?.viewController = self
                showAlert()
    }
    
    private func showAlert() {
            guard let alertPresenter = alertPresenter else { return }
            alertPresenter.showAlert()
        }
    
    private func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    
    
    func showAnswerResult(isCorrect: Bool) {
      
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
        if presenter.isLastQuestion() { // - 1 потому что индекс
            //начинается с 0, а длинна массива — с 1 показать результат квиза
            guard let statisticService = statisticService else { return }
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            
            let text = correctAnswers == presenter.questionsAmount ? """
            Поздравляем, Вы ответили на \(presenter.questionsAmount) из \(presenter.questionsAmount)!
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """ : """
            Вы ответили на \(correctAnswers) из \(presenter.questionsAmount), попробуйте ещё раз!
            Количество сыгранных квизов: \(statisticService.gamesCount)
            Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
            Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
            """
           
            alertPresenter = AlertPresenter(modelShowAlert: AlertModel.init(title: "Этот раунд окончен!", message: text, buttonText: "Сыграть еще раз", completion: {self.presenter.resetQuestionIndex()
               
                self.correctAnswers = 0
                return self.questionFactory?.requestNextQuestion()
                     
            }))
            alertPresenter?.viewController = self
                   showAlert()
                   imageView.layer.borderColor = nil
                   imageView.layer.borderWidth = 0
            
        } else {
            presenter.switchToNextQuestion() // увеличиваем индекс текущего вопроса на 1;
            //таким образом мы сможем получить следующий вопрос
            // показать следующий вопрос
            questionFactory?.requestNextQuestion()
            imageView.layer.borderWidth = 0
            }
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = presenter.currentQuestion
        presenter.yesButtonClicked()
            
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = presenter.currentQuestion
        presenter.noButtonClicked()

    }
}
