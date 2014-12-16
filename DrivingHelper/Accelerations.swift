//
//  Accelerations.swift
//  DrivingHelper
//
//  Created by formando on 12/12/14.
//  Copyright (c) 2014 Claudio Silva, Tiago Pedro, Josip Bagaric. All rights reserved.
//

import Foundation

class Accelerations: NSObject, NSCoding
{
    
    var acc: Double = 0;
    var roadCondition: String = "";
    var currentSpeed: Double = 0;
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(acc, forKey: "acc");
        aCoder.encodeObject(roadCondition, forKey: "roadCondition");
        aCoder.encodeObject(currentSpeed, forKey: "currentSpeed");
        
    }
    
    required init (coder aDecoder: NSCoder)
    {
        
        acc = aDecoder.decodeObjectForKey("acc") as Double;
        roadCondition = aDecoder.decodeObjectForKey("roadCondition") as String;
        currentSpeed = aDecoder.decodeObjectForKey("currentSpeed") as Double;
        
        
    }
    
    override init()
    {
        
        
        
    }
    
}