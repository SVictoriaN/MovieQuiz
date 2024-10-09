import Foundation

final class StatisticService: StatisticServiceProtocol {
    
    private let storage = UserDefaults.standard
    private enum Keys: String {
        case correct
        case bestGame
        case gamesCount
        case total
        case date
        case totalAccuracy
        case totalCorrectAnswers
        case totalQuestions
    }
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.correct.rawValue)
            let total = storage.integer(forKey: Keys.total.rawValue)
            let date = storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
            
            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    var totalCorrectAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }
    
    var totalQuestions: Int {
        get {
            storage.integer(forKey: Keys.totalQuestions.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestions.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        get {
            return storage.double(forKey: Keys.totalAccuracy.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalAccuracy.rawValue)
        }
    }
    
    func getCurrentAccuracy() -> Double {
        guard totalQuestions > 0 else { return 0.0 }
        return (Double(totalCorrectAnswers) / Double(totalQuestions)) * 100.0
    }
    
    func store(correct count: Int, total amount: Int) {
        gamesCount += 1
        totalCorrectAnswers += count
        totalQuestions += amount
        guard totalCorrectAnswers > 0 else { return }
        let newAccuracy = Double(totalCorrectAnswers) / Double(totalQuestions) * 100.0
        totalAccuracy = newAccuracy
        
        let currentGameResult = GameResult(correct: count, total: amount, date: Date())
        if currentGameResult.isBetterThan(bestGame) {
            bestGame = currentGameResult
        }
    }
}




