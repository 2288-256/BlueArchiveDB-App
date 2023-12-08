//
//  CharacterSelect.swift
//  BlueArchive Database
//
//  Created by clark on 2023/11/22.
//

import Foundation
import UIKit

class CharacterSelect: UIViewController,UICollectionViewDataSource,
                       UICollectionViewDelegateFlowLayout{
    var viewMode: String = ""
    var jsonArrays: [[String: Any]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        if viewMode == "Main" {
            loadMainStudents()
        } else if viewMode == "Support" {
            loadSupportStudents()
        } else {
            loadAllStudents()
        }
    }
    @IBAction func BackButton(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
    }
    @IBAction func HomeButton(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let nextVC = storyboard.instantiateViewController(withIdentifier: "Home") as! ViewController
        self.present(nextVC, animated: false, completion: nil)
    }
    @IBAction func MainStudentsFilter(_ sender: UIButton) {
        presentCharacterSelect(viewMode: "Main")
    }
    @IBAction func AllStudentsFilter(_ sender: UIButton) {
        presentCharacterSelect(viewMode: "All")
    }
    @IBAction func SupporterStudentsFilter(_ sender: UIButton) {
        presentCharacterSelect(viewMode: "Support")
    }
    @IBOutlet weak var collectionView: UICollectionView!
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let testCell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "character-cell", for: indexPath)
        
        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        let label = testCell.contentView.viewWithTag(2) as! UILabel
        if jsonArrays.count > indexPath.row {
            let characterInfo = jsonArrays[indexPath.row]
            if let unitId = characterInfo["Id"] as? Int,
               let name = characterInfo["Name"] as? String {
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
    func loadMainStudents() {
        if let path = Bundle.main.path(forResource: "students", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []
                jsonArrays = jsonArray.filter { ($0["SquadType"] as? String) == "Main" }
                print("STRIKERの生徒数:\(jsonArrays.count)人")
            } catch {
                print("Error reading JSON file: \(error)")
            }
        }
    }
    func loadSupportStudents() {
        if let path = Bundle.main.path(forResource: "students", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []
                jsonArrays = jsonArray.filter { ($0["SquadType"] as? String) == "Support" }
                print("SUPPORTERの生徒数:\(jsonArrays.count)人")
            } catch {
                print("Error reading JSON file: \(error)")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jsonArrays.count
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
    func presentCharacterSelect(viewMode viewMode: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "CharacterSelect") as? CharacterSelect {
            // 引き渡したい変数を設定する
            viewController.viewMode = viewMode
            viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .fullScreen
            self.present(viewController, animated: true, completion: nil)
        } else {
            print("Error: Failed to instantiate CharacterSelect")
        }
    }
}
