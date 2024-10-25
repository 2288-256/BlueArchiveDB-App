//
//  CharacterGear.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/08/28
//  Copyright (c) 2024 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class CharacterGear: UIViewController
{
    var unitId: Int = 0
    var studentStatus: [String: Any] = [:]
    var jsonArrays: [String: Any] = [:]
    var GearData: [String: Any] = [:]
    var SkillArrays: [String: Any] = [:]
    var GearSkill: [String: Any] = [:]

    @IBOutlet var GearUIView: UIView!
    @IBOutlet var GearName: UILabel!
    @IBOutlet var GearImage: UIImageView!
    @IBOutlet var GearDesc: UITextView!
    @IBOutlet var GearStatusUI: UIView!
    @IBOutlet var SkillUIView: UIView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        jsonArrays = LoadFile.shared.getStudents()
//                jsonArrays = []
        studentStatus = jsonArrays["\(unitId)"] as? [String:Any] ?? [:]
        SkillArrays = studentStatus["Skills"] as? [String: Any] ?? [:]
        GearSkill = SkillArrays["GearPublic"] as? [String: Any] ?? [:]
        GearName.text = GearData["Name"] as? String
        let fileManager = FileManager.default
        let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
        let imagePath = libraryDirectory.appendingPathComponent("assets/images/gear/full/\(unitId).webp")

        if let image = UIImage(contentsOfFile: imagePath.path)
        {
            GearImage.image = image
            GearImage.contentMode = .scaleAspectFit
            let height = GearImage.frame.size.width * (image.size.height / image.size.width)
            GearImage.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if let statTypeArray = GearData["StatType"] as? [String], let statValue = GearData["StatValue"] as? [[Int]]
        {
            if statTypeArray.count >= 3
            {
                GearUIView.frame.size.height = 358
                GearUIView.heightAnchor.constraint(equalToConstant: 358).isActive = true
                GearStatusUI.frame.size.height = 95
                GearStatusUI.heightAnchor.constraint(equalToConstant: 95).isActive = true
            } else
            {
                GearUIView.frame.size.height = 313
                GearUIView.heightAnchor.constraint(equalToConstant: 313).isActive = true
                GearStatusUI.frame.size.height = 50
            }
            for (index, statType) in statTypeArray.enumerated()
            {
                let cleanedStatType = statType.components(separatedBy: "_")[0]
                let statusName = LoadFile.shared.translateString(cleanedStatType, mainKey: "Stat")
                print("aaaa")
                let Label1 = CreateElement.shared.createWeaponStatusView(addSubview: GearStatusUI, tag: 1, statusID: cleanedStatType, statusName: statusName!, statusValue: statValue[index][0], posx: 281 * index, leftEqualTo: index)
            }
        }
        GearDesc.text = GearData["Desc"] as? String
        let mainView = LoadSkill.shared.loadAllSkillCell(studentStatus: studentStatus, skillIndex: 1, SkillArray: GearSkill, SkillCellPosition: 0, SkillName: "GearPublic", action: #selector(sliderDidChangeValue(_:)), target: self)
        SkillUIView.addSubview(mainView)
    }

    @objc func sliderDidChangeValue(_ sender: UISlider)
    {
        // 1ごとにスライダーの値を更新
        sender.value = round(sender.value)
        let tag = sender.tag
        let SkillLevelSlider = view.viewWithTag(tag) as! UISlider
        let SkillDesc = view.viewWithTag(tag - 1) as! UITextView
        let SkillArray = SkillArrays["GearPublic"] as? [String:Any] ?? [:]
        let SkillLevelLabel = view.viewWithTag(tag + 1) as! UILabel
        SkillLevelLabel.text = "Lv.\(Int(sender.value) + 1)"
        LoadSkill.shared.SkillDescValueChange(SkillArray: GearSkill, nowSkillLevel: Int(sender.value), skillDescTextView: SkillDesc, SkillName: "GearPublic")
    }
}
