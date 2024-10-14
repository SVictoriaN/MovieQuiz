import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Lifecycle
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak private var textLabel: UILabel!
    @IBOutlet weak private var counterLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticService: StatisticServiceProtocol?
    private var presenter: MovieQuizPresenter!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoadingIndicator()
        configureView()
        
        presenter = MovieQuizPresenter(viewController: self)
        
        activityIndicator.hidesWhenStopped = true
        presenter.resetQuestionIndex()
        
        showLoadingIndicator()
        
        alertPresenter = AlertPresenter(viewController: self)
        
        statisticService = StatisticService()
    }

    
    // MARK: - Actions
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    // MARK: - Private functions
    
    private func configureView() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
    }
    
    func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }
    
    func showAnswerResult(isCorrect: Bool) {
        presenter.didAnswer(isCorrectAnswer: isCorrect)
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.presenter.showNextQuestionOrResults()
        }
    }
    
    func show(quiz result: QuizResultsViewModel) {
        guard let statisticService = statisticService else { return }
        statisticService.store(correct: presenter.correctAnswers, total: presenter.questionsAmount)
        
        let gamesCount = statisticService.gamesCount
        let bestGame = statisticService.bestGame
        let formattedDate = (bestGame.date).dateTimeString
        
        let accuracy = statisticService.getCurrentAccuracy()
        let accuracyString = String(format: "%.2f", accuracy)
        
        let message = """
     Ваш результат: \(presenter.correctAnswers) / \(presenter.questionsAmount) \n
     Количество сыгранных квизов: \(gamesCount)\n
     Рекорд: \(bestGame.correct) из \(bestGame.total) (дата: \(formattedDate))\n
     Средняя точность: \(accuracyString)%\n
     """
        
        let alertModel = AlertModel(
            title: result.title,
            message: message,
            buttonText: result.buttonText,
            completion: { [weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.presenter.restartGame()
            }
        )
        
        alertPresenter?.presentAlert(with: alertModel)
        alertPresenter?.delegate?.didPresentAlert(with: alertModel)
    }

    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.presenter.resetQuestionIndex()
            
            self.presenter.restartGame()
        }
        
        alertPresenter?.show(in: self, model: model)
    }
}

/*
 Mock-данные
 
 
 Картинка: The Godfather
 Настоящий рейтинг: 9,2
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Dark Knight
 Настоящий рейтинг: 9
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Kill Bill
 Настоящий рейтинг: 8,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Avengers
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Deadpool
 Настоящий рейтинг: 8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: The Green Knight
 Настоящий рейтинг: 6,6
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: ДА
 
 
 Картинка: Old
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: The Ice Age Adventures of Buck Wild
 Настоящий рейтинг: 4,3
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Tesla
 Настоящий рейтинг: 5,1
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 
 
 Картинка: Vivarium
 Настоящий рейтинг: 5,8
 Вопрос: Рейтинг этого фильма больше чем 6?
 Ответ: НЕТ
 */
