//
//  UIViewController+Children.swift
//  MultipeerDemo


import UIKit

extension UIViewController {

    func installChild(_ controller: UIViewController) {
        addChildViewController(controller)
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        controller.view.frame = view.bounds
        view.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
    }

}
