//
//  SettingsViewController.swift
//  ProjectoPSS_IAU
//
//  Created by Cláudio Silva on 01/12/14.
//  Copyright (c) 2014 Claudio Silva, Tiago Pedro, Josip Bagaric. All rights reserved.
//

import UIKit

protocol ViewSettingsControllerDelegate{
    func viewSettingsFinish(controller:SettingsViewController, limitAcel: CGFloat, limitLeft: CGFloat, limitRight: CGFloat)
}

class SettingsViewController: UIViewController {
    var delegate:ViewSettingsControllerDelegate?
    
    @IBAction func SaveSettings(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        //delegate!.viewSettingsFinish(self,limitAcel: 0.5, limitLeft: 0.2, limitRight: 0.9)
        let userDefaults = NSUserDefaults.standardUserDefaults();
        
        var limitAcel:Float = 0.3;
        var limitLeft:Float = 0.5;
        var limitRight:Float = 0.7;

        
        //NSUserDefaults
        userDefaults.setFloat(limitAcel, forKey: "LimitAcel");
        userDefaults.setFloat(limitLeft, forKey: "LimitLeft");
        userDefaults.setFloat(limitRight, forKey: "LimitRight");
        userDefaults.synchronize();
        
       
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    
    

}
