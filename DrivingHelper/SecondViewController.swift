//
//  SecondViewController.swift
//  ProjectoPSS_IAU
//
//  Created by Claudio Silva on 26/11/14.
//  Copyright (c) 2014 Claudio Silva. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion

class SecondViewController: UIViewController {
    
    
    let userDefaults = NSUserDefaults.standardUserDefaults();
    
    var limitGmeter: CGFloat = 1.0
    
    // Constants
    let gmeterUpdateInterval = 0.3
    // Accelerometer initialization
    let motionManager = CMMotionManager()
    
    @IBOutlet weak var imgGBall: UIImageView!
    @IBOutlet weak var imgGBase: UIImageView!
    var rectangle:CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.imgGBase.layer.cornerRadius = self.imgGBase.bounds.size.width/2
        rectangle = CGRect(origin: imgGBase.frame.origin, size: imgGBase.frame.size)
        
        // Check if the accelerometer is inactive and available
        if self.motionManager.accelerometerActive {
            self.stopAccelerometer()
            return
        }
        if !self.motionManager.accelerometerAvailable {
            println("No accelerometer detected.")
            return
        }
        
        // Run the accelerometer in the background
        motionManager.accelerometerUpdateInterval = gmeterUpdateInterval
        motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {(accelerometerData: CMAccelerometerData!, error:NSError!)in
            self.outputAccelerationData(accelerometerData.acceleration)
            if (error != nil) {
                println("\(error)")
            }
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        //Loading
        limitGmeter = CGFloat(userDefaults.floatForKey("limitG"))
        
    }
    
    func stopAccelerometer () {
        self.motionManager.stopAccelerometerUpdates()
    }
    
    // Processes data taken from the accelerometer
    func outputAccelerationData(acceleration:CMAcceleration) {
        updateGmeter((CGFloat(acceleration.x * 90) * limitGmeter), valueY: (CGFloat(acceleration.z * 90) * limitGmeter))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateGmeter(valueX:CGFloat, valueY:CGFloat){
        var originX = self.imgGBase.frame.origin.x+90
        var originY = self.imgGBase.frame.origin.y+90
        var newPoint = CGPoint (x: originX+valueX, y: originY+valueY)
        
        var radius = sqrt(pow((newPoint.x),2) + pow((newPoint.y),2))
        var constraintRatio = 90/radius
        
        if !CGRectContainsPoint(rectangle!,newPoint) {
            
            if radius > 90 {
                newPoint.x = newPoint.x * constraintRatio + originX
                newPoint.y = newPoint.y * constraintRatio + originY
            }
            
            UIView.animateWithDuration(gmeterUpdateInterval, animations:{
                self.imgGBall.frame.origin = newPoint
            })
        } else {
            UIView.animateWithDuration(gmeterUpdateInterval, animations:{
                self.imgGBall.frame.origin = newPoint
            })
        }
        
    }
}

