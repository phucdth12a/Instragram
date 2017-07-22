//
//  FollowersCell.swift
//  Instragram
//
//  Created by Phu on 6/15/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit
import Parse

class FollowersCell: UITableViewCell {
    
    // MARK: *** UI Element
    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var buttonFollowing: UIButton!
    
    
    // MARK: *** UI Event
    @IBAction func buttonFollowing_Clicked(_ sender: Any) {
        
        let title = buttonFollowing.title(for: .normal)
        
        // to follow 
        if title == "FOLLOW" {
            
            let object = PFObject(className: "follow")
            object["follower"] = PFUser.current()?.username
            object["following"] = labelUsername.text
            object.saveInBackground(block: { (success: Bool, error: Error?) in
                
                if success {
                    
                    self.buttonFollowing.setTitle("FOLLOWING", for: .normal)
                    self.buttonFollowing.backgroundColor = UIColor.green
                } else {
                    print(error!.localizedDescription)
                }
            })
        } else {
            
            let query = PFQuery(className: "follow")
            query.whereKey("follower", equalTo: PFUser.current()!.username!)
            query.whereKey("following", equalTo: labelUsername.text!)
            query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                
                if error == nil {
                    
                    for object in objects! {
                        
                        object.deleteInBackground(block: { (success: Bool, error: Error?) in
                            
                            if success {
                                
                                self.buttonFollowing.setTitle("FOLLOW", for: .normal)
                                self.buttonFollowing.backgroundColor = UIColor.lightGray
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        
    }

    
    // MARK: *** ViewLoad
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // roud avatar
        imageViewAvatar.layer.cornerRadius = imageViewAvatar.frame.size.width / 2
        imageViewAvatar.clipsToBounds = true
        buttonFollowing.layer.cornerRadius = buttonFollowing.frame.size.width / 20
    }

}
