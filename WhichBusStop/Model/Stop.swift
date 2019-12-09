//
//  Stop.swift
//  WhichBusStop
//
//  Created by Lorenzo Muscio on 03/12/2019.
//  Copyright © 2019 Leila Hadjioual. All rights reserved.
//

import Foundation

public class Stop: Decodable {
    var name: String?
    var lines: [String]?
    var lon: Double?
    var lat: Double?
    
    init(name: String, lon: Double, lat: Double?, lines: [String]) {
        self.name = name
        self.lines = lines
        self.lon = lon
        self.lat = lat
    }
}
