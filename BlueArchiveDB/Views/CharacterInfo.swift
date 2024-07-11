//
//  CharacterInfo.swift
//  BlueArchive Database
//
//  Created by 2288-256 on 2023/11/28.
//  Copyright (c) 2023 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class CharacterInfo: UIViewController
{
	var unitId: Int = 0
	var BackPage: String = ""
	var jsonArrays: [[String: Any]] = []
	var LightArmorColor = UIColor(red: 167 / 255, green: 12 / 255, blue: 25 / 255, alpha: 1.0)
	var HeavyArmorColor = UIColor(red: 178 / 255, green: 109 / 255, blue: 31 / 255, alpha: 1.0)
	var UnarmedColor = UIColor(red: 33 / 255, green: 111 / 255, blue: 156 / 255, alpha: 1.0)
	var ElasticArmorColor = UIColor(red: 148 / 255, green: 49 / 255, blue: 165 / 255, alpha: 1.0)
	var NormalColor = UIColor(red: 72 / 255, green: 85 / 255, blue: 130 / 255, alpha: 1.0)
	var viewWidth: CGFloat = 0

	@IBOutlet var BackgroundImage: UIImageView!
	@IBOutlet var CharacterImage: UIImageView!
	@IBOutlet var Name: UILabel!

	@IBOutlet var Position: UILabel!
	@IBOutlet var ArmorType: UILabel!
	@IBOutlet var BulletType: UILabel!
	@IBOutlet var TacticRole: UILabel!
	@IBOutlet var TacticRoleImage: UIImageView!
	@IBOutlet var BulletTypeBGColor: UILabel!
	@IBOutlet var ArmorTypeBGColor: UILabel!

	@IBOutlet var StreetBattleAdaptationImage: UIImageView!
	@IBOutlet var OutdoorBattleAdaptationImage: UIImageView!
	@IBOutlet var IndoorBattleAdaptationImage: UIImageView!

	@IBOutlet var ContainerView: UIView!
	@IBOutlet var InfoView: UIView!
	@IBOutlet var StatusView: UIView!
	@IBOutlet var SkillView: UIView!
	@IBOutlet var WeaponView: UIView!
	@IBOutlet var MoreView: UIView!

	override func viewDidLoad()
	{
		super.viewDidLoad()
		ContainerView.bringSubviewToFront(SkillView)
		InfoView.isHidden = false
		StatusView.isHidden = true
		SkillView.isHidden = true
		WeaponView.isHidden = true
		MoreView.isHidden = true
		DispatchQueue.main.async
		{
			if self.jsonArrays.isEmpty
			{
				self.jsonArrays = LoadFile.shared.getStudents()
			}
		}
		setup(unitId: unitId)
		viewWidth = view.frame.width
	}

	// 初期化処理
	func setup(unitId: Int)
	{
		Name.text = ""
		Position.text = ""
		ArmorType.text = ""
		BulletType.text = ""
		TacticRole.text = ""
		TacticRoleImage.image = nil
		BulletTypeBGColor.text = ""
		ArmorTypeBGColor.text = ""
		StreetBattleAdaptationImage.image = nil
		OutdoorBattleAdaptationImage.image = nil
		IndoorBattleAdaptationImage.image = nil
		CharacterImage.image = nil
		ArmorTypeBGColor.backgroundColor = UIColor.white
		BulletTypeBGColor.backgroundColor = UIColor.white
		view.backgroundColor = UIColor.white

		// Do any additional setup after loading the view.
		let fileManager = FileManager.default
		let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
		let imagePath = libraryDirectory.appendingPathComponent("assets/images/student/portrait/\(unitId).webp")
		if let image = UIImage(contentsOfFile: imagePath.path)
		{
			DispatchQueue.main.async
			{
				self.CharacterImage.image = image
				self.CharacterImage.contentMode = .scaleAspectFit
				let height = self.CharacterImage.frame.size.width * (image.size.height / image.size.width)
				self.CharacterImage.heightAnchor.constraint(equalToConstant: height).isActive = true
			}
		}
		let matchingStudents = jsonArrays.filter { $0["Id"] as? Int == unitId }
		Name.text = matchingStudents.first?["Name"] as? String
		let PositionText = matchingStudents.first?["Position"] as? String
		Position.text = PositionText?.uppercased()
		ArmorType.text = LoadFile.shared.translateString((matchingStudents.first?["ArmorType"])! as! String)
		BulletType.text = LoadFile.shared.translateString((matchingStudents.first?["BulletType"])! as! String)
		TacticRole.text = LoadFile.shared.translateString((matchingStudents.first?["TacticRole"])! as! String)
		let image = UIImage(named: "Role_\((matchingStudents.first?["TacticRole"])! as! String)")
		TacticRoleImage.image = image

		if let armorType = matchingStudents.first?["ArmorType"] as? String
		{
			switch armorType
			{
			case "LightArmor":
				ArmorTypeBGColor.backgroundColor = LightArmorColor
			case "HeavyArmor":
				ArmorTypeBGColor.backgroundColor = HeavyArmorColor
			case "Unarmed":
				ArmorTypeBGColor.backgroundColor = UnarmedColor
			case "ElasticArmor":
				ArmorTypeBGColor.backgroundColor = ElasticArmorColor
			default:
				ArmorTypeBGColor.backgroundColor = NormalColor
			}
		}

		if let bulletType = matchingStudents.first?["BulletType"] as? String
		{
			switch bulletType
			{
			case "Explosion":
				BulletTypeBGColor.backgroundColor = LightArmorColor
			case "Pierce":
				BulletTypeBGColor.backgroundColor = HeavyArmorColor
			case "Mystic":
				BulletTypeBGColor.backgroundColor = UnarmedColor
			case "Sonic":
				BulletTypeBGColor.backgroundColor = ElasticArmorColor
			default:
				BulletTypeBGColor.backgroundColor = NormalColor
			}
		}

		let StreetAdaptationImage = UIImage(named: "Ingame_Emo_Adaptresult\((matchingStudents.first?["StreetBattleAdaptation"])! as! Int)")
		StreetBattleAdaptationImage.image = StreetAdaptationImage

		let OutdoorAdaptationImage = UIImage(named: "Ingame_Emo_Adaptresult\((matchingStudents.first?["OutdoorBattleAdaptation"])! as! Int)")
		OutdoorBattleAdaptationImage.image = OutdoorAdaptationImage

		let IndoorAdaptationImage = UIImage(named: "Ingame_Emo_Adaptresult\((matchingStudents.first?["IndoorBattleAdaptation"])! as! Int)")
		IndoorBattleAdaptationImage.image = IndoorAdaptationImage

		let BackgroundImageFileName = matchingStudents.first?["CollectionBG"]! as! String
		let BackgroundImagePath = libraryDirectory.appendingPathComponent("assets/images/background/\(BackgroundImageFileName).jpg")
		if let image = UIImage(contentsOfFile: BackgroundImagePath.path)
		{
			DispatchQueue.main.async
			{
				self.BackgroundImage.image = image
				self.BackgroundImage.contentMode = .scaleAspectFill
				let width = self.BackgroundImage.frame.size.height * (image.size.width / image.size.height)
				self.BackgroundImage.widthAnchor.constraint(equalToConstant: width).isActive = true
			}
		}
	}

	override func didReceiveMemoryWarning()
	{
		super.didReceiveMemoryWarning()
	}

	func updateViewWithNewData(unitId: Int)
	{
		setup(unitId: unitId)
	}

	override func prepare(for segue: UIStoryboardSegue, sender _: Any?)
	{
		if jsonArrays.isEmpty
		{
			jsonArrays = LoadFile.shared.getStudents()
		}
		switch (segue.identifier, segue.destination)
		{
		case let ("toCharacterProfile"?, destination as CharacterProfilePage):
			destination.unitId = unitId
			destination.jsonArrays = jsonArrays
		case let ("toMorePage"?, destination as CharacterMorePage):
			destination.unitId = unitId
		case let ("toStatus"?, destination as CharacterStatus):
			destination.unitId = unitId
			destination.jsonArrays = jsonArrays
		case let ("toSkill"?, destination as CharacterSkill):
			destination.unitId = unitId
			destination.jsonArrays = jsonArrays
		case let ("toWeapon"?, destination as CharacterWeaponGearPage):
			destination.unitId = unitId
			destination.jsonArrays = jsonArrays
		default:
			()
		}
	}

	@IBAction func changeInfoView(_: UISegmentedControl)
	{
		InfoView.isHidden = false
		MoreView.isHidden = true
		StatusView.isHidden = true
		SkillView.isHidden = true
		WeaponView.isHidden = true
		ContainerView.bringSubviewToFront(InfoView)
	}

	@IBAction func changeMoreView(_: UISegmentedControl)
	{
		InfoView.isHidden = true
		MoreView.isHidden = false
		StatusView.isHidden = true
		SkillView.isHidden = true
		WeaponView.isHidden = true
		ContainerView.bringSubviewToFront(MoreView)
	}

	@IBAction func changeStatusView(_: UISegmentedControl)
	{
		InfoView.isHidden = true
		MoreView.isHidden = true
		StatusView.isHidden = false
		SkillView.isHidden = true
		WeaponView.isHidden = true
		ContainerView.bringSubviewToFront(StatusView)
	}

	@IBAction func changeSkillView(_: UISegmentedControl)
	{
		InfoView.isHidden = true
		MoreView.isHidden = true
		StatusView.isHidden = true
		SkillView.isHidden = false
		WeaponView.isHidden = true
		ContainerView.bringSubviewToFront(SkillView)
	}

	@IBAction func changeWeaponView(_: UISegmentedControl)
	{
		InfoView.isHidden = true
		MoreView.isHidden = true
		StatusView.isHidden = true
		SkillView.isHidden = true
		WeaponView.isHidden = false
		ContainerView.bringSubviewToFront(WeaponView)
	}

	@IBAction func BackButton(_: Any)
	{
		dismiss(animated: false, completion: nil)
	}

	@IBAction func HomeButton(_: UIButton)
	{
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let nextVC = storyboard.instantiateViewController(withIdentifier: "Home") as! ViewController
		present(nextVC, animated: false, completion: nil)
	}
}
