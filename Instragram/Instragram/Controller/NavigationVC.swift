//
//  NavigationVC.swift
//  Instragram
//
//  Created by Phu on 6/18/17.
//  Copyright © 2017 Phu. All rights reserved.
//

import UIKit

class NavigationVC: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // color of the title at the top
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        // color of butons in nav controller
        self.navigationBar.tintColor = UIColor.white
        
        // color of background of nav controller
        self.navigationBar.barTintColor = UIColor(colorLiteralRed: 18 / 255, green: 86 / 255, blue: 136 / 255, alpha: 1)
        
        // unable translucent
        self.navigationBar.isTranslucent = false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

}
