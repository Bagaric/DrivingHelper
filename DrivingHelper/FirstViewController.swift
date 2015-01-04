//
//  FirstViewController.swift
//  ProjectoPSS_IAU
//
//  Created by Claudio Silva on 26/11/14.
//  Copyright (c) 2014 Claudio Silva. All rights reserved.
//

import UIKit
import CoreMotion
import CoreLocation
import Social


class FirstViewController: UIViewController, CLLocationManagerDelegate {
    
    var toPass:String!
    
    let locationManager = CLLocationManager()
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var momentRoute: [Accelerations] = [];
    var route = Route();
    
    var listSpeed: [Double] = [];
    
    // Constants
    let motionUpdateInterval: Double = 0.2
    
    
    // Accelerometer and gyro initialization
    let motionManager = CMMotionManager()
    var startingAccX: Double = 0.0
    var startingAccY: Double = 0.0
    var startingAccZ: Double = 0.0
    var currRelativeAccX: Double = 0.0
    var currRelativeAccY: Double = 0.0
    var currRelativeAccZ: Double = 0.0
    var measuringStarted: Bool = false
    var startingPitch: Double = 0.0
    var startingRoll: Double = 0.0
    var startingYaw: Double = 0.0
    
    // Location initialization
    @IBOutlet weak var btnRoute: UIButton!
    @IBOutlet weak var roadConditionLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    var speed: CLLocationSpeed = 0.0
    var startPoint: String = "Unknown"
    var endPoint: String = "Unknown"
    
    // UI element declarations
    @IBOutlet weak var RightColor: UIImageView!
    @IBOutlet weak var LeftColor: UIImageView!
    @IBOutlet weak var BrakeColor: UIImageView!
    @IBOutlet weak var GasColor: UIImageView!
    
    
    var limitAccelerate: CGFloat = 1.0
    var limitBraking: CGFloat = 1.0
    var limitTurning: CGFloat = 1.0
    var limitRoad: CGFloat = 1.0
    
    // Variables needed to do the rating
    var accBrakingAverage: Double = 0.0
    var totalTime: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Enclosure that get the accelerometer and gyro data
        if self.motionManager.gyroAvailable && self.motionManager.accelerometerAvailable {
            let ref = CMAttitudeReferenceFrameXArbitraryZVertical
            
            motionManager.deviceMotionUpdateInterval = motionUpdateInterval
            
            motionManager.startDeviceMotionUpdatesUsingReferenceFrame(ref, toQueue: NSOperationQueue.mainQueue(), withHandler: { (devMotion, error) -> Void in
       
                if devMotion != nil {
                    self.outputMotionData(devMotion)
                }
                if (error != nil)
                {
                    println("\(error)")
                }
            })
        }
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
         limitAccelerate = CGFloat(userDefaults.floatForKey("limitAccel"))
         limitBraking = CGFloat(userDefaults.floatForKey("limitBraking"))
         limitTurning = CGFloat(userDefaults.floatForKey("limitTurning"))
         limitRoad = CGFloat(userDefaults.floatForKey("limitRoad"))
    }
    

    /*
     * Accelerometer and Gyroscope management functions
     */
    
    // Stops the accelerometer if it's already running
    func stopAccelerometer () {
        self.motionManager.stopAccelerometerUpdates()
    }
    
    
    func outputMotionData(devMot: CMDeviceMotion)
    {
        var moment: Accelerations = Accelerations()
        //moment.acc = 15
        
        if !measuringStarted {
            
            startingPitch = devMot.attitude.pitch
            startingRoll = devMot.attitude.roll
            startingYaw = devMot.attitude.yaw
            
        } else {
            
            var x = devMot.userAcceleration.x
            var y = devMot.userAcceleration.y
            var z = devMot.userAcceleration.z
            
            //println(String(format: "\nAcc \t- X: \t%.2f \t %.2f \n\t \t- Y: \t%.2f \t %.2f\n\t \t- Z: \t%.2f \t %.2f", devMot.userAcceleration.x, x, devMot.userAcceleration.y, y, devMot.userAcceleration.z, z))
            
            
            // Change arrow colors
            if x > Double(0) {
                ChangeColorRightTurn(CGFloat(x)*limitTurning)
            } else {
                ChangeColorLeftTurn(CGFloat(abs(x))*limitTurning)
            }
            
            moment.acc = z
            
            
            
            // Change car color
            if z > Double(0) {
                var braking: Double = z * Double(limitBraking)
                ChangeColorCarBrake(CGFloat(braking))
                if braking > 0.3 {
                    accBrakingAverage += braking
                }
                //moment.acc = Double(z)
            } else {
                ChangeColorCarAccelerate(CGFloat(abs(z))*limitAccelerate)
                //moment.acc = Double(z)
            }
            
            // Set up road condition limits to fit the calibration
            var reverseLimitRoad = 0.7 - limitRoad / 2.0
            
            // Road condition label set
            if devMot.userAcceleration.y > Double(reverseLimitRoad) {
                roadConditionLabel.text = "Bad"
                moment.roadCondition = "Bad"
                roadConditionLabel.textColor = UIColor.redColor()
            } else {
                roadConditionLabel.text = "Good"
                moment.roadCondition = "Good"
                roadConditionLabel.textColor = UIColor.greenColor()
            }
        }
        
        momentRoute.append(moment)
    }
    
    
    /*
     *  Interface
    
     */
    
    /*
     *  Changing colors of the interface
     */
    func ChangeColorLeftTurn(speed: CGFloat) {
        UIView.animateWithDuration(motionUpdateInterval, animations:{
            var red:CGFloat = speed * 2 * 300
            var green:CGFloat = 510 - red
            let color = UIColor(red: (red/255.0), green: (green/255.0), blue: (0/255.0), alpha: 1.0)
            self.LeftColor.backgroundColor = color})
    }
    func ChangeColorRightTurn(speed: CGFloat) {
        UIView.animateWithDuration(motionUpdateInterval, animations:{
            var red:CGFloat = speed * 2 * 300
            var green:CGFloat = 510 - red
            let color = UIColor(red: (red/255.0), green: (green/255.0), blue: (0/255.0), alpha: 1.0)
            self.RightColor.backgroundColor = color})
        
    }
    func ChangeColorCarAccelerate(speed: CGFloat) {
        UIView.animateWithDuration(motionUpdateInterval, animations:{
            var red:CGFloat = speed * 2 * 300
            var green:CGFloat = 510 - red
            let color = UIColor(red: (red/255.0), green: (green/255.0), blue: (0/255.0), alpha: 1.0)
            self.GasColor.backgroundColor = color})
        
    }
    func ChangeColorCarBrake(speed: CGFloat) {
        UIView.animateWithDuration(motionUpdateInterval, animations:{
            var red:CGFloat = speed * 2 * 300
            var green:CGFloat = 510 - red
            let color = UIColor(red: (red/255.0), green: (green/255.0), blue: (0/255.0), alpha: 1.0)
            self.BrakeColor.backgroundColor = color})
        
    }
    
    /*
     *  Location stuff
     */
    
    func detectLocation() {
        // Run the location detection
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in

            if (error != nil) {
                println("GPS failed with error: " + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let pm = placemarks[0] as CLPlacemark
                self.displayLocationInfo(pm)
            } else {
                println("Problem with the data received from geocoder.")
            }
        })
        
        var tmp = (manager.location.speed.description as NSString).doubleValue
        tmp = tmp * 3.6;
        
        listSpeed.append(tmp);
        
        speedLabel.text = String(format: "%.1f",tmp) + " km/h"
    }
    
    func displayLocationInfo(placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            var administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            var streetName = (containsPlacemark.thoroughfare != nil) ? containsPlacemark.thoroughfare : ""
            var country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            
            if startPoint == "Unknown" {
                println("Looking for starting location..")
                startPoint = "\(streetName), \(administrativeArea), \(country)"
                endPoint = "\(streetName), \(administrativeArea), \(country)"
            } else {
                println("Looking for ending location..")
                endPoint = "\(streetName), \(administrativeArea), \(country)"
            }
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location: " + error.localizedDescription)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    var stateMain = 1;
    
    @IBAction func btnStop(sender: AnyObject) {
        
        if (stateMain == 1) {
            btnRoute.setTitle("STOP ROUTE", forState: UIControlState.Normal);
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a"
            
            route.startTime = dateFormatter.stringFromDate(NSDate());
            totalTime = CFAbsoluteTimeGetCurrent()
            
            measuringStarted = true
            
            detectLocation()
            
            momentRoute.removeAll(keepCapacity: false);
            
            stateMain = 0;
            
        } else {
            
            measuringStarted = false
            
            detectLocation()

            
            var alert = UIAlertController(title: "Route complete", message: "Do you want to share?", preferredStyle: UIAlertControllerStyle.ActionSheet)
            alert.addAction(UIAlertAction(title: "Share on Twitter", style: UIAlertActionStyle.Default, handler: {(actionSheet: UIAlertAction!) in (self.Tweet())}))
            alert.addAction(UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.Default, handler: {(actionSheet: UIAlertAction!) in (self.ShareFacebook())}))
            alert.addAction(UIAlertAction(title: "See Report", style: UIAlertActionStyle.Default, handler: {(actionSheet: UIAlertAction!) in (self.performSegueWithIdentifier("segReport", sender: String(0)))}))
            alert.addAction(UIAlertAction(title: "Don't share", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            let dateTime = NSDate();
            //Code for getting the ending point

            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a"
            
            route.endTime = dateFormatter.stringFromDate(NSDate());
            route.endMoment = momentRoute;
            totalTime = CFAbsoluteTimeGetCurrent() - totalTime
            
            // Ratings
            var drivingRating = 10000 - accBrakingAverage / (totalTime / 1000)
            if drivingRating < 0 {
                drivingRating = 0.0
            }
            
            route.rating = Int(drivingRating);
            
            println("Driving rating: \(drivingRating)\nTotal time: \(totalTime)\nAcc/Braking average: \(accBrakingAverage)")

            var tmpres: Double = 0.0
            
            for x in listSpeed{
                tmpres += x;
            }
            
            if (listSpeed.count != 0){
                route.speed = Int(tmpres / Double(listSpeed.count));}
            
            btnRoute.setTitle("START ROUTE", forState: UIControlState.Normal);
            
            
            let resultRoute = ArchiveRoute().retrieveData() as [Route]
            var listRoute: [Route] = resultRoute
            
            //ArchiveRoute().saveData(nameProject: listRoute)
            
            route.rating = Int(drivingRating)
            route.startPoint = self.startPoint
            route.endPoint = self.endPoint
            
            if (listRoute[0].startTime == "")
            {
                
                //listRoute.append(route);
                listRoute.insert(route, atIndex: 0)
                listRoute.removeAtIndex(1)
                
                ArchiveRoute().saveData(nameProject: listRoute);
                
            }
            else
            {
                
                //listRoute.append(route);
                listRoute.insert(route, atIndex: 0)
                ArchiveRoute().saveData(nameProject: listRoute)
                
            }
            
            startPoint = "Unknown";
            endPoint = "Unknown";
            
            stateMain = 1;
            
            //println("Teste2: ");
            //btnRoute.setTitle(String(momentRoute.count), forState: UIControlState.Normal);
            
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //let palavra = palavraTextFiled.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString
        
        println("Teste: \(segue.identifier)");
        if (segue.identifier! == "segReport")
        {
            var targetController = segue.destinationViewController as RouteViewController
            targetController.rowList = sender == nil ? toPass : (sender as String)
        }
        else if (segue.identifier! == "segSettings")
        {
            var targetController = segue.destinationViewController as SettingsViewController
        }
        else if (segue.identifier! == "segTipsHelper")
        {
            var targetController = segue.destinationViewController as ecoModeTipsViewController
        }
        
        
    }
    
}