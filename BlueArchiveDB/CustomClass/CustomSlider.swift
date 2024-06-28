//
//  CustomSlider.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/02/21
//  Copyright (c) 2024 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class CustomSlider: UISlider
{
	override func beginTracking(_ touch: UITouch, with _: UIEvent?) -> Bool
	{
		let tapPoint = touch.location(in: self)
		let fraction = Float(tapPoint.x / bounds.width)
		let newValue = (maximumValue - minimumValue) * fraction + minimumValue
		if newValue != value
		{
			value = newValue
		}
		return true
	}
}
