//
//  TimerTips.swift
//  DrivingHelper
//
//  Created by Cláudio Silva on 11/12/14.
//  Copyright (c) 2014 Claudio Silva, Tiago Pedro, Josip Bagaric. All rights reserved.
//

import UIKit

class TimerTips: UIViewController {

    @IBAction func dismissView(sender: AnyObject) {
            self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
}