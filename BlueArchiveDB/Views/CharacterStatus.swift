//
//  CharacterStatus.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/02/05.
//  Copyright (c) 2023 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class CharacterStatus: UIViewController {
    
    var unitId: Int = 0
    var jsonArrays: [[String: Any]] = []
    var ItemJson: [[String: Any]] = []
    var studentStatus: [[String: Any]] = []
    var stargrade: Int = 1
    var nowLevel:Int = 1
    var nowWeaponLevel:Int = 0
    var fromStatusMore = false
    var StarHPCorrection: [[String: Any]] = [["1":0,"2":1.05,"3":1.12,"4":1.21,"5":1.35]]
    var StarATKCorrection: [[String: Any]] = [["1":0,"2":1.10,"3":1.22,"4":1.36,"5":1.53]]
    var StarHealingCorrection: [[String: Any]] = [["1":0,"2":1.075,"3":1.175,"4":1.295,"5":1.445]]
    var EquipmentTier:Dictionary<Int, String> = [1:"1",2:"1",3:"1"]
    var OrangeColor: UIColor = UIColor(red: 255/255, green: 147/255, blue: 0/255, alpha: 1.0)
    var addBonus:[String:Int] = [:]
    var weaponBuff:[String:Int] = [:]
    var EquipmentArray:[String] = []
    let checkedImage = UIImage(named: "ico_check_on")!
    let uncheckedImage = UIImage(named: "ico_check_off")!
    @IBOutlet weak var MaxHpLabel: UILabel!
    @IBOutlet weak var DEFLabel: UILabel!
    @IBOutlet weak var AccuracyLabel: UILabel!
    @IBOutlet weak var CritLabel: UILabel!
    @IBOutlet weak var CritDMGLabel: UILabel!
    @IBOutlet weak var StabilityLabel: UILabel!
    @IBOutlet weak var ATKLabel: UILabel!
    @IBOutlet weak var HealingLabel: UILabel!
    @IBOutlet weak var EvasionLabel: UILabel!
    @IBOutlet weak var AttackRangeLabel: UILabel!
    @IBOutlet weak var CCPowerLabel: UILabel!
    @IBOutlet weak var CCRESLabel: UILabel!
    @IBOutlet weak var LevelSlider: UISlider!
    @IBOutlet weak var LevelSliderLabel: UILabel!
    @IBOutlet weak var WeaponImage: UIImageView!
    @IBOutlet weak var WeaponType: UILabel!
    @IBOutlet weak var WeaponLevelLabel: UILabel!
    @IBOutlet weak var CoverImage:UIImageView!
    @IBOutlet weak var StreetBattleAdaptationImage: UIImageView!
    @IBOutlet weak var OutdoorBattleAdaptationImage: UIImageView!
    @IBOutlet weak var IndoorBattleAdaptationImage: UIImageView!
    @IBOutlet weak var Equipment1: UIImageView!
    @IBOutlet weak var Equipment2: UIImageView!
    @IBOutlet weak var Equipment3: UIImageView!
    @IBOutlet var StarTierImages:[UIImageView] = []
    @IBOutlet weak var EquipmentToggleButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItem()
        EquipmentToggleButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        EquipmentToggleButton.setImage(uncheckedImage, for: .normal)
        EquipmentToggleButton.setImage(checkedImage, for: .selected)
        EquipmentToggleButton.isSelected = false
        LevelSlider.value = 1
        LevelSliderLabel.text = "Lv.1"
        studentStatus = jsonArrays.filter { $0["Id"] as? Int == unitId }
        let levelUpValueHp = studentStatus.first?["MaxHP100"] as! Int/99
        print(levelUpValueHp)
        EquipmentArray = studentStatus.first?["Equipment"] as! [String]
        for i in 1...StarTierImages.count {
            StarTierImages[i-1].image = UIImage(systemName: "star.fill")
            StarTierImages[i-1].tintColor = UIColor.gray
        }
        StarTierImages[0].image = UIImage(systemName: "star.fill")
        StarTierImages[0].tintColor = UIColor(red: 255/255, green: 147/255, blue: 0/255, alpha: 1.0)
        
        let StreetAdaptationImage = UIImage(named: "Ingame_Emo_Adaptresult\(GetAdaptation(AdaptationName: "Street"))")
        StreetBattleAdaptationImage.image = StreetAdaptationImage
        
        let OutdoorAdaptationImage = UIImage(named: "Ingame_Emo_Adaptresult\(GetAdaptation(AdaptationName: "Outdoor"))")
        OutdoorBattleAdaptationImage.image = OutdoorAdaptationImage
        
        let IndoorAdaptationImage = UIImage(named: "Ingame_Emo_Adaptresult\((GetAdaptation(AdaptationName: "Indoor")))")
        IndoorBattleAdaptationImage.image = IndoorAdaptationImage
        
        let fileManager = FileManager.default
        let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
        let imageName = studentStatus.first?["WeaponImg"] as! String
        WeaponType.text = studentStatus.first?["WeaponType"] as! String
        
        if studentStatus.first?["Cover"] as! Bool == false {
            CoverImage.isHidden = true
        }
        
        setupEquipment()
        let imagePath = libraryDirectory.appendingPathComponent("assets/images/weapon/\(imageName).webp")
        
        if let image = UIImage(contentsOfFile: imagePath.path) {
            self.WeaponImage.image = image
            self.WeaponImage.contentMode = .scaleAspectFit
            let height = self.WeaponImage.frame.size.width * (image.size.height / image.size.width)
            self.WeaponImage.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if nowWeaponLevel >= 0 && stargrade <= 5{
            nowWeaponLevel = 0
            WeaponLevelLabel.text = ""
            WeaponImage.image = WeaponImage.image?.withRenderingMode(.alwaysTemplate)
            WeaponImage.tintColor = .gray
        }else{
            WeaponImage.image = WeaponImage.image?.withRenderingMode(.alwaysOriginal)
            WeaponImage.tintColor = .clear
            WeaponLevelLabel.text = "Lv.\(nowWeaponLevel)"
        }
        
        LabelSetUp(level: 1)
    }
    func sendDataBack(data: String) {
        print("Received data: \(data)")
    }
    @IBAction func buttonDidTap(_ sender: UIButton) {
        // ここは`button`と`sender`は同じオブジェクトなので、`sender.isSelected = ...`とか`= !button.isSelected`でも大丈夫
        EquipmentToggleButton.isSelected = !sender.isSelected
        LabelSetUp(level: nowLevel)
    }
    func setupEquipment() {
        let fileManager = FileManager.default
        let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
        print("assets/images/equipment/full/equipment_icon_\((EquipmentArray[0] as! String).lowercased())_tier\(String(EquipmentTier[1]!)).webp")
        let Equipment1ImagePath = libraryDirectory.appendingPathComponent("assets/images/equipment/full/equipment_icon_\((EquipmentArray[0] as! String).lowercased())_tier\(String(EquipmentTier[1]!)).webp")
        Equipment1.image = UIImage(contentsOfFile: Equipment1ImagePath.path)
        let Equipment2ImagePath = libraryDirectory.appendingPathComponent("assets/images/equipment/full/equipment_icon_\((EquipmentArray[1] as! String).lowercased())_tier\(String(EquipmentTier[2]!)).webp")
        Equipment2.image = UIImage(contentsOfFile: Equipment2ImagePath.path)
        let Equipment3ImagePath = libraryDirectory.appendingPathComponent("assets/images/equipment/full/equipment_icon_\((EquipmentArray[2] as! String).lowercased())_tier\(String(EquipmentTier[3]!)).webp")
        Equipment3.image = UIImage(contentsOfFile: Equipment3ImagePath.path)
    }
    @IBAction func onTapShowPopup(_ sender: UIButton) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        let popupView: CharacterStatusMore = storyBoard.instantiateViewController(withIdentifier: "characterStatusMore") as! CharacterStatusMore
        popupView.modalPresentationStyle = .overFullScreen
        popupView.modalTransitionStyle = .crossDissolve
        
        popupView.WeaponImageName = studentStatus.first?["WeaponImg"] as! String
        let EquipmentArray = studentStatus.first?["Equipment"] as! [String]
        popupView.EquipmentName = EquipmentArray
        var sendEquipmentTier:[Int] = []
        sendEquipmentTier.append(Int(EquipmentTier[1]!)!)
        sendEquipmentTier.append(Int(EquipmentTier[2]!)!)
        sendEquipmentTier.append(Int(EquipmentTier[3]!)!)
        popupView.EquipmentTier = sendEquipmentTier
        popupView.studentStatus = studentStatus
        popupView.nowWeaponLevel = nowWeaponLevel
        popupView.nowLevel = nowLevel
        popupView.EquipmentToggleButtonStatus = EquipmentToggleButton.isSelected
        popupView.stargrade = stargrade
        popupView.delegate = self
        self.present(popupView, animated: false, completion: nil)
    }
    //LevelSliderの値の変更を検知する
    @IBAction func LevelSliderChanged(_ sender: UISlider) {
        nowLevel = Int(sender.value)
        LevelSliderLabel.text = "Lv." + String(Int(sender.value))
        LabelSetUp(level: Int(sender.value))
    }
    
    @IBAction func TapStarTier(_ sender: UITapGestureRecognizer) {
        let cell = sender.view as! UIImageView
        updateStar(selStarGrade: Int(cell.tag))
        LabelSetUp(level: nowLevel)
    }
    func updateStar(selStarGrade:Int){
        stargrade = selStarGrade
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
            WeaponImage.image = WeaponImage.image?.withRenderingMode(.alwaysTemplate)
            WeaponImage.tintColor = .gray
        }else{
            WeaponImage.image = WeaponImage.image?.withRenderingMode(.alwaysOriginal)
            WeaponImage.tintColor = .clear
            if !fromStatusMore {
                switch stargrade {
                case ...5:
                    nowWeaponLevel = 0
                    WeaponLevelLabel.text = ""
                case 6:
                    nowWeaponLevel = 30
                    WeaponLevelLabel.text = "Lv."+String(nowWeaponLevel)
                case 7:
                    nowWeaponLevel = 40
                    WeaponLevelLabel.text = "Lv."+String(nowWeaponLevel)
                case 8:
                    nowWeaponLevel = 50
                    WeaponLevelLabel.text = "Lv."+String(nowWeaponLevel)
                default:
                    ()
                }
            }else{
                WeaponLevelLabel.text = "Lv."+String(nowWeaponLevel)
            }
        }
        let StreetAdaptationImage = UIImage(named: "Ingame_Emo_Adaptresult\(GetAdaptation(AdaptationName: "Street"))")
        StreetBattleAdaptationImage.image = StreetAdaptationImage
        
        let OutdoorAdaptationImage = UIImage(named: "Ingame_Emo_Adaptresult\(GetAdaptation(AdaptationName: "Outdoor"))")
        OutdoorBattleAdaptationImage.image = OutdoorAdaptationImage
        
        let IndoorAdaptationImage = UIImage(named: "Ingame_Emo_Adaptresult\((GetAdaptation(AdaptationName: "Indoor")))")
        IndoorBattleAdaptationImage.image = IndoorAdaptationImage
    }
    func LabelSetUp(level: Int) {
        addBonus.removeAll()
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
                    let matchingStudents = ItemJson.filter { $0["Icon"] as? String == "equipment_icon_\(EquipmentArray[i-1].lowercased())_tier\(String(EquipmentTier[i]!))" }
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
        GetStatusValue(StatusName: "MaxHP", Label: MaxHpLabel, level: level)
        GetStatusValue(StatusName: "DefensePower", Label: DEFLabel, level: level)
        GetStatusValue(StatusName: "HealPower", Label: HealingLabel, level: level)
        GetStatusValue(StatusName: "AttackPower", Label: ATKLabel, level: level)
        GetStatusValue(StatusName: "AccuracyPoint", Label: AccuracyLabel, level: level)
        GetStatusValue(StatusName: "CriticalPoint", Label: CritLabel, level: level)
        GetStatusValue(StatusName: "CriticalDamageRate", Label: CritDMGLabel, level: level)
        GetStatusValue(StatusName: "StabilityPoint", Label: StabilityLabel, level: level)
        GetStatusValue(StatusName: "DodgePoint", Label: EvasionLabel, level: level)
        GetStatusValue(StatusName: "Range", Label: AttackRangeLabel, level: level)
        //OppressionPower
        CCPowerLabel.text = "100"
        //OppressionResist
        CCRESLabel.text = "100"
        fromStatusMore = false
    }
    
    func GetAdaptation(AdaptationName: String) -> Int {
        
        var DefaultAdaptation = studentStatus.first?["\(AdaptationName)BattleAdaptation"] as! Int
        if stargrade == 8 {
            let weaponStatus = studentStatus.first?["Weapon"] as? [String: Any]
            let weaponAdaptationType = weaponStatus?["AdaptationType"] as! String
            if AdaptationName == "\(weaponAdaptationType)" {
                DefaultAdaptation += weaponStatus?["AdaptationValue"] as! Int
            }
        }
        return DefaultAdaptation
    }
    
    func GetStatusValue(StatusName: String, Label: UILabel, level: Int) {
        let transcendence: [[Double]] = [[0, 1000, 1200, 1400, 1700], [0, 500, 700, 900, 1400], [0, 750, 1000, 1200, 1500]]
        var transcendenceAttack: Double = 1
        var transcendenceHP: Double = 1
        var transcendenceHeal: Double = 1
        var addValue:Int=0
        var addCoefficient:Double=1.0
        
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
            
            var matchedKeys: [String] = []
            
            for (key, _) in addBonus {
                if key.contains(StatusName) {
                    matchedKeys.append(key)
                }
            }
            
            if !matchedKeys.isEmpty {
                for i in 1...matchedKeys.count{
                    if matchedKeys[i-1].contains("Base"){
                        addValue = addBonus[matchedKeys[i-1]]!
                    }
                    if matchedKeys[i-1].contains("Coefficient"){
                        addCoefficient = Double(addBonus[matchedKeys[i-1]]!)/10000+1
                        
                    }
                }
            }
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.groupingSeparator = ","
            formatter.groupingSize = 3
            formatter.usesGroupingSeparator = true
            
            Label.text = formatter.string(from: NSNumber(value:Int(round(Double(scaledValue+addValue) * addCoefficient)*10000)/10000))
        } else if StatusName == "CriticalDamageRate",
                  let StatusValue = studentStatus.first?["\(StatusName)"] as? Int {
            Label.text = "\(StatusValue / 100)%"
        } else if let StatusValue = studentStatus.first?["\(StatusName)"] as? Int {
            Label.text = "\(StatusValue)"
        } else {
            Label.text = "Error"
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
    
}

extension CharacterStatus : CharacterStatusDelegate{
    
    func dataBack(EquipmentTier:Dictionary<Int, String>, WeaponLevel: Int,nowLevel:Int,EquipmentToggleButtonStatus:Bool,StarTier:Int) {
        self.EquipmentTier = EquipmentTier
        self.nowWeaponLevel = WeaponLevel
        self.nowLevel = nowLevel
        self.nowWeaponLevel = WeaponLevel
        self.LevelSlider.value = Float(nowLevel)
        self.LevelSliderLabel.text = "Lv.\(nowLevel)"
        self.stargrade = StarTier
        self.fromStatusMore = true
        updateStar(selStarGrade: stargrade)
        if EquipmentToggleButtonStatus == true{
            self.EquipmentToggleButton.isSelected = true
        }else{
            self.EquipmentToggleButton.isSelected = false
        }
        if self.stargrade >= 6{
            self.WeaponLevelLabel.text = "Lv.\(WeaponLevel)"
            self.WeaponImage.image = self.WeaponImage.image?.withRenderingMode(.alwaysOriginal)
            self.WeaponImage.tintColor = .clear
        }else{
            self.WeaponLevelLabel.text = ""
            self.WeaponImage.image = self.WeaponImage.image?.withRenderingMode(.alwaysTemplate)
            self.WeaponImage.tintColor = .gray
        }
        setupEquipment()
        LabelSetUp(level: Int(LevelSlider.value))
    }
}
