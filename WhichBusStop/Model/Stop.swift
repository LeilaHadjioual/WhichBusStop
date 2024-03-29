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
    var id: String?
    
    init(name: String, lines: [String], lon: Double, lat: Double?, id: String?) {

        self.name = name
        self.lines = lines
        self.lon = lon
        self.lat = lat
        self.id = id
    }
}
