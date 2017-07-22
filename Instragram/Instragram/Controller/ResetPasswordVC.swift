//
//  ResetPasswordVC.swift
//  Instragram
//
//  Created by Phu on 6/13/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit
import Parse

class ResetPasswordVC: UIViewController {
    
    // MARK: *** UI Element
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var buttonReset: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    
    // MARK: *** UI Event
    @IBAction func buttonReset_Clicked(_ sender: Any) {
        
        // Hide keyboard
        self.view.endEditing(true)
        
        // Email textfield empty
        if textFieldEmail.isEmpty() {
            
            // Alert message
            alert(title: "Email field", message: "is empty")
        }
        
        PFUser.requestPasswordResetForEmail(inBackground: textFieldEmail.text!, block: { (success, error) in
            
            if success {
                
                // Alert message
                self.alert(title: "Email for reseting password", message: "has been sent to texted email")
            } else {
                print(error!)
            }
        })
        
    }
    
    @IBAction func buttonCancel_Clicked(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    

    // MARK: *** UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttonReset.layer.cornerRadius = buttonReset.frame.size.width / 20
        buttonCancel.layer.cornerRadius = buttonCancel.frame.size.width / 20

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
