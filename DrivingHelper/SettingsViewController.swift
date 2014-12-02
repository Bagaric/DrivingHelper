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

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var delegate:ViewSettingsControllerDelegate?
    
    var limitAccel: Float
    var limitBraking: Float
    var limitTurning: Float
    var limitRoad: Float
    
    
    @IBAction func accelerationSlider(sender: UISlider) {
        var currentValue = Int(sender.value)
        println(sender.value)
        
        
    }
    
    @IBAction func brakingSlider(sender: UISlider) {
        var currentValue = Int(sender.value)
        println(sender.value)
    }
    
    @IBAction func turningSlider(sender: UISlider) {
        var currentValue = Int(sender.value)
        println(sender.value)
        
    }
    
    @IBAction func roadSlider(sender: UISlider) {
        var currentValue = Int(sender.value)
        println(sender.value)
        
    }
    
    @IBAction func SaveSettings(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        //delegate!.viewSettingsFinish(self,limitAcel: 0.5, limitLeft: 0.2, limitRight: 0.9)
        let userDefaults = NSUserDefaults.standardUserDefaults();
        
        

        
        //NSUserDefaults
        userDefaults.setFloat(limitAccel, forKey: "limitAccel");
        userDefaults.setFloat(limitBraking, forKey: "limitBraking");
        userDefaults.setFloat(limitTurning, forKey: "limitTurning");
        userDefaults.setFloat(limitRoad, forKey: "limitRoad");
        userDefaults.synchronize();
        
       
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (limitAccel == 0) {
            limitAccel = 1.0
        }
        if (limitBraking == 0) {
            limitBraking = 1.0
        }
        if (limitTurning == 0) {
            limitTurning = 1.0
        }
        if (limitRoad == 0) {
            limitRoad = 1.0
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
