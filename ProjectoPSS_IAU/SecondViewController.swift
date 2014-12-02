//
//  SecondViewController.swift
//  ProjectoPSS_IAU
//
//  Created by Claudio Silva on 26/11/14.
//  Copyright (c) 2014 Claudio Silva. All rights reserved.
//

import UIKit
import CoreLocation

class SecondViewController: UIViewController {
    
    let gpsManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if CLLocationManager.locationServicesEnabled() {
            gpsManager.startUpdatingLocation()
        }
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            gpsManager.requestWhenInUseAuthorization()
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

