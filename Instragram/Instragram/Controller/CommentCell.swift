//
//  CommentCell.swift
//  Instragram
//
//  Created by Phu on 6/18/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    // MARK: *** UI Element
    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var buttonUsername: UIButton!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelComment: KILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // round avatar
        imageViewAvatar.layer.cornerRadius = imageViewAvatar.frame.size.width / 2
        imageViewAvatar.clipsToBounds = true
    }
}
