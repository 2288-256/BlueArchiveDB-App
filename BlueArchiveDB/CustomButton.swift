//
//  CustomButton.swift
//  BlueArchive Database
//
//  Created by clark on 2023/11/22.
//

import Foundation
import UIKit

class CustomButton: UIButton {
    // @IBInspectable のアノテーションを設定することでカスタムプロパティを追加することができる
    @IBInspectable var borderColor: UIColor = UIColor.clear // 枠線の色
    @IBInspectable var borderWidth: CGFloat = 0.0 // 枠線の太さ
    @IBInspectable var cornerRadius: CGFloat = 0.0 // 枠線の角丸
    
    override func draw(_ rect: CGRect) {
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.layer.cornerRadius = cornerRadius
        self.layer.masksToBounds = true
        super.draw(rect)
    }
}