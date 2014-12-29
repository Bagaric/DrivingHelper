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
import Social

class SecondViewController: UIViewController, CLLocationManagerDelegate {
    
    
    let userDefaults = NSUserDefaults.standardUserDefaults();
    
    var limitGmeter: CGFloat = 1.0
    
    var listSpeed: [Double] = [];
    var listLapTimes: [String] = [];
    var listTurning: [Double] = [];
    var listBraking: [Double] = [];
    
    // Constants
    let gmeterUpdateInterval = 0.2
    // Accelerometer initialization
    let motionManager = CMMotionManager()
    
    let locationManager = CLLocationManager()
    
    var statTrack = 0;
    
    @IBOutlet weak var imgGBall: UIImageView!
    @IBOutlet weak var imgGBase: UIImageView!
    var imgBallView = UIImageView()
    var originX: CGFloat = 0
    var originY: CGFloat = 0
    var maxRadius: CGFloat = 0.0
    
    var rectangle:CGRect?
    
    @IBOutlet weak var stopwatch: UILabel!
    @IBOutlet weak var lastLapTime: UILabel!
    
    @IBOutlet weak var btnTrackDay: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    
    var startTime = NSTimeInterval()
    var timer: NSTimer = NSTimer()
    
    //start lap button
    var buttonStatus = 1
    
    @IBOutlet weak var lapButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let img = UIImage(named: "GMeterBall2")
        imgBallView = UIImageView(image: img)
        imgBallView.frame = CGRect(x: imgGBase.frame.origin.x, y: imgGBase.frame.origin.y, width: 20, height: 20)
        imgGBase.addSubview(imgBallView)
        maxRadius = self.imgGBase.frame.size.width/2.0
        imgBallView.center = CGPoint(x: self.imgGBase.bounds.size.width/2 , y: self.imgGBase.bounds.size.height/2)
        imgGBall = imgBallView

        originX = self.imgBallView.center.x
        originY = self.imgBallView.center.y
        
        println("\(imgBallView.center)")
        
        // Run the accelerometer in the background
        if self.motionManager.gyroAvailable && self.motionManager.accelerometerAvailable {
            let ref = CMAttitudeReferenceFrameXArbitraryZVertical
            
            motionManager.deviceMotionUpdateInterval = gmeterUpdateInterval
            
            motionManager.startDeviceMotionUpdatesUsingReferenceFrame(ref, toQueue: NSOperationQueue.mainQueue(), withHandler: { (devMotion, error) -> Void in
                
                if devMotion != nil{
                    self.outputAccelerationData(devMotion)
                }
                if (error != nil)
                {
                    println("\(error)")
                }
            })
        }
        
        // Run the location detection
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    override func shouldAutorotate() -> Bool {
        if (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.Unknown) {
                return false;
        }
        else {
            return true;
        }
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.sharedApplication().idleTimerDisabled = true
        
        //Loading
        limitGmeter = CGFloat(userDefaults.floatForKey("limitG"))
        
    }
    
    func stopAccelerometer () {
        self.motionManager.stopAccelerometerUpdates()
    }
    
    // Processes data taken from the accelerometer
    func outputAccelerationData(devMot: CMDeviceMotion) {
        
        listBraking.append(devMot.userAcceleration.z);
        listTurning.append(devMot.userAcceleration.x);
        
        updateGmeter((CGFloat(devMot.userAcceleration.x * 90) * limitGmeter), valueY: (CGFloat(devMot.userAcceleration.z * 90) * limitGmeter))
    }
    
    func updateGmeter(valueX: CGFloat, valueY: CGFloat){
        
        var gX = valueX
        var gY = valueY
        let gVector = sqrt(pow((valueX),2) + pow((valueY),2))
        if (gVector > maxRadius) {
            gX *= maxRadius / gVector
            gY *= maxRadius / gVector
        }
        
        var newPoint = CGPoint (x: originX + gX, y: originY + gY)
        
        /*println("Origin: \(originX) \(originY)")
        println("Point: \(newPoint.x) \(newPoint.y)")
        println("Rectangle: \(rectangle?.origin.x) \(rectangle?.origin.y)")
        println("Rectangle size: \(rectangle?.size.height) \(rectangle?.size.width)")*/
        
        UIView.animateWithDuration(gmeterUpdateInterval, animations:{
            self.imgGBall.center = newPoint
        })
    }
    
    /*
     *  Stopwatch stuff
     */
    
    @IBAction func startStopwatch(sender: AnyObject) {
        if(buttonStatus == 1){
            buttonStatus = 0
            lapButton.setTitle("Stop Lap", forState: UIControlState.Normal);
            if (!timer.valid) {
                var lastLap = stopwatch.text
                listLapTimes.append(lastLap!);
                lastLapTime.text = "Last lap: \(lastLap!)"
                let aSelector : Selector = "updateTime"
                timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: aSelector, userInfo: nil, repeats: true)
                startTime = NSDate.timeIntervalSinceReferenceDate()
            }
   
            
        }
        else{
            timer.invalidate()
            lapButton.setTitle("Start Lap", forState: UIControlState.Normal)
            buttonStatus = 1
        }
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
        
        var tmp = (manager.location.speed.description as NSString).doubleValue
        tmp = tmp * 3.6;
        
        listSpeed.append(tmp);
        
        speedLabel.text = String(format: "%.1f",tmp) + " km/h"
    }
    
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func lblTrackDay(sender: AnyObject) {

        
        if (statTrack == 0)
        {
            btnTrackDay.setTitle("Stop Trackday", forState: UIControlState.Normal)
            
            statTrack = 1;
        }
        else
        {
            
            var maxLateral: Double = 0.0;
            var maxBraking: Double = 0.0;
            var fastestLap: String = "99:99:99";
            var maxSpeed: Double = 0.0;
            
            for x in listTurning
            {
                if (maxLateral > x)
                {
                    maxLateral = abs(x);
                }
            }
            
            println("MaxLateral: \(maxLateral)");
            
            for x in listBraking
            {
                if (maxBraking > x)
                {
                    maxBraking = abs(x);
                }
            }
            
            println("MaxBraking: \(maxBraking)");
            
            if (listLapTimes.count > 0)
            {
                listLapTimes.removeAtIndex(0);
            }
            
            
            for x in listLapTimes
            {
                
                var arrLaptime = x.componentsSeparatedByString(":");
                var tmpLap = fastestLap.componentsSeparatedByString(":");
                println("Tempo: \(x)");
                println("Minutos: \(arrLaptime[0])");
                println("Segundos: \(arrLaptime[1])");
                println("Frag: \(arrLaptime[2])\n\n");
                
                if (arrLaptime[0].toInt() < tmpLap[0].toInt())
                {
                    fastestLap = x;
                } else if (arrLaptime[1].toInt() < tmpLap[1].toInt())
                {
                    fastestLap = x;
                } else if (arrLaptime[2].toInt() < tmpLap[2].toInt())
                {
                    fastestLap = x;
                }
                
                
            }
            
            for x in listSpeed
            {
                if (maxSpeed > x)
                {
                    maxSpeed = x;
                }
            }
            
            println("Top Speed: \(maxSpeed)");
            
            println ("FastestLap: \(fastestLap)");
            
            var alert = UIAlertController(title: "Share", message: "Do you want to share?", preferredStyle: UIAlertControllerStyle.ActionSheet)
            alert.addAction(UIAlertAction(title: "Twitter", style: UIAlertActionStyle.Default, handler: {(actionSheet: UIAlertAction!) in (self.Tweet())}))
            alert.addAction(UIAlertAction(title: "Facebook", style: UIAlertActionStyle.Default, handler: {(actionSheet: UIAlertAction!) in (self.ShareFacebook())}))
            alert.addAction(UIAlertAction(title: "Don't share", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            btnTrackDay.setTitle("Start Trackday", forState: UIControlState.Normal)
            
            listLapTimes.removeAll(keepCapacity: false);
            listSpeed.removeAll(keepCapacity: false);
            listTurning.removeAll(keepCapacity: false);
            listBraking.removeAll(keepCapacity: false);
            
            statTrack = 0;
        }
    
    }
    
    func Tweet()
    {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            var twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            //twitterSheet.setInitialText("Share on Twitter")
            self.presentViewController(twitterSheet, animated: true, completion: nil)
        } else {
            var alert = UIAlertController(title: "Accounts", message: "Please login to your Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func ShareFacebook()
    {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook){
            var facebookSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            //facebookSheet.setInitialText("Share on Facebook")
            self.presentViewController(facebookSheet, animated: true, completion: nil)
        } else {
            var alert = UIAlertController(title: "Accounts", message: "Please login to your Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    
}

