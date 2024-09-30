//
//  CharacterWeaponMore.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/07/18
//  Copyright (c) 2024 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class CharacterWeaponMore: UIViewController
{
    var unitId: Int = 0
    var studentStatus: [String: Any] = [:]
    var jsonArrays: [String: Any] = [:]
    var weaponData: [String: Any]?
    var SkillArrays: [String: Any] = [:]
    var weaponSkill: [String:Any] = [:]
    override func viewDidLoad()
    {
        super.viewDidLoad()
                jsonArrays = LoadFile.shared.getStudents()
//                jsonArrays = []
        studentStatus = jsonArrays["\(unitId)"] as! [String : Any]
//        weaponData = studentStatus?["Weapon"] as? [String: Any] ?? [:]
        SkillArrays = studentStatus["Skills"] as? [String: Any] ?? [:]
        weaponSkill = SkillArrays["weaponpassive"] as? [String:Any] ?? [:]
        let View = view.viewWithTag(0)!
        let StarInfo = view.viewWithTag(1)!
        let mainView = LoadSkill.shared.loadAllSkillCell(studentStatus: studentStatus, skillIndex: 1, SkillArray: weaponSkill, SkillCellPosition: 0, SkillName: "weaponpassive", action: #selector(sliderDidChangeValue(_:)), target: self)
        View.addSubview(mainView)
        let mainViewWidth = mainView.frame.width
        let mainViewHeight = mainView.frame.height
        mainView.frame = CGRect(x: 2, y: 40, width: mainViewWidth, height: mainViewHeight)
        mainView.topAnchor.constraint(equalTo: StarInfo.topAnchor,constant: 3).isActive = true
    }
    @objc func sliderDidChangeValue(_ sender: UISlider)
    {
        // 1ごとにスライダーの値を更新
        sender.value = round(sender.value)
        let tag = sender.tag
        let SkillLevelSlider = view.viewWithTag(tag) as! UISlider
        let SkillDesc = view.viewWithTag(tag - 1) as! UITextView
        let SkillArray = SkillArrays["weaponpassive"] as? [String:Any] ?? [:]
        let SkillLevelLabel = view.viewWithTag(tag + 1) as! UILabel
        SkillLevelLabel.text = "Lv.\(Int(sender.value) + 1)"
        LoadSkill.shared.SkillDescValueChange(SkillArray: SkillArray, nowSkillLevel: Int(sender.value), skillDescTextView: SkillDesc, SkillName: "weaponpassive")
    }
}
