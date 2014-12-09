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

class SecondViewController: UIViewController, CLLocationManagerDelegate {
    
    
    let userDefaults = NSUserDefaults.standardUserDefaults();
    
    var limitGmeter: CGFloat = 1.0
    
    // Constants
    let gmeterUpdateInterval = 0.2
    // Accelerometer initialization
    let motionManager = CMMotionManager()
    
    let locationManager = CLLocationManager()
    
    
    
    @IBOutlet weak var imgGBall: UIImageView!
    @IBOutlet weak var imgGBase: UIImageView!
    var imgBallView = UIImageView()
    var originX: CGFloat = 0
    var originY: CGFloat = 0
    
    var rectangle:CGRect?
    
    @IBOutlet weak var stopwatch: UILabel!
    @IBOutlet weak var lastLapTime: UILabel!
    
    @IBOutlet weak var speedLabel: UILabel!
    
    var startTime = NSTimeInterval()
    var timer: NSTimer = NSTimer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.imgGBase.layer.cornerRadius = self.imgGBase.bounds.size.width / 2
        //rectangle = CGRect(origin: imgGBase.frame.origin, size: imgGBase.frame.size)
        rectangle = CGRect(x: imgGBase.frame.origin.x, y: imgGBase.frame.origin.y , width: imgGBase.frame.width, height: imgGBase.frame.height)
        
        println("RectHeight:\(rectangle?.size.height)\nRectWidth: \(rectangle?.size.width)\n OriginX: \(rectangle?.origin.x) OriginY: \(rectangle?.origin.y)")
        
        let img = UIImage(named: "GMeterBall2")
        imgBallView = UIImageView(image: img)
        imgBallView.frame = CGRect(x: imgGBase.frame.origin.x, y: imgGBase.frame.origin.y, width: 20, height: 20)
        imgGBase.addSubview(imgBallView)
        imgBallView.center = CGPoint(x: self.imgGBase.bounds.size.width/2 , y: self.imgGBase.bounds.size.height/2)
        imgGBall = imgBallView

        originX = self.imgBallView.center.x
        originY = self.imgBallView.center.y
        
        println("\(imgBallView.center)")
        
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
        
        // Run the location detection
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
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
    
    func updateGmeter(valueX: CGFloat, valueY: CGFloat){

        var newPoint = CGPoint (x: originX + valueX, y: originY + valueY)
        
        var radius = sqrt(pow((newPoint.x),2) + pow((newPoint.y),2))
        var constraintRatio = 90 / radius
        
        println("Origin: \(originX) \(originY)")
        println("Point: \(newPoint.x) \(newPoint.y)")
        println("Rectangle: \(rectangle?.origin.x) \(rectangle?.origin.y)")
        println("Rectangle size: \(rectangle?.size.height) \(rectangle?.size.width)")
        
        if !CGRectContainsPoint(rectangle!, newPoint) {
            
            println("Not contains")
            
            if radius > 90 {
                newPoint.x = newPoint.x * constraintRatio + originX
                newPoint.y = newPoint.y * constraintRatio + originY
            }
            
            UIView.animateWithDuration(gmeterUpdateInterval, animations:{
                self.imgGBall.center = newPoint
            })
        } else {
            UIView.animateWithDuration(gmeterUpdateInterval, animations:{
                
                println("Contains")
                self.imgGBall.center = newPoint
            })
        }
        
    }
    
    /*
     *  Stopwatch stuff
     */
    
    @IBAction func startStopwatch(sender: AnyObject) {
        if (!timer.valid) {
            var lastLap = stopwatch.text
            lastLapTime.text = "Last lap: \(lastLap!)"
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
        let strMinutes = minutes > 9 ? String(minutes): "0" + String(minutes)
        let strSeconds = seconds > 9 ? String(seconds): "0" + String(seconds)
        let strFraction = fraction > 9 ? String(fraction): "0" + String(fraction)
        
        //concatenate minuets, seconds and milliseconds as assign it to the UILabel
        stopwatch.text = "\(strMinutes):\(strSeconds):\(strFraction)"
        

    }
    
    
    /*
    *  Location stuff
    */
    
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        speedLabel.text = String(manager.location.speed.hashValue) + " km/h"
    }
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

