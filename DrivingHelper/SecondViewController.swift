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
        self.imgGBase.layer.cornerRadius = self.imgGBase.bounds.size.width/2
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnMove(sender: AnyObject) {
            var originX = self.imgGBase.frame.origin.x+90
            var originY = self.imgGBase.frame.origin.y+90
      
            UIView.animateWithDuration(0.5, animations:{
                self.imgGBall.frame.origin = CGPoint (x: originX+85, y: originY+30);
            })
    }
    
    func updateGmeter(valorX:CGFloat,valorY:CGFloat){
        var originX = self.imgGBase.frame.origin.x+90
        var originY = self.imgGBase.frame.origin.y+90
        
        UIView.animateWithDuration(0.5, animations:{
            self.imgGBall.frame.origin = CGPoint (x: originX+valorX, y: originY+valorY);
        })
    
    }
}

