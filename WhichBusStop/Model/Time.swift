//
//  Time.swift
//  WhichBusStop
//
//  Created by Leila Hadjioual on 11/12/2019.
//  Copyright © 2019 Leila Hadjioual. All rights reserved.
//

import Foundation

public class Time: Decodable {
    var name: String?
    var stopId: String?
    var realtimeDepart: Int?
    
    
    init(name: String, stopId: String?, realtimeDepart: Int?) {
        self.name = name
        self.stopId = stopId
        self.realtimeDepart = realtimeDepart
    }
}
