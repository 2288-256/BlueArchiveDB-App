//
//  CharacterStatusMore.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/02/15
//  Copyright (c) 2024 2288-256 All Rights Reserved
//

import Foundation
import UIKit
class CharacterStatusMore: UIViewController {
    var unitId: Int = 0
    var studentStatus: [[String: Any]] = []
    let checkedImage = UIImage(named: "ico_check_on")!
    let uncheckedImage = UIImage(named: "ico_check_off")!
    var EquipmentTier: [Int] = []
    var EquipmentName: [String] = []
    var WeaponImageName:String = ""
    var ItemJson: [[String: Any]] = []
    var configJson: [String: Any] = [:]
    var localizeJson: [String: Any] = [:]
    var MaxTir:[Int] = []
    var MaxWeaponLevel:Int = 0
    var nowWeaponLevel:Int = 50
    var stargrade: Int = 1
    var addBonus: [String: Int] = [:]
    var weaponBuff:[String:Int] = [:]
    var StatusList:[String: Any]=["1":"MaxHP","2":"AttackPower","3":"DefensePower","4":"HealPower","5":"AccuracyPoint","6":"DodgePoint","7":"CriticalPoint","8":"CriticalChanceResistPoint","9":"CriticalDamageRate","10":"CriticalDamageResistRate","11":"StabilityPoint","12":"Range","13":"OppressionPower","14":"OppressionResist","15":"HealEffectivenessRate","16":"RegenCost","17":"AttackSpeed","18":"BlockRate","19":"DefensePenetration","20":"AmmoCount"]
    var StarHPCorrection: [[String: Any]] = [["1":0,"2":1.05,"3":1.12,"4":1.21,"5":1.35]]
    var StarATKCorrection: [[String: Any]] = [["1":0,"2":1.10,"3":1.22,"4":1.36,"5":1.53]]
    var StarHealingCorrection: [[String: Any]] = [["1":0,"2":1.075,"3":1.175,"4":1.295,"5":1.445]]
    var EquipmentArray:[String] = []
    var EquipmentToggleButtonStatus = false
    @IBOutlet var StarTierImages:[UIImageView] = []
    @IBOutlet weak var LevelSliderLabel: UILabel!
    @IBOutlet weak var LevelSlider:UISlider!
    @IBOutlet weak var EquipmentToggleButton: UIButton!
    var nowLevel: Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItem()
        loadConfig()
        loadTranslation()
        EquipmentToggleButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        EquipmentToggleButton.setImage(uncheckedImage, for: .normal)
        EquipmentToggleButton.setImage(checkedImage, for: .selected)
        if EquipmentToggleButtonStatus == true{
            EquipmentToggleButton.isSelected = true
        }else{
            EquipmentToggleButton.isSelected = false
        }
        EquipmentArray = studentStatus.first?["Equipment"] as! [String]
        LevelSlider.value = Float(nowLevel)
        LevelSliderLabel.text = "Lv." + String(nowLevel)
        let regions = configJson["Regions"] as! [[String: Any]]
        let jpRegion = regions.first(where: { $0["Name"] as? String == "Jp" })
        MaxTir = jpRegion?["EquipmentMaxLevel"] as? [Int] ?? []
        MaxWeaponLevel = jpRegion?["WeaponMaxLevel"] as? Int ?? 0
        let weaponStatus = studentStatus.first?["Weapon"] as? [String: Any]
        var contentStackView: UIStackView
        contentStackView = self.view.viewWithTag(999) as! UIStackView
        for i in 1...StatusList.count {
            var stackView: UIStackView
            var childStackView: UIStackView
            var categoryLabel: UILabel
            var beforeLabel: UILabel
            var addLabel: UILabel
            var addPercentLabel: UILabel
            var afterLabel: UILabel
            stackView = UIStackView()
            childStackView = UIStackView()
            categoryLabel = UILabel()
            beforeLabel = UILabel()
            addLabel = UILabel()
            addPercentLabel = UILabel()
            afterLabel = UILabel()
            stackView.axis = .horizontal
            stackView.distribution = .fill
            stackView.alignment = .fill
            childStackView.axis = .horizontal
            childStackView.distribution = .fillEqually
            childStackView.alignment = .fill
            categoryLabel.text = "\(translateStat(text: StatusList["\(i)"] as! String))"
            categoryLabel.tag = i*1000+1
            categoryLabel.widthAnchor.constraint(equalToConstant: 205).isActive = true
            beforeLabel.tag = i*1000+2
            beforeLabel.text = "0"
            beforeLabel.textAlignment = .right
            addLabel.tag = i*1000+3
            addLabel.text = "0"
            addLabel.textAlignment = .right
            addPercentLabel.tag = i*1000+4
            addPercentLabel.text = "0"
            addPercentLabel.textAlignment = .right
            afterLabel.tag = i*1000+5
            afterLabel.text = "0"
            afterLabel.textAlignment = .right
            stackView.addArrangedSubview(categoryLabel)
            childStackView.addArrangedSubview(beforeLabel)
            childStackView.addArrangedSubview(addLabel)
            childStackView.addArrangedSubview(addPercentLabel)
            childStackView.addArrangedSubview(afterLabel)
            stackView.addArrangedSubview(childStackView)
            contentStackView.addArrangedSubview(stackView)
        }
        
        //        MaxTir =
        for i in 1...3 {
            let equipmentView = self.view.viewWithTag(i) as! UIView
            let equipmentTierSlider = equipmentView.viewWithTag(i*10) as! UISlider
            equipmentTierSlider.maximumValue = Float(MaxTir[i-1])
            equipmentTierSlider.value = Float(EquipmentTier[i-1])
            let equipmentEffectLabel = equipmentView.viewWithTag((i*100)+1) as! UILabel
            let equipmentName = equipmentView.viewWithTag(i*100) as! UILabel
            let equipmentTierLabel = equipmentView.viewWithTag((i*100)+2) as! UILabel
            equipmentTierLabel.text = "T\(EquipmentTier[i-1])"
            let equipmentImageView = equipmentView.viewWithTag((i*100)+3) as! UIImageView
            UpdateEquipmentName(EquipmentType: EquipmentName[i-1], Tier: EquipmentTier[i-1], EquipmentNameLabel: equipmentName, EquipmentImage: equipmentImageView, equipmentEffectLabel: equipmentEffectLabel,tag:i)
        }
        let equipmentView = self.view.viewWithTag(4) as! UIView
        let equipmentTierSlider = equipmentView.viewWithTag(4*10) as! UISlider
        equipmentTierSlider.maximumValue = Float(MaxWeaponLevel)
        equipmentTierSlider.minimumValue = 0
        equipmentTierSlider.value = Float(nowWeaponLevel)
        let equipmentEffectLabel = equipmentView.viewWithTag((4*100)+1) as! UILabel
        let equipmentName = equipmentView.viewWithTag(4*100) as! UILabel
        equipmentName.text = weaponStatus?["Name"] as? String ?? "Error"
        let equipmentTierLabel = equipmentView.viewWithTag((4*100)+2) as! UILabel
        equipmentTierLabel.text = "Lv.\(nowWeaponLevel)"
        let equipmentImageView = equipmentView.viewWithTag((4*100)+3) as! UIImageView
        let imageName = studentStatus.first?["WeaponImg"] as! String
        let fileManager = FileManager.default
        let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
        let imagePath = libraryDirectory.appendingPathComponent("assets/images/weapon/\(imageName).webp")
        
        if let image = UIImage(contentsOfFile: imagePath.path) {
            equipmentImageView.image = image
            equipmentImageView.contentMode = .scaleAspectFit
            let height = equipmentImageView.frame.size.width * (image.size.height / image.size.width)
            equipmentImageView.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        UpdateWeaponLevel(level: Int(equipmentTierSlider.value), equipmentEffectLabel: equipmentEffectLabel)
        updateStar(selStarGrade: stargrade)
        LabelSetUp(level: nowLevel)
    }
    weak var delegate: CharacterStatusDelegate?
    @IBAction func TapStarTier(_ sender: UITapGestureRecognizer) {
        let cell = sender.view as! UIImageView
        updateStar(selStarGrade: Int(cell.tag))
        let equipmentView = self.view.viewWithTag(4) as! UIView
        var WeaponLevelLabel = equipmentView.viewWithTag((4*100)+2) as! UILabel
        var WeaponLevelSlider = equipmentView.viewWithTag(40) as! UISlider
        switch stargrade {
        case ...5:
            nowWeaponLevel = 0
            WeaponLevelLabel.text = ""
            WeaponLevelSlider.value = 0.0
        case 6:
            nowWeaponLevel = 30
            WeaponLevelLabel.text = "Lv."+String(nowWeaponLevel)
            WeaponLevelSlider.value = Float(nowWeaponLevel)
        case 7:
            nowWeaponLevel = 40
            WeaponLevelLabel.text = "Lv."+String(nowWeaponLevel)
            WeaponLevelSlider.value = Float(nowWeaponLevel)
        case 8:
            nowWeaponLevel = 50
            WeaponLevelLabel.text = "Lv."+String(nowWeaponLevel)
            WeaponLevelSlider.value = Float(nowWeaponLevel)
        default:
            ()
        }
        LabelSetUp(level: nowLevel)
    }
    @IBAction func buttonDidTap(_ sender: UIButton) {
        // ここは`button`と`sender`は同じオブジェクトなので、`sender.isSelected = ...`とか`= !button.isSelected`でも大丈夫
        EquipmentToggleButton.isSelected = !sender.isSelected
        LabelSetUp(level: nowLevel)
    }
    @IBAction func LevelSliderChanged(_ sender: UISlider) {
        nowLevel = Int(sender.value)
        LevelSliderLabel.text = "Lv." + String(Int(sender.value))
        LabelSetUp(level: Int(sender.value))
    }
    
    @IBAction func WeaponLevelChanged(_ sender: UISlider){
        sender.value = round(sender.value)
        let equipmentView = self.view.viewWithTag(4) as! UIView
        let equipmentEffectLabel = equipmentView.viewWithTag((4*100)+1) as! UILabel
        let WeaponLevelLabel = equipmentView.viewWithTag((4*100)+2) as! UILabel
        WeaponLevelLabel.text = "Lv.\(Int(sender.value))"
        nowWeaponLevel = Int(sender.value)
        UpdateWeaponLevel(level: Int(sender.value), equipmentEffectLabel: equipmentEffectLabel)
        if nowWeaponLevel == 0{
            equipmentEffectLabel.text = ""
        }
        LabelSetUp(level: nowLevel)
    }
    @IBAction func TierSliderChanged(_ sender: UISlider) {
        sender.value = round(sender.value)
        let senderTag = sender.tag
        let equipmentView = self.view.viewWithTag(senderTag/10) as! UIView
        let equipmentName = equipmentView.viewWithTag(senderTag*10) as! UILabel
        let equipmentEffectLabel = equipmentView.viewWithTag((senderTag*10)+1) as! UILabel
        let equipmentTierLabel = equipmentView.viewWithTag((senderTag*10)+2) as! UILabel
        let equipmentImageView = equipmentView.viewWithTag((senderTag*10)+3) as! UIImageView
        equipmentTierLabel.text = "T\(Int(sender.value))"
        UpdateEquipmentName(EquipmentType: EquipmentName[senderTag/10-1], Tier: Int(sender.value), EquipmentNameLabel: equipmentName,EquipmentImage:equipmentImageView,equipmentEffectLabel:equipmentEffectLabel,tag:senderTag/10)
    }
    func UpdateWeaponLevel(level:Int,equipmentEffectLabel:UILabel){
        var BuffText:String = ""
        var levelscale:Double = Double(Double(level-1)/99)
        let weaponStatus = studentStatus.first?["Weapon"] as? [String: Any]
        if weaponStatus?["StatLevelUpType"] as? String == "Standard" {
            levelscale = (round(levelscale * 10000) / 10000)
        }
        weaponBuff["AttackPower"] = Int(round((weaponStatus!["AttackPower1"] as! Double) + ((weaponStatus!["AttackPower100"] as! Double) - (weaponStatus!["AttackPower1"] as! Double)) * Double(levelscale)))
        weaponBuff["MaxHP"] = Int(round((weaponStatus!["MaxHP1"] as! Double) + ((weaponStatus!["MaxHP100"] as! Double) - (weaponStatus!["MaxHP1"] as! Double)) * Double(levelscale)))
        weaponBuff["HealPower"] = Int(round((weaponStatus!["HealPower1"] as! Double) + ((weaponStatus!["HealPower100"] as! Double) - (weaponStatus!["HealPower1"] as! Double)) * Double(levelscale)))
        let sortedWeaponBuff = weaponBuff.sorted { $0.key < $1.key }
        for (key, value) in sortedWeaponBuff {
            if value != 0 {
                BuffText.append("\(translateStat(text: key)) +\(value) ")
            }
        }
        
        let equipmentView = self.view.viewWithTag(4) as! UIView
        var WeaponImage = self.view.viewWithTag((4*100)+3) as! UIImageView
        if nowWeaponLevel != 0{
            equipmentEffectLabel.text = BuffText
            WeaponImage.image = WeaponImage.image?.withRenderingMode(.alwaysOriginal)
            WeaponImage.tintColor = .clear
        }else{
            equipmentEffectLabel.text = ""
            WeaponImage.image = WeaponImage.image?.withRenderingMode(.alwaysTemplate)
            WeaponImage.tintColor = .gray
        }
    }
    func UpdateEquipmentName(EquipmentType:String,Tier:Int,EquipmentNameLabel:UILabel,EquipmentImage:UIImageView,equipmentEffectLabel:UILabel,tag:Int){
        let matchingStudents = ItemJson.filter { $0["Icon"] as? String == "equipment_icon_\(EquipmentType.lowercased())_tier\(Tier)" }
        let StatType = matchingStudents.first?["StatType"] as! [String]
        let StatValue = matchingStudents.first?["StatValue"] as! [[Int]]
        var EffectText:String = ""
        for i in 0..<StatType.count {
            if StatType[i].components(separatedBy: "_")[1] == "Coefficient"{
                EffectText.append("\(translateStat(text: StatType[i].components(separatedBy: "_")[0]) ) +\(StatValue[i][1]/100)% ")
            }else{
                EffectText.append("\(translateStat(text: StatType[i].components(separatedBy: "_")[0]) ) +\(StatValue[i][1]) ")
            }
        }
        equipmentEffectLabel.text = EffectText
        EquipmentNameLabel.text = matchingStudents.first?["Name"] as? String
        let fileManager = FileManager.default
        let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
        let Equipment1ImagePath = libraryDirectory.appendingPathComponent("assets/images/equipment/full/equipment_icon_\(EquipmentType.lowercased())_tier\(Tier).webp")
        EquipmentImage.image = UIImage(contentsOfFile: Equipment1ImagePath.path)
        EquipmentTier[tag-1] = Tier
        LabelSetUp(level: nowLevel)
    }
    func updateStar(selStarGrade:Int){
        stargrade = selStarGrade
        let equipmentView = self.view.viewWithTag(4) as! UIView
        var WeaponLevelLabel = equipmentView.viewWithTag((4*100)+2) as! UILabel
        var equipmentEffectLabel = equipmentView.viewWithTag((4*100)+1) as! UILabel
        var WeaponLevelSlider = equipmentView.viewWithTag(40) as! UISlider
        for i in 1...StarTierImages.count {
            StarTierImages[i-1].image = UIImage(systemName: "star.fill")
            StarTierImages[i-1].tintColor = UIColor.gray
        }
        //1からtagまでの間繰り返す
        for i in 1 ... stargrade {
            //もし6以上なら
            if i >= 6 {
                StarTierImages[i-1].image = UIImage(systemName: "star.fill")
                StarTierImages[i-1].tintColor = UIColor(red: 0, green: 196/255, blue: 245/255, alpha: 1)
            } else {
                //iのtagがついたUIImageViewをstar.fillにする
                StarTierImages[i-1].image = UIImage(systemName: "star.fill")
                StarTierImages[i-1].tintColor = UIColor(red: 255/255, green: 147/255, blue: 0/255, alpha: 1.0)
            }
        }
        if nowWeaponLevel >= 0 && stargrade <= 5{
            nowWeaponLevel = 0
            WeaponLevelLabel.text = ""
            WeaponLevelSlider.value = 0.0
        }else{
            
        }
        UpdateWeaponLevel(level: nowWeaponLevel, equipmentEffectLabel: equipmentEffectLabel)
    }
    func LabelSetUp(level: Int,noWeaponLevel:Bool = true) {
        addBonus.removeAll()
        var Equipment1 = self.view.viewWithTag(103) as! UIImageView
        var Equipment2 = self.view.viewWithTag(203) as! UIImageView
        var Equipment3 = self.view.viewWithTag(303) as! UIImageView
        if EquipmentToggleButton.isSelected {
            Equipment1.image = Equipment1.image?.withRenderingMode(.alwaysOriginal)
            Equipment1.tintColor = .clear
            Equipment2.image = Equipment2.image?.withRenderingMode(.alwaysOriginal)
            Equipment2.tintColor = .clear
            Equipment3.image = Equipment3.image?.withRenderingMode(.alwaysOriginal)
            Equipment3.tintColor = .clear
            for i in 1...3 {
                switch i {
                case 2 where level < 15:
                    Equipment2.image = Equipment2.image?.withRenderingMode(.alwaysTemplate)
                    Equipment2.tintColor = .gray
                    Equipment3.image = Equipment3.image?.withRenderingMode(.alwaysTemplate)
                    Equipment3.tintColor = .gray
                    break
                case 3 where level < 35:
                    Equipment3.image = Equipment3.image?.withRenderingMode(.alwaysTemplate)
                    Equipment3.tintColor = .gray
                    break
                default:
                    let matchingStudents = ItemJson.filter { $0["Icon"] as? String == "equipment_icon_\(EquipmentName[i-1].lowercased())_tier\(String(EquipmentTier[i-1]))" }
                    let statType = matchingStudents.first?["StatType"] as! [String]
                    let statValue = matchingStudents.first?["StatValue"] as! [[Int]]
                    for j in 0..<statType.count {
                        if let existingValue = addBonus[statType[j]] {
                            addBonus[statType[j]] = existingValue + statValue[j][1]
                        } else {
                            addBonus[statType[j]] = statValue[j][1]
                        }
                    }
                }
            }
        } else {
            Equipment1.image = Equipment1.image?.withRenderingMode(.alwaysTemplate)
            Equipment1.tintColor = .gray
            Equipment2.image = Equipment2.image?.withRenderingMode(.alwaysTemplate)
            Equipment2.tintColor = .gray
            Equipment3.image = Equipment3.image?.withRenderingMode(.alwaysTemplate)
            Equipment3.tintColor = .gray
        }
        
        switch nowWeaponLevel {
        case let s where s > 40:
            updateStar(selStarGrade: 8)
        case let s where s > 30:
            updateStar(selStarGrade: 7)
        case let s where s > 0:
            updateStar(selStarGrade: 6)
        case let s where s == 0 && stargrade >= 5:
            updateStar(selStarGrade: 5)
        default:
            ()
        }
        for i in 1...StatusList.count {
            var beforeLabel = self.view.viewWithTag((i*1000)+2) as! UILabel
            var addLabel = self.view.viewWithTag((i*1000)+3) as! UILabel
            var addPercentLabel = self.view.viewWithTag((i*1000)+4) as! UILabel
            var afterLabel = self.view.viewWithTag((i*1000)+5) as! UILabel
            GetStatusValue(StatusName: StatusList["\(i)"] as! String, BeforeLabel: beforeLabel, addLabel: addLabel, addPercentLabel: addPercentLabel, afterLabel: afterLabel, level: level)
            if addLabel.text == "0"{
                addLabel.textColor = .darkGray
            }else{
                addLabel.textColor = .systemBlue
            }
            if addPercentLabel.text == "0"{
                addPercentLabel.textColor = .darkGray
            }else{
                addPercentLabel.textColor = .systemBlue
            }
            addLabel.text = "+" + addLabel.text!
            addPercentLabel.text = "+" + addPercentLabel.text! + "%"
        }
        //OppressionPower
        //        CCPowerLabel.text = "100"
        //        //OppressionResist
        //        CCRESLabel.text = "100"
        //        fromStatusMore = false
    }
    func GetStatusValue(StatusName: String, BeforeLabel: UILabel,addLabel:UILabel,addPercentLabel:UILabel,afterLabel:UILabel, level: Int) {
        let transcendence: [[Double]] = [[0, 1000, 1200, 1400, 1700], [0, 500, 700, 900, 1400], [0, 750, 1000, 1200, 1500]]
        var transcendenceAttack: Double = 1
        var transcendenceHP: Double = 1
        var transcendenceHeal: Double = 1
        var addValue:Int=0
        var addCoefficient:Double=1.0
        addLabel.text = addLabel.text?.replacingOccurrences(of: "+", with: "").replacingOccurrences(of: ",", with: "")
        addPercentLabel.text = addPercentLabel.text?.replacingOccurrences(of: "+", with: "").replacingOccurrences(of: "%", with: "").replacingOccurrences(of: ",", with: "")
        for i in 1 ..< stargrade {
            if i < 5 {
                transcendenceAttack += Double(transcendence[0][i] / 10000)
                transcendenceHP += Double(transcendence[1][i] / 10000)
                transcendenceHeal += Double(transcendence[2][i] / 10000)
            }
        }
        
        if let start1 = studentStatus.first?["\(StatusName)1"] as? Double,
           let weaponStatus = studentStatus.first?["Weapon"] as? [String: Any],
           let start100 = studentStatus.first?["\(StatusName)100"] as? Double {
            var levelScale: Double = 0
            levelScale = round((Double(level - 1) / 99) * 10000) / 10000
            var scaledValue = 0
            
            switch StatusName {
            case "MaxHP":
                var addWeaponHP = 0
                if nowWeaponLevel > 0 && stargrade > 5 {
                    let MaxHP1 = weaponStatus["\(StatusName)1"] as! Double
                    let MaxHP100 = weaponStatus["\(StatusName)100"] as! Double
                    var levelscale = Double(nowWeaponLevel - 1) / 99
                    
                    if weaponStatus["StatLevelUpType"] as! String == "Standard" {
                        levelscale = (round(levelscale * 10000) / 10000)
                    }
                    
                    addWeaponHP = Int(round(MaxHP1 + (MaxHP100 - MaxHP1) * levelscale))
                } else {
                    addWeaponHP = 0
                }
                
                let tempValue: Double = round((start1 + (start100 - start1) * levelScale) * 10000) / 10000
                scaledValue = Int(ceil((round(tempValue) * Double(transcendenceHP)) + Double(addWeaponHP)))
                
            case "AttackPower":
                var addWeaponATK = 0
                if nowWeaponLevel > 0 && stargrade > 5 {
                    let ATK1 = weaponStatus["\(StatusName)1"] as! Double
                    let ATK100 = weaponStatus["\(StatusName)100"] as! Double
                    var levelscale = Double(nowWeaponLevel - 1) / 99
                    
                    if weaponStatus["StatLevelUpType"] as! String == "Standard" {
                        levelscale = (round(levelscale * 10000) / 10000)
                    }
                    
                    addWeaponATK = Int(round(ATK1 + (ATK100 - ATK1) * levelscale))
                } else {
                    addWeaponATK = 0
                }
                
                let tempValue: Double = round((start1 + (start100 - start1) * levelScale) * 10000) / 10000
                scaledValue = Int(ceil((round(tempValue) * Double(transcendenceAttack)) + Double(addWeaponATK)))
                
            case "HealPower":
                var addWeaponHeal = 0
                if nowWeaponLevel > 0 && stargrade > 5 {
                    let Heal1 = weaponStatus["\(StatusName)1"] as! Double
                    let Heal100 = weaponStatus["\(StatusName)100"] as! Double
                    var levelscale = Double(nowWeaponLevel - 1) / 99
                    
                    if weaponStatus["StatLevelUpType"] as! String == "Standard" {
                        levelscale = (round(levelscale * 10000) / 10000)
                    }
                    
                    addWeaponHeal = Int(round(Heal1 + (Heal100 - Heal1) * levelscale))
                } else {
                    addWeaponHeal = 0
                }
                
                let tempValue: Double = round((start1 + (start100 - start1) * levelScale) * 10000) / 10000
                scaledValue = Int(ceil((round(tempValue) * Double(transcendenceHeal)) + Double(addWeaponHeal)))
                
            default:
                var levelscale = Double(nowWeaponLevel - 1) / 99
                
                if weaponStatus["StatLevelUpType"] as! String == "Standard" {
                    levelscale = (round(levelscale * 10000) / 10000)
                }
                
                scaledValue = Int(round((start1 + (start100 - start1) * levelScale) * 10000) / 10000)
            }
            
            
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = ","
            formatter.groupingSize = 3
            formatter.usesGroupingSeparator = true
            
            BeforeLabel.text = formatter.string(from: NSNumber(value: scaledValue))
            viewMoreStatus(StatusName: StatusName, addLabel: addLabel, addPercentLabel: addPercentLabel, BeforeValue: scaledValue, afterLabel: afterLabel)
        } else{
            if StatusName == "CriticalDamageRate",
               let StatusValue = studentStatus.first?["\(StatusName)"] as? Int {
                BeforeLabel.text = "\(StatusValue / 100)"
            } else if let StatusValue = studentStatus.first?["\(StatusName)"] as? Int {
                BeforeLabel.text = "\(StatusValue)"
            } else if StatusName == "CriticalChanceResistPoint" {
                if let StatusValue = studentStatus.first?["\(StatusName)"] as? Int{
                    BeforeLabel.text = "\(StatusValue)"
                }else{
                    BeforeLabel.text = "100"
                }
            } else if StatusName == "CriticalDamageResistRate" {
                if let StatusValue = studentStatus.first?["\(StatusName)"] as? Int{
                    BeforeLabel.text = "\(StatusValue/100)"
                }else{
                    BeforeLabel.text = "50"
                }
            }else if StatusName == "OppressionPower" {
                if let StatusValue = studentStatus.first?["\(StatusName)"] as? Int{
                    BeforeLabel.text = "\(StatusValue)"
                }else{
                    BeforeLabel.text = "100"
                }
            }else if StatusName == "HealEffectivenessRate" {
                if let StatusValue = studentStatus.first?["\(StatusName)"] as? Int{
                    BeforeLabel.text = "\(StatusValue)"
                }else{
                    BeforeLabel.text = "100"
                }
            } else if StatusName == "OppressionResist" || StatusName == "AttackSpeed" {
                BeforeLabel.text = "100"
            }else if StatusName == "BlockRate" {
                BeforeLabel.text = "0"
            }else if StatusName == "DefensePenetration" {
                BeforeLabel.text = "0"
            }else{
                BeforeLabel.text = "Error"
            }
            viewMoreStatus(StatusName: StatusName, addLabel: addLabel, addPercentLabel: addPercentLabel, BeforeValue: Int("\(BeforeLabel.text ?? "0")")!, afterLabel: afterLabel)
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = ","
            formatter.groupingSize = 3
            formatter.usesGroupingSeparator = true
            
            BeforeLabel.text = formatter.string(from: NSNumber(value: Int(BeforeLabel.text ?? "0")!))
        }
    }
    func viewMoreStatus(StatusName:String,addLabel:UILabel,addPercentLabel:UILabel,BeforeValue:Int,afterLabel:UILabel){
        
        var addValue = 0
        var addCoefficient = 1.0
        var matchedKeys: [String] = []
        addLabel.text = "0"
        addPercentLabel.text = "0"
        
        for (key, _) in addBonus {
            if key.contains(StatusName) {
                matchedKeys.append(key)
            }
        }
        if !matchedKeys.isEmpty {
            for i in 1...matchedKeys.count{
                if matchedKeys[i-1].contains("Base"){
                    addValue = addBonus[matchedKeys[i-1]]!
                    print("\(StatusName)_Base_\(addValue)")
                    addLabel.text = "\(Int(addLabel.text!)! + Int(addBonus[matchedKeys[i-1]]!))"
                    
                }
                if matchedKeys[i-1].contains("Coefficient"){
                    addCoefficient = Double(addBonus[matchedKeys[i-1]]!)/10000+1
                    
                    print("\(StatusName)_Coefficient_\(addCoefficient)")
                    addPercentLabel.text = String("\(Double(addPercentLabel.text!)! + Double(addBonus[matchedKeys[i-1]]!)/100)".suffixZeroSuppress()!)
                    
                }
            }
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        formatter.usesGroupingSeparator = true
        afterLabel.text = formatter.string(from: NSNumber(value: Int(round(Double(BeforeValue+addValue) * addCoefficient)*10000)/10000))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ポップアップの外側をタップした時にポップアップを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        var tapLocation: CGPoint = CGPoint()
        // タッチイベントを取得する
        let touch = touches.first
        // タップした座標を取得する
        tapLocation = touch!.location(in: self.view)
        
        let popUpView: UIView = self.view.viewWithTag(100)! as UIView
        
        if !popUpView.frame.contains(tapLocation) {
            loadItem()
            var EquipmentTier: Dictionary<Int, String> = [:]
            for i in 1 ... 3{
                let equipmentView = self.view.viewWithTag(i) as! UIView
                let equipmentTierSlider = equipmentView.viewWithTag(i*10) as! UISlider
                EquipmentTier[i] = String(Int(round(equipmentTierSlider.value)))
            }
            let equipmentView = self.view.viewWithTag(4) as! UIView
            let equipmentTierSlider = equipmentView.viewWithTag(4*10) as! UISlider
            let WeaponLevel = Int(equipmentTierSlider.value)
            let nowLevel = Int(nowLevel)
            let EquipmentToggleButtonStatus = EquipmentToggleButton.isSelected
            let StarTier = stargrade
            delegate?.dataBack(EquipmentTier: EquipmentTier, WeaponLevel: WeaponLevel,nowLevel:nowLevel,EquipmentToggleButtonStatus:EquipmentToggleButtonStatus,StarTier:StarTier)
            self.dismiss(animated: false, completion: nil)
        }
    }
    func loadItem() {
        do {
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
            let studentsFileURL = documentsURL.appendingPathComponent("assets/data/jp/equipment.json")
            
            guard FileManager.default.fileExists(atPath: studentsFileURL.path) else {
                return
            }
            
            let data = try Data(contentsOf: studentsFileURL)
            ItemJson = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
        } catch {
            print("Error reading students JSON file: \(error)")
        }
    }
    func loadConfig() {
        do {
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
            let studentsFileURL = documentsURL.appendingPathComponent("assets/data/config.json")
            
            guard FileManager.default.fileExists(atPath: studentsFileURL.path) else {
                return
            }
            
            let data = try Data(contentsOf: studentsFileURL)
            configJson = try (JSONSerialization.jsonObject(with: data) as? [String: Any]? ?? [:])!
        } catch {
            print("Error reading students JSON file: \(error)")
        }
    }
    func loadTranslation(){
        do {
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
            let studentsFileURL = documentsURL.appendingPathComponent("assets/data/jp/localization.json")
            
            guard FileManager.default.fileExists(atPath: studentsFileURL.path) else {
                return
            }
            
            let data = try Data(contentsOf: studentsFileURL)
            localizeJson = try JSONSerialization.jsonObject(with: data) as! [String : Any]
        } catch {
            print("Error reading students JSON file: \(error)")
        }
    }
    func translateStat(text: String) -> String {
        if let localization = localizeJson["Stat"] as? [String: Any] {
            return localization["\(text)"] as! String
        }
        return "" // Add this line to provide a default return value
    }
}


extension String {
    func suffixZeroSuppress() -> String? {
        guard let d = Double(self) else {
            return nil
        }
        
        var t = String(d)
        
        if let range = t.range(of: ".0") {
            t.replaceSubrange(range, with: "")
        }
        return t
    }
}
