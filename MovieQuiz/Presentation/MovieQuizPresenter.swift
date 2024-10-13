import UIKit

final class MovieQuizPresenter {
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    var correctAnswers: Int = 0
    let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0

    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
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
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func didRecieveNextQuestion(question: QuizQuestion?) {
            guard let question = question else {
                return
            }
            
            currentQuestion = question
            let viewModel = convert(model: question)
            DispatchQueue.main.async { [weak self] in
                self?.viewController?.show(quiz: viewModel)
            }
        }
    
    func showNextQuestionOrResults() {
        if self.isLastQuestion() {
            viewController?.imageView.layer.borderColor = UIColor.clear.cgColor
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
            viewController?.imageView.layer.borderColor = UIColor.clear.cgColor
            self.questionFactory?.requestNextQuestion()
        }
    }
}
