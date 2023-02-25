import UIKit
extension UIColor {
    static var ypGreen: UIColor {
        UIColor(named: "YP Green" ) ?? UIColor.green
    }
    static var ypRed: UIColor {
        UIColor(named: "YP Red" ) ?? UIColor.red
    }
}

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func showAlert()
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator()
    func hideLoadingIndicator()
    func showNetworkError(message: String)
}

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var yesButton: UIButton!
    @IBOutlet weak private var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    private var presenter: MovieQuizPresenter!
    var alertPresenter: AlertPresenter?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = MovieQuizPresenter(viewController: self)
        imageView.layer.cornerRadius = 20
        showLoadingIndicator()
        
    }
    
    // MARK: - Private functions
    func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию
    }
    
    func hideLoadingIndicator() {
        activityIndicator.isHidden = true
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        alertPresenter = AlertPresenter(modelShowAlert:
                                            AlertModel.init(
                                                title: "Ошибка",
                                                message: message,
                                                buttonText: "Попробовать еще раз",
                                                completion: {
                                                    self.showLoadingIndicator()
                                                    self.presenter.questionFactory?.loadData()
                                                    return self.presenter.questionFactory?.requestNextQuestion()
                                                }))
        
        alertPresenter?.viewController = self
        alertPresenter?.showAlert()
    }
    
    func showAlert(){
        let text = presenter.makeResultsMessage()
        alertPresenter = AlertPresenter(modelShowAlert: AlertModel.init(
            title: "Этот раунд окончен!",
            message: text,
            buttonText: "Сыграть ещё раз",
            completion: {
                self.presenter.restartGame()
            }))
        
        alertPresenter?.viewController = self
        alertPresenter?.showAlert()
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.layer.borderColor = UIColor.clear.cgColor
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    private func disableButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
        }
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    // MARK: - Actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
        disableButtons()
        
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
        disableButtons()
        
    }
    
}
