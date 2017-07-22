//
//  UIExtension.swift
//  Instragram
//
//  Created by Phu on 6/11/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // Shown notification simple
    func alert(title: String, message: String) {
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Shown notification and action after
    func alert(title: String, message: String, handler: @escaping (UIAlertAction) -> Void ) {
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: handler)
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // Thêm nút Done để ẩn đi bàn phím
    func addDoneButton(to control: UITextField){
        
        let toolbar = UIToolbar()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: control,
                            action: #selector(UITextField.resignFirstResponder))
        ]
        
        toolbar.sizeToFit()
        control.inputAccessoryView = toolbar
    }
    
    func addDoneButton(_ textview: UITextView){
        
        let toolbar = UIToolbar()
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: textview,
                            action: #selector(UITextField.resignFirstResponder))
        ]
        
        toolbar.sizeToFit()
        textview.inputAccessoryView = toolbar
    }
    
    func addDoneButton(tos controls: [UITextField]){
        
        for control in controls {
            let toolbar = UIToolbar()
            toolbar.items = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
                UIBarButtonItem(title: "Done", style: .done, target: control,
                                action: #selector(UITextField.resignFirstResponder))
            ]
            
            toolbar.sizeToFit()
            control.inputAccessoryView = toolbar
        }
    }
    
    // regax restriction of email textField
    func validateEmail(_ email: String) -> Bool {
        let regax = "[A-Z0-9a-z._%+-]{4}+@[A-Za-z0-9.-]+\\.[A-Za-z]{2}"
        let range = email.range(of: regax, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }
    
    // regax restriction for web textField
    func validateWeb(_ web: String) -> Bool {
        let regax = "www.+[A-Z0-9a-z._%+-]+.[A-Za-z]{2}"
        let range = web.range(of: regax, options: .regularExpression)
        let result = range != nil ? true : false
        return result
    }

}

extension UITextField {
    func isEmpty() -> Bool {
        return self.text?.characters.count == 0
    }
}

extension UITextView {
    func isEmpty() -> Bool {
        return self.text?.characters.count == 0
    }
}

