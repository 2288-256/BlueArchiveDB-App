//
//  VoiceCell.swift
//  BlueArchive Database
//
//  Created by 2288-256 on 2023/12/05.
//  Copyright (c) 2023 2288-256 All Rights Reserved
//

import Foundation
import UIKit

class VoiceCell: UICollectionViewCell {
    let groupLabel = UILabel()
    let transcriptionTextView = UITextView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(groupLabel)
        contentView.addSubview(transcriptionTextView)
        
        // Set frames or use autoresizing masks
        groupLabel.frame = CGRect(x: 8, y: 9, width: 278, height: 21)
        transcriptionTextView.frame = CGRect(x: 8, y: 38, width: 522, height: 46)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
