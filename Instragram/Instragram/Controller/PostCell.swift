//
//  PostCell.swift
//  Instragram
//
//  Created by Phu on 6/18/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit
import Parse

class PostCell: UITableViewCell {
    
    // MARK: *** UI Element
    @IBOutlet weak var imageviewAvatar: UIImageView!
    @IBOutlet weak var buttonUsername: UIButton!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var imageViewPicture: UIImageView!
    @IBOutlet weak var buttonLike: UIButton!
    @IBOutlet weak var labelLike: UILabel!
    @IBOutlet weak var buttonComment: UIButton!
    @IBOutlet weak var buttonMore: UIButton!
    @IBOutlet weak var labelTitle: KILabel!
    @IBOutlet weak var labelUuid: UILabel!
    
    // MARK: *** UI Event
    @IBAction func buttonLike_Clicked(_ sender: Any) {
        
        // declare title of the button
        let title = (sender as AnyObject).title(for: UIControlState())
        
        // to like
        if title == "unlike" {
            
            let object = PFObject(className: "likes")
            object["by"] = PFUser.current()?.username
            object["to"] = labelUuid.text
            object.saveInBackground(block: { (success: Bool, error: Error?) in
                
                if success {
                    print("liked")
                    self.buttonLike.setTitle("like", for: .normal)
                    self.buttonLike.setImage(UIImage(named: "like.png"), for: .normal)
                    
                    // send notification if we liked to refesh tableview
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                    
                    // send notification as like
                    let newsObj = PFObject(className: "news")
                    newsObj["by"] = PFUser.current()?.username
                    newsObj["to"] = self.buttonUsername.titleLabel!.text
                    newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                    newsObj["owner"] = self.buttonUsername.titleLabel!.text
                    newsObj["uuid"] = self.labelUuid.text
                    newsObj["type"] = "like"
                    newsObj["checked"] = "no"
                    newsObj.saveEventually()
                } else {
                    print(error!.localizedDescription)
                }
            })
        // to dislike
        } else {
            
            // request existing likes of current user to shown post
            let query = PFQuery(className: "likes")
            query.whereKey("by", equalTo: PFUser.current()!.username!)
            query.whereKey("to", equalTo: labelUuid.text!)
            query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                
                if error == nil {
                    
                    // find objects - likes
                    for object in objects! {
                        
                        object.deleteInBackground(block: { (success: Bool, error: Error?) in
                            
                            if success {
                                self.buttonLike.setTitle("unlike", for: .normal)
                                self.buttonLike.setImage(UIImage(named: "unlike.png"), for: .normal)
                                
                                // send notification if we liked to refesh tablview
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                                
                                // Delete notification like
                                if self.buttonUsername.titleLabel?.text != PFUser.current()?.username {
                                    
                                    let newQuery = PFQuery(className: "news")
                                    newQuery.whereKey("by", equalTo: PFUser.current()!.username!)
                                    newQuery.whereKey("to", equalTo: self.buttonUsername.titleLabel!.text!)
                                    newQuery.whereKey("uuid", equalTo: self.labelUuid.text!)
                                    newQuery.whereKey("type", equalTo: "like")
                                    newQuery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                                        
                                        if error == nil {
                                            for object in objects! {
                                                object.deleteEventually()
                                            }
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
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
    }
    
    // MARK: *** ViewDidLoad
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // clear like button title color
        buttonLike.setTitleColor(UIColor.clear, for: .normal)
        
        // double tap to like
        let likeTap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        likeTap.numberOfTapsRequired = 2
        imageViewPicture.isUserInteractionEnabled = true
        imageViewPicture.addGestureRecognizer(likeTap)
        
        // round ava
        imageviewAvatar.layer.cornerRadius = imageviewAvatar.frame.size.width / 2
        imageviewAvatar.clipsToBounds = true
    }

    // double tapped to like
    func likeTapped() {
        
        // create large like gray heart
        let likePic = UIImageView(image: UIImage(named: "unlike.png"))
        likePic.frame.size.width = imageViewPicture.frame.size.width / 1.5
        likePic.frame.size.height = imageViewPicture.frame.size.width / 1.5
        likePic.center = imageViewPicture.center
        likePic.alpha = 0.8
        self.addSubview(likePic)
        
        // hide likePic with animation and transform to be smller
        UIView.animate(withDuration: 0.4) { 
            
            likePic.alpha = 0
            likePic.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }
        
        // declare title of button
        let title = buttonLike.title(for: .normal)
        
        if title == "unlike" {
            
            let object = PFObject(className: "likes")
            object["by"] = PFUser.current()?.username
            object["to"] = labelUuid.text
            object.saveInBackground(block: { (success: Bool, error: Error?) in
                
                if success {
                    print("liked")
                    self.buttonLike.setTitle("like", for: .normal)
                    self.buttonLike.setImage(UIImage(named: "like.png"), for: .normal)
                    
                    // send notification if we liked to refesh tableview
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "liked"), object: nil)
                    
                    // send notification as like
                    let newsObj = PFObject(className: "news")
                    newsObj["by"] = PFUser.current()?.username
                    newsObj["to"] = self.buttonUsername.titleLabel!.text
                    newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                    newsObj["owner"] = self.buttonUsername.titleLabel!.text
                    newsObj["uuid"] = self.labelUuid.text
                    newsObj["type"] = "like"
                    newsObj["checked"] = "no"
                    newsObj.saveEventually()
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
    }

}
