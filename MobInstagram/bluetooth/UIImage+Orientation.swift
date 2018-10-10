//
//  UIImage+Orientation.swift
//  MultipeerDemo


import UIKit

extension UIImage {

    var withOrientationFixed: UIImage {
        guard imageOrientation != .up else { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))

        guard let fixedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            fatalError("Failed to get image from CGContext!")
        }

        UIGraphicsEndImageContext()

        return fixedImage
    }

}
