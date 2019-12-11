//
//  CollectionViewCell.swift
//  superdiff
//
//  Created by Frank Foster on 12/5/19.
//  Copyright © 2019 Frank Foster. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var userText: UILabel!
    @IBOutlet weak var checkmarkLabel: UILabel!
    
    @IBOutlet weak var subtitleText: UILabel!
    
    var isInEditingMode: Bool = false {
        didSet {
            checkmarkLabel.isHidden = !isInEditingMode
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isInEditingMode {
                checkmarkLabel.text = isSelected ? "y" : ""
            }
        }
    }
    
    
    
}
