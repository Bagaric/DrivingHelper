//
//  RouteViewController.swift
//  DrivingHelper
//
//  Created by formando on 15/12/14.
//  Copyright (c) 2014 Claudio Silva, Tiago Pedro, Josip Bagaric. All rights reserved.
//

import UIKit

class RouteViewController: UIViewController {

    var rowList:String!;

    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    
    @IBOutlet weak var lblStartPoint: UILabel!
    @IBOutlet weak var lblEndPoint: UILabel!
    
    @IBOutlet weak var lblKMDone: UILabel!
    @IBOutlet weak var lblAVGSpeed: UILabel!
    
    @IBOutlet weak var lblAcceleration: UILabel!
    @IBOutlet weak var lblBraking: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //lblTeste.text = rowList;
        
        //rowList = toPass;

        // Do any additional setup after loading the view.
        
        let resultRoute = ArchiveRoute().retrieveData() as [Route];
        
        var index = rowList.toInt()!;
        
        lblStartTime.text = resultRoute[index].startTime;
        lblEndTime.text = resultRoute[index].endTime;
        
        lblStartPoint.text = resultRoute[index].startPoint;
        lblEndPoint.text = resultRoute[index].endPoint;
        
        lblKMDone.text = String(resultRoute[index].kmDone);
        lblAVGSpeed.text = String(resultRoute[index].speed);
        
        lblAcceleration.text = String(resultRoute[index].endMoment.count)
        
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
    
    @IBAction func itmDismissView(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil);
        
    }
    

}
