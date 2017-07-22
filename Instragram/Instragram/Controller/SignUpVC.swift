//
//  SignUpVC.swift
//  Instragram
//
//  Created by Phu on 6/11/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit
import Parse

class SignUpVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: *** UI Element
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldRepeatPassword: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldFullname: UITextField!
    @IBOutlet weak var textFieldBio: UITextField!
    @IBOutlet weak var textFieldWeb: UITextField!
    @IBOutlet weak var buttonSignUp: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!

    
    // MARK: *** UI Event
    @IBAction func buttonSignUp_Clicked(_ sender: Any) {
        print("sign up pressed")
        
        // Dimiss keyboard
        self.view.endEditing(true)
        
        // If fields are empty
        if textFieldUsername.isEmpty() || textFieldPassword.isEmpty() || textFieldRepeatPassword.isEmpty() || textFieldEmail.isEmpty() || textFieldFullname.isEmpty() || textFieldBio.isEmpty() || textFieldWeb.isEmpty() {
            
            // Alert message
            alert(title: "PLEASE", message: "fill all fields")
        } else {
            
            // If different passwords
            if textFieldPassword.text! != textFieldRepeatPassword.text! {
                
                // Alert message
                alert(title: "PASSWORD", message: "do not match")
            } else {
                
                // Send data to server to related collumns
                let user = PFUser()
                user.username = textFieldUsername.text?.lowercased()
                user.email = textFieldEmail.text?.lowercased()
                user.password = textFieldPassword.text
                user["fullname"] = textFieldFullname.text?.lowercased()
                user["bio"] = textFieldBio.text
                user["web"] = textFieldWeb.text?.lowercased()
                
                // In Edit Profile it's gonna be assigned
                user["tel"] = ""
                user["gender"] = ""
                
                // Convert our image for sending to server
                let avaData = UIImageJPEGRepresentation(imageViewAvatar.image!, 0.5)
                let avaFile = PFFile(name: "ava.jpg", data: avaData!)
                user["ava"] = avaFile
                
                // Save data in server
                user.signUpInBackground { (success: Bool, error: Error?) in
                    
                    if success {
                        
                        self.alert(title: "Successfully", message: "please verify email", handler: { (UIAlertAction) in
                            
                            self.dismiss(animated: true, completion: nil)
                        })
                        
                    } else {
                        
                        // Alert message
                        self.alert(title: "Error", message: (error!.localizedDescription))
                    }
                }
            }
        }
    }
    
    @IBAction func buttonCancel_Clicked(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    // MARK: *** UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonSignUp.layer.cornerRadius = buttonSignUp.frame.size.width / 20
        buttonCancel.layer.cornerRadius = buttonCancel.frame.size.width / 20
        
        // Check notification if keyboard is shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
        // Avatar roud
        imageViewAvatar.layer.cornerRadius = imageViewAvatar.frame.size.width / 2
        imageViewAvatar.clipsToBounds = true
        
        // Declare select image tap
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(loadImg(_:)))
        avaTap.numberOfTapsRequired = 1
        imageViewAvatar.isUserInteractionEnabled = true
        imageViewAvatar.addGestureRecognizer(avaTap)
        
        // Tap to hide keyboard
        let tapHide = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        tapHide.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapHide)
        
        // Background
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.mainView.addSubview(bg)
    }
    
    // Hide keyboard fun
    func hideKeyboard(_ recognizer: UITapGestureRecognizer) {
        
        self.view.endEditing(true)
    }
    
    // Call picker to select image
    func loadImg(_ recognizer: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    // Connect selected image to our ImageView
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageViewAvatar.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }

    func keyboardWillShow(_ notification: Notification) {
    
        // Get info keyboard
        var info = notification.userInfo!
        var keyboardFrame: CGRect = (info[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)

        // Change content inset scroll
        var contentInset: UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = contentInset
    }
    
    func keyboardWillHide(_ notification: Notification) {
    
        // Change content inset scrill
        let contentInset: UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
        self.scrollView.scrollIndicatorInsets = contentInset
        
    }

}
