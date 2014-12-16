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

class Matrix {
    var cols:Int, rows:Int
    var matrix:[Double]
    
    
    init(cols:Int, rows:Int) {
        self.cols = cols
        self.rows = rows
        matrix = Array(count:cols*rows, repeatedValue:0)
    }
    
    subscript(col:Int, row:Int) -> Double {
        get {
            return matrix[cols * row + col]
        }
        set {
            matrix[cols*row+col] = newValue
        }
    }
    
    func colCount() -> Int {
        return self.cols
    }
    
    func rowCount() -> Int {
        return self.rows
    }
}

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
    var currentAccX: Double = 0.0
    var currentAccY: Double = 0.0
    var currentAccZ: Double = 0.0
    var measuringStarted: Bool = false
    var accStartingMatrix: Matrix = Matrix(cols: 4, rows: 4)
    var inversedMatrix: Matrix = Matrix(cols: 3, rows: 3)
    
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

            generateInitialMatrix(accStartingMatrix)
        }
        
        if self.motionManager.gyroAvailable {
            let ref = CMAttitudeReferenceFrameXTrueNorthZVertical
            
            motionManager.gyroUpdateInterval = gyroUpdateInterval
            
            motionManager.startDeviceMotionUpdatesUsingReferenceFrame(ref, toQueue: NSOperationQueue.mainQueue(), withHandler: { (devMotion, error) -> Void in
       
                self.outputRotationData(devMotion.attitude.rotationMatrix)
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
        
        if !measuringStarted {
            
            currentAccX = acceleration.x
            currentAccY = acceleration.y
            currentAccZ = acceleration.z
            
            for i in 0...2 {
                for j in 0...2 {
                    accStartingMatrix[j,i] = inversedMatrix[j,i]
                }
            }
            
        } else {
            
            accStartingMatrix[3,0] = -(currentAccX)
            accStartingMatrix[3,1] = -(currentAccY)
            accStartingMatrix[3,2] = -(currentAccZ)
            
            var currentValuesVector = Array<Double>(count: 4, repeatedValue: 0.0)
            var resultVector = Array<Double>(count: 4, repeatedValue: 0.0)
            
            currentValuesVector[0] = acceleration.x
            currentValuesVector[1] = acceleration.y
            currentValuesVector[2] = acceleration.z
            currentValuesVector[3] = 1.0
            
            for i in 0...3 {
                var sum: Double = 0.0
                for j in 0...3 {
                    sum += accStartingMatrix[i,j] * currentValuesVector[j]
                }
                resultVector[i] = sum
            }
            
            println("Starting Matrix:")
            println("| \(accStartingMatrix[0,0]) | \(accStartingMatrix[1,0]) | \(accStartingMatrix[2,0]) | \(accStartingMatrix[3,0]) |")
            println("| \(accStartingMatrix[0,1]) | \(accStartingMatrix[1,1]) | \(accStartingMatrix[2,1]) | \(accStartingMatrix[3,1]) |")
            println("| \(accStartingMatrix[0,2]) | \(accStartingMatrix[1,2]) | \(accStartingMatrix[2,2]) | \(accStartingMatrix[3,2]) |")
            println("| \(accStartingMatrix[0,3]) | \(accStartingMatrix[1,3]) | \(accStartingMatrix[2,3]) | \(accStartingMatrix[3,3]) |")
            println("Current values vector:")
            for i in 0...(currentValuesVector.count) {
                println(currentValuesVector[i])
            }
            
            // Change arrow colors
            if acceleration.x > Double(0) {
                ChangeColorRightTurn(CGFloat(resultVector[0])*limitTurning)
            } else {
                ChangeColorLeftTurn(CGFloat(abs(resultVector[0]))*limitTurning)
            }
        
            // Change car color
            if acceleration.z > Double(0) {
                ChangeColorCarBrake(CGFloat(resultVector[2])*limitBraking)
            } else {
                ChangeColorCarAccelerate(CGFloat(abs(resultVector[2]))*limitBraking)
            }
        
            // Set up road condition limits to fit the calibration
            var reverseLimitRoad = 0.5 - Double(limitRoad)

            // Road condition label set
            if resultVector[1] > (-1.0 + reverseLimitRoad) {
                roadConditionLabel.text = "Bad"
                moment.roadCondition = "Bad";
            } else {
                roadConditionLabel.text = "Good"
                moment.roadCondition = "Good";
            }
            
            
            println("X axis: Real - \(resultVector[0]), Changed - \(acceleration.x)")
            println("Y axis: Real - \(resultVector[1]), Changed - \(acceleration.y)")
            println("Z axis: Real - \(resultVector[2]), Changed - \(acceleration.z)")
            
        }
        
        momentRoute.append(moment);
        
    }
    
    func outputRotationData(mat: CMRotationMatrix)
    {
        if !measuringStarted {
            
            self.inversedMatrix = inverseMatrix(mat)
            
        }
    }
    
    func generateInitialMatrix(matrix: Matrix) {
        
        matrix[0,0] = 1
        matrix[0,1] = 0
        matrix[0,2] = 0
        matrix[0,3] = 0
        
        matrix[1,0] = 0
        matrix[1,1] = 1
        matrix[1,2] = 0
        matrix[1,3] = 0
        
        matrix[2,0] = 0
        matrix[2,1] = 0
        matrix[2,2] = 1
        matrix[2,3] = 0
        
        matrix[3,0] = 0
        matrix[3,1] = 0
        matrix[3,2] = 0
        matrix[3,3] = 1
    }
    
    func inverseMatrix(mat: CMRotationMatrix) -> Matrix {
        
        var detMatrix = mat.m11 * mat.m22 * mat.m33 + mat.m21 * mat.m32 * mat.m13
                        + mat.m31 * mat.m12 * mat.m23 - mat.m11 * mat.m32 * mat.m23
                        - mat.m31 * mat.m22 * mat.m13 - mat.m21 * mat.m12 * mat.m33
        
        var scalar = 1 / detMatrix
        
        var inverse: Matrix = Matrix(cols: 3, rows: 3)
        
        inverse[0,0] = scalar * (mat.m22 * mat.m33 - mat.m23 * mat.m32)
        inverse[1,0] = scalar * (mat.m13 * mat.m32 - mat.m12 * mat.m33)
        inverse[2,0] = scalar * (mat.m12 * mat.m23 - mat.m13 * mat.m22)
        
        inverse[0,1] = scalar * (mat.m23 * mat.m31 - mat.m21 * mat.m33)
        inverse[1,1] = scalar * (mat.m11 * mat.m33 - mat.m13 * mat.m31)
        inverse[2,1] = scalar * (mat.m13 * mat.m21 - mat.m11 * mat.m23)
        
        inverse[0,2] = scalar * (mat.m21 * mat.m32 - mat.m22 * mat.m31)
        inverse[1,2] = scalar * (mat.m12 * mat.m31 - mat.m11 * mat.m32)
        inverse[2,2] = scalar * (mat.m11 * mat.m22 - mat.m12 * mat.m21)
        
        return inverse
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
    
    // I WILL NEED THIS CODE LATER - Josip
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
            var administrativeArea = (containsPlacemark.administrativeArea != nil) ? containsPlacemark.administrativeArea : ""
            var streetName = (containsPlacemark.thoroughfare != nil) ? containsPlacemark.thoroughfare : ""
            var country = (containsPlacemark.country != nil) ? containsPlacemark.country : ""
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

            //println("Data: \(date)")
            
            //Code for getting the initial point (Street)
            
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd 'at' h:mm a"
            
            route.startTime = dateFormatter.stringFromDate(NSDate());
            
            measuringStarted = true
            
            stateMain = 0;
        } else {
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