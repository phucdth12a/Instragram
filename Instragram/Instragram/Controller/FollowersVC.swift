//
//  FollowersVC.swift
//  Instragram
//
//  Created by Phu on 6/15/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit
import Parse

var user = String()
var category = String()

class FollowersVC: UITableViewController {
    
    // MARK: *** Data model
    // array to hold data received from servers
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    
    // array showing who do we follow or who following us
    var followArray = [String]()

    // MARK: *** ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // title at the top
        self.navigationItem.title = category.uppercased()
        
        
        // load followers if tapped on followers label
        if category == "followers" {
            loadFollowers()
        }
        
        // load follwings if tapped on followings label
        if category == "followings" {
            loadFollowings()
        }
        
    }
    
    // loading followers
    func loadFollowers() {
        
        // find followers of user
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: user)
        followers.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            
            if error == nil {
                
                // clean up
                self.followArray.removeAll(keepingCapacity: false)
                
                // find related objects depend on query setting
                for object in objects! {
                    
                    self.followArray.append(object.value(forKey: "follower") as! String)
                }
                
                // find users following user
                let query = PFUser.query()
                query?.whereKey("username", containedIn: self.followArray)
                query?.addDescendingOrder("createdAt")
                query?.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                    
                    if error == nil {
                        
                        // clean up
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        
                        // find related objects in User class of Parse
                        for object in objects! {
                            
                            self.usernameArray.append(object.value(forKey: "username") as! String)
                            self.avaArray.append(object.value(forKey: "ava") as! PFFile)
                            
                            self.tableView.reloadData()
                        }
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    // loading followings
    func loadFollowings() {
        
        let followings = PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: user)
        followings.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            
            if error == nil {
                
                //clean up
                self.followArray.removeAll(keepingCapacity: false)
                
                // find related objects in follow class of Parse
                for object in objects! {
                    
                    self.followArray.append(object.value(forKey: "following") as! String)
                }
                
                // find User followered by user
                let query = PFUser.query()
                query?.whereKey("username", containedIn: self.followArray)
                query?.addDescendingOrder("createdAt")
                query?.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                    
                    if error == nil {
                        // clean up
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        
                        // find related object in User classs of Parse
                        for object in objects! {
                            
                            self.usernameArray.append(object.value(forKey: "username") as! String)
                            self.avaArray.append(object.value(forKey: "ava") as! PFFile)
                            
                            self.tableView.reloadData()
                        }
                    } else {
                        print(error!.localizedDescription)
                    }
                    
                })
            } else {
                print(error!.localizedDescription)
            }
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowersCell

        cell.labelUsername.text = usernameArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            
            if error == nil {
                
                cell.imageViewAvatar.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        // shown do user following or do dot
        let query = PFQuery(className: "follow")
        query.whereKey("follower", equalTo: PFUser.current()!.username!)
        query.whereKey("following", equalTo: cell.labelUsername.text!)
        query.countObjectsInBackground { (count: Int32, error: Error?) in
            
            if error == nil {
                if count == 0 {
                    cell.buttonFollowing.setTitle("FOLLOW", for: .normal)
                    cell.buttonFollowing.backgroundColor = UIColor.lightGray
                } else {
                    cell.buttonFollowing.setTitle("FOLLOWING", for: .normal)
                    cell.buttonFollowing.backgroundColor = UIColor.green
                }
            }
        }

        // hide follow button for current user
        if cell.labelUsername.text == PFUser.current()?.username {
            cell.buttonFollowing.isHidden = true
        }

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // recall cell to call futher cell's data
        let cell = tableView.cellForRow(at: indexPath) as! FollowersCell
        
        // if user tapped on himseft, go home. else go guest
        if cell.labelUsername.text! == PFUser.current()!.username! {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.labelUsername.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }

    
}
