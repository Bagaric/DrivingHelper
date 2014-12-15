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
    
    var items: [String] = ["WeTESTE", "Heart", "Swift"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        return resultRoute.count;

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "HistoryCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as CustomCell
        
        let resultRoute = ArchiveRoute().retrieveData() as [Route];
        
        
        //let hotelName = items[indexPath.row]
        cell.lblTime.text = resultRoute[indexPath.row].endTime;
        //cell.lblKMDone.text = resultRoute[indexPath.row].startTime; //String(resultRoute.kmDone)
        //cell.lblSpeed.text = String(resultRoute[indexPath.row].speed)
        cell.lblRating.text = String(resultRoute[indexPath.row].rating)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("You selected cell #\(indexPath.row)!")
    }

    
}