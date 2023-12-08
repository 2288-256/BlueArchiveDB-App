//
//  CharacterProfilePage.swift
//  BlueArchive Database
//
//  Created by clark on 2023/12/01.
//

import UIKit

class CharacterProfilePage: UIViewController {

    var unitId: Int = 100
    var jsonArrays: [[String: Any]] = []
    
    @IBOutlet weak var CharacterProfileText: UILabel!
    @IBOutlet weak var CharacterSchoolText: UILabel!
    @IBOutlet weak var CharacterSchoolYear: UILabel!
    @IBOutlet weak var CharacterClub: UILabel!
    @IBOutlet weak var CharacterAge: UILabel!
    @IBOutlet weak var CharacterBirthday:UILabel!
    @IBOutlet weak var CharacterCharHeightMetric: UILabel!
    @IBOutlet weak var CharacterHobby: UILabel!
    @IBOutlet weak var CharacterDesigner: UILabel!
    @IBOutlet weak var CharacterIllustrator: UILabel!
    @IBOutlet weak var CharacterCharacterVoice: UILabel!
    @IBOutlet weak var CharacterWeaponType: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loadAllStudents()
        let matchingStudents = jsonArrays.filter { $0["Id"] as? Int == unitId }
        
        CharacterProfileText.text = matchingStudents.first?["ProfileIntroduction"] as? String
        CharacterSchoolText.text = translateString((matchingStudents.first?["School"])! as! String)
        CharacterSchoolYear.text = matchingStudents.first?["SchoolYear"] as? String
        CharacterClub.text = translateString((matchingStudents.first?["Club"])! as! String)
        CharacterAge.text = matchingStudents.first?["CharacterAge"] as? String
        CharacterBirthday.text = matchingStudents.first?["Birthday"] as? String
        CharacterCharHeightMetric.text = matchingStudents.first?["CharHeightMetric"] as? String
        CharacterHobby.text = matchingStudents.first?["Hobby"] as? String
        CharacterDesigner.text = matchingStudents.first?["Designer"] as? String
        CharacterIllustrator.text = matchingStudents.first?["Illustrator"] as? String
        CharacterCharacterVoice.text = matchingStudents.first?["CharacterVoice"] as? String
        CharacterWeaponType.text = matchingStudents.first?["WeaponType"] as? String
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
