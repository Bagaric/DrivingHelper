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
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var limitAccel: Float = 0.0
    var limitBraking: Float = 0.0
    var limitTurning: Float = 0.0
    var limitRoad: Float = 0.0
    
    
    @IBAction func accelerationSlider(sender: UISlider) {
        limitAccel = sender.value
        println(limitAccel)
        
    }
    
    @IBAction func brakingSlider(sender: UISlider) {
        limitBraking = sender.value
        println(limitBraking)
    }
    
    @IBAction func turningSlider(sender: UISlider) {
        limitTurning = sender.value
        println(sender.value)
    }
    
    @IBAction func roadSlider(sender: UISlider) {
        limitRoad = sender.value
        println(limitRoad)
    }
    
    @IBOutlet weak var accelerationSliderPosition: UISlider!
    @IBOutlet weak var brakingSliderPosition: UISlider!
    @IBOutlet weak var turningSliderPosition: UISlider!
    @IBOutlet weak var roadSliderPosition: UISlider!
    
    @IBAction func cancelSettings(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func SaveSettings(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        //delegate!.viewSettingsFinish(self,limitAcel: 0.5, limitLeft: 0.2, limitRight: 0.9)
        
        
        
        //NSUserDefaults
        userDefaults.setFloat(limitAccel, forKey: "limitAccel");
        userDefaults.setFloat(limitBraking, forKey: "limitBraking");
        userDefaults.setFloat(limitTurning, forKey: "limitTurning");
        userDefaults.setFloat(limitRoad, forKey: "limitRoad");
        userDefaults.synchronize();
        
        println("Set Acceleration to: \(limitAccel)")
        println("Set Acceleration to: \(limitBraking)")
        println("Set Acceleration to: \(limitTurning)")
        println("Set Acceleration to: \(limitRoad)")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Loading
        limitAccel = userDefaults.floatForKey("limitAccel")
        limitBraking = userDefaults.floatForKey("limitBraking")
        limitTurning = userDefaults.floatForKey("limitTurning")
        limitRoad = userDefaults.floatForKey("limitRoad")
        
        accelerationSliderPosition.value = limitAccel
        brakingSliderPosition.value = limitBraking
        turningSliderPosition.value = limitTurning
        roadSliderPosition.value = limitRoad
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*if (limitAccel == 0) {
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
        }*/
        
        // Do any additional setup after loading the view.
    }

    @IBAction func resetValues(sender: UIButton) {
        limitAccel = 0.5
        limitBraking = 0.5
        limitTurning = 0.5
        limitRoad = 0.5
        
        accelerationSliderPosition.value = limitAccel
        brakingSliderPosition.value = limitBraking
        turningSliderPosition.value = limitTurning
        roadSliderPosition.value = limitRoad
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
