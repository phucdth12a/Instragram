//
//  NewsCell.swift
//  Instragram
//
//  Created by Phu on 7/3/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit

class NewsCell: UITableViewCell {
    
    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var buttonUsername: UIButton!
    @IBOutlet weak var labelInfo: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    
        imageViewAvatar.layer.cornerRadius = imageViewAvatar.frame.size.width / 2
        imageViewAvatar.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
