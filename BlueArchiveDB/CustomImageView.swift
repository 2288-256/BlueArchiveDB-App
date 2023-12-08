//
//  CustomImageView.swift
//  BlueArchive Database
//
//  Created by clark on 2023/11/29.
//
import UIKit

class CustomImageView: UIImageView {
    @IBInspectable var borderColor: UIColor = UIColor.clear // Border color
    @IBInspectable var borderWidth: CGFloat = 0.0 // Border width
    @IBInspectable var cornerRadius: CGFloat = 0.0 // Corner radius

    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true // This is important for cornerRadius
    }
}
