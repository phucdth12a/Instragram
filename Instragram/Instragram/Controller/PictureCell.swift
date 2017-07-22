//
//  PictureCell.swift
//  Instragram
//
//  Created by Phu on 6/14/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit

class PictureCell: UICollectionViewCell {
    
    // MARK: *** UI Element
    @IBOutlet weak var imageViewPicture: UIImageView!
    
    // MARK: *** ViewLoad
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // aligment
        let width = UIScreen.main.bounds.width
        
        imageViewPicture.frame = CGRect(x: 0, y: 0, width: width / 3, height: width / 3)
    }
    
}
