//
//  ApiViewController.swift
//  WhichBusStop
//
//  Created by Lorenzo Muscio on 03/12/2019.
//  Copyright © 2019 Leila Hadjioual. All rights reserved.
//

import UIKit
import CoreLocation

class ApiViewController: UIViewController, CLLocationManagerDelegate {
    
    private func API () {
        
        let locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        
        var currentLocation: CLLocation!

        if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() ==  .authorizedAlways){
              currentLocation = locManager.location
        }
        
        let position_longitude = 5.7289425//currenocation.coordinate.longitude
        let position_latitude = 45.1859607//currentLocation.coordinate.latitude
        
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
