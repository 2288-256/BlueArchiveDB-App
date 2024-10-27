//
//  CharacterWeapon.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/05/07
//  Copyright (c) 2024 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class CharacterWeapon: UIViewController
{
    var unitId: Int = 0
    var studentStatus: [String: Any]?
    var studentData: [String: Any] = [:]
    var weaponData: [String: Any]?
    var contentCount: Int = 0
    @IBOutlet var nowWeaponLevel: UILabel!
    @IBOutlet var weaponUIView: UIView!
    @IBOutlet var weaponName: UILabel!
    @IBOutlet var weaponImage: UIImageView!
    @IBOutlet var weaponDesc: UITextView!
    @IBOutlet var weaponStatusUI: UIView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        weaponData = studentData["Weapon"] as? [String: Any] ?? [:]
        Logger.standard.debug("\(self.weaponData ?? [:])")
        weaponName.text = weaponData?["Name"] as? String
        let imageName = studentData["WeaponImg"] as! String
        let fileManager = FileManager.default
        let libraryDirectory = fileManager.urls(for: .libraryDirectory, in: .userDomainMask).first!
        let imagePath = libraryDirectory.appendingPathComponent("assets/images/weapon/\(imageName).webp")

        if let image = UIImage(contentsOfFile: imagePath.path)
        {
            weaponImage.image = image
            weaponImage.contentMode = .scaleAspectFit
            let height = weaponImage.frame.size.width * (image.size.height / image.size.width)
            weaponImage.heightAnchor.constraint(equalToConstant: height).isActive = true
        }

        weaponDesc.text = weaponData?["Desc"] as! String
        let attackPower1 = weaponData?["AttackPower1"] as! Int
        let maxHP1 = weaponData?["MaxHP1"] as! Int
        let healPower1 = weaponData?["HealPower1"] as! Int
        if (attackPower1 > 0 ? 1 : 0) +
            (maxHP1 > 0 ? 1 : 0) +
            (healPower1 > 0 ? 1 : 0) >= 3
        {
            // ステータスの数値の3つ以上が1以上の場合
            contentCount = 3
            weaponUIView.frame.size.height = 358
            weaponUIView.heightAnchor.constraint(equalToConstant: 358).isActive = true
            weaponStatusUI.frame.size.height = 95
            weaponStatusUI.heightAnchor.constraint(equalToConstant: 95).isActive = true
            // 高さ35幅265のUIView

            let Label1 = CreateElement.shared.createWeaponStatusView(addSubview: weaponStatusUI, tag: 1, statusID: "AttackPower", statusName: "攻撃力", statusValue: attackPower1)
            let Label2 = CreateElement.shared.createWeaponStatusView(addSubview: weaponStatusUI, tag: 2, statusID: "MaxHP", statusName: "最大HP", statusValue: maxHP1, posx: 281, leftEqualTo: 1)
            let Label3 = CreateElement.shared.createWeaponStatusView(addSubview: weaponStatusUI, tag: 3, statusID: "HealPower", statusName: "回復力", statusValue: healPower1, posy: 50, topEqualTo: 1)
        } else
        {
            contentCount = 2
            weaponUIView.frame.size.height = 313
            weaponUIView.heightAnchor.constraint(equalToConstant: 313).isActive = true
            weaponStatusUI.frame.size.height = 50
            // 高さ35幅265のUIView
            let Label1 = CreateElement.shared.createWeaponStatusView(addSubview: weaponStatusUI, tag: 1, statusID: "AttackPower", statusName: "攻撃力", statusValue: attackPower1)
            let Label2 = CreateElement.shared.createWeaponStatusView(addSubview: weaponStatusUI, tag: 2, statusID: "MaxHP", statusName: "最大HP", statusValue: maxHP1, posx: 281, leftEqualTo: 1)
        }
    }

    @IBAction func LevelSliderChanged(_ sender: UISlider)
    {
        sender.value = round(sender.value)
        nowWeaponLevel.text = "Lv.\(Int(sender.value))"
        LevelChange(level: Int(sender.value))
    }

    func LevelChange(level: Int)
    {
        guard let weaponData = weaponData else { return }

        let levelScale = round(Double(level - 1) / 99 * 10000) / 10000

        func calculateStatus(forKey key: String) -> Int
        {
            let start1 = Double(weaponData[key + "1"] as! Int)
            let start100 = Double(weaponData[key + "100"] as! Int)
            return Int(ceil(round((start1 + (start100 - start1) * levelScale) * 10000) / 10000))
        }

        if contentCount >= 2
        {
            let AttackPower = calculateStatus(forKey: "AttackPower")
            // viewWithTagのフォースアンラップを避ける
            if let label = view.viewWithTag(1) as? UILabel
            {
                label.text = "+" + String(AttackPower)
            }

            let MaxHP = calculateStatus(forKey: "MaxHP")
            // viewWithTagのフォースアンラップを避ける
            if let label = view.viewWithTag(2) as? UILabel
            {
                label.text = "+" + String(MaxHP)
            }
        }

        if contentCount >= 3
        {
            let HealPower = calculateStatus(forKey: "HealPower")
            // viewWithTagのフォースアンラップを避ける
            if let label = view.viewWithTag(3) as? UILabel
            {
                label.text = "+" + String(HealPower)
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender _: Any?)
    {
        switch (segue.identifier, segue.destination)
        {
        case let ("toWeaponMore"?, destination as CharacterWeaponMore):
            destination.unitId = unitId
        default:
            ()
        }
    }
}
