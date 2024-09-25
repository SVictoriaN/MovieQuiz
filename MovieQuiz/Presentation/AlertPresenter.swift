import UIKit

final class AlertPresenter {
    weak var delegate: AlertPresenterDelegate?
     weak var viewController: UIViewController?
     
     init(viewController: UIViewController) {
         self.viewController = viewController
     }
     
     func presentAlert(with model: AlertModel?) {
         guard let model = model else { return }
         
         let alert = UIAlertController(title: model.title, message: model.message, preferredStyle: .alert)
         let action = UIAlertAction(title: model.buttonText, style: .default) { [weak self] _ in
             model.completion()
             self?.delegate?.didPresentAlert(with: model)
         }
         
         alert.addAction(action)
         viewController?.present(alert, animated: true, completion: nil)
     }
}
