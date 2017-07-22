//
//  GuestVC.swift
//  Instragram
//
//  Created by Phu on 6/15/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit
import Parse

var guestname = [String]()

class GuestVC: UICollectionViewController {

    // MARK: *** Data model
    // UI object
    var refresher: UIRefreshControl!
    var page: Int = 12
    
    // array to hold data from server
    var uuidArray = [String]()
    var picArray = [PFFile]()
    
    
    // MARK: *** ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        // always verical scroll
        self.collectionView?.alwaysBounceVertical = true
        
        // top title
        self.navigationItem.title = guestname.last!.uppercased()
        
        // new back button
        self.navigationItem.hidesBackButton = true
        let buttonBack = UIBarButtonItem(image: UIImage(named: "back.png"), style: .plain, target: self, action: #selector(back(_:)))
        self.navigationItem.leftBarButtonItem = buttonBack
        
        // swipe go to back
        let backSwipe = UISwipeGestureRecognizer(target: self, action: #selector(back))
        backSwipe.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(backSwipe)
        
        // pull to refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(refresh), for: .valueChanged)
        collectionView?.addSubview(refresher)
        
        // call load posts func
        loadPosts()
    }
    
    // back func
    func back(_ sender: UIBarButtonItem) {
        
        // push back
        self.navigationController?.popViewController(animated: true)
        
        // clean guest username or deduct last guest username from guestname = Array
        if !guestname.isEmpty {
            guestname.removeLast()
        }
    }
    
    // refresh func
    func refresh() {
        collectionView?.reloadData()
        refresher.endRefreshing()
        
    }
    
    // post loading func
    func loadPosts() {
        
        // load posts
        let query = PFQuery(className: "posts")
        query.whereKey("username", equalTo: guestname.last!)
        query.limit = page
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            
            if error == nil {
                
                // clean up
                self.uuidArray.removeAll(keepingCapacity: false)
                self.picArray.removeAll(keepingCapacity: false)
                
                // find related objects
                for object in objects! {
                    
                    // hold found information in arrays
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
            query.whereKey("username", equalTo: guestname.last!)
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

    
    // MARK: *** CollectionView
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        return size
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! PictureCell
        
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
        
        // fefine header
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "Header", for: indexPath) as! HeaderView
        
        // STEP 1: Get user data
        // get users data with connections to columns of PFUser class
        let infoQuery = PFUser.query()
        infoQuery?.whereKey("username", equalTo: guestname.last!)
        infoQuery?.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
            
            if error == nil {
                
                // shown wrong user
                if objects!.isEmpty {
                    self.alert(title: "\(guestname.last!.uppercased())", message: "is not existing", handler: { (UIAlertAction) in
                        self.navigationController?.popViewController(animated: true)
                    })
                }
                
                for object in objects! {
                    header.labelFullname.text = (object.value(forKey: "fullname") as? String)?.uppercased()
                    header.labelBio.text = object.value(forKey: "bio") as? String
                    header.labelBio.sizeToFit()
                    header.textViewWeb.text = object.value(forKey: "web") as? String
                    header.textViewWeb.sizeToFit()
                    
                    let avaFile = (object.value(forKey: "ava") as? PFFile)!
                    avaFile.getDataInBackground(block: { (data: Data?, error: Error?) in
                        
                        if error == nil {
                            header.imageViewAvatar.image = UIImage(data: data!)
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                }
            } else {
                print(error!.localizedDescription)
            }
        })
        
        // STEP 2: Count statistics
        // check FOLLOW or FOLLOWING
        let followQuery = PFQuery(className: "follow")
        followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
        followQuery.whereKey("following", equalTo: guestname.last!)
        followQuery.countObjectsInBackground { (count: Int32, error: Error?) in
            
            if error == nil {
                
                if count == 0 {
                    header.buttonEditProfile.setTitle("FOLLOW", for: .normal)
                    header.buttonEditProfile.backgroundColor = UIColor.lightGray
                } else {
                    header.buttonEditProfile.setTitle("FOLLOWING", for: .normal)
                    header.buttonEditProfile.backgroundColor = UIColor.green
                }
            } else {
                print(error!.localizedDescription)
            }
        }
        
        // count total posts
        let posts = PFQuery(className: "posts")
        posts.whereKey("username", equalTo: guestname.last!)
        posts.countObjectsInBackground { (count: Int32, error: Error?) in
            
            if error == nil {
                header.labelPost.text = "\(count)"
            } else {
                print(error!.localizedDescription)
            }
        }
        
        // count total follower
        let followers = PFQuery(className: "follow")
        followers.whereKey("following", equalTo: guestname.last!)
        followers.countObjectsInBackground { (count: Int32, error: Error?) in
            
            if error == nil {
                header.labelFollowers.text = "\(count)"
            } else {
                print(error!.localizedDescription)
            }
        }
        
        // count total following
        let following = PFQuery(className: "follow")
        following.whereKey("follower", equalTo: guestname.last!)
        following.countObjectsInBackground { (count: Int32, error: Error?) in
            
            if error == nil {
                header.labelFollowings.text = "\(count)"

            } else {
                print(error!.localizedDescription)
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
        let post = self.storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostVC
        self.navigationController?.pushViewController(post, animated: true)
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
        
        user = guestname.last!
        category = "followers"
        
        // make references to followersVC
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! FollowersVC
        
        // present
        self.navigationController?.pushViewController(followers, animated: true)
    }
    
    // tapped followings label
    func followingsTapped() {
        
        user = guestname.last!
        category = "followings"
        
        // make references to followersVC
        let followers = self.storyboard?.instantiateViewController(withIdentifier: "followersVC") as! FollowersVC
        
        // present
        self.navigationController?.pushViewController(followers, animated: true)
    }


}
