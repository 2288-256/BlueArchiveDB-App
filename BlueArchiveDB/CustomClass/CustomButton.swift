//
//  CustomButton.swift
//  BlueArchive Database
//
//  Created by 2288-256 on 2023/11/22.
//  Copyright (c) 2023 2288-256 All Rights Reserved
//

import Foundation
import UIKit

@IBDesignable class CustomButton: UIButton
{
	// @IBInspectable のアノテーションを設定することでカスタムプロパティを追加することができる
	@IBInspectable var borderColor: UIColor = .clear // 枠線の色
	@IBInspectable var borderWidth: CGFloat = 0.0 // 枠線の太さ
	@IBInspectable var cornerRadius: CGFloat = 0.0 // 枠線の角丸

	override func draw(_ rect: CGRect)
	{
		layer.borderColor = borderColor.cgColor
		layer.borderWidth = borderWidth
		layer.cornerRadius = cornerRadius
		layer.masksToBounds = true
		super.draw(rect)
	}
}
