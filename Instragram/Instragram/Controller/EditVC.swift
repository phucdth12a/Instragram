//
//  EditVC.swift
//  Instragram
//
//  Created by Phu on 6/17/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit
import Parse

class EditVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: *** UI Element
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var textFieldFullname: UITextField!
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldWeb: UITextField!
    @IBOutlet weak var textViewBio: UITextView!
    
    @IBOutlet weak var lableTitle: UILabel!
    @IBOutlet weak var textFieldGender: UITextField!
    
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldTel: UITextField!
    
    // pickerView and pickerData
    var genderPicker: UIPickerView!
    let gender = ["male", "female"]
    
    // MARK: *** UI Event
    @IBAction func buttonCancel_Clicked(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonSave_Clicked(_ sender: Any) {
    
        if !validateEmail(textFieldEmail.text!) {
            
            alert(title: "Incorrect email", message: "please provide correct email address")
        } else {
            
            if !validateWeb(textFieldWeb.text!) {
                alert(title: "Incorrect web-link", message: "please provide correct website")
            } else {
            
                let user = PFUser.current()!
                user.username = textFieldUsername.text?.lowercased()
                user.email = textFieldEmail.text?.lowercased()
                user["fullname"] = textFieldFullname.text?.lowercased()
                user["bio"] = textViewBio.text
                user["web"] = textFieldWeb.text?.lowercased()
                
                if textFieldTel.isEmpty() {
                    user["tel"] = ""
                } else {
                    user["tel"] = textFieldTel.text
                }
                
                if textFieldGender.isEmpty() {
                    user["gender"] = ""
                } else {
                    user["gender"] = textFieldGender.text
                }
                
                let avaData = UIImageJPEGRepresentation(imageViewAvatar.image!, 0.5)
                let avaFile = PFFile(name: "ava.jpg", data: avaData!)
                user["ava"] = avaFile
                
                user.saveInBackground(block: { (success: Bool, error: Error?) in
                    
                    if success {
                        
                        // hide keyboard
                        self.view.endEditing(true)
                        
                        // dimiss editVC
                        self.dismiss(animated: true, completion: nil)
                        
                        // send notification
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload"), object: nil)
                    }
                })
            }
        }
        
    }
    

    // MARK: *** UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        imageViewAvatar.layer.cornerRadius = imageViewAvatar.frame.size.width / 2
        imageViewAvatar.clipsToBounds = true
        
        textViewBio.layer.borderWidth = 1
        textViewBio.layer.borderColor = UIColor(colorLiteralRed: 230 / 255.5, green: 230 / 255.5, blue: 230 / 255.5, alpha: 1).cgColor
        textViewBio.layer.cornerRadius = 6
        textViewBio.clipsToBounds = true
        
        // Check notification if keyboard is shown or not
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        
        // Tap to hide keyboard
        let tapHide = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        tapHide.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapHide)
        
        // create picker
        genderPicker = UIPickerView()
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderPicker.backgroundColor = UIColor.groupTableViewBackground
        genderPicker.showsSelectionIndicator = true
        textFieldGender.inputView = genderPicker
        
        // tap to choose image
        let avaTap = UITapGestureRecognizer(target: self, action: #selector(loadImg(_:)))
        avaTap.numberOfTapsRequired = 1
        imageViewAvatar.isUserInteractionEnabled = true
        imageViewAvatar.addGestureRecognizer(avaTap)
        
        // call information function
        information()
    }
    
    // user information function
    func information() {
        
        // receive profile picture
        let avaFile = PFUser.current()?.object(forKey: "ava") as! PFFile
        avaFile.getDataInBackground { (data: Data?, error: Error?) in
            if error == nil {
                self.imageViewAvatar.image = UIImage(data: data!)
            } else {
                print(error!.localizedDescription)
            }
        }
        
        // receive text information
        textFieldFullname.text = PFUser.current()?.object(forKey: "fullname") as? String
        textFieldUsername.text = PFUser.current()?.username
        textFieldWeb.text = PFUser.current()?.object(forKey: "web") as? String
        textViewBio.text = PFUser.current()?.object(forKey: "bio") as? String
        textFieldEmail.text = PFUser.current()?.email
        textFieldTel.text = PFUser.current()?.object(forKey: "tel") as? String
        textFieldGender.text = PFUser.current()?.object(forKey: "gender") as? String
        
    }
    
    // func call UIImagePickerController
    func loadImg(_ recognizer: UITapGestureRecognizer) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    // method to finilize our actions with UIImagePickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imageViewAvatar.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
    // Hide keyboard fun
    func hideKeyboard(_ recognizer: UITapGestureRecognizer) {
        
        self.view.endEditing(true)
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
    
    // MARK: *** UIPickerView
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return gender.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return gender[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textFieldGender.text = gender[row]
        self.view.endEditing(true)
    }

}
