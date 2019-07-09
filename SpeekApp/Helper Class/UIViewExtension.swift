// MARK: - Show hide animations in StackViews
import UIKit

extension UIView {
    
    func hideAnimated(in stackView: UIStackView) {
        if !self.isHidden {
            UIView.animate(
                withDuration: 3.0,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 1,
                options: [],
                animations: {
                    self.isHidden = true
                    stackView.layoutIfNeeded()
            },
                completion: nil
            )
        }
    }
    
    func showAnimated(in stackView: UIStackView) {
        if self.isHidden {
            UIView.animate(
                withDuration: 3,
                delay: 0,
                usingSpringWithDamping: 0.9,
                initialSpringVelocity: 1,
                options: [],
                animations: {
                    self.isHidden = false
                    stackView.layoutIfNeeded()
            },
                completion: nil
            )
        }
}

}
