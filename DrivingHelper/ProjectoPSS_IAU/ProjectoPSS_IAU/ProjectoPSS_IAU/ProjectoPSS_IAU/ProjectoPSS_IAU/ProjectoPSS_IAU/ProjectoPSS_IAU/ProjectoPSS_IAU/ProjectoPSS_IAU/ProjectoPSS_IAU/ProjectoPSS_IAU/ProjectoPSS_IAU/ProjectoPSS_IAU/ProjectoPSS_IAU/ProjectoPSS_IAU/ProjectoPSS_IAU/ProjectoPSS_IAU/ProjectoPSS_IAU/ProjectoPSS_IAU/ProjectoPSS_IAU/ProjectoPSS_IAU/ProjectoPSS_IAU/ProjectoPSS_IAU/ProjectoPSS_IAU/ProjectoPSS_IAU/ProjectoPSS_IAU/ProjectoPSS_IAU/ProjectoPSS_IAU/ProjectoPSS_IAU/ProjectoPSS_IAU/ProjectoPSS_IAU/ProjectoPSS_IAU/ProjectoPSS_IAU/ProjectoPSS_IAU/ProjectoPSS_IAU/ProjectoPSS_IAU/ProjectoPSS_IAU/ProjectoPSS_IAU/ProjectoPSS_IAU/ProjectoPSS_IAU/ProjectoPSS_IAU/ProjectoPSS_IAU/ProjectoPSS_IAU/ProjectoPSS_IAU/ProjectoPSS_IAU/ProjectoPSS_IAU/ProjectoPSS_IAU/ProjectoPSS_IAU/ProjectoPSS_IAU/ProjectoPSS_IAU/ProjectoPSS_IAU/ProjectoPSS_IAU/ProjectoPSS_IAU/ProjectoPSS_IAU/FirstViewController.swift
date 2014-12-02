//
//  FirstViewController.swift
//  ProjectoPSS_IAU
//
//  Created by Claudio Silva on 26/11/14.
//  Copyright (c) 2014 Claudio Silva. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    var x:CGFloat = 0
    
    @IBOutlet weak var RightColor: UIImageView!
    
    @IBOutlet weak var LeftColor: UIImageView!
    @IBOutlet weak var carColor: UIImageView!
    @IBOutlet weak var carroImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set image over layer
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func ChangeColor(speed:CGFloat,viewToChange:UIImageView){
        var vermelho = speed
        var verde = 255-vermelho
        let color = UIColor(red: (vermelho/255.0),green: (verde/255.0), blue: (0/255.0), alpha: 1.0)
        viewToChange.backgroundColor = color
    }
    
}