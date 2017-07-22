//
//  NewsVC.swift
//  Instragram
//
//  Created by Phu on 7/3/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit
import Parse

class NewsVC: UITableViewController {
    
    // MARK: *** Data model
    // arrays to hold data from server
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var typeArray = [String]()
    var dateArray = [Date?]()
    var uuidArray = [String]()
    var ownerArray = [String]()
    
    
    // MARK: *** UI Event
    @IBAction func buttonUsername_Clicked(_ sender: Any) {
        
        // call index of button
        let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! NewsCell
        
        // if user tapped on himself go home, else go guest
        if cell.buttonUsername.titleLabel?.text == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.buttonUsername.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
        
    }

    
    // MARK: *** ViewDidLoad
    override func viewDidLoad() {
        
        // dynamic tableview height - dynamic cell
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        
        // title ar the top
        self.navigationItem.title = "NOTIFICATIIONS"
        
        // request notifications
        let query = PFQuery(className: "news")
        query.whereKey("to", equalTo: PFUser.current()!.username!)
        query.limit = 30
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            
            if error == nil {
                
                // clean up
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                self.typeArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                self.ownerArray.removeAll(keepingCapacity: false)
                
                // found related objects
                for object in objects! {
                    self.usernameArray.append(object.value(forKey: "by") as! String)
                    self.avaArray.append(object.value(forKey: "ava") as! PFFile)
                    self.typeArray.append(object.value(forKey: "type") as! String)
                    self.dateArray.append(object.createdAt)
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.ownerArray.append(object.value(forKey: "owner") as! String)
                    
                    // save notification as checked
                    object["checked"] = "yes"
                    object.saveEventually()
                }
                
                // reload tableview to show received data
                self.tableView.reloadData()
                
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! NewsCell
        
        cell.buttonUsername.setTitle(usernameArray[indexPath.row], for: .normal)
        cell.buttonUsername.sizeToFit()
        avaArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                cell.imageViewAvatar.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        // caculate post date
        let from = dateArray[indexPath.row]
        let now = Date()
        let components: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfMonth]
        let difference = (Calendar.current as NSCalendar).components(components, from: from!, to: now, options: [])
        
        // logic what to shown: seconds, minutes, hours, days or weeks
        if difference.second! <= 0 {
            cell.labelDate.text = "now"
        } else if difference.second! > 0 && difference.minute! == 0 {
            cell.labelDate.text = "\(difference.second!)s."
        } else if difference.minute! > 0 && difference.hour! == 0 {
            cell.labelDate.text = "\(difference.minute!)m."
        } else if difference.hour! > 0 && difference.day! == 0 {
            cell.labelDate.text = "\(difference.hour!)h."
        } else if difference.day! > 0 && difference.weekOfMonth! == 0 {
            cell.labelDate.text = "\(difference.day!)d."
        } else if difference.weekOfMonth! > 0 {
            cell.labelDate.text = "\(difference.weekOfMonth!)w."
        }
        
        // define info text
        if typeArray[indexPath.row] == "mention" {
            cell.labelInfo.text = "has mentioned you."
        } else if typeArray[indexPath.row] == "comment" {
            cell.labelInfo.text = "has commented your posts."
        } else if typeArray[indexPath.row] == "follow" {
            cell.labelInfo.text = "now following you."
        } else if typeArray[indexPath.row] == "like" {
            cell.labelInfo.text = "likes your photos."
        }
        
        // assign index of button
        cell.buttonUsername.layer.setValue(indexPath, forKey: "index")
        
        return cell        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // call cell for calling cell data
        let cell = tableView.cellForRow(at: indexPath) as! NewsCell
        
        // going to @mentioned comment
        if cell.labelInfo.text == "has mentioned you." {
            
            // send related data to golbal variable
            commentUuid.append(uuidArray[indexPath.row])
            commentOwner.append(ownerArray[indexPath.row])
            
            // go comment
            let comment = self.storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
            self.navigationController?.pushViewController(comment, animated: true)
            
        }
        
        // going to own comment
        if cell.labelInfo.text == "has commented your posts." {
            
            // send related data to global variable
            commentUuid.append(uuidArray[indexPath.row])
            commentOwner.append(ownerArray[indexPath.row])
            
            // go comment
            let comment = self.storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
            self.navigationController?.pushViewController(comment, animated: true)
        }
        
        // going to user followed current user
        if cell.labelInfo.text == "now following you." {
            
            // take guestname
            guestname.append(cell.buttonUsername.titleLabel!.text!)
            
            // go guest
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
        
        // going to liked post
        if cell.labelInfo.text == "likes your photos." {
            
            // take post uuid
            postuuid.append(uuidArray[indexPath.row])
            
            // go post
            let post = self.storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostVC
            self.navigationController?.pushViewController(post, animated: true)
        }
    }

}
