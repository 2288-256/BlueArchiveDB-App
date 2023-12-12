//
//  ViewController.swift
//  BlueArchive Database
//
//  Created by clark on 2023/11/22.
//
import Foundation
import UIKit

class ViewController: UIViewController,UICollectionViewDataSource,
                      UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var versionLabel: UILabel!
    var jsonArrays: [[String: Any]] = []
    var sevenDaysBirthDay: [[String: Any]] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
            let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String {
            versionLabel.text = "Version: \(version) Build: \(build)"
        }
        loadAllStudents()

        var days7: [String] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for i in 0..<7 {
            if let nextDate = calendar.date(byAdding: .day, value: i, to: today) {
                days7.append(dateFormatter.string(from: nextDate))
            }
        }
        
        sevenDaysBirthDay = jsonArrays.filter { person in
            guard let birthDay = person["BirthDay"] as? String,
                  let name = person["Name"] as? String,
                  !name.contains("（"),
                  !name.contains("）") else { 
                return false 
            }
            return days7.contains(birthDay)
        }
        
        // Assuming 'sevenDaysBirthDay' is an array of dictionaries like 'jsonArrays'.
        
        // First, let's create a function to convert a "BirthDay" string to a Date object.
        func birthDayToDate(_ birthDay: String) -> Date? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M/d"
            dateFormatter.timeZone = TimeZone.current
            
            let currentYear = Calendar.current.component(.year, from: Date())
            let birthDayWithCurrentYear = "\(birthDay)/\(currentYear)"
            dateFormatter.dateFormat = "M/d/yyyy"
            
            return dateFormatter.date(from: birthDayWithCurrentYear)
        }
        
        // Now, sort 'sevenDaysBirthDay' based on the "BirthDay" field.
        sevenDaysBirthDay.sort { firstPerson, secondPerson in
            guard let firstBirthDay = firstPerson["BirthDay"] as? String,
                  let secondBirthDay = secondPerson["BirthDay"] as? String,
                  let firstDate = birthDayToDate(firstBirthDay),
                  let secondDate = birthDayToDate(secondBirthDay) else {
                return false
            }
            
            let calendar = Calendar.current
            
            // Extract month and day components from the dates.
            let firstMonth = calendar.component(.month, from: firstDate)
            let firstDay = calendar.component(.day, from: firstDate)
            let secondMonth = calendar.component(.month, from: secondDate)
            let secondDay = calendar.component(.day, from: secondDate)
            
            // Handle the scenario where one date is in January and the other is in December.
            if (firstMonth == 1 && secondMonth == 12) {
                return false // January comes after December, so the first date should be after the second.
            } else if (firstMonth == 12 && secondMonth == 1) {
                return true // December comes before January, so the first date should be before the second.
            }
            
            // If both dates are in the same month or neither is January or December, sort by date.
            if firstMonth == secondMonth {
                return firstDay < secondDay // Same month: sort by day.
            } else {
                return firstMonth < secondMonth // Different months: sort by month.
            }
        }
        print(sevenDaysBirthDay.count)
    }
    @IBAction func destinationWindow(_ sender: UISegmentedControl) {
        //"「未実装です」というアラートを表示"
        let alert = UIAlertController(title: "エラー", message: "まだ実装されていない機能です", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let testCell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "birthday-cell", for: indexPath)
        
        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        let label = testCell.contentView.viewWithTag(2) as! UILabel
        if sevenDaysBirthDay.count > indexPath.row {
            let characterInfo = sevenDaysBirthDay[indexPath.row]
            if let unitId = characterInfo["Id"] as? Int,
               let name = characterInfo["BirthDay"] as? String {
                testCell.tag = unitId
                let imageUrlString = "https://schale.gg/images/student/collection/\(unitId).webp"
                // キャッシュオブジェクトの作成
                let imageCache = NSCache<NSString, UIImage>()
                
                DispatchQueue.global(qos: .userInitiated).async {
                    if let imageUrl = URL(string: imageUrlString) {
                        if let cachedImage = imageCache.object(forKey: imageUrlString as NSString) {
                            // キャッシュから画像を取得
                            DispatchQueue.main.async {
                                imageView.image = cachedImage
                            }
                        } else {
                            // ネットワークから画像を取得
                            if let imageData = try? Data(contentsOf: imageUrl),
                               let image = UIImage(data: imageData) {
                                // 取得した画像をキャッシュ
                                imageCache.setObject(image, forKey: imageUrlString as NSString)
                                DispatchQueue.main.async {
                                    imageView.backgroundColor = UIColor.white
                                    imageView.image = image
                                }
                            }
                        }
                    }
                }
                
                label.text = name
            }
        }
        
        return testCell
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let horizontalSpace: CGFloat = 8
        let cellSize: CGFloat = (self.view.bounds.width - (horizontalSpace * 8)) / 8
        return CGSize(width: cellSize, height: 165)
    }
//    func collectionView(_ collectionView: UICollectionView,
//                       layout collectionViewLayout: UICollectionViewLayout,
//                       insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 0, left: 0, bottom: 11, right: 0)
//    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // section数は１つ
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sevenDaysBirthDay.count
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 選択されたセルを取得
        let selectedCell = collectionView.cellForItem(at: indexPath)
        
        // セルのtagを取得
        let cellTag = selectedCell?.tag
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "CharacterInfo") as? CharacterInfo {
            // 引き渡したい変数を設定する
            viewController.unitId = Int(cellTag!)
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: false, completion: nil)
        } else {
            print("Error: Failed to instantiate CharacterSelect")
        }
        // セル選択の解除
        collectionView.deselectItem(at: indexPath, animated: true)
    }
    func loadAllStudents() {
        if let path = Bundle.main.path(forResource: "students", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                jsonArrays = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []
                print("ロードした生徒数:\(jsonArrays.count)人")
            } catch {
                print("Error reading JSON file: \(error)")
            }
        }
    }
    
}

