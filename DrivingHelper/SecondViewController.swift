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
    
    @IBOutlet weak var imgGBall: UIImageView!
    @IBOutlet weak var imgGBase: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func btnMove(sender: AnyObject) {
        
        
        imgGBall.frame.origin = CGPoint (x: imgGBase.frame.origin.x+70, y: imgGBase.frame.origin.y + 70);
        
    }
    
}

