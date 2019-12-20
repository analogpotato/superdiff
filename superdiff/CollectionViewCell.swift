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
    @IBOutlet weak var subtitleText: UILabel!
    @IBOutlet weak var checkmarkButton: UIButton!
    
    var isInEditingMode: Bool = false {
        didSet {
            checkmarkButton.isHidden = !isInEditingMode
        }
    }
    
    override var isSelected: Bool {
        didSet {
            guard isInEditingMode else { return }
            
            if isSelected {
                checkmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
                checkmarkButton.tintColor = .systemBlue
            } else {
                checkmarkButton.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
                checkmarkButton.tintColor = .lightGray
            }
        }
    }
    
    
    
}
