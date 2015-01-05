//
//  HistoryViewController.swift
//  DrivingHelper
//
//  Created by formando on 04/12/14.
//  Copyright (c) 2014 Claudio Silva, Tiago Pedro, Josip Bagaric. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet
    var tableView: UITableView!
    
    //var items: [String] = ["WeTESTE", "Heart", "Swift"]
    
    var toPass:String!

    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view, typically from a nib.
        
        //self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        //dispatch_async(dispatch_get_main_queue(), {
            
            
            self.tableView.reloadData()
            
            // Masquer l'icône de chargement dans la barre de status
            //UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        //})
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        if (UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight ||
            UIDevice.currentDevice().orientation == UIDeviceOrientation.Unknown) {
                return false;
        }
        else {
            return true;
        }
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientationMask.Portrait.rawValue)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let resultRoute = ArchiveRoute().retrieveData() as [Route];
        
        if (resultRoute[0].startTime == "")
        {
            
            return 0;
            
        }
        
        /*dispatch_async(dispatch_get_main_queue(), {
            
            
            self.tableView.reloadData()
            
            // Masquer l'icône de chargement dans la barre de status
            //UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })*/

        return resultRoute.count;

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "HistoryCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as CustomCell
        
        let resultRoute = ArchiveRoute().retrieveData() as [Route];
        
        //println ("Valur: \(resultRoute.count - indexPath.row - 1)")
        
        println ("\(indexPath.row)")
        
        //let hotelName = items[indexPath.row]
        cell.lblTime.text = "Date: " + resultRoute[indexPath.row].endTime
        cell.lblKMDone.text = "Kilometers: " + String(resultRoute[indexPath.row].kmDone) //String(resultRoute.kmDone)
        cell.lblSpeed.text = "Avg. Speed: " + String(resultRoute[indexPath.row].speed)
        var ratingInt = resultRoute[indexPath.row].rating
        var ratingDouble: Double = Double(ratingInt) / 100.0
        cell.lblRating.text = "Rating: \(ratingDouble) %"
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")

        toPass = String(indexPath.row);
        
        self.performSegueWithIdentifier("segList", sender: String(indexPath.row ));
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //let palavra = palavraTextFiled.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).lowercaseString
        var targetController = segue.destinationViewController as RouteViewController
        targetController.rowList = sender == nil ? toPass : (sender as String)
    }

    /*override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        if (segue.identifier == "segueTest") {
            var svc = segue!.destinationViewController as secondViewController;
            
            svc.toPass = textField.text
            
        }
    }*/
    
}