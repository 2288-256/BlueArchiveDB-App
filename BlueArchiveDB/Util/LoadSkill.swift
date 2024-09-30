//
//  LoadSkill.swift
//  BlueArchiveDB
//  
//  Created by 2288-256 on 2024/08/28
//  Copyright (c) 2024 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class LoadSkill {
    
    static let shared = LoadSkill()
    
    var LightArmorColor = UIColor(
        red: 167 / 255, green: 12 / 255, blue: 25 / 255, alpha: 1.0
    )
    var HeavyArmorColor = UIColor(
        red: 178 / 255, green: 109 / 255, blue: 31 / 255, alpha: 1.0
    )
    var UnarmedColor = UIColor(red: 33 / 255, green: 111 / 255, blue: 156 / 255, alpha: 1.0)
    var ElasticArmorColor = UIColor(
        red: 148 / 255, green: 49 / 255, blue: 165 / 255, alpha: 1.0
    )
    var NormalColor = UIColor(red: 72 / 255, green: 85 / 255, blue: 130 / 255, alpha: 1.0)
    
    func loadAllSkillCell(studentStatus:[String: Any],skillIndex: Int, SkillArray: [String: Any],SkillCellPosition: Int,SkillName:String,action: Selector,target: Any) -> UIView
    {
        let fileManager = FileManager.default
        let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
        var mainView = UIView()
        mainView.tag = skillIndex * 100
        mainView.backgroundColor = .white.withAlphaComponent(CGFloat(0.5))
        mainView.frame = CGRect(x: 0, y: SkillCellPosition, width: 564, height: 200)
        var skillImageView = UIImageView()
        skillImageView.tag = skillIndex * 100 + 1
        mainView.addSubview(skillImageView)
        skillImageView.frame = CGRect(x: 5, y: 5, width: 88, height: 88)
        skillImageView.topAnchor.constraint(equalTo: mainView.topAnchor, constant: 5).isActive = true
        skillImageView.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 5).isActive = true
        var skillName = UILabel()
        skillName.tag = skillIndex * 100 + 2
        mainView.addSubview(skillName)
        skillName.frame = CGRect(x: 98, y: 10, width: 461, height: 35)
        skillName.leftAnchor.constraint(equalTo: mainView.rightAnchor, constant: 10).isActive = true
        skillName.leftAnchor.constraint(equalTo: skillImageView.leftAnchor, constant: 5).isActive = true
        var skillDesc = UILabel()
        skillDesc.tag = skillIndex * 100 + 3
        mainView.addSubview(skillDesc)
        skillDesc.frame = CGRect(x: 98, y: 53, width: 461, height: 35)
        skillDesc.topAnchor.constraint(equalTo: skillName.topAnchor, constant: 8).isActive = true
        skillDesc.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: 8).isActive = true
        var skillDescTextView = UITextView()
        var SkillDescTemp: String
        var nowSkillLevel = 0
        if SkillName != "Normal"
        {
            skillDescTextView.backgroundColor = .clear
            skillDescTextView.isEditable = false
            skillDescTextView.isSelectable = false
            skillDescTextView.tag = skillIndex * 100 + 4
            mainView.addSubview(skillDescTextView)
            skillDescTextView.frame = CGRect(x: 0, y: 101, width: 564, height: 56)
            skillDescTextView.topAnchor.constraint(equalTo: skillImageView.topAnchor, constant: 8)
                .isActive = true
            skillDescTextView.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: 0)
                .isActive = true
            skillDescTextView.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 0).isActive =
                true

            let SkillLevelSlider = CustomSlider()
            SkillLevelSlider.tag = skillIndex * 100 + 5
            mainView.addSubview(SkillLevelSlider)
            //                 SkillLevelSlider.topAnchor.constraint(equalTo: skillDescTextView.bottomAnchor, constant: )
            //                .isActive = true
            SkillLevelSlider.rightAnchor.constraint(equalTo: mainView.rightAnchor, constant: 5)
                .isActive = true
            SkillLevelSlider.leftAnchor.constraint(equalTo: mainView.leftAnchor, constant: 5)
                .isActive = true
            SkillLevelSlider.frame = CGRect(x: 0, y: 165, width: 459, height: 20)
            SkillLevelSlider.addTarget(target, action: action, for: .valueChanged)
            if SkillArray["SkillType"] as? String == "ex"
            {
                SkillLevelSlider.maximumValue = Float(4)
            } else
            {
                SkillLevelSlider.maximumValue = Float(9)
            }
            let SkillLevelLabel = UILabel()
            SkillLevelLabel.tag = skillIndex * 100 + 6
            mainView.addSubview(SkillLevelLabel)
            SkillLevelLabel.frame = CGRect(x: 467, y: 165, width: 79, height: 20)
            SkillLevelLabel.rightAnchor.constraint(equalTo: SkillLevelSlider.leftAnchor, constant: 8)
                .isActive = true
            SkillLevelLabel.leftAnchor.constraint(equalTo: mainView.rightAnchor, constant: 8)
                .isActive = true
            SkillLevelLabel.text = "Lv.1"
            SkillLevelLabel.textAlignment = .center
        } else
        {
            mainView.frame.size.height = 95
        }
        SkillDescValueChange(SkillArray: SkillArray, nowSkillLevel: 0, skillDescTextView: skillDescTextView, SkillName: SkillName)
        // // Repeat until the input text doesn't change anymore
        // if SkillArray["SkillType"] as? String == "ex" {
        //     nowSkillLevel = ExSkillLevel
        // }else{
        //     SkillLevelSlider.isHidden = true
        //     nowSkillLevel = SkillLevel
        // }
        if let radius = SkillArray["Radius"] as? [[String: Any]],
           let type = radius[0]["Type"] as? String
        {
            switch type
            {
            case "Circle":
                let Desc = LoadFile.shared.translateString("skill_normalattack_circle")
                let IconImagePath = libraryDirectory.appendingPathComponent(
                    "assets/images/skill/COMMON_SKILLICON_CIRCLE.webp")
                skillImageView.image = UIImage(contentsOfFile: IconImagePath.path)
            case "Obb":
                let Desc = LoadFile.shared.translateString("skill_normalattack_line")
                let IconImagePath = libraryDirectory.appendingPathComponent(
                    "assets/images/skill/COMMON_SKILLICON_LINE.webp")
                skillImageView.image = UIImage(contentsOfFile: IconImagePath.path)
            case "Fan":
                let Desc = LoadFile.shared.translateString("skill_normalattack_fan")
                let IconImagePath = libraryDirectory.appendingPathComponent(
                    "assets/images/skill/COMMON_SKILLICON_FAN.webp")
                skillImageView.image = UIImage(contentsOfFile: IconImagePath.path)
            default:
                break
            }
        } else
        {
            let Desc = LoadFile.shared.translateString("skill_normalattack_target")
            let IconImagePath = libraryDirectory.appendingPathComponent(
                "assets/images/skill/COMMON_SKILLICON_TARGET.webp")
            skillImageView.image = UIImage(contentsOfFile: IconImagePath.path)
        }
        if SkillArray["Icon"] != nil
        {
            let IconImagePath = libraryDirectory.appendingPathComponent(
                "assets/images/skill/\(SkillArray["Icon"]!).webp")

            skillImageView.image = UIImage(contentsOfFile: IconImagePath.path)
        }
        if let bulletType = studentStatus["BulletType"] as? String
        {
            switch bulletType
            {
            case "Explosion":
                skillImageView.backgroundColor = LightArmorColor
            case "Pierce":
                skillImageView.backgroundColor = HeavyArmorColor
            case "Mystic":
                skillImageView.backgroundColor = UnarmedColor
            case "Sonic":
                skillImageView.backgroundColor = ElasticArmorColor
            default:
                skillImageView.backgroundColor = NormalColor
            }
        }
        if SkillArray["Name"] != nil
        {
            skillName.text = SkillArray["Name"] as? String
        } else if SkillName == "autoattack"
        {
            skillName.text = "通常攻撃"
        }
        switch SkillName
        {
        case "autoattack":
            var RadiusType: String
            if let radius = SkillArray["Radius"] as? [[String: Any]],
               let type = radius[0]["Type"] as? String
            {
                if type == "Obb"
                {
                    RadiusType = "line"
                } else
                {
                    RadiusType = type.lowercased()
                }
            } else
            {
                RadiusType = "target"
            }
            var AutoAttackDescTemp = SkillDescReplace(
                SkillDesc: LoadFile.shared.translateString("skill_normalattack_\(RadiusType)") ?? "null",
                regexPattern: "<b:([a-zA-Z0-9_]+)>", replaceOf: "b:", replaceWithCategory: "Buff_",
                replaceWithKey: "BuffName"
            )
            AutoAttackDescTemp = SkillDescReplace(
                SkillDesc: AutoAttackDescTemp, regexPattern: "<d:([a-zA-Z0-9_]+)>", replaceOf: "d:",
                replaceWithCategory: "Debuff_", replaceWithKey: "BuffName"
            )
            AutoAttackDescTemp = SkillDescReplace(
                SkillDesc: AutoAttackDescTemp, regexPattern: "<c:([a-zA-Z0-9_]+)>", replaceOf: "c:",
                replaceWithCategory: "CC_", replaceWithKey: "BuffName"
            )
            do
            {
                let regex = try NSRegularExpression(pattern: "<?([0-9]+)>")
                let nsRange = NSRange(
                    AutoAttackDescTemp.startIndex ..< AutoAttackDescTemp.endIndex, in: AutoAttackDescTemp
                )

                if let match = regex.firstMatch(in: AutoAttackDescTemp, options: [], range: nsRange)
                {
                    let matchedRange = match.range(at: 1) // Capture group 1 range

                    if let swiftRange = Range(matchedRange, in: AutoAttackDescTemp)
                    {
                        let matchedText = String(AutoAttackDescTemp[swiftRange]) // The text between <? and >
                        // print("Matched text: \(matchedText)") // Do something with matched text

                        // Replace the matched text with an empty string or any replacement text
                        let Parameters = SkillArray["Parameters"] as? [[Any]]
                        if AutoAttackDescTemp
                            != AutoAttackDescTemp.replacingOccurrences(of: "<?1>", with: "100%")
                        {
                            AutoAttackDescTemp = AutoAttackDescTemp.replacingOccurrences(of: "<?1>", with: "100%")
                        }
                    }
                }
            } catch
            {
                print("Regex error: \(error.localizedDescription)")
            }

            skillDesc.text = AutoAttackDescTemp

        case "ex":
            skillDesc.text = LoadFile.shared.translateString("student_skill_ex") ?? "null"
            let Cost = SkillArray["Cost"] as? [Any]
            skillDesc.text! += "・コスト\(Cost?[0] as? Int)"

        case "normal":
            skillDesc.text = LoadFile.shared.translateString("student_skill_normal") ?? "null"

        case "gearnormal":
            skillDesc.text = LoadFile.shared.translateString("student_skill_gearnormal") ?? "null"

        case "passive":
            skillDesc.text = LoadFile.shared.translateString("student_skill_passive") ?? "null"

        case "weaponpassive":
            skillDesc.text = LoadFile.shared.translateString("student_skill_weaponpassive") ?? "null"

        case "sub":
            skillDesc.text = LoadFile.shared.translateString("student_skill_sub") ?? "null"

        default:
            break
        }
        return mainView
    }
    func SkillDescValueChange(SkillArray: [String: Any], nowSkillLevel: Int, skillDescTextView: UITextView,SkillName:String)
    {
        var SkillDescTemp = SkillDescReplace(
            SkillDesc: SkillArray["Desc"] as? String ?? "nil", regexPattern: "<b:([a-zA-Z0-9_]+)>",
            replaceOf: "b:", replaceWithCategory: "Buff_", replaceWithKey: "BuffName"
        )
        SkillDescTemp = SkillDescReplace(
            SkillDesc: SkillDescTemp, regexPattern: "<d:([a-zA-Z0-9_]+)>", replaceOf: "d:",
            replaceWithCategory: "Debuff_", replaceWithKey: "BuffName"
        )
        SkillDescTemp = SkillDescReplace(
            SkillDesc: SkillDescTemp, regexPattern: "<c:([a-zA-Z0-9_]+)>", replaceOf: "c:",
            replaceWithCategory: "CC_", replaceWithKey: "BuffName"
        )
        SkillDescTemp = SkillDescReplace(
            SkillDesc: SkillDescTemp, regexPattern: "<s:([a-zA-Z0-9_]+)>", replaceOf: "s:",
            replaceWithCategory: "Special_", replaceWithKey: "BuffName"
        )
        SkillDescTemp = SkillKbValueReplace(
            SkillDesc: SkillDescTemp, regexPattern: "<kb:([0-9]+)>", replaceOf: "kb:",
            nowSkillLevel: nowSkillLevel, SkillArray: SkillArray
        )
        SkillDescTemp = SkillDescValueReplace(
            SkillDesc: SkillDescTemp, regexPattern: "<?([0-9]+)>", replaceOf: "?",
            nowSkillLevel: nowSkillLevel, SkillArray: SkillArray
        )
        if SkillName != "autoattack"
        {
            skillDescTextView.text = SkillDescTemp
        }
    }
    func SkillDescReplace(
        SkillDesc: String, regexPattern: String, replaceOf: String, replaceWithCategory: String,
        replaceWithKey: String? = nil
    ) -> String
    {
        var Desc = SkillDesc
        var valueChanged = true
        while valueChanged
        {
            valueChanged = false

            do
            {
                let regex = try NSRegularExpression(pattern: regexPattern)
                let nsRange = NSRange(Desc.startIndex ..< Desc.endIndex, in: Desc)

                if let match = regex.firstMatch(in: Desc, options: [], range: nsRange)
                {
                    let matchedRange = match.range(at: 1) // Capture group 1 range

                    if let swiftRange = Range(matchedRange, in: Desc)
                    {
                        let matchedText = String(Desc[swiftRange]) // The text between <b: and >
                        // print("Matched text: \(matchedText)") // Do something with matched text

                        // Replace the matched text with an empty string or any replacement text
                        let replacementText =
                            LoadFile.shared.translateString("\(replaceWithCategory)\(matchedText)", mainKey: replaceWithKey) ?? ""
                        if Desc
                            != Desc.replacingOccurrences(
                                of: "<\(replaceOf)\(matchedText)>", with: replacementText
                            )
                        {
                            Desc = Desc.replacingOccurrences(
                                of: "<\(replaceOf)\(matchedText)>", with: replacementText
                            )
                            valueChanged = true
                        }
                    }
                }
            } catch
            {
                print("Regex error: \(error.localizedDescription)")
            }
        }
        return Desc
    }
    func SkillKbValueReplace(
        SkillDesc: String, regexPattern: String, replaceOf: String, nowSkillLevel: Int,
        SkillArray: [String: Any]
    ) -> String
    {
        var Desc = SkillDesc
        var BuffValuechanged = true
        while BuffValuechanged
        {
            BuffValuechanged = false
            do
            {
                let regex = try NSRegularExpression(pattern: regexPattern)
                let nsRange = NSRange(Desc.startIndex ..< Desc.endIndex, in: Desc)

                if let match = regex.firstMatch(in: Desc, options: [], range: nsRange)
                {
                    let matchedRange = match.range(at: 1) // Capture group 1 range

                    if let swiftRange = Range(matchedRange, in: Desc)
                    {
                        let matchedText = String(Desc[swiftRange]) // The text between <? and >
                        // print("Matched text: \(matchedText)") // Do something with matched text

                        // Replace the matched text with an empty string or any replacement text
                        let Effects = SkillArray["Effects"] as! [[String: Any]]
                        let filter = Effects.filter { $0["Type"] as! String == "Knockback" }
                        let replacementText = filter.first?["Scale"] as! [Int]
                        if Desc
                            != Desc.replacingOccurrences(
                                of: "<\(replaceOf)\(matchedText)>", with: String(replacementText[nowSkillLevel])
                            )
                        {
                            Desc = Desc.replacingOccurrences(
                                of: "<\(replaceOf)\(matchedText)>", with: String(replacementText[nowSkillLevel])
                            )
                            BuffValuechanged = true
                        }
                    }
                }
            } catch
            {
                print("Regex error: \(error.localizedDescription)")
            }
        }
        return Desc
    }
    func SkillDescValueReplace(
        SkillDesc: String, regexPattern: String, replaceOf: String, nowSkillLevel: Int,
        SkillArray: [String: Any]
    ) -> String
    {
        var Desc = SkillDesc
        var BuffValuechanged = true
        while BuffValuechanged
        {
            BuffValuechanged = false
            do
            {
                let regex = try NSRegularExpression(pattern: regexPattern)
                let nsRange = NSRange(Desc.startIndex ..< Desc.endIndex, in: Desc)

                if let match = regex.firstMatch(in: Desc, options: [], range: nsRange)
                {
                    let matchedRange = match.range(at: 1) // Capture group 1 range

                    if let swiftRange = Range(matchedRange, in: Desc)
                    {
                        let matchedText = String(Desc[swiftRange]) // The text between <? and >
                        // print("Matched text: \(matchedText)") // Do something with matched text

                        // Replace the matched text with an empty string or any replacement text
                        let Parameters = SkillArray["Parameters"] as? [[Any]]
                        let replacementText: String =
                            Parameters?[Int(matchedText)! - 1][nowSkillLevel] as! String
                        if Desc
                            != Desc.replacingOccurrences(
                                of: "<\(replaceOf)\(matchedText)>", with: replacementText
                            )
                        {
                            Desc = Desc.replacingOccurrences(
                                of: "<\(replaceOf)\(matchedText)>", with: replacementText
                            )
                            BuffValuechanged = true
                            //                            print(replacementText)
                        }
                    }
                }
            } catch
            {
                print("Regex error: \(error.localizedDescription)")
            }
        }
        return Desc
    }
}
