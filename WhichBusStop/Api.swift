//
//  ApiViewController.swift
//  WhichBusStop
//
//  Created by Lorenzo Muscio on 03/12/2019.
//  Copyright © 2019 Leila Hadjioual. All rights reserved.
//

import UIKit
import CoreLocation

class Api {
    
    public func getStopPoint(longitude : Double, latitude : Double) {

        let position_longitude = longitude//currenocation.coordinate.longitude
        let position_latitude = latitude//currentLocation.coordinate.latitude
        
        let url = URL(string: "https://data.metromobilite.fr/api/linesNear/json?x=\(position_longitude)&y=\(position_latitude)&details=true")
                
        let session = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            do {
                if let dataResult = data {
                    do {// Decode data to object
                        let jsonDecoder = JSONDecoder()
                        let stopsResult = try jsonDecoder.decode([Stop].self, from: dataResult)
                        
                        DispatchQueue.main.async {
                        }
                    }
                    catch {
                        print("Error")
                    }
                }
                else {
                    print("No result")
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
        session.resume()
    }
}
//45,18541716   -   5,72996383 //Chavant
//45,19193413   -   5,72666532 //Jardin de ville
//45,19130205   -   5,71517336 //Gare grenoble

