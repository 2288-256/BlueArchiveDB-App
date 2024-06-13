//
//  CharacterWeaponStar1.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/05/10
//  Copyright (c) 2024 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class CharacterWeaponStar1: UIViewController
{
	var unitId: Int = 0
	var studentStatus: [[String: Any]] = []
	var jsonArrays: [[String: Any]] = []
	var SkillArrays: [[String: Any]] = []
	var SkillLevel: Int = 1
	var nowSkillLevel: Int = 0
	var LightArmorColor: UIColor = .init(red: 167 / 255, green: 12 / 255, blue: 25 / 255, alpha: 1.0)
	var HeavyArmorColor: UIColor = .init(red: 178 / 255, green: 109 / 255, blue: 31 / 255, alpha: 1.0)
	var UnarmedColor: UIColor = .init(red: 33 / 255, green: 111 / 255, blue: 156 / 255, alpha: 1.0)
	var ElasticArmorColor: UIColor = .init(red: 148 / 255, green: 49 / 255, blue: 165 / 255, alpha: 1.0)
	var NormalColor: UIColor = .init(red: 72 / 255, green: 85 / 255, blue: 130 / 255, alpha: 1.0)
	@IBOutlet var SkillDesc: UITextView!
	@IBOutlet var SkillName: UILabel!
	@IBOutlet var skillTypeIconImagePath: UIImageView!
	@IBOutlet var SkillTypeName: UILabel!
	@IBOutlet var SkillLevelSlider: UISlider!
	@IBOutlet var SkillLevelSliderLabel: UILabel!

	override func viewDidLoad()
	{
		super.viewDidLoad()
		studentStatus = jsonArrays.filter { $0["Id"] as? Int == unitId }
		SkillArrays = studentStatus.first?["Skills"] as! [[String: Any]]
		SkillLevelSlider.value = Float(0)
		SkillLevelSliderLabel.text = "Lv.1"
	}

	@IBAction func WeaponLevelChanged(_ sender: UISlider)
	{
		sender.value = round(sender.value)
		nowSkillLevel = Int(sender.value)
		SkillLevelSliderLabel.text = "Lv.\(Int(sender.value + 1))"
		loadWeaponStatus()
	}

	func loadWeaponStatus()
	{
		let fileManager = FileManager.default
		let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
		let SkillArray = SkillArrays.first(where: { ($0["SkillType"] as? String)?.hasPrefix("weaponpassive") == true })
		if let Parameters = SkillArray!["Parameters"] as? [[Any]]
		{
			print(Parameters[0].count)
			SkillLevelSlider.maximumValue = Float(Parameters[0].count - 1)
		}

		var SkillDescTemp: String
		var nowSkillLevel: Int = nowSkillLevel
		SkillDescTemp = SkillDescReplace(SkillDesc: SkillArray?["Desc"] as? String ?? "nil", regexPattern: "<b:([a-zA-Z0-9_]+)>", replaceOf: "b:", replaceWithCategory: "Buff_", replaceWithKey: "BuffName")
		SkillDescTemp = SkillDescReplace(SkillDesc: SkillDescTemp, regexPattern: "<d:([a-zA-Z0-9_]+)>", replaceOf: "d:", replaceWithCategory: "Debuff_", replaceWithKey: "BuffName")
		SkillDescTemp = SkillDescReplace(SkillDesc: SkillDescTemp, regexPattern: "<c:([a-zA-Z0-9_]+)>", replaceOf: "c:", replaceWithCategory: "CC_", replaceWithKey: "BuffName")
		SkillDescTemp = SkillDescReplace(SkillDesc: SkillDescTemp, regexPattern: "<s:([a-zA-Z0-9_]+)>", replaceOf: "s:", replaceWithCategory: "Special_", replaceWithKey: "BuffName")
		SkillDescTemp = SkillKbValueReplace(SkillDesc: SkillDescTemp, regexPattern: "<kb:([0-9]+)>", replaceOf: "kb:", nowSkillLevel: nowSkillLevel, SkillArray: SkillArray!)
		SkillDescTemp = SkillDescValueReplace(SkillDesc: SkillDescTemp, regexPattern: "<?([0-9]+)>", replaceOf: "?", nowSkillLevel: nowSkillLevel, SkillArray: SkillArray!)
		SkillDesc.isHidden = false
		SkillDesc.text = SkillDescTemp

		if let radius = SkillArray!["Radius"] as? [[String: Any]], let type = radius[0]["Type"] as? String
		{
			switch type
			{
			case "Circle":
				let Desc = translateString("skill_normalattack_circle")
				let IconImagePath = libraryDirectory.appendingPathComponent("assets/images/skill/COMMON_SKILLICON_CIRCLE.webp")
				skillTypeIconImagePath.image = UIImage(contentsOfFile: IconImagePath.path)
			case "Obb":
				let Desc = translateString("skill_normalattack_line")
				let IconImagePath = libraryDirectory.appendingPathComponent("assets/images/skill/COMMON_SKILLICON_LINE.webp")
				skillTypeIconImagePath.image = UIImage(contentsOfFile: IconImagePath.path)
			case "Fan":
				let Desc = translateString("skill_normalattack_fan")
				let IconImagePath = libraryDirectory.appendingPathComponent("assets/images/skill/COMMON_SKILLICON_FAN.webp")
				skillTypeIconImagePath.image = UIImage(contentsOfFile: IconImagePath.path)
			default:
				break
			}
		} else
		{
			let Desc = translateString("skill_normalattack_target")
			let IconImagePath = libraryDirectory.appendingPathComponent("assets/images/skill/COMMON_SKILLICON_TARGET.webp")
			skillTypeIconImagePath.image = UIImage(contentsOfFile: IconImagePath.path)
		}
		if SkillArray!["Icon"] != nil
		{
			let IconImagePath = libraryDirectory.appendingPathComponent("assets/images/skill/\(SkillArray!["Icon"]!).webp")
			skillTypeIconImagePath.image = UIImage(contentsOfFile: IconImagePath.path)
		}
		if let bulletType = studentStatus.first?["BulletType"] as? String
		{
			switch bulletType
			{
			case "Explosion":
				skillTypeIconImagePath.backgroundColor = LightArmorColor
			case "Pierce":
				skillTypeIconImagePath.backgroundColor = HeavyArmorColor
			case "Mystic":
				skillTypeIconImagePath.backgroundColor = UnarmedColor
			case "Sonic":
				skillTypeIconImagePath.backgroundColor = ElasticArmorColor
			default:
				skillTypeIconImagePath.backgroundColor = NormalColor
			}
		}
		if SkillArray!["Name"] != nil
		{
			SkillName.text = SkillArray!["Name"] as! String
		} else if SkillArray!["SkillType"] as! String == "autoattack"
		{
			SkillName.text = "通常攻撃"
		}
		switch SkillArray!["SkillType"] as! String
		{
		case "autoattack":
			var RadiusType: String
			if let radius = SkillArray!["Radius"] as? [[String: Any]], let type = radius[0]["Type"] as? String
			{
				//                    print(type)
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
			var AutoAttackDescTemp = SkillDescReplace(SkillDesc: translateString("skill_normalattack_\(RadiusType)") ?? "null", regexPattern: "<b:([a-zA-Z0-9_]+)>", replaceOf: "b:", replaceWithCategory: "Buff_", replaceWithKey: "BuffName")
			AutoAttackDescTemp = SkillDescReplace(SkillDesc: AutoAttackDescTemp, regexPattern: "<d:([a-zA-Z0-9_]+)>", replaceOf: "d:", replaceWithCategory: "Debuff_", replaceWithKey: "BuffName")
			AutoAttackDescTemp = SkillDescReplace(SkillDesc: AutoAttackDescTemp, regexPattern: "<c:([a-zA-Z0-9_]+)>", replaceOf: "c:", replaceWithCategory: "CC_", replaceWithKey: "BuffName")
			do
			{
				let regex = try NSRegularExpression(pattern: "<?([0-9]+)>")
				let nsRange = NSRange(AutoAttackDescTemp.startIndex ..< AutoAttackDescTemp.endIndex, in: AutoAttackDescTemp)

				if let match = regex.firstMatch(in: AutoAttackDescTemp, options: [], range: nsRange)
				{
					let matchedRange = match.range(at: 1) // Capture group 1 range

					if let swiftRange = Range(matchedRange, in: AutoAttackDescTemp)
					{
						let matchedText = String(AutoAttackDescTemp[swiftRange]) // The text between <? and >
						// print("Matched text: \(matchedText)") // Do something with matched text

						// Replace the matched text with an empty string or any replacement text
						let Parameters = SkillArray!["Parameters"] as? [[Any]]
						if AutoAttackDescTemp != AutoAttackDescTemp.replacingOccurrences(of: "<?1>", with: "100%")
						{
							AutoAttackDescTemp = AutoAttackDescTemp.replacingOccurrences(of: "<?1>", with: "100%")
						}
					}
				}
			} catch
			{
				print("Regex error: \(error.localizedDescription)")
			}

			SkillTypeName.text = AutoAttackDescTemp

		case "ex":
			SkillTypeName.text = translateString("student_skill_ex") ?? "null"
			let Cost = SkillArray!["Cost"] as? [Any]
			SkillTypeName.text! += "・コスト\(Cost?[0] as! Int)"

		case "normal":
			SkillTypeName.text = translateString("student_skill_normal") ?? "null"

		case "gearnormal":
			SkillTypeName.text = translateString("student_skill_gearnormal") ?? "null"

		case "passive":
			SkillTypeName.text = translateString("student_skill_passive") ?? "null"

		case "weaponpassive":
			SkillTypeName.text = translateString("student_skill_weaponpassive") ?? "null"

		case "sub":
			SkillTypeName.text = translateString("student_skill_sub") ?? "null"

		default:
			break
		}
	}

	func SkillDescReplace(SkillDesc: String, regexPattern: String, replaceOf: String, replaceWithCategory: String, replaceWithKey: String? = nil) -> String
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
						let replacementText = translateString("\(replaceWithCategory)\(matchedText)", mainKey: replaceWithKey) ?? ""
						if Desc != Desc.replacingOccurrences(of: "<\(replaceOf)\(matchedText)>", with: replacementText)
						{
							Desc = Desc.replacingOccurrences(of: "<\(replaceOf)\(matchedText)>", with: replacementText)
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

	func SkillKbValueReplace(SkillDesc: String, regexPattern: String, replaceOf: String, nowSkillLevel: Int, SkillArray: [String: Any]) -> String
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
						if Desc != Desc.replacingOccurrences(of: "<\(replaceOf)\(matchedText)>", with: String(replacementText[nowSkillLevel]))
						{
							Desc = Desc.replacingOccurrences(of: "<\(replaceOf)\(matchedText)>", with: String(replacementText[nowSkillLevel]))
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

	func SkillDescValueReplace(SkillDesc: String, regexPattern: String, replaceOf: String, nowSkillLevel: Int, SkillArray: [String: Any]) -> String
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
						let replacementText: String = Parameters?[Int(matchedText)! - 1][nowSkillLevel] as! String
						if Desc != Desc.replacingOccurrences(of: "<\(replaceOf)\(matchedText)>", with: replacementText)
						{
							Desc = Desc.replacingOccurrences(of: "<\(replaceOf)\(matchedText)>", with: replacementText)
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

	func translateString(_ input: String, mainKey: String? = nil) -> String?
	{
		// Load the contents of localization.json from the Documents directory
		let fileManager = FileManager.default
		do
		{
			let libraryDirectoryURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first
			if let localizationFileURL = libraryDirectoryURL?.appendingPathComponent("assets/data/jp/localization.json")
			{
				let fileData = try Data(contentsOf: localizationFileURL)
				let json = try JSONSerialization.jsonObject(with: fileData, options: [])
				if let localization = json as? [String: Any]
				{
					// If mainKey is provided, search within the nested dictionary
					if let mainKey = mainKey,
					   let mainDictionary = localization[mainKey] as? [String: String],
					   let translatedString = mainDictionary[input]
					{
						return translatedString
					} else
					{
						// Search for the translation based on the input string
						for (_, value) in localization
						{
							if let translations = value as? [String: String],
							   let translatedString = translations[input]
							{
								return translatedString
							}
						}
					}
				}
			} else
			{
				print("")
			}
		} catch
		{
			print("Error loading localization JSON from Documents directory: \(error)")
			return nil
		}

		return "Error" // Translation not found
	}
}
