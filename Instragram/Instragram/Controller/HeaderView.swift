//
//  HeaderView.swift
//  Instragram
//
//  Created by Phu on 6/14/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit
import Parse

class HeaderView: UICollectionReusableView {
    
    // MARK: *** UI Element
    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var labelFullname: UILabel!
    @IBOutlet weak var textViewWeb: UITextView!
    @IBOutlet weak var labelBio: UILabel!
    @IBOutlet weak var labelPost: UILabel!
    @IBOutlet weak var labelFollowers: UILabel!
    @IBOutlet weak var labelFollowings: UILabel!
    @IBOutlet weak var labelPostTitle: UILabel!
    @IBOutlet weak var labelFollowersTitle: UILabel!
    @IBOutlet weak var labelFollowingsTitle: UILabel!
    
    @IBOutlet weak var buttonEditProfile: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // round vavtar
        imageViewAvatar.layer.cornerRadius = imageViewAvatar.frame.size.width / 2
        imageViewAvatar.clipsToBounds = true
        
        buttonEditProfile.layer.cornerRadius = buttonEditProfile.frame.size.width / 50
    }
    
    @IBAction func buttonFollow_Clicked(_ sender: Any) {
        
        let title = buttonEditProfile.title(for: .normal)
        
        // to follow
        if title == "FOLLOW" {
            
            let object = PFObject(className: "follow")
            object["follower"] = PFUser.current()?.username
            object["following"] = guestname.last!
            object.saveInBackground(block: { (success: Bool, error: Error?) in
                
                if success {
                    
                    self.buttonEditProfile.setTitle("FOLLOWING", for: .normal)
                    self.buttonEditProfile.backgroundColor = UIColor.green
                    
                    // send notification follow
                    let newsObj = PFObject(className: "news")
                    newsObj["by"] = PFUser.current()?.username
                    newsObj["to"] = guestname.last
                    newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                    newsObj["owner"] = ""
                    newsObj["uuid"] = ""
                    newsObj["type"] = "follow"
                    newsObj["checked"] = "no"
                    newsObj.saveEventually()
                    
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            // unfollow
        } else {
            
            let query = PFQuery(className: "follow")
            query.whereKey("follower", equalTo: PFUser.current()!.username!)
            query.whereKey("following", equalTo: guestname.last!)
            query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                
                if error == nil {
                    
                    for object in objects! {
                        
                        object.deleteInBackground(block: { (success: Bool, error: Error?) in
                            
                            if success {
                                
                                self.buttonEditProfile.setTitle("FOLLOW", for: .normal)
                                self.buttonEditProfile.backgroundColor = UIColor.lightGray
                                
                                //Delete notification follow
                                let newQuery = PFQuery(className: "news")
                                newQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                newQuery.whereKey("to", equalTo: guestname.last!)
                                newQuery.whereKey("type", equalTo: "follow")
                                newQuery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                                    
                                    if error == nil {
                                        for object in objects! {
                                            object.deleteEventually()
                                        }
                                    } else {
                                        print(error!.localizedDescription)
                                    }
                                })

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
    
        
}
