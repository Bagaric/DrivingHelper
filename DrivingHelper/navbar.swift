//
//  navbar.swift
//  DrivingHelper
//
//  Created by Josip Bagaric on 18/12/14.
//  Copyright (c) 2014 Claudio Silva, Tiago Pedro, Josip Bagaric. All rights reserved.
//

import Foundation
import UIKit

class Navbar: UITabBarController, UIViewControllerTransitioningDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        tabBarController?.navigationController?.navigationBar.barTintColor = UIColor.grayColor()
        
    }
}