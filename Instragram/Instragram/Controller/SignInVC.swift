//
//  SignInVC.swift
//  Instragram
//
//  Created by Phu on 6/11/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit
import Parse

class SignInVC: UIViewController, UINavigationControllerDelegate {
    
    // MARK: *** UI Element
    @IBOutlet weak var textFieldUsername: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var buttonSignIn: UIButton!
    @IBOutlet weak var buttonSignUp: UIButton!
    
    
    // MARK: *** UI Event
    @IBAction func buttonForgotPassword_Clicked(_ sender: Any) {
        
    }
    
    @IBAction func buttonSignIn_Clicked(_ sender: Any) {
        print("Sign in pressed")
        
        // Hide keyboard
        self.view.endEditing(true)
        
        // If textfileds are empty
        if textFieldUsername.isEmpty() || textFieldPassword.isEmpty() {
            
            // Alert message
            self.alert(title: "Please", message: "fill in fields")
        } else {
            
            // Login functions
            PFUser.logInWithUsername(inBackground: textFieldUsername.text!, password:   textFieldPassword.text!) { (user: PFUser?, error: Error?) in
                
                if error == nil {
                    
                    let emailVerified = user?["emailVerified"] as! Bool
                    
                    if  emailVerified == true {
                        // Remember user or save in App Memory did the user login or not
                        UserDefaults.standard.set(user!.username, forKey: "username")
                        UserDefaults.standard.synchronize()
                        
                        // Call login function from AppDelegate.swift class
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.login()
                    } else {
                        
                        // Alert message
                        self.alert(title: "Please", message: "verify email")
                    }
                } else {
                    
                    // Alert message
                    self.alert(title: "Error", message: (error!.localizedDescription))
                }
            }
        }
    }

    
    // MARK: *** UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonSignIn.layer.cornerRadius = buttonSignIn.frame.size.width / 20
        buttonSignUp.layer.cornerRadius = buttonSignUp.frame.size.width / 20
        
        // Tap to hide keyboard
        let tapHide = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard(_:)))
        tapHide.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(tapHide)
        
        // Background
        let bg = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        bg.image = UIImage(named: "bg.jpg")
        bg.layer.zPosition = -1
        self.view.addSubview(bg)
        
    }
    
    // Hide keyboard func
    func hideKeyboard(_ recognizer: UITapGestureRecognizer) {
        
        self.view.endEditing(true)
    }
    

}
