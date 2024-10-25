//
//  CharacterWeaponGearPage.swift
//  BlueArchiveDB
//
//  Created by 2288-256 on 2024/04/26
//  Copyright (c) 2024 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class CharacterWeaponGearPage: UIViewController
{
	var unitId: Int = 0
    var studentData: [String: Any] = [:]
    var GearData: [String: Any] = [:]
	@IBOutlet var GearSwitchButton: UIButton!

	@IBOutlet var ContainerView: UIView!
	@IBOutlet var WeaponView: UIView!
	@IBOutlet var GearView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        WeaponView.isHidden = false
        GearView.isHidden = true
        ContainerView.bringSubviewToFront(WeaponView)
        GearSwitchButton.isEnabled = !GearData.isEmpty
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender _: Any?) {
        switch (segue.identifier, segue.destination) {
        case let ("toWeaponPage"?, destination as CharacterWeapon):
            destination.unitId = unitId
            destination.studentData = studentData
        case let ("toGearPage"?, destination as CharacterGear):
            destination.unitId = unitId
            GearData = studentData["Gear"] as? [String: Any] ?? [:]
            destination.GearData = GearData
        default:
            ()
        }
    }

    @IBAction func changeWeaponView(_: UISegmentedControl)
    {
        WeaponView.isHidden = false
        GearView.isHidden = true
        ContainerView.bringSubviewToFront(WeaponView)
    }
    @IBAction func changeGearView(_: UISegmentedControl)
    {
        WeaponView.isHidden = true
        GearView.isHidden = false
        ContainerView.bringSubviewToFront(GearView)
    }
}
