
import UIKit

extension UIViewController {

    func installChild(_ controller: UIViewController) {
        addChild(controller)
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        controller.view.frame = view.bounds
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
    }

}
