//
//  CharacterInfo.swift
//  BlueArchive Database
//
//  Created by 2288-256 on 2023/11/28.
//  Copyright (c) 2023 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class CharacterInfo: UIViewController {
    
    var unitId: Int = 0
    var BackPage: String = ""
    var jsonArrays: [[String: Any]] = []
    var LightArmorColor: UIColor = UIColor(red: 167/255, green: 12/255, blue: 25/255, alpha: 1.0)
    var HeavyArmorColor: UIColor = UIColor(red: 178/255, green: 109/255, blue: 31/255, alpha: 1.0)
    var UnarmedColor: UIColor = UIColor(red: 33/255, green: 111/255, blue: 156/255, alpha: 1.0)
    var ElasticArmorColor: UIColor = UIColor(red: 148/255, green: 49/255, blue: 165/255, alpha: 1.0)
    var NormalColor: UIColor = UIColor(red: 72/255, green: 85/255, blue: 130/255, alpha: 1.0)
    var viewWidth: CGFloat = 0
    
    @IBOutlet weak var BackgroundImage : UIImageView!
    @IBOutlet weak var CharacterImage: UIImageView!
    @IBOutlet weak var Name: UILabel!
    
    @IBOutlet weak var Position: UILabel!
    @IBOutlet weak var ArmorType:UILabel!
    @IBOutlet weak var BulletType:UILabel!
    @IBOutlet weak var TacticRole:UILabel!
    @IBOutlet weak var TacticRoleImage: UIImageView!
    @IBOutlet weak var BulletTypeBGColor:UILabel!
    @IBOutlet weak var ArmorTypeBGColor: UILabel!
    
    @IBOutlet weak var StreetBattleAdaptationImage: UIImageView!
    @IBOutlet weak var OutdoorBattleAdaptationImage: UIImageView!
    @IBOutlet weak var IndoorBattleAdaptationImage: UIImageView!
    
    
    @IBOutlet weak var ContainerView: UIView!
    @IBOutlet weak var InfoView: UIView!
    @IBOutlet weak var StatusView: UIView!
    @IBOutlet weak var SkillView: UIView!
    @IBOutlet weak var ArmorView: UIView!
    @IBOutlet weak var MoreView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ContainerView.bringSubviewToFront(InfoView)
        MoreView.isHidden = true
        StatusView.isHidden = true
        DispatchQueue.main.async {
            if self.jsonArrays.isEmpty{
                self.loadAllStudents()
            }
        }
        setup(unitId: unitId)
        viewWidth = self.view.frame.width
    }
    //初期化処理
    func setup( unitId: Int) {
        let CharacterImageHeight = CharacterImage.frame.height
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
        if let image = UIImage(contentsOfFile: imagePath.path) {
            DispatchQueue.main.async {
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
        ArmorType.text = translateString((matchingStudents.first?["ArmorType"])! as! String)
        BulletType.text = translateString((matchingStudents.first?["BulletType"])! as! String)
        TacticRole.text = translateString((matchingStudents.first?["TacticRole"])! as! String)
        let image = UIImage(named: "Role_\((matchingStudents.first?["TacticRole"])! as! String)")
        TacticRoleImage.image = image
        
        if let armorType = matchingStudents.first?["ArmorType"] as? String {
            switch armorType {
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
        
        if let bulletType = matchingStudents.first?["BulletType"] as? String {
            switch bulletType {
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
        if let image = UIImage(contentsOfFile: BackgroundImagePath.path) {
            DispatchQueue.main.async {
                self.BackgroundImage.image = image
                self.BackgroundImage.contentMode = .scaleAspectFill
                let width = self.BackgroundImage.frame.size.height * (image.size.width / image.size.height)
                self.BackgroundImage.widthAnchor.constraint(equalToConstant: width).isActive = true
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func updateViewWithNewData(unitId : Int) {
        setup(unitId: unitId)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if jsonArrays.isEmpty{
            loadAllStudents()
        }
        switch (segue.identifier, segue.destination) {
        case ("toCharacterProfile"?, let destination as CharacterProfilePage):
            destination.unitId = unitId
            destination.jsonArrays = jsonArrays
        case ("toMorePage"?, let destination as CharacterMorePage):
            destination.unitId = unitId
        case ("toStatus"?, let destination as CharacterStatus):
            destination.unitId = unitId
            destination.jsonArrays = jsonArrays
        default:
            ()
        }
    }
    @IBAction func changeInfoView(_ sender: UISegmentedControl) {
        InfoView.isHidden = false
        MoreView.isHidden = true
        StatusView.isHidden = true
        ContainerView.bringSubviewToFront(InfoView)
    }
    @IBAction func changeMoreView(_ sender: UISegmentedControl){
        InfoView.isHidden = true
        MoreView.isHidden = false
        StatusView.isHidden = true
        ContainerView.bringSubviewToFront(MoreView)
    }
    @IBAction func changeStatusView(_ sender: UISegmentedControl) {
        InfoView.isHidden = true
        MoreView.isHidden = true
        StatusView.isHidden = false
        ContainerView.bringSubviewToFront(StatusView)
    }
    @IBAction func destinationWindow(_ sender: UISegmentedControl) {
        //"「未実装です」というアラートを表示"
        let alert = UIAlertController(title: "エラー", message: "まだ実装されていない機能です", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    @IBAction func BackButton(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func HomeButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "Home") as! ViewController
        self.present(nextVC, animated: false, completion: nil)
    }
    func loadAllStudents() {
            do {
                let fileManager = FileManager.default
                let documentsURL = try fileManager.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                let studentsFileURL = documentsURL.appendingPathComponent("assets/data/jp/students.json")
                
                let data = try Data(contentsOf: studentsFileURL)
                self.jsonArrays = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
                print("ロードした生徒数:\(self.jsonArrays.count)")
            } catch {
                print("Error reading students JSON file: \(error)")
            }
    }
    func translateString(_ input: String) -> String? {
        // Load the contents of localization.json from the Documents directory
        let fileManager = FileManager.default
        do {
            let documentsURL = try fileManager.url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let localizationFileURL = documentsURL.appendingPathComponent("assets/data/jp/localization.json")
            
            let fileData = try Data(contentsOf: localizationFileURL)
            let json = try JSONSerialization.jsonObject(with: fileData, options: [])
            if let localization = json as? [String: Any] {
                // Search for the translation based on the input string
                for (key, value) in localization {
                    if let translations = value as? [String: String],
                       let translatedString = translations[input] {
                        return translatedString
                    }
                }
            }
        } catch {
            print("Error loading localization JSON from Documents directory: \(error)")
            return nil
        }
        
        return "Error" // Translation not found
    }
}
