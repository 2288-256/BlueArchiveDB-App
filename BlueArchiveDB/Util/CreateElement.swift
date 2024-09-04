//
//  CreateElement.swift
//  BlueArchiveDB
//  
//  Created by 2288-256 on 2024/09/01
//  Copyright (c) 2024 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class CreateElement{
    
    static let shared = CreateElement()
    
    func createWeaponStatusView(addSubview weaponStatusUI: UIView, tag: Int, statusID: String, statusName: String, statusValue: Int, posx x: Int? = 8, posy y: Int? = 8, width w: Int? = 265, height h: Int? = 35, topEqualTo topElement: Int? = nil, leftEqualTo leftElement: Int? = nil) -> UIView
    {
        let topConstraint = weaponStatusUI.viewWithTag(topElement ?? -1) ?? weaponStatusUI
        let leftConstraint = weaponStatusUI.viewWithTag(leftElement ?? -1) ?? weaponStatusUI

        let statusView = UIView(frame: CGRect(x: x!, y: y!, width: w!, height: h!))
        weaponStatusUI.addSubview(statusView)
        statusView.topAnchor.constraint(equalTo: topConstraint.topAnchor, constant: 8).isActive = true
        statusView.leftAnchor.constraint(equalTo: leftConstraint.leftAnchor, constant: 8).isActive = true

        let statusImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: h!, height: h!))
        statusView.addSubview(statusImageView)
        let fileManager = FileManager.default
        let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
        let imagePath = libraryDirectory.appendingPathComponent("assets/images/staticon/Stat_\(statusID).png")
        if let image = UIImage(contentsOfFile: imagePath.path)
        {
            statusImageView.image = image.withRenderingMode(.alwaysTemplate)
            statusImageView.contentMode = .scaleAspectFit
            statusImageView.tintColor = .black
        }
        let statusNameLabel = UILabel(frame: CGRect(x: 35 + 2, y: 0, width: ((w! - (h! + 2)) / 2) - 6, height: h!))
        statusView.addSubview(statusNameLabel)
        statusNameLabel.leftAnchor.constraint(equalTo: statusImageView.leftAnchor, constant: 2).isActive = true
        statusNameLabel.text = statusName
        let statusValueLabel = UILabel(frame: CGRect(x: h! + ((w! - (h! + 2)) / 2) + 4 + 2, y: 0, width: ((w! - (h! + 2)) / 2) - 6, height: h!))
        statusView.addSubview(statusValueLabel)
        statusValueLabel.tag = tag
        statusValueLabel.leftAnchor.constraint(equalTo: statusNameLabel.rightAnchor, constant: 4).isActive = true
        statusValueLabel.text = "+" + String(statusValue)
        statusValueLabel.textAlignment = .right
        return statusView
    }
    
}
