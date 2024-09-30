//
//  CharacterSkill.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/04/17
//  Copyright (c) 2024 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class CharacterSkill: UIViewController
{
	var unitId: Int = 0
    var studentData: [String: Any] = [:]
	var studentStatus: [[String: Any]] = []
    var SkillArrays: [String: Any] = [:]
	var ExSkillLevel: Int = 0
	var SkillLevel: Int = 0
	var SkillCellPosition: Int = 0
	var OldLevelSliderValue: Int = 0
    var SkillList: [String] = ["Normal","Ex","Public","Passive","ExtraPassive"]
    

	//    @IBOutlet weak var collectionView: UICollectionView!
	// 親のSkillView
	@IBOutlet var ContainerSkillView: UIView!
	override func viewDidLoad()
	{
		super.viewDidLoad()
        SkillArrays = studentData["Skills"] as? [String: Any] ?? [:]
        SkillArrays = SkillArrays.filter { (key, value) in
            guard let skillDict = value as? [String: Any],
                  let skillType = skillDict["SkillType"] as? String else {
                return true
            }
            return !(skillType.contains("gear") || skillType.contains("weapon"))
        }

		print("count", SkillArrays.count)
		SkillCellPosition = 0
        
//        for key in SkillArrays.keys {
//            guard let SkillArray = SkillArrays[key] else {
//                // SkillArrayがnilでないことを確認
//                continue
//            }
//            
//            print(key)
//            let skillIndex = Int(key) ?? 0  // キーが整数として扱われる場合、Intに変換
//            var mainView = LoadSkill.shared.loadAllSkillCell(
//                studentStatus: studentStatus,
//                skillIndex: skillIndex,
//                SkillArray: SkillArray as! [String : Any],
//                SkillCellPosition: SkillCellPosition,
//                action: #selector(sliderDidChangeValue(_:)),
//                target: self
//            )
//            
//            // returnでmainViewを返す
//            ContainerSkillView.addSubview(mainView)
//            SkillCellPosition += Int(mainView.frame.height) + 5
//        }

		print(SkillCellPosition + 10)
		let heightConstraint = NSLayoutConstraint(item: ContainerSkillView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(SkillCellPosition + 10))
		heightConstraint.isActive = true
	}

    @objc func sliderDidChangeValue(_ sender: UISlider) {
        // 1ごとにスライダーの値を更新
        sender.value = round(sender.value)
        let tag = sender.tag
        
        // タグを使ってビューを取得
        guard let SkillLevelSlider = view.viewWithTag(tag) as? UISlider,
              let SkillDesc = view.viewWithTag(tag - 1) as? UITextView,
              let SkillLevelLabel = view.viewWithTag(tag + 1) as? UILabel else {
            return
        }
        
        // (tag - 5) / 100 から辞書のキーを決定する処理を追加
        let key = String((tag - 5) / 100)  // キーが文字列であると仮定
        guard let SkillArray = SkillArrays[key] else {
            // SkillArrayがnilでないことを確認
            return
        }
        // スライダーの値をラベルに表示
        SkillLevelLabel.text = "Lv.\(Int(sender.value) + 1)"
        
        // SkillDescValueChangeメソッドを呼び出す
        LoadSkill.shared.SkillDescValueChange(
            SkillArray: SkillArray as! [String : Any],
            nowSkillLevel: Int(sender.value),
            skillDescTextView: SkillDesc,
            SkillName: SkillList[(tag - 5) / 100]
        )
    }


	

	

	func getParentCell(of view: UIView) -> UICollectionViewCell?
	{
		var superview = view.superview
		while let view = superview, !(view is UICollectionViewCell)
		{
			superview = view.superview
		}
		return superview as? UICollectionViewCell
	}

	//    @IBAction func LevelSliderChanged(_ sender: UISlider) {
	//        sender.value = round(sender.value)
	//        ExSkillLevel = Int(sender.value)
	//        var cellTag = 1
	//        if let cell = getParentCell(of: sender), let indexPath = collectionView.indexPath(for: cell) {
	//                    cellTag = cell.tag
	//                }
	////        print(cellTag)
	//        collectionView.reloadItems(at: [IndexPath(item: cellTag/100, section: 0)])
	//
	//        //        let reusableview = self.view.viewWithTag(100) as! UICollectionReusableView
	//        //        let label = reusableview.viewWithTag(2) as! UILabel
	//        //        label.text = "Lv.\(Int(sender.value))"
	//
	//    }
	

	

	

	// func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
	//     let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "skill-cell", for: indexPath)
	//     cell.tag = indexPath.row * 100
	//     print(indexPath.row)
	//     let skillTypeIconImagePath = cell.contentView.viewWithTag(1) as! UIImageView
	//     skillTypeIconImagePath.image = nil
	//     let SkillName = cell.contentView.viewWithTag(2) as! UILabel
	//     SkillName.text = nil
	//     let SkillTypeName = cell.contentView.viewWithTag(3) as! UILabel
	//     SkillTypeName.text = nil
	//     let SkillDesc = cell.contentView.viewWithTag(4) as! UITextView
	//     SkillDesc.text = nil
	//     let SkillLevelSlider = cell.contentView.viewWithTag(5) as! UISlider
	//     SkillLevelSlider.value = Float(ExSkillLevel)

	//     let fileManager = FileManager.default
	//     let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
	//     if SkillArrays.count > indexPath.row {
	//         let SkillArray = SkillArrays[indexPath.row]
	//         var SkillDescTemp : String
	//         var nowSkillLevel : Int
	//         // Repeat until the input text doesn't change anymore
	//         if SkillArray["SkillType"] as? String == "ex" {
	//             nowSkillLevel = ExSkillLevel
	//         }else{
	//             SkillLevelSlider.isHidden = true
	//             nowSkillLevel = SkillLevel
	//         }
	//         SkillDescTemp = SkillDescReplace(SkillDesc: SkillArray["Desc"] as? String ?? "nil", regexPattern: "<b:([a-zA-Z0-9_]+)>", replaceOf: "b:", replaceWithCategory: "Buff_", replaceWithKey: "BuffName")
	//         SkillDescTemp = SkillDescReplace(SkillDesc: SkillDescTemp, regexPattern: "<d:([a-zA-Z0-9_]+)>", replaceOf: "d:", replaceWithCategory: "Debuff_", replaceWithKey: "BuffName")
	//         SkillDescTemp = SkillDescReplace(SkillDesc: SkillDescTemp, regexPattern: "<c:([a-zA-Z0-9_]+)>", replaceOf: "c:", replaceWithCategory: "CC_", replaceWithKey: "BuffName")
	//         SkillDescTemp = SkillDescReplace(SkillDesc: SkillDescTemp, regexPattern: "<s:([a-zA-Z0-9_]+)>", replaceOf: "s:", replaceWithCategory: "Special_", replaceWithKey: "BuffName")
	//         SkillDescTemp = SkillKbValueReplace(SkillDesc: SkillDescTemp, regexPattern: "<kb:([0-9]+)>", replaceOf: "kb:", nowSkillLevel: nowSkillLevel, SkillArray: SkillArray)
	//         SkillDescTemp = SkillDescValueReplace(SkillDesc: SkillDescTemp, regexPattern: "<?([0-9]+)>", replaceOf: "?", nowSkillLevel: nowSkillLevel,SkillArray:SkillArray)
	//         if (SkillArray["SkillType"] as! String != "autoattack") {
	//             SkillDesc.isHidden = false
	//             SkillDesc.text = SkillDescTemp
	//         }else{
	//             SkillDesc.text = nil
	//             SkillDesc.isHidden = true
	//             cell.frame.size.height = 125
	//         }
	//         if let radius = SkillArray["Radius"] as? [[String: Any]], let type = radius[0]["Type"] as? String {
	//             switch type {
	//             case "Circle":
	//                 let Desc  = translateString("skill_normalattack_circle")
	//                 let IconImagePath = libraryDirectory.appendingPathComponent("assets/images/skill/COMMON_SKILLICON_CIRCLE.webp")
	//                 skillTypeIconImagePath.image = UIImage(contentsOfFile: IconImagePath.path)
	//             case "Obb":
	//                 let Desc  = translateString("skill_normalattack_line")
	//                 let IconImagePath = libraryDirectory.appendingPathComponent("assets/images/skill/COMMON_SKILLICON_LINE.webp")
	//                 skillTypeIconImagePath.image = UIImage(contentsOfFile: IconImagePath.path)
	//             case "Fan":
	//                 let Desc  = translateString("skill_normalattack_fan")
	//                 let IconImagePath = libraryDirectory.appendingPathComponent("assets/images/skill/COMMON_SKILLICON_FAN.webp")
	//                 skillTypeIconImagePath.image = UIImage(contentsOfFile: IconImagePath.path)
	//             default:
	//                 break
	//             }
	//         } else {
	//             let Desc  = translateString("skill_normalattack_target")
	//             let IconImagePath = libraryDirectory.appendingPathComponent("assets/images/skill/COMMON_SKILLICON_TARGET.webp")
	//             skillTypeIconImagePath.image = UIImage(contentsOfFile: IconImagePath.path)
	//         }
	//         if (SkillArray["Icon"] != nil){
	//             let IconImagePath = libraryDirectory.appendingPathComponent("assets/images/skill/\(SkillArray["Icon"]!).webp")
	//             skillTypeIconImagePath.image = UIImage(contentsOfFile: IconImagePath.path)
	//         }
	//         if let bulletType = studentStatus.first?["BulletType"] as? String {
	//             switch bulletType {
	//             case "Explosion":
	//                 skillTypeIconImagePath.backgroundColor = LightArmorColor
	//             case "Pierce":
	//                 skillTypeIconImagePath.backgroundColor = HeavyArmorColor
	//             case "Mystic":
	//                 skillTypeIconImagePath.backgroundColor = UnarmedColor
	//             case "Sonic":
	//                 skillTypeIconImagePath.backgroundColor = ElasticArmorColor
	//             default:
	//                 skillTypeIconImagePath.backgroundColor = NormalColor
	//             }
	//         }
	//         if (SkillArray["Name"] != nil){
	//             SkillName.text = SkillArray["Name"] as! String
	//         }else if (SkillArray["SkillType"] as! String == "autoattack"){
	//             SkillName.text = "通常攻撃"
	//         }
	//         switch SkillArray["SkillType"] as! String {
	//         case "autoattack":
	//             var RadiusType:String
	//             if let radius = SkillArray["Radius"] as? [[String: Any]], let type = radius[0]["Type"] as? String {

	//                 if type == "Obb"{
	//                     RadiusType = "line"
	//                 }else{
	//                     RadiusType = type.lowercased()
	//                 }
	//             }else{
	//                 RadiusType = "target"
	//             }
	//             var AutoAttackDescTemp = SkillDescReplace(SkillDesc: translateString("skill_normalattack_\(RadiusType)") ?? "null", regexPattern: "<b:([a-zA-Z0-9_]+)>", replaceOf: "b:", replaceWithCategory: "Buff_", replaceWithKey: "BuffName")
	//             AutoAttackDescTemp = SkillDescReplace(SkillDesc: AutoAttackDescTemp, regexPattern: "<d:([a-zA-Z0-9_]+)>", replaceOf: "d:", replaceWithCategory: "Debuff_", replaceWithKey: "BuffName")
	//             AutoAttackDescTemp = SkillDescReplace(SkillDesc: AutoAttackDescTemp, regexPattern: "<c:([a-zA-Z0-9_]+)>", replaceOf: "c:", replaceWithCategory: "CC_", replaceWithKey: "BuffName")
	//             do {
	//                 let regex = try NSRegularExpression(pattern: "<?([0-9]+)>")
	//                 let nsRange = NSRange(AutoAttackDescTemp.startIndex..<AutoAttackDescTemp.endIndex, in: AutoAttackDescTemp)

	//                 if let match = regex.firstMatch(in: AutoAttackDescTemp, options: [], range: nsRange) {
	//                     let matchedRange = match.range(at: 1) // Capture group 1 range

	//                     if let swiftRange = Range(matchedRange, in: AutoAttackDescTemp) {
	//                         let matchedText = String(AutoAttackDescTemp[swiftRange]) // The text between <? and >
	//                         // print("Matched text: \(matchedText)") // Do something with matched text

	//                         // Replace the matched text with an empty string or any replacement text
	//                         let Parameters = SkillArray["Parameters"] as? [[Any]]
	//                         if AutoAttackDescTemp != AutoAttackDescTemp.replacingOccurrences(of: "<?1>", with: "100%") {
	//                             AutoAttackDescTemp = AutoAttackDescTemp.replacingOccurrences(of: "<?1>", with: "100%")
	//                         }
	//                     }
	//                 }
	//             } catch {
	//                 print("Regex error: \(error.localizedDescription)")
	//             }

	//             SkillTypeName.text = AutoAttackDescTemp
	//         case "ex":
	//             SkillTypeName.text = translateString("student_skill_ex") ?? "null"
	//             let Cost = SkillArray["Cost"] as? [Any]
	//             SkillTypeName.text! += "・コスト\(Cost?[0] as! Int)"
	//         case "normal":
	//             SkillTypeName.text = translateString("student_skill_normal") ?? "null"

	//         case "gearnormal":
	//             SkillTypeName.text = translateString("student_skill_gearnormal") ?? "null"

	//         case "passive":
	//             SkillTypeName.text = translateString("student_skill_passive") ?? "null"

	//         case "weaponpassive":
	//             SkillTypeName.text = translateString("student_skill_weaponpassive") ?? "null"

	//         case "sub":
	//             SkillTypeName.text = translateString("student_skill_sub") ?? "null"

	//         default:
	//             break
	//         }

	//     }
	//     return cell
	// }
	// func numberOfSections(in collectionView: UICollectionView) -> Int {
	//     // section数は１つ
	//     return 1
	// }

	// func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
	//     studentStatus = jsonArrays.filter { $0["Id"] as? Int == unitId }
	//     SkillArrays = studentStatus.first?["Skills"] as! [[String: Any]]
	//     SkillArrays.removeAll { skillDict in
	//         guard let skillType = skillDict["SkillType"] as? String else { return false }
	//         return skillType.contains("gear") || skillType.contains("weapon")
	//     }
	//     return SkillArrays.count
	// }
	// func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
	//     // Existing width calculation is maintained
	//     let cellWidth = collectionView.frame.width

	//     // Default cell height
	//     var cellHeight: CGFloat = 184

	//     if SkillArrays[indexPath.row]["SkillType"] as! String == "ex" {
	//         cellHeight = 226
	//     }

	//     // Determine if there is a transcription for the specific indexPath
	//     if SkillArrays[indexPath.row]["SkillType"] as! String == "autoattack" {
	//         cellHeight = 125
	//     }

	//     return CGSize(width: cellWidth, height: cellHeight)
	// }
}
