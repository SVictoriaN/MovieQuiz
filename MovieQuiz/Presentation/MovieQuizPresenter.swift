import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate {
    private var statisticService: StatisticServiceProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private var currentQuestion: QuizQuestion?
    private var correctAnswers: Int = 0
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        let message = error.localizedDescription
        viewController?.showNetworkError(message: message)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)")
    }
    
    @IBAction func noButtonClicked() {
        answerGiven(answer: false)
    }
    @IBAction func yesButtonClicked() {
        answerGiven(answer: true)
    }
    
    private func answerGiven(answer: Bool) {
        guard let currentQuestion = currentQuestion else {
            return
        }
        let givenAnswer = answer
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.proceedToNextQuestionOrResults()
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            statisticService?.store(correct: correctAnswers, total: questionsAmount)
            
            let text: String = correctAnswers == self.questionsAmount ?
            "Поздравляем, вы ответили на 10 из 10!" :
            "Вы ответили на \(correctAnswers) из 10, попробуйте ещё раз!"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            
            viewController?.show(quiz: viewModel)
        } else {
            switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    func makeResultsMessage() -> String {
        guard let statisticService = statisticService else { return "Ошибка: статистика недоступна" }
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let gamesCount = statisticService.gamesCount
        let bestGame = statisticService.bestGame
        let formattedDate = (bestGame.date).dateTimeString
        
        let accuracy = statisticService.getCurrentAccuracy()
        let accuracyString = String(format: "%.2f", accuracy)
        
        
        let currentGameResultLine = "Ваш результат: \(correctAnswers) / \(questionsAmount)"
        let totalPlaysCountLine = "Количество сыгранных квизов: \(gamesCount)"
        let bestGameInfoLine = "Рекорд: \(bestGame.correct) из \(bestGame.total) (дата: \(formattedDate))"
        let averageAccuracyLine = "Средняя точность: \(accuracyString)%"
        
        let resultMessage = [
            currentGameResultLine, totalPlaysCountLine, bestGameInfoLine, averageAccuracyLine
        ].joined(separator: "\n")
        
        return resultMessage
    }
}
