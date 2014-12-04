//
//  Locate.swift
//  DrivingHelper
//
//  Created by Josip Bagaric on 04/12/14.
//  Copyright (c) 2014 Claudio Silva, Tiago Pedro, Josip Bagaric. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

@objc protocol LocateDelegate : NSObjectProtocol {
    
    optional func locateRecordedLocation(locate: Locate, location: CLLocation)
    optional func locateAuthorized(locate: Locate, authorized: Bool)
}

@objc class Locate : NSObject, CLLocationManagerDelegate {
    
    class var shared : Locate {
        struct Static {
            static let instance : Locate = Locate()
        }
        return Static.instance
    }
    
    lazy var locationManager:CLLocationManager = {
        var manager = CLLocationManager()
        manager.delegate = self
        manager.activityType = .Fitness
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.disallowDeferredLocationUpdates()
        
        return manager;
        }()
    
    var desiredAccuracy = 20.0
    var delegate: LocateDelegate?
    
    var recordingInProgress = false
    var recordedLocations : [CLLocation] = []
    var recordedCoordinates : [CLLocationCoordinate2D] = []
    var recordedDistance : CLLocationDistance = 0.0
    var recordStartedAt : NSDate?
    var recordedTime : NSTimeInterval = 0.0
    var recordedSpeed : CLLocationSpeed = 0.0
    
    var defersLocationUpdates = false
    
    var nLocations:Int {
        return self.recordedLocations.count
    }
    
    //    var isAuthorized:Bool {
    //        return (self.locationManager.authorizationStatus() ==
    //    }
    
    // Location Manager helper stuff
    func start() {
        self.reset()
        self.locationManager.requestAlwaysAuthorization()
        self.recordingInProgress = true
        self.locationManager.startUpdatingLocation()
    }
    
    func stop() {
        self.recordingInProgress = false
        self.locationManager.stopUpdatingLocation()
        self.defersLocationUpdates = false
        self.locationManager.disallowDeferredLocationUpdates()
    }
    
    func reset() {
        self.recordedLocations = []
        self.recordedCoordinates = []
        self.recordedDistance = 0.0
        self.recordedTime = 0.0
        self.recordedSpeed = 0.0
        self.recordStartedAt = nil
    }
    
    // Location Manager Delegate stuff
    // If failed
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        locationManager.stopUpdatingLocation()
        println("Location: Error getting location")
    }
    // if success
    // Assumptions: locations is an array, locationObj is a CLLocation
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        if !self.recordingInProgress {
            return
        }
        
        for location in locations as [CLLocation] {
            
            //NSLog("incoming location \(location)")
            if location.horizontalAccuracy > self.desiredAccuracy {
                //NSLog("Bad accuracy for \(location)")
                continue
            }
            
            if !(self.recordStartedAt != nil) {
                self.recordStartedAt = location.timestamp
            }
            self.recordedTime = NSDate().timeIntervalSinceDate(self.recordStartedAt!)
            
            // First, calculate distance
            if self.recordedCoordinates.count > 0 {
                self.recordedDistance += location.distanceFromLocation(self.recordedLocations.last)
            }
            
            if (self.recordedCoordinates.count > 1 && self.recordedDistance > 0 && self.recordedTime > 0) {
                self.recordedSpeed = self.recordedDistance / self.recordedTime
            }
            
            // Then add a new location to array
            self.recordedLocations.append(location)
            self.recordedCoordinates.append(location.coordinate)
            
            delegate?.locateRecordedLocation!(self, location: location)
        }
        
        if (!self.defersLocationUpdates && CLLocationManager.deferredLocationUpdatesAvailable()) {
            self.defersLocationUpdates = true
            locationManager.allowDeferredLocationUpdatesUntilTraveled(100000, timeout: 10000)
        }
    }
    
    var isAuthorized:Bool {
        let enabled = CLLocationManager.locationServicesEnabled()
        let status = CLLocationManager.authorizationStatus()
        NSLog("Enabled: \(enabled), status: \(status)")
        
        return locationManagerIsAuthorized(status)
    }
    
    func locationManagerIsAuthorized(status: CLAuthorizationStatus) -> Bool {
        switch status {
        case .Restricted:
            return false
        case .Denied:
            return false
        case .NotDetermined:
            return false
        default:
            return true
        }
    }
    
    // authorization status
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if locationManagerIsAuthorized(status) {
            delegate?.locateAuthorized!(self, authorized: true)
            locationManager.startUpdatingLocation()
        } else {
            delegate?.locateAuthorized!(self, authorized: false)
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFinishDeferredUpdatesWithError error: NSError!) {
        //NSLog("Deferred locations error: \(error)")
        self.defersLocationUpdates = false
    }

}