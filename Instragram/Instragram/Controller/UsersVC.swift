//
//  UsersVC.swift
//  Instragram
//
//  Created by Phu on 6/22/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit
import Parse

class UsersVC: UITableViewController, UISearchBarDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: *** Data model
    // declare searchbar
    var searchBar = UISearchBar()
    
    // arrays to hold information from server
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    
    // collectionView UI
    var collectionView: UICollectionView!
    
    // collectionView arrays to hold information from server
    var picArray = [PFFile]()
    var uuidArray = [String]()
    var page: Int = 15
    
    
    // MARK: *** ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // implement search bar
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        searchBar.sizeToFit()
        searchBar.tintColor = UIColor.groupTableViewBackground
        searchBar.frame.size.width = self.view.frame.size.width - 34
        let searchItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = searchItem
        
        searchBar.showsCancelButton = false
        
        // call load users function
        loadUsers()
        
        // call CollectionView
        collectionViewLaunch()
        
    }
    
    // load users function
    func loadUsers() {
        
        let userQuery = PFUser.query()
        userQuery?.addDescendingOrder("createdAt")
        userQuery?.limit = 20
        userQuery?.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
            
            if error == nil {
                
                // clean up
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                
                // finf related objects
                for object in objects! {
                    self.usernameArray.append(object.value(forKey: "username") as! String)
                    self.avaArray.append(object.value(forKey: "ava") as! PFFile)
                }
                
                self.tableView.reloadData()
            } else {
                print(error!.localizedDescription)
            }
        })
    }
    
    // MARK: *** SearchBar
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let usernameQuery = PFUser.query()
        usernameQuery?.whereKey("username", matchesRegex: "(?i)" + searchBar.text!)
        usernameQuery?.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
            
            if error == nil {
                
                // if no objects are found according to entered text in username colomn, find by fullname
                if objects!.isEmpty {
                    
                    let fullnameQuery = PFUser.query()
                    fullnameQuery?.whereKey("fullname", matchesRegex: "(?i)" + self.searchBar.text!)
                    fullnameQuery?.findObjectsInBackground(block: { (objects: [PFObject]?, error: Error?) in
                        
                        if error == nil {
                            
                            // clean up
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            
                            // find related objects
                            for object in objects! {
                                self.usernameArray.append(object.value(forKey: "username") as! String)
                                self.avaArray.append(object.value(forKey: "ava") as! PFFile)
                            }
                            
                            self.tableView.reloadData()
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                }
                
                // clean up
                self.usernameArray.removeAll(keepingCapacity: false)
                self.avaArray.removeAll(keepingCapacity: false)
                
                // find related objects
                for object in objects! {
                    self.usernameArray.append(object.value(forKey: "username") as! String)
                    self.avaArray.append(object.value(forKey: "ava") as! PFFile)
                }
                
                self.tableView.reloadData()
            } else {
                print(error!.localizedDescription)
            }
        })
        
        return true
    }
    
    // tapped on the searchBar
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        // hide collectionView when started search
        collectionView.isHidden = true
        
        // show cancel button
        searchBar.showsCancelButton = true
    }
    
    // clicked cancel button
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // unhide collectionView when tapped cancel button
        collectionView.isHidden = false
        
        // dimiss keyboard
        searchBar.resignFirstResponder()
        
        // hide cancel button
        searchBar.showsCancelButton = false
        
        // reset text
        searchBar.text = ""
        
        // load shown users
        loadUsers()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! FollowersCell
        
        // hide button follow
        cell.buttonFollowing.isHidden = true
        
        // connect cell's objects with received information from server
        cell.labelUsername.text = usernameArray[indexPath.row]
        avaArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                cell.imageViewAvatar.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // calling cell again to call cell data
        let cell = tableView.cellForRow(at: indexPath) as! FollowersCell
        
        // if user tapped on his name go home, else go guest
        if cell.labelUsername.text! == PFUser.current()?.username {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.labelUsername.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "GuestVC") as! GuestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
    }
    
    // MARK: *** CollectionView
    func collectionViewLaunch() {
        
        // layout of collectionView
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        // item size
        layout.itemSize = CGSize(width: self.view.frame.size.width / 3, height: self.view.frame.size.width / 3)
        
        // direction of scrolling
        layout.scrollDirection = .vertical
        
        // define frame of collection
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - self.tabBarController!.tabBar.frame.size.height - self.navigationController!.navigationBar.frame.size.height - 20)
        
        // declare collectionView
        collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.white
        self.view.addSubview(collectionView)
        
        // define cell for collectionView
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        
        // call function to load posts
        loadPosts()
    }
    
    // cell line spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    // cell inner spacing
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return picArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        // create picture imageview in cell to show loaded pictures
        let imageViewPicture = UIImageView(frame: CGRect(x: 0, y: 0, width: cell.frame.size.width, height: cell.frame.size.height))
        cell.addSubview(imageViewPicture)
        
        // get loaded image from array
        picArray[indexPath.row].getDataInBackground { (data: Data?, error: Error?) in
            
            if error == nil {
                imageViewPicture.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // take relevant unique id of post to load post in PostVC
        postuuid.append(uuidArray[indexPath.row])
        
        // present PostVC programmatically
        let post = self.storyboard?.instantiateViewController(withIdentifier: "PostVC") as! PostVC
        self.navigationController?.pushViewController(post, animated: true)
        
    }
    
    // load posts
    func loadPosts() {
        
        let query = PFQuery(className: "posts")
        query.limit = self.page
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
            
            if error == nil {
                
                // clean up
                self.picArray.removeAll(keepingCapacity: false)
                self.uuidArray.removeAll(keepingCapacity: false)
                
                // find related objects
                for object in objects! {
                    self.picArray.append(object.value(forKey: "pic") as! PFFile)
                    self.uuidArray.append(object.value(forKey: "uuid") as! String)
                }
                
                self.collectionView.reloadData()
            } else {
                print(error!.localizedDescription)
            }
        }
    }
    
    // scrolled down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height / 6 {
            self.loadMore()
        }
    }
    
    // pagination
    func loadMore() {
        
        // if more posts are unloaded, we wanna load them
        if page <= picArray.count {
            
            // increase page size
            self.page += 15
            
            // load additional posts
            let query = PFQuery(className: "posts")
            query.limit = self.page
            query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) in
                
                if error == nil {
                    
                    // clean up
                    self.picArray.removeAll(keepingCapacity: false)
                    self.uuidArray.removeAll(keepingCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.picArray.append(object.value(forKey: "pic") as! PFFile)
                        self.uuidArray.append(object.value(forKey: "uuid") as! String)
                    }
                    
                    self.collectionView.reloadData()
                } else {
                    print(error!.localizedDescription)
                }
            }

        }
    }

}
