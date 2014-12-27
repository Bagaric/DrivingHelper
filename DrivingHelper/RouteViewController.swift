//
//  RouteViewController.swift
//  DrivingHelper
//
//  Created by formando on 15/12/14.
//  Copyright (c) 2014 Claudio Silva, Tiago Pedro, Josip Bagaric. All rights reserved.
//

import UIKit
import Social

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
    
    
    @IBOutlet weak var lblMaxAcceleration: UILabel!
    @IBOutlet weak var lblMaxBraking: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //lblTeste.text = rowList;
        
        //rowList = toPass;

        // Do any additional setup after loading the view.
        
        let resultRoute = ArchiveRoute().retrieveData() as [Route];
        
        
        
        var index = rowList.toInt()!;
        
        //var mtz = resultRoute[index].endMoment;
        
        lblStartTime.text = resultRoute[index].startTime;
        lblEndTime.text = resultRoute[index].endTime;
        
        lblStartPoint.text = resultRoute[index].startPoint;
        lblEndPoint.text = resultRoute[index].endPoint;
        
        lblKMDone.text = String(resultRoute[index].kmDone);
        lblAVGSpeed.text = String(resultRoute[index].speed);
        
        var resAvg = AverageValue(resultRoute[index]);
        var maxValues = MaxValue(resultRoute[index]);
        
        lblAcceleration.text = String(format: "%.2f",resAvg.0);
        lblMaxAcceleration.text = String(format: "%.2f",maxValues.0);
        
        lblBraking.text = String(format: "%.2f",resAvg.1);
        lblMaxBraking.text = String(format: "%.2f",maxValues.1);
        
        
        //lblAcceleration.text = String(resultRoute[index].endMoment.count)
        
    }

    func AverageValue(r:Route)->(Double, Double){
        var resultBrk: Double = 0
        var resultAcc: Double = 0
        var countAcc: Int = 0;
        var countBrk: Int = 0;
        
        for x in r.endMoment
        {
            if (x.acc > Double(0))
            {
                resultBrk += Double(x.acc);
                countBrk++;
            }
            else
            {
                resultAcc += Double(x.acc);
                countAcc++;
            }
        }
        
        resultBrk = resultBrk / Double(countBrk);
        resultAcc = resultAcc / Double(countAcc);
        
        return (abs(resultAcc),resultBrk);
    }
    
    func MaxValue(r:Route)->(Double, Double){
        var maxBrk: Double = 0
        var maxAcc: Double = 0
        
        for x in r.endMoment
        {
            if (x.acc > Double(0))
            {
                if (x.acc > maxBrk)
                {
                    maxBrk = x.acc;
                }
            }
            else
            {
                if (abs(x.acc) > abs(maxAcc))
                {
                    maxAcc = abs(x.acc);
                }
            }
        }

        
        return (abs(maxAcc),maxBrk);
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
    
    @IBAction func itmDeleteRoute(sender: AnyObject) {
        
        var resultRoute = ArchiveRoute().retrieveData() as [Route];
        var index = rowList.toInt()!;
        
        println("Valor: \(index)")
        
        self.dismissViewControllerAnimated(true, completion: nil);
        
        //resultRoute.removeAtIndex(index);
        
        
    }
    
    @IBAction func Tweet(sender: AnyObject) {
        
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
    
    @IBAction func ShareFacebook(sender: AnyObject) {
        
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
