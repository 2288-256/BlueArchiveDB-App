//
//  CharacterInfo.swift
//  BlueArchive Database
//
//  Created by clark on 2023/11/28.
//

import Foundation
import UIKit

class CharacterInfo: UIViewController {
    
    var unitId: Int = 0
    var jsonArrays: [[String: Any]] = []
    var LightArmorColor: UIColor = UIColor(red: 167/255, green: 12/255, blue: 25/255, alpha: 1.0)
    var HeavyArmorColor: UIColor = UIColor(red: 178/255, green: 109/255, blue: 31/255, alpha: 1.0)
    var UnarmedColor: UIColor = UIColor(red: 33/255, green: 111/255, blue: 156/255, alpha: 1.0)
    var ElasticArmorColor: UIColor = UIColor(red: 148/255, green: 49/255, blue: 165/255, alpha: 1.0)
    var NormalColor: UIColor = UIColor(red: 72/255, green: 85/255, blue: 130/255, alpha: 1.0)
    
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

        loadAllStudents()

        // Do any additional setup after loading the view.
        if let imageUrl = URL(string: "https://schale.gg/images/student/portrait/\(unitId).webp") {
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageUrl),
                   let image = UIImage(data: imageData) {
                    let resizedImage = self.resizeImage(image: image, targetHeight: 703)
                    DispatchQueue.main.async {
                        self.CharacterImage.image = resizedImage
                        self.CharacterImage.contentMode = .center
                    }
                }
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


        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch (segue.identifier, segue.destination) {
        case ("toCharacterProfile"?, let destination as CharacterProfilePage):
            destination.unitId = unitId
        case ("toMorePage"?, let destination as CharacterMorePage):
            destination.unitId = unitId
        default:
            ()
        }
    }
    @IBAction func changeInfoView(_ sender: UISegmentedControl) {
        ContainerView.bringSubviewToFront(InfoView)
    }
    @IBAction func changeMoreView(_ sender: UISegmentedControl){
        ContainerView.bringSubviewToFront(MoreView)
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
    func resizeImage(image: UIImage, targetHeight: CGFloat) -> UIImage {
        let aspectRatio = image.size.width / image.size.height
        let targetWidth = targetHeight * aspectRatio
        let size = CGSize(width: targetWidth, height: targetHeight)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return image
    }
    func loadAllStudents() {
        if let path = Bundle.main.path(forResource: "students", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                jsonArrays = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []
            } catch {
                print("Error reading JSON file: \(error)")
            }
        }
    }
    func translateString(_ input: String) -> String? {
        // Load the contents of localization.json
        guard let path = Bundle.main.path(forResource: "localization", ofType: "json"),
              let fileData = FileManager.default.contents(atPath: path),
              let json = try? JSONSerialization.jsonObject(with: fileData, options: []),
              let localization = json as? [String: Any] else {
            return nil
        }
        
        // Search for the translation based on the input string
        for (key, value) in localization {
            if let translations = value as? [String: String],
               let translatedString = translations[input] {
                return translatedString
            }
        }
        
        return "Error" // Translation not found
    }
}
