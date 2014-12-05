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
    
    @IBOutlet weak var stopwatch: UILabel!
    @IBOutlet weak var lastLapTime: UILabel!
    
    var startTime = NSTimeInterval()
    var timer: NSTimer = NSTimer()
    
    
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
    
    /*
     *  Stopwatch stuff
     */
    
    @IBAction func startStopwatch(sender: AnyObject) {
        if (!timer.valid) {
            let aSelector : Selector = "updateTime"
            timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
            startTime = NSDate.timeIntervalSinceReferenceDate()
        }
    }
    
    @IBAction func stopStopwatch(sender: AnyObject) {
        timer.invalidate()
    }
    
    func updateTime() {
        var currentTime = NSDate.timeIntervalSinceReferenceDate()
        
        //Find the difference between current time and start time.
        var elapsedTime: NSTimeInterval = currentTime - startTime
        
        //calculate the minutes in elapsed time.
        let minutes = UInt8(elapsedTime / 60.0)
        elapsedTime -= (NSTimeInterval(minutes) * 60)
        
        //calculate the seconds in elapsed time.
        let seconds = UInt8(elapsedTime)
        elapsedTime -= NSTimeInterval(seconds)
        
        //find out the fraction of milliseconds to be displayed.
        let fraction = UInt8(elapsedTime * 100)
        
        //add the leading zero for minutes, seconds and millseconds and store them as string constants
        let strMinutes = minutes > 9 ? String(minutes):"0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds):"0" + String(seconds)
        let strFraction = fraction > 9 ? String(fraction):"0" + String(fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        stopwatch.text = "\(strMinutes):\(strSeconds):\(strFraction)"
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

