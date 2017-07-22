//
//  UploadVC.swift
//  Instragram
//
//  Created by Phu on 6/17/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit
import Parse

class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: *** UI Element
    @IBOutlet weak var imageViewPicture: UIImageView!
    @IBOutlet weak var textViewTitle: UITextView!
    
    @IBOutlet weak var buttonPublish: UIButton!
    @IBOutlet weak var buttonRemove: UIButton!
    
    // MARK: *** UI Event
    @IBAction func buttonPublish_Clicked(_ sender: Any) {
        
        // hide keyboard
        self.view.endEditing(true)
        
        // send data to server to "posts" class in Parse
        let object = PFObject(className: "posts")
        object["username"] = PFUser.current()!.username
        object["ava"] = PFUser.current()?.object(forKey: "ava") as! PFFile
        
        let uuid = UUID().uuidString
        object["uuid"] = "\(PFUser.current()!.username!) \(uuid)"
        
        if textViewTitle.isEmpty() {
            object["title"] = ""
        } else {
            object["title"] = textViewTitle.text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        
        // send picture to server after converting to FILE and comprassion
        let picData = UIImageJPEGRepresentation(imageViewPicture.image!, 0.5)
        let picFile = PFFile(name: "post.jpg", data: picData!)
        
        object["pic"] = picFile
        
        // send #hashtag to server
        let words: [String] = textViewTitle.text!.components(separatedBy: .whitespacesAndNewlines)
        
        // define tagged word
        for var word in words {
            
            // save #hashtag in server
            if word.hasPrefix("#") {
                
                // cut symbold
                word = word.trimmingCharacters(in: .punctuationCharacters)
                word = word.trimmingCharacters(in: .symbols)
                
                let hashtagObj = PFObject(className: "hashtags")
                hashtagObj["to"] = "\(PFUser.current()!.username!) \(uuid)"
                hashtagObj["by"] = PFUser.current()?.username
                hashtagObj["hashtag"] = word.lowercased()
                hashtagObj["comment"] = textViewTitle.text
                hashtagObj.saveInBackground(block: { (success: Bool, error: Error?) in
                    
                    if success {
                        print("hashtag \(word) is created")
                    } else {
                        print(error!.localizedDescription)
                    }
                })
            }
        }

        
        // finally save information
        object.saveInBackground { (success: Bool, error: Error?) in
            
            if error == nil {
                
                // send notification with name "uploaded"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploaded"), object: nil)
                
                // switch to another ViewController at 0 of index tabbar
                self.tabBarController?.selectedIndex = 0
                
                // reset everything
                self.viewDidLoad()
                self.textViewTitle.text = ""
            } else {
                print(error!.localizedDescription)
            }
        }
        
    }
    
    @IBAction func buttonRemove_Clicked(_ sender: Any) {
        self.viewDidLoad()
    }
    
    
    // MARK: *** UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        // disable publish button
        buttonPublish.isEnabled = false
        buttonPublish.backgroundColor = UIColor.lightGray
        
        // hidden button remove
        buttonRemove.isHidden = true
        
        // standart UI containt
        imageViewPicture.image = UIImage(named: "pbg.jpg")
        
        // hide keyboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(hidekeyboard))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // select image tap
        let picTap = UITapGestureRecognizer(target: self, action: #selector(selectImg))
        picTap.numberOfTapsRequired = 1
        imageViewPicture.isUserInteractionEnabled = true
        imageViewPicture.addGestureRecognizer(picTap)
    }
    
    // hide keyboard function
    func hidekeyboard() {
        self.view.endEditing(true)
    }
    
    // function call UIImagePickerController
    func selectImg() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    // hold selected iamge in imageViewPicture and dimiss PikcerController()
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageViewPicture.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        // enable button publish
        buttonPublish.isEnabled = true
        buttonPublish.backgroundColor = UIColor(colorLiteralRed: 52 / 255, green: 169 / 255, blue: 255 / 255, alpha: 1)
        
        // shown button remove
        buttonRemove.isHidden = false
        
        // implement second tap for zoom image
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(zoomImg))
        zoomTap.numberOfTapsRequired = 1
        imageViewPicture.isUserInteractionEnabled = true
        imageViewPicture.addGestureRecognizer(zoomTap)
    }
    
    // zooming in/out function
    func zoomImg() {
        
        let zoomed = CGRect(x: 0, y: self.view.center.y - self.view.center.x, width: self.view.frame.size.width, height: self.view.frame.size.width)
        let unzoomed = CGRect(x: 16, y: (self.navigationController?.navigationBar.frame.size.height)! + 36, width: 70, height: 70)
        
        // frame of unzoomed (small) image
        if imageViewPicture.frame == unzoomed {
            
            UIView.animate(withDuration: 0.3, animations: {
            
                self.imageViewPicture.frame = zoomed
                
                // hide object from background
                self.view.backgroundColor = UIColor.black
                self.textViewTitle.alpha = 0
                self.buttonPublish.alpha = 0
            })
        } else {
            
            UIView.animate(withDuration: 0.3, animations: {
                
                self.imageViewPicture.frame = unzoomed
                
                // shown object from background
                self.view.backgroundColor = UIColor.white
                self.textViewTitle.alpha = 1
                self.buttonPublish.alpha = 1
            })
        }
        
    }

}
