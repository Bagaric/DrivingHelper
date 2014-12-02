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

class FirstViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    let userDefaults = NSUserDefaults.standardUserDefaults();
    
    
    // Constants
    let accelerometerUpdateInterval = 0.2
    
    
    // Accelerometer initialization
    let motionManager = CMMotionManager()
    
    
    // UI element declarations
    @IBOutlet weak var RightColor: UIImageView!
    @IBOutlet weak var LeftColor: UIImageView!
    @IBOutlet weak var carColor: UIImageView!
    
    var limitAcelerate:CGFloat = 0
    var limitLeftTurn:CGFloat = 0
    var limitRightTurn:CGFloat = 0
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Reseting colors to green by default
        ChangeColorLeftTurn(0)
        ChangeColorCarAccelerate(0)
        ChangeColorRightTurn(0)
        
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
        
        motionManager.accelerometerUpdateInterval = accelerometerUpdateInterval

        
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
         limitAcelerate = CGFloat(userDefaults.floatForKey("LimitAcel"))
         limitLeftTurn =  CGFloat(userDefaults.floatForKey("LimitLeft"))
         limitRightTurn =  CGFloat(userDefaults.floatForKey("LimitRight"))
         ChangeColorCarAccelerate(limitAcelerate)
         ChangeColorLeftTurn(limitLeftTurn)
         ChangeColorRightTurn(limitRightTurn)
        
    }
    
    /*
     * Accelerometer management functions
     */
    
    // Stops the accelerometer if it's already running
    func stopAccelerometer () {
        self.motionManager.stopAccelerometerUpdates()
    }
    
    
    // Processes data taken from the accelerometer
    func outputAccelerationData(acceleration:CMAcceleration) {
        
        // Change arrow colors
        if acceleration.x > Double(0) {
            ChangeColorRightTurn(CGFloat(acceleration.x))
        }
        if acceleration.x <= Double(0) {
            ChangeColorLeftTurn(CGFloat(abs(acceleration.x)))
        }
        
        // Change car color
        if acceleration.z > Double(0) {
            ChangeColorCarBrake(CGFloat(acceleration.z))
        }
        if acceleration.z <= Double(0) {
            ChangeColorCarAccelerate(CGFloat(abs(acceleration.z)))
        }
        
    }
    
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
     *  Location detection
     */
    
    @IBAction func detectLocation(sender: AnyObject) {
        // Run the location detection
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        println("Checkpoint 1")
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: {(placemarks, error)->Void in
            
            println("Chekpoint 4")
            if (error != nil) {
                println("Reverse geocoder failed with error" + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0 {
                let pm = placemarks[0] as CLPlacemark
                self.displayLocationInfo(pm)
            } else {
                println("Problem with the data received from geocoder")
            }
        })
    }
    
    func displayLocationInfo(placemark: CLPlacemark?) {
        println("Checkpoint 2")
        if let containsPlacemark = placemark {
            //stop updating location to save battery life
            locationManager.stopUpdatingLocation()
            let locality = (containsPlacemark.locality != nil) ? containsPlacemark.locality : ""
            let postalCode = (containsPlacemark.postalCode != nil) ? containsPlacemark.postalCode : ""
            let administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            let country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
            println(locality)
            println(postalCode)
            println(administrativeArea)
            println(country)
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        println("Checkpoint 3")
        println("Error while updating location " + error.localizedDescription)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
}