//
//  Route.swift
//  DrivingHelper
//
//  Created by formando on 12/12/14.
//  Copyright (c) 2014 Claudio Silva, Tiago Pedro, Josip Bagaric. All rights reserved.
//

import Foundation

class Route: NSObject, NSCoding
{
    
    var startTime: String = "";
    var endTime: String = "";
    
    var startPoint: String = "";
    var endPoint: String = "";
    
    var rating: Int = 0;
    var speed: Int = 0;
    var kmDone: Int = 0;
    
    var endMoment: [Accelerations] = [];
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(startTime, forKey: "startTime");
        aCoder.encodeObject(endTime, forKey: "endTime");
        
        aCoder.encodeObject(startTime, forKey: "startPoint");
        aCoder.encodeObject(endTime, forKey: "endPoint");
        
        aCoder.encodeObject(rating, forKey: "rating");
        aCoder.encodeObject(speed, forKey: "speed");
        
        aCoder.encodeObject(kmDone, forKey: "kmDone");
        aCoder.encodeObject(endMoment, forKey: "endMoment");
    }
    
    required init (coder aDecoder: NSCoder)
    {
        
        startTime = aDecoder.decodeObjectForKey("startTime") as String;
        endTime = aDecoder.decodeObjectForKey("endTime") as String;
        
        startPoint = aDecoder.decodeObjectForKey("startPoint") as String;
        endPoint = aDecoder.decodeObjectForKey("endPoint") as String;
        
        speed = aDecoder.decodeObjectForKey("speed") as Int;
        rating = aDecoder.decodeObjectForKey("rating") as Int;
        
        kmDone = aDecoder.decodeObjectForKey("kmDone") as Int;
        endMoment = aDecoder.decodeObjectForKey("endMoment") as [Accelerations];
        
    }
    
    override init()
    {
        
        
        
    }
    
}