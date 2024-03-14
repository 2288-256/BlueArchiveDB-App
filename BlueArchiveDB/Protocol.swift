//
//  Protocol.swift
//  BlueArchiveDB
//  
//  Created by 2288-256 on 2024/02/15
//  Copyright (c) 2024 2288-256 All Rights Reserved
//
import Foundation
protocol CharacterStatusDelegate: AnyObject {
    func dataBack(EquipmentTier:Dictionary<Int, String>,WeaponLevel:Int,nowLevel:Int,EquipmentToggleButtonStatus:Bool,StarTier:Int)
}
