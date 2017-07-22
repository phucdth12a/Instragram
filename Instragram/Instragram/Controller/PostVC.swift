//
//  PostVC.swift
//  Instragram
//
//  Created by Phu on 6/18/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit
import Parse

var postuuid = [String]()

class PostVC: UITableViewController {
    
    // MARK: *** Data model
    // arrays to hold information from server
    var avaArray = [PFFile]()
    var usernameArray = [String]()
    var dateArray = [Date?]()
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var titleArray = [String]()

    // MARK: *** UI Event
    @IBAction func buttonUsername_Clicked(_ sender: Any) {
        
        // call index of button
        let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! PostCell
        
        if cell.buttonUsername.titleLabel?.text == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.buttonUsername.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    @IBAction func buttonComment_Clicked(_ sender: Any) {
        
        // call index of button
        let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! PostCell
        
        commentUuid.append(cell.labelUuid.text!)
        commentOwner.append(cell.buttonUsername.titleLabel!.text!)
        
        // go to comment, present vc
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "CommentVC") as! CommentVC
        self.navigationController?.pushViewController(comment, animated: true)
    }
    
    @IBAction func buttonMore_Clicked(_ sender: Any) {
        
        // call index of button
        let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! PostCell
        
        // Delete action
        let delete = UIAlertAction(title: "Delete", style: .default) { (UIAlertAction) in
            
            // STEP 1. Delete row from tableView
            self.usernameArray.remove(at: i.row)
            self.avaArray.remove(at: i.row)
            self.dateArray.remove(at: i.row)
            self.picArray.remove(at: i.row)
            self.titleArray.remove(at: i.row)
            self.uuidArray.remove(at: i.row)
            
            // STEP 2. Delete post from server
            let postQuery = PFQuery(className: "posts")
            postQuery.whereKey("uuid", equalTo: cell.labelUuid.text!)
            postQuery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                
                if error == nil {
                    
                    for object in objects! {
                        object.deleteInBackground(block: { (success: Bool, error: Error?) in
                            
                            if success {
                                
                                // send notification to rootViewController to update shown posts
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                                
                                // push back
                                self.navigationController?.popViewController(animated: true)
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            // STEP 3. delete likes of posts from server
            let likeQuery = PFQuery(className: "likes")
            likeQuery.whereKey("to", equalTo: cell.labelUuid.text!)
            likeQuery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                
                if error == nil {
                    
                    for object in objects! {
                        object.deleteInBackground(block: { (success: Bool, error: Error?) in
                            if error == nil {
                                object.deleteEventually()
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            // STEP 4. Delete hashtags of posts from server
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("to", equalTo: cell.labelUuid.text!)
            hashtagQuery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                
                if error == nil {
                    
                    for object in objects! {
                        object.deleteEventually()
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        
        // Complain action
        let complain = UIAlertAction(title: "Complain", style: .default) { (UIAlertAction) in
            
            // send complain to server
            let complainObj = PFObject(className: "complain")
            complainObj["by"] = PFUser.current()?.username
            complainObj["to"] = cell.labelUuid.text
            complainObj["owner"] = cell.buttonUsername.titleLabel?.text
            complainObj.saveInBackground(block: { (success: Bool, error: Error?) in
                
                if error == nil {
                    self.alert(title: "Complain has been made successfully", message: "Thank you! We will consider your complain")
                } else {
                    self.alert(title: "ERROR", message: error!.localizedDescription)
                }
            })
        }
        
        // Cancel action
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // create menu controller
        let menu = UIAlertController(title: "Menu", message: nil, preferredStyle: .actionSheet)
        
        // if post belong to user, he can delete post, else he can't
        if cell.buttonUsername.titleLabel?.text == PFUser.current()?.username {
            menu.addAction(delete)
            menu.addAction(cancel)
        } else {
            menu.addAction(complain)
            menu.addAction(cancel)
        }
        
        // show menu
        self.present(menu, animated: true, completion: nil)
    }
    
    
    // MARK: *** ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // title lable at the top
        self.navigationItem.title = "PHOTO"
        
        // new button back
        self.navigationItem.hidesBackButton = true
        let buttonBack = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = buttonBack
        
        // swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = .right
        self.view.addGestureRecognizer(backSwipe)
        
        // 
        NotificationCenter.default.addObserver(self, selector: #selector(refresh(_:)), name: NSNotification.Name(rawValue: "liked"), object: nil)
        
        // dynamic cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        let postQuery = PFQuery(className: "posts")
        postQuery.whereKey("uuid", equalTo: postuuid.last!)
        postQuery.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            
            if error == nil {
                
                // clean up
                self.avaArray.removeAll(keepingCapacity: false)
                self.usernameArray.removeAll(keepingCapacity: false)
                self.dateArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                self.titleArray.removeAll(keepingCapacity: false)
                
                // find related objects
                for object in objects! {
                    
                    self.avaArray.append(object.value(forKey: "ava") as! PFFile)
                    self.usernameArray.append(object.value(forKey: "username") as! String)
                    self.dateArray.append(object.createdAt)
                    self.picArray.append(object.value(forKey: "pic") as! PFFile)
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.titleArray.append(object.value(forKey: "title") as! String)
                    
                    self.tableView.reloadData()
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
    }
    
    // refresh
    func refresh(_ notification: Notification) {
        self.tableView.reloadData()
    }
    
    // go back
    func back(_ sender: UIBarButtonItem) {
        
        // push back
        self.navigationController?.popViewController(animated: true)
        
        // clean post uuid from the hold
        if !postuuid.isEmpty {
            postuuid.removeLast()
        }
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // define cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        
        // connect object with our information from arrays
        cell.buttonUsername.setTitle(usernameArray[indexPath.row], for: .normal)
        cell.buttonUsername.sizeToFit()
        cell.labelUuid.text = uuidArray[indexPath.row]
        cell.labelTitle.text = titleArray[indexPath.row]
        cell.labelTitle.sizeToFit()
        
        // place profile picture
        avaArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            
            if error == nil {
                cell.imageviewAvatar.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        // place post pictire
        picArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            
            if error == nil {
                cell.imageViewPicture.image = UIImage(data: data!)
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
        
        // mainplute like button depending on did user like it or not
        let didLike = PFQuery(className: "likes")
        didLike.whereKey("by", equalTo: PFUser.current()!.username!)
        didLike.whereKey("to", equalTo: cell.labelUuid.text!)
        didLike.countObjectsInBackground { (count: Int32, error: Error?) in
    
            if error == nil {
                
                // if no any likes are found, else found likes
                if count == 0 {
                    cell.buttonLike.setTitle("unlike", for: .normal)
                    cell.buttonLike.setImage(UIImage(named: "unlike.png"), for: .normal)
                } else {
                    cell.buttonLike.setTitle("like", for: .normal)
                    cell.buttonLike.setImage(UIImage(named: "like.png"), for: .normal)
                }
                
            } else {
                print(error!.localizedDescription)
            }
        }
        
        // count total likes of shown post
        let countLikes = PFQuery(className: "likes")
        countLikes.whereKey("to", equalTo: cell.labelUuid.text!)
        countLikes.countObjectsInBackground { (count: Int32, error: Error?) in
            
            if error == nil {
                cell.labelLike.text = "\(count)"
            } else {
                print(error!.localizedDescription)
            }
        }
        
        //@mention is tapped
        cell.labelTitle.userHandleLinkTapHandler = { label, handle, range in
            
            var mention = handle
            mention = String(mention.characters.dropFirst())
            
            // if tapped on @CurrentUser go home, else go guest
            if mention.lowercased() == PFUser.current()?.username {
                let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                self.navigationController?.pushViewController(home, animated: true)
            } else {
                guestname.append(mention.lowercased())
                let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
                self.navigationController?.pushViewController(guest, animated: true)
            }
        }
        
        // #hashtag is tapped
        cell.labelTitle.hashtagLinkTapHandler = { label, hanlde, range in
            
            var mention = hanlde
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention.lowercased())
            let hash = self.storyboard?.instantiateViewController(withIdentifier: "HashtagsVC") as! HashtagsVC
            self.navigationController?.pushViewController(hash, animated: true)
        }

        
        // assign index
        cell.buttonUsername.layer.setValue(indexPath, forKey: "index")
        cell.buttonComment.layer.setValue(indexPath, forKey: "index")
        cell.buttonMore.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }

}
