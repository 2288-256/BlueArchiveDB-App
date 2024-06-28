//
//  CustomImageView.swift
//  BlueArchive Database
//
//  Created by 2288-256 on 2023/11/29.
//  Copyright (c) 2023 2288-256 All Rights Reserved
//
import UIKit

class CustomImageView: UIImageView
{
	@IBInspectable var borderColor: UIColor = .clear // Border color
	@IBInspectable var borderWidth: CGFloat = 0.0 // Border width
	@IBInspectable var cornerRadius: CGFloat = 0.0 // Corner radius

	override func layoutSubviews()
	{
		super.layoutSubviews()
		layer.borderColor = borderColor.cgColor
		layer.borderWidth = borderWidth
		layer.cornerRadius = cornerRadius
		layer.masksToBounds = true // This is important for cornerRadius
	}
}
