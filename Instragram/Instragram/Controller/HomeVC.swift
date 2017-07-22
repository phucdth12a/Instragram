//
//  HomeVC.swift
//  Instragram
//
//  Created by Phu on 6/14/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit
import Parse

class HomeVC: UICollectionViewController {
    
    // MARK: *** Data model
    // refresher variable
    var refresher: UIRefreshControl!
    
    // size of page
    var page: Int = 12
    
    var uuidArray = [String]()
    var picArray = [PFFile]()
    
    // MARK: *** UI Event
    @IBAction func buttonLogout_Clicked(_ sender: Any) {
        
        PFUser.logOutInBackground { (error: Error?) in
            
            if error == nil {
                
                // remove logged in user from App memory
                UserDefaults.standard.removeObject(forKey: "username")
                UserDefaults.standard.synchronize()
                
                let signin = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.window?.rootViewController = signin
            } else {
                print(error!.localizedDescription)
            }
        }
        
    }
    

    // MARK: *** ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // always vertical scroll
        self.collectionView?.alwaysBounceVertical = true
        
        // Title at the top
        self.navigationItem.title = PFUser.current()?.username?.uppercased()
        
        // pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView?.addSubview(refresher)
        
        // receive notification from editVC
        NotificationCenter.default.addObserver(self, selector: #selector(reload(_:)), name: NSNotification.Name(rawValue: "reload"), object: nil)
        
        // receive notification from uploadVC
        NotificationCenter.default.addObserver(self, selector: #selector(uploaded(_:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
        
        // load posts func
        loadPosts()
    }
    
    // refreshing func
    func refresh() {
        
        // reload data information
        collectionView?.reloadData()
        
        // stop refresher animating
        refresher.endRefreshing()
    }
    
    // reloading func
    func reload(_ notification: Notification) {
        collectionView?.reloadData()
    }
    
    // uploaded func
    func uploaded(_ notification: Notification) {
        loadPosts()
    }
    
    // load posts func
    func loadPosts() {
        
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: PFUser.current()!.username!)
        query.limit = page
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            
            if error == nil {
                
                // clean up
                self.uuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                // find related to our request
                for object in objects! {
                    
                    // add found data to arrays (holders)
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    self.picArray.append(object.value(forKey: "pic") as! PFFile)
                    
                    self.collectionView?.reloadData()
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
    }
    
    // load more while scrolling down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height {
            self.loadMore()
        }
    }
    
    // paging 
    func loadMore() {
        
        // if there is more objects
        if page <= picArray.count {
        
            // increase page size
            page = page + 12
            
            // load more posts
            let query = PFQuery(className: "posts")
            query.whereKey("username", equalTo: PFUser.current()!.username!)
            query.limit = page
            query.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                
                if error == nil {
                    
                    // clean up
                    self.uuidArray.removeAll(keepingCapacity: false)
                    self.picArray.removeAll(keepingCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.uuidArray.append(object.value(forKey: "uuid") as! String)
                        self.picArray.append(object.value(forKey: "pic") as! PFFile)
                        
                        self.collectionView?.reloadData()
                    }
                } else {
                    print(error!.localizedDescription)
                }
            })
        }
        
    }

    // MARK: *** UICollectionViewDataSource

    // number cell
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        return size
    }
    
    // cell config
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // difine cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
        
        // get picture from picArray
        picArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            
            if error == nil {
                
                cell.imageViewPicture.image = UIImage(data: data!)
            } else {
                
                print(error!.localizedDescription)
            }
        }
        
        return cell
    }
    
    // header config
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        // difine header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        
        // STEP 1: Get user data
        // get users data with connections to columns of PFUser class
        header.labelFullname.text = (PFUser.current()?.object(forKey: "fullname") as? String)?.uppercased()
        header.textViewWeb.text = PFUser.current()?.object(forKey: "web") as? String
        header.textViewWeb.sizeToFit()
        header.labelBio.text = PFUser.current()?.object(forKey: "bio") as? String
        header.labelBio.sizeToFit()
        header.buttonEditProfile.setTitle("edit profile", for: .normal)
        let avaQuery = PFUser.current()?.object(forKey: "ava") as! PFFile
        avaQuery.getDataInBackground { (data: Data?, error: Error?) in
            
            header.imageViewAvatar.image = UIImage(data: data!)
        }
        
        // count total posts
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: PFUser.current()!.username!)
        posts.countObjectsInBackground { (count: Int32, error: Error?) in
            
            if error == nil {
                
                header.labelPost.text = "\(count)"
            }
        }
        
        // STEP 2: Count statistics
        // count total follower
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: PFUser.current()!.username!)
        followers.countObjectsInBackground { (count: Int32, error: Error?) in
            
            if error == nil {
                
                header.labelFollowers.text = "\(count)"
            }
        }
        
        // count total following
        let followings = PFQuery(className: "follow")
        followings.whereKey("follower", equalTo: PFUser.current()!.username!)
        followings.countObjectsInBackground { (count: Int32, error: Error?) in
            
            if error == nil {
                
                header.labelFollowings.text = "\(count)"
            }
        }
        
        // STEP 3: Implement tap gestures
        // tap posts
        let postsTap = UITapGestureRecognizer(target: self, action: #selector(postsTapped))
        postsTap.numberOfTapsRequired = 1
        header.labelPost.isUserInteractionEnabled = true
        header.labelPost.addGestureRecognizer(postsTap)
        
        // tap followers
        let followersTap = UITapGestureRecognizer(target: self, action: #selector(followersTapped))
        followersTap.numberOfTapsRequired = 1
        header.labelFollowers.isUserInteractionEnabled = true
        header.labelFollowers.addGestureRecognizer(followersTap)
        
        // tap followings
        let followingsTap = UITapGestureRecognizer(target: self, action: #selector(followingsTapped))
        followingsTap.numberOfTapsRequired = 1
        header.labelFollowings.isUserInteractionEnabled = true
        header.labelFollowings.addGestureRecognizer(followingsTap)
        
        return header
    }
    
    // go post
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // send post uuid to "postuuid" variable
        postuuid.append(uuidArray[indexPath.row])
        
        // navigate to post view controller
        let post = self.storyboard?.instantiateViewController(withIdentifier: "PostVC")
        self.navigationController?.pushViewController(post!, animated: true)
    }
    
    // tapped posts label
    func postsTapped() {
        
        if !picArray.isEmpty {
            
            let index = NSIndexPath(item: 0, section: 0)
            self.collectionView?.scrollToItem(at: index as IndexPath, at: .top, animated: true)
        }
    }
    
    // tapped followers label
    func followersTapped() {
        
        user = PFUser.current()!.username!
        category = "followers"
        
        // make references to followersVC
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! FollowersVC
        
        // present
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    // tapped followings label
    func followingsTapped() {
        
        user = PFUser.current()!.username!
        category = "followings"
        
        // make references to followersVC
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! FollowersVC
        
        // present
        self.navigationController?.pushViewController(followers, animated: true)
    }
}
