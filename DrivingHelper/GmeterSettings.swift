//
//  GmeterSettings.swift
//  DrivingHelper
//
//  Created by Cláudio Silva on 04/12/14.
//  Copyright (c) 2014 Claudio Silva, Tiago Pedro, Josip Bagaric. All rights reserved.
//

import UIKit


class GmeterSettings: UIViewController {
    
    var limitG:Float=0
    let userDefaults = NSUserDefaults.standardUserDefaults()

    
    @IBOutlet weak var sliderG: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func CancelSettings(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func SaveSettings(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    
        //NSUserDefaults
        userDefaults.setFloat(limitG, forKey: "limitG");
      
        userDefaults.synchronize();
    }
                                           
    @IBAction func defaultValues(sender: AnyObject) {
        limitG = 0.5
        sliderG.value = limitG
    }
    
    @IBAction func getSlideValue(sender: AnyObject) {
        limitG = sliderG.value
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Loading
        limitG = userDefaults.floatForKey("limitG")
        sliderG.value = limitG
        
    }
    
    
}