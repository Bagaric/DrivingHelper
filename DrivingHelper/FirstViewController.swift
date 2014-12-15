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
    
    let locationManager = CLLocationManager()
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    var momentRoute: [Accelerations] = [];
    var route = Route();
    
    
    // Constants
    let accelerometerUpdateInterval = 0.2
    let gyroUpdateInterval = 0.2
    
    
    // Accelerometer initialization
    let motionManager = CMMotionManager()
    
    @IBOutlet weak var btnRoute: UIButton!
    @IBOutlet weak var roadConditionLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    var speed: CLLocationSpeed = 0.0
    
    
    // UI element declarations
    @IBOutlet weak var RightColor: UIImageView!
    @IBOutlet weak var LeftColor: UIImageView!
    @IBOutlet weak var carColor: UIImageView!
    
    var limitAccelerate:CGFloat = 1.0
    var limitBraking:CGFloat = 1.0
    var limitTurning:CGFloat = 1.0
    var limitRoad:CGFloat = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Run the accelerometer in the background
        if self.motionManager.accelerometerAvailable {
            motionManager.accelerometerUpdateInterval = accelerometerUpdateInterval
            
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {(accelerometerData: CMAccelerometerData!, error:NSError!)in
                self.outputAccelerationData(accelerometerData.acceleration)
                if (error != nil) {
                    println("\(error)")
                }
            })
        }
        
        // Run the gyro in the background
        if self.motionManager.gyroAvailable {
            motionManager.gyroUpdateInterval = gyroUpdateInterval
            
            motionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue(), withHandler: {(gyroData: CMGyroData!, error: NSError!)in
                self.outputRotationData(gyroData.rotationRate)
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
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
    
    
    // Processes data taken from the accelerometer
    func outputAccelerationData(acceleration: CMAcceleration) {
        
        var moment: Accelerations = Accelerations();
        moment.acc = 15;
        
        // Change arrow colors
        if acceleration.x > Double(0) {
            ChangeColorRightTurn(CGFloat(acceleration.x)*limitTurning)
        } else {
            ChangeColorLeftTurn(CGFloat(abs(acceleration.x))*limitTurning)
        }
        
        // Change car color
        if acceleration.z > Double(0) {
            ChangeColorCarBrake(CGFloat(acceleration.z)*limitBraking)
        } else {
            ChangeColorCarAccelerate(CGFloat(abs(acceleration.z))*limitBraking)
        }
        
        // Set up road condition limits to fit the calibration
        var reverseLimitRoad = 0.5 - Double(limitRoad)

        // Road condition label set
        if acceleration.y > (-1.0 + reverseLimitRoad) {
            roadConditionLabel.text = "Bad"
            moment.roadCondition = "Bad";
            
        } else {
            roadConditionLabel.text = "Good"
            moment.roadCondition = "Good";
        }
        
        momentRoute.append(moment);
        
    }
    
    func outputRotationData(rotation: CMRotationRate) {
        println("Rotation X: \(rotation.x)")
        //println("Rotation Y: \(rotation.y)")
        //println("Rotation Z: \(rotation.z)")
    }
    
    
    
    /*
     *  Interface
     */
    
    @IBAction func ChangeColor(sender: AnyObject) {
        ChangeColorLeftTurn(0)
        ChangeColorCarAccelerate(0)
        ChangeColorRightTurn(0)
    }
    
    /*
     *  Changing colors of the interface
     */
    func ChangeColorLeftTurn(speed: CGFloat) {
        UIView.animateWithDuration(accelerometerUpdateInterval, animations:{
            var red:CGFloat = speed * 2 * 300
            var green:CGFloat = 510 - red
            let color = UIColor(red: (red/255.0), green: (green/255.0), blue: (0/255.0), alpha: 1.0)
            self.LeftColor.backgroundColor = color})
    }
    func ChangeColorRightTurn(speed: CGFloat) {
        UIView.animateWithDuration(accelerometerUpdateInterval, animations:{
            var red:CGFloat = speed * 2 * 300
            var green:CGFloat = 510 - red
            let color = UIColor(red: (red/255.0), green: (green/255.0), blue: (0/255.0), alpha: 1.0)
            self.RightColor.backgroundColor = color})
        
    }
    func ChangeColorCarAccelerate(speed: CGFloat) {
        UIView.animateWithDuration(accelerometerUpdateInterval, animations:{
            var red:CGFloat = speed * 2 * 300
            var green:CGFloat = 510 - red
            let color = UIColor(red: (red/255.0), green: (green/255.0), blue: (0/255.0), alpha: 1.0)
            self.carColor.backgroundColor = color})
        
    }
    func ChangeColorCarBrake(speed: CGFloat) {
        UIView.animateWithDuration(accelerometerUpdateInterval, animations:{
            var red:CGFloat = speed * 2 * 300
            var green:CGFloat = 510 - red
            let color = UIColor(red: (red/255.0), green: (green/255.0), blue: (0/255.0), alpha: 1.0)
            self.carColor.backgroundColor = color})
        
    }
    
    /*
     *  Location stuff
     */
    
    /*@IBAction func detectLocation(sender: AnyObject) {
        // Run the location detection
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }*/
    
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
        
        speedLabel.text = String(manager.location.speed.hashValue) + " km/h"
    }
    
    func displayLocationInfo(placemark: CLPlacemark?) {
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            let streetName = (containsPlacemark.thoroughfare != nil) ? containsPlacemark.thoroughfare : ""
            let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            println("County: \(administrativeArea)")
            println("Country: \(country)")
            println("Streetname: \(streetName)")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Error while updating location " + error.localizedDescription)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    var stateMain = 1;
    
    @IBAction func btnStop(sender: AnyObject) {
        
        if (stateMain == 1){
            btnRoute.setTitle("STOP", forState: UIControlState.Normal);

            //let dateTime = NSDate();
            /*let calendar = NSCalendar.currentCalendar()
            let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute , fromDate: date)
            let hour = components.hour
            let minutes = components.minute*/

            //println("Data: \(date)");
            
            //Code for getting the initial point (Street)
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a"
            
            route.startTime = dateFormatter.stringFromDate(NSDate());
            
            stateMain = 0;
        }
        else {
            var alert = UIAlertController(title: "Share", message: "Do you want to share?", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Twitter", style: UIAlertActionStyle.Default, handler: {(actionSheet: UIAlertAction!) in (self.Tweet())}))
            alert.addAction(UIAlertAction(title: "Facebook", style: UIAlertActionStyle.Default, handler: {(actionSheet: UIAlertAction!) in (self.ShareFacebook())}))
            alert.addAction(UIAlertAction(title: "Don't share", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            let dateTime = NSDate();
            //Code for getting the ending point

            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a"
            
            route.endTime = dateFormatter.stringFromDate(NSDate());
            
            route.endMoment = momentRoute;

            btnRoute.setTitle("START", forState: UIControlState.Normal);
            stateMain = 1;
            
            
            let resultRoute = ArchiveRoute().retrieveData() as [Route];
            var listRoute: [Route] = resultRoute;
            
            //ArchiveRoute().saveData(nameProject: listRoute);
            
            if (listRoute[0].startTime == "")
            {
                
                listRoute.append(route);
                listRoute.removeAtIndex(0)
                ArchiveRoute().saveData(nameProject: listRoute);
                
            }
            else
            {
                
                listRoute.append(route);
                ArchiveRoute().saveData(nameProject: listRoute);
                
            }
            
            
            
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
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Twitter account to share.", preferredStyle: UIAlertControllerStyle.Alert)
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
            var alert = UIAlertController(title: "Accounts", message: "Please login to a Facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    
}