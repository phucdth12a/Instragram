//
//  CommentVC.swift
//  Instragram
//
//  Created by Phu on 6/18/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit
import Parse

var commentUuid = [String]()
var commentOwner = [String]()

class CommentVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    // MARK: *** UI Element
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textViewComment: UITextView!
    @IBOutlet weak var buttonSend: UIButton!
    @IBOutlet weak var bottomConstraintsComment: NSLayoutConstraint!
    @IBOutlet weak var heightConstraintsComment: NSLayoutConstraint!
    
    // MARK: *** Data model
    var refresher = UIRefreshControl()
    var commentY : CGFloat = 0
    
    // arrays to hold server data
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var commentArray = [String]()
    var dateArray = [Date?]()
    var labelPlaceHolder = UILabel()
    
    // page size
    var page: Int32 = 15

    // MARK: *** UI Event
    @IBAction func buttonUsername_Clicked(_ sender: Any) {
        
        // cell index of button
        let i = (sender as AnyObject).layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = self.tableView.cellForRow(at: i) as! CommentCell
        
        if cell.buttonUsername.titleLabel?.text == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.buttonUsername.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    @IBAction func buttonSend_Clicked(_ sender: Any) {
        
        // STEP 1. add row in tableView
        self.usernameArray.append(PFUser.current()!.username!)
        self.avaArray.append(PFUser.current()?.object(forKey: "ava") as! PFFile)
        self.dateArray.append(Date())
        self.commentArray.append(textViewComment.text.trimmingCharacters(in: .whitespacesAndNewlines))
        self.tableView.reloadData()
        
        // STEP 2. send comment to server
        let commentObj = PFObject(className: "comments")
        commentObj["to"] = commentUuid.last
        commentObj["username"] = PFUser.current()?.username
        commentObj["ava"] = PFUser.current()?.object(forKey: "ava")
        commentObj["comment"] = textViewComment.text.trimmingCharacters(in: .whitespacesAndNewlines)
        commentObj.saveEventually()
        
        // STEP 3. send #hashtag to server
        let words: [String] = textViewComment.text!.components(separatedBy: .whitespacesAndNewlines)
        
        // define tagged word
        for var word in words {
            
            // save #hashtag in server
            if word.hasPrefix("#") {
                
                // cut symbold
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                
                let hashtagObj = PFObject(className: "hashtags")
                hashtagObj["to"] = commentUuid.last
                hashtagObj["by"] = PFUser.current()?.username
                hashtagObj["hashtag"] = word.lowercased()
                hashtagObj["comment"] = textViewComment.text
                hashtagObj.saveInBackground(block: { (success: Bool, error: Error?) in
                    
                    if success {
                        print("hashtag \(word) is created")
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
        }
        
        // STEP 4. send notification as @mention
        var mentionCreated = Bool()
        for var word in words {
            
            if word.hasPrefix("@") {
                
                // cut symbols
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                
                let newsObj = PFObject(className: "news")
                newsObj["by"] = PFUser.current()?.username
                newsObj["to"] = word
                newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
                newsObj["owner"] = commentOwner.last
                newsObj["uuid"] = commentUuid.last
                newsObj["type"] = "mention"
                newsObj["checked"] = "no"
                newsObj.saveEventually()
                mentionCreated = true
            }
        }
        
        // STEP 5. send notification as comment
        if commentOwner.last != PFUser.current()?.username && mentionCreated == false {
            
            let newsObj = PFObject(className: "news")
            newsObj["by"] = PFUser.current()?.username
            newsObj["to"] = commentOwner.last
            newsObj["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
            newsObj["owner"] = commentOwner.last
            newsObj["uuid"] = commentUuid.last
            newsObj["type"] = "comment"
            newsObj["checked"] = "no"
            newsObj.saveEventually()
        }
        
        // scroll to bottom
        self.tableView.scrollToRow(at: IndexPath(row: commentArray.count - 1, section: 0), at: .bottom, animated: false)
        
        // STEP 6. reset UI
        self.buttonSend.isEnabled = false
        self.labelPlaceHolder.isHidden = false
        textViewComment.text = ""
        self.heightConstraintsComment.constant = 33
    }
    
    // MARK: *** UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title at the top
        self.navigationItem.title = "COMMENTS"
        
        self.navigationItem.hidesBackButton = true
        let buttonBack = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = buttonBack
        
        // Check notification if keyboard is shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
        // Tap to hide keyboard
        let tapHide = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        tapHide.numberOfTapsRequired = 2
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapHide)
        
        // swipe to go back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back(_:)))
        backSwipe.direction = .right
        self.view.addGestureRecognizer(backSwipe)
        
        buttonSend.isEnabled = false
        
        // create placeholder label programtically
        let placeholderX: CGFloat = self.view.frame.width / 75
        let placeholderY: CGFloat = 0
        let placeholderWidth = textViewComment.bounds.width - placeholderX
        let placeholderHeight = textViewComment.bounds.height
        let placeholderFontSize = self.view.frame.size.width / 25
        
        labelPlaceHolder.frame = CGRect(x: placeholderX, y: placeholderY, width: placeholderWidth, height: placeholderHeight)
        labelPlaceHolder.text = "Enter text..."
        labelPlaceHolder.textColor = .lightGray
        labelPlaceHolder.font = UIFont(name: "HelveticaNeue", size: placeholderFontSize)
        labelPlaceHolder.textAlignment = .left
        textViewComment.addSubview(labelPlaceHolder)
        
        // call alignment function
        alignment()
        
        // call loadComment function
        loadComments()
    }
    
    // alignment function
    func alignment() {
        
        self.tableView.estimatedRowHeight = 60
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        textViewComment.delegate = self
        self.commentY = bottomConstraintsComment.constant
        self.textViewComment.layer.cornerRadius = 6
        self.textViewComment.clipsToBounds = true
       
    }

    // while writting something
    func textViewDidChange(_ textView: UITextView) {
        
        // disable button if entered no text
        if !textViewComment.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self.buttonSend.isEnabled = true
            self.labelPlaceHolder.isHidden = true
        } else {
            self.buttonSend.isEnabled = false
            self.labelPlaceHolder.isHidden = false
        }
        
        // + paragraph
        if textViewComment.contentSize.height > textViewComment.frame.size.height && heightConstraintsComment.constant < 130 {
            
            heightConstraintsComment.constant = textViewComment.contentSize.height

        } else if textViewComment.contentSize.height < textViewComment.frame.size.height {
            heightConstraintsComment.constant = textViewComment.contentSize.height
        }
    }
    
    // go back
    func back(_ sender: UIBarButtonItem) {
        
        // push back
        self.navigationController?.popViewController(animated: true)
        
        // clean comment uuid last holding information
        if !commentUuid.isEmpty {
            commentUuid.removeLast()
        }
        
        // clean comment ower from last holding information
        if !commentOwner.isEmpty {
            commentOwner.removeLast()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // hide custom tabbar button
        tabbarPostButton.isHidden = true
        
        // hide bottom bar
        self.tabBarController?.tabBar.isHidden = true
        
        // call keyboard
        textViewComment.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // shown bottom bar
        self.tabBarController?.tabBar.isHidden = false
        
        // show custom tabbar button
        tabbarPostButton.isHidden = false
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        //print(self.commentY)
        
        // Get info keyboard
        let keyboard = ((notification.userInfo?[UIKeyboardFrameEndUserInfoKey]! as AnyObject).cgRectValue)!
        
        // move UI up
        UIView.animate(withDuration: 0.4) { 
            self.bottomConstraintsComment.constant += keyboard.height
        }
        
        //print(self.tableView.frame.size.height)
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        // move UI down
        UIView.animate(withDuration: 0.4) { 
            self.bottomConstraintsComment.constant = self.commentY
        }
    }
    
    // Hide keyboard fun
    func hideKeyboard(_ recognizer: UITapGestureRecognizer) {
        
        self.view.endEditing(true)
    }
    
    // load comments function
    func loadComments() {
        
        // STEP 1. Count total comments in order to skip all expect (page size = 15)
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentUuid.last!)
        countQuery.countObjectsInBackground { (count: Int32, error: Error?) in
            
            if error == nil {
                
                // if comments on the server for current post are more than (page size 15), implement pull to refresh func
                if self.page < count {
                    self.refresher.addTarget(self, action: #selector(self.loadMore), for: .valueChanged)
                    self.tableView.addSubview(self.refresher)
                }
                
                // STEP 2. Request last (page size 15) comments
                let query = PFQuery(className: "comments")
                query.whereKey("to", equalTo: commentUuid.last!)
                query.skip = count - self.page
                query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                    
                    if error == nil {
                        
                        // clean up
                        self.usernameArray.removeAll(keepingCapacity: false)
                        self.avaArray.removeAll(keepingCapacity: false)
                        self.commentArray.removeAll(keepingCapacity: false)
                        self.dateArray.removeAll(keepingCapacity: false)
                        
                        // find related object
                        for object in objects! {
                            self.usernameArray.append(object.value(forKey: "username") as! String)
                            self.avaArray.append(object.value(forKey: "ava") as! PFFile)
                            self.commentArray.append(object.value(forKey: "comment") as! String)
                            self.dateArray.append(object.createdAt)
                            
                            self.tableView.reloadData()
                            
                            // scroll to bottom
                            self.tableView.scrollToRow(at: IndexPath(row: self.commentArray.count - 1, section: 0), at: .bottom, animated: false)
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
    
    // pagination
    func loadMore() {
        
        // STEP 1. Count total comments in order to skip all expect (page size = 15)
        let countQuery = PFQuery(className: "comments")
        countQuery.whereKey("to", equalTo: commentUuid.last!)
        countQuery.countObjectsInBackground { (count: Int32, error: Error?) in
            
            if error == nil {
                
                // refresher
                self.refresher.endRefreshing()
                
                // remove refresher if loaded all comments
                if self.page >= count {
                    self.refresher.removeFromSuperview()
                }
                
                // STEP 2. load more comments
                if self.page < count {
                    
                    // increase page to load 30 as first paging
                    self.page += 15
                    
                    // request existing comments from the server
                    let query = PFQuery(className: "comments")
                    query.whereKey("to", equalTo: commentUuid.last!)
                    query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                        
                        if error == nil {
                            
                            // clean up
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            self.commentArray.removeAll(keepingCapacity: false)
                            self.dateArray.removeAll(keepingCapacity: false)
                            
                            // find related objects
                            for object in objects! {
                                self.usernameArray.append(object.value(forKey: "username") as! String)
                                self.avaArray.append(object.value(forKey: "ava") as! PFFile)
                                self.commentArray.append(object.value(forKey: "comment") as! String)
                                self.dateArray.append(object.createdAt)
                                
                                self.tableView.reloadData()
                            }
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                }
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    // MARK: *** UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // define cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CommentCell
        
        // get data from arrays
        cell.buttonUsername.setTitle(usernameArray[indexPath.row], for: .normal)
        cell.buttonUsername.sizeToFit()
        cell.labelComment.text = commentArray[indexPath.row]
        
        // get avatar
        avaArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            
            if error == nil {
                cell.imageViewAvatar.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        // caculate comment date
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
        
        //@mention is tapped
        cell.labelComment.userHandleLinkTapHandler = { label, handle, range in
            
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
        cell.labelComment.hashtagLinkTapHandler = { label, hanlde, range in
            
            var mention = hanlde
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention.lowercased())
            let hash = self.storyboard?.instantiateViewController(withIdentifier: "HashtagsVC") as! HashtagsVC
            self.navigationController?.pushViewController(hash, animated: true)
        }
        
        // assign index
        cell.buttonUsername.layer.setValue(indexPath, forKey: "index")

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let cell = tableView.cellForRow(at: indexPath) as! CommentCell
        
        // ACTION 1. Delete
        let delete = UITableViewRowAction(style: .normal, title: "    ", handler: { (action: UITableViewRowAction, indexPath: IndexPath) in
            
            // STEP 1. Delete comment from server
            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("to", equalTo: commentUuid.last!)
            commentQuery.whereKey("comment", equalTo: cell.labelComment.text!)
            commentQuery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                
                if error == nil {
                    
                    // find related objects
                    for object in objects! {
                        object.deleteEventually()
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            // STEP 2. Delete #hashtag from server
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("to", equalTo: commentUuid.last!)
            hashtagQuery.whereKey("by", equalTo: cell.buttonUsername.titleLabel!.text!)
            hashtagQuery.whereKey("comment", equalTo: cell.labelComment.text!)
            hashtagQuery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            // STEP 3. Delete notification mention comment
            let newQuery = PFQuery(className: "news")
            newQuery.whereKey("by", equalTo: cell.buttonUsername.titleLabel!.text!)
            newQuery.whereKey("to", equalTo: commentOwner.last!)
            newQuery.whereKey("uuid", equalTo: commentUuid.last!)
            newQuery.whereKey("type", containedIn: ["comment", "mention"])
            newQuery.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
            
            
            // close cell
            self.tableView.setEditing(false, animated: true)
            
            // STEP 3. Delete comment row from tableView
            self.commentArray.remove(at: indexPath.row)
            self.dateArray.remove(at: indexPath.row)
            self.usernameArray.remove(at: indexPath.row)
            self.avaArray.remove(at: indexPath.row)
            
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        })
        
        // ACTION 2. Metion or address message to someone
        let address = UITableViewRowAction(style: .normal, title: "    ") { (action: UITableViewRowAction, indexPath: IndexPath) in
            
            // include username in textview
            self.textViewComment.text = "\(self.textViewComment.text + "@" + self.usernameArray[indexPath.row] + " ")"
            
            // enable button
            self.buttonSend.isEnabled = true
            self.labelPlaceHolder.isHidden = true
            
            // close cell
            self.tableView.setEditing(false, animated: true)
        }
        
        // ACTION 3. Complain
        let complain = UITableViewRowAction(style: .normal, title: "    ") { (action: UITableViewRowAction, indexPath: IndexPath) in
            
            // send complain to server regarding selected comment
            let complainObj = PFObject(className: "complain")
            complainObj["by"] = PFUser.current()?.username
            complainObj["post"] = commentUuid.last
            complainObj["to"] = cell.labelComment.text
            complainObj["owner"] = cell.buttonUsername.titleLabel?.text
            complainObj.saveInBackground(block: { (success: Bool, error: Error?) in
                
                if success {
                    self.alert(title: "Complain has been made successfully", message: "Thank you! We will consider your complain")
                } else {
                    self.alert(title: "ERROR", message: error!.localizedDescription)
                }
            })
            
            // close cell
            self.tableView.setEditing(false, animated: true)
        }
        
        // button background
        delete.backgroundColor = UIColor(patternImage: UIImage(named: "delete.png")!)
        address.backgroundColor = UIColor(patternImage: UIImage(named: "address.png")!)
        complain.backgroundColor = UIColor(patternImage: UIImage(named: "complain.png")!)
        
        // comment belongs to user
        if cell.buttonUsername.titleLabel?.text == PFUser.current()?.username {
            return [delete, address]
        }
        // post belongs to user
        else if commentOwner.last == PFUser.current()?.username {
            return [delete, address, complain]
        }
        // post belongs to another user
        else {
            return [address, complain]
        }
    }
}
