//
//  RouteViewController.swift
//  DrivingHelper
//
//  Created by formando on 15/12/14.
//  Copyright (c) 2014 Claudio Silva, Tiago Pedro, Josip Bagaric. All rights reserved.
//

import UIKit

class RouteViewController: UIViewController {

    var rowList:Int!;
    @IBOutlet weak var lblTeste: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblTeste.text = String(rowList);
        
        //rowList = toPass;

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}
