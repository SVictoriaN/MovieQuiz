protocol StatisticServiceProtocol {
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalQuestions: Int { get }
    var totalCorrectAnswers: Int { get }
    
    func getCurrentAccuracy() -> Double
    
    func store(correct count: Int, total amount: Int)
    
}
