//
//  ArchiveRoute.swift
//  DrivingHelper
//
//  Created by formando on 12/12/14.
//  Copyright (c) 2014 Claudio Silva, Tiago Pedro, Josip Bagaric. All rights reserved.
//

import Foundation

class ArchiveRoute: NSObject {
    
    var documentDirectories:NSArray = []
    var documentDirectory:String = ""
    var path:String = ""
    
    func saveData(#nameProject: [Route]) {
        documentDirectories = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        documentDirectory = documentDirectories.objectAtIndex(0) as String
        path = documentDirectory.stringByAppendingPathComponent("listRoute.archive")
        
        if NSKeyedArchiver.archiveRootObject(nameProject, toFile: path) {
            println("Success writing to file!")
            println("Path: \(path)");
        } else {
            println("Unable to write to file!")
        }
    }
    
    func retrieveData() -> NSObject {
        var dataToRetrieve = [Route()]
        documentDirectories = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        documentDirectory = documentDirectories.objectAtIndex(0) as String
        path = documentDirectory.stringByAppendingPathComponent("listRoute.archive")
        if let dataToRetrieve2 = NSKeyedUnarchiver.unarchiveObjectWithFile(path) as? [Route] {
            dataToRetrieve = dataToRetrieve2 as [Route]
        }
        return(dataToRetrieve)
    }
    
}