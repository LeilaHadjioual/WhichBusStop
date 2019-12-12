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
    
    public func getStopPoint(longitude : Double, latitude : Double, completion: @escaping ([Stop]?) -> Void) {

        let position_longitude = longitude//currenocation.coordinate.longitude
        let position_latitude = latitude//currentLocation.coordinate.latitude
        
        let url = URL(string: "https://data.metromobilite.fr/api/linesNear/json?x=\(position_longitude)&y=\(position_latitude)&dist=800&details=true")
                
        let session = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            do {
                if let dataResult = data {
                    do {// Decode data to object
                        let jsonDecoder = JSONDecoder()
                        let stopsResult = try jsonDecoder.decode([Stop].self, from: dataResult)
                        completion(stopsResult)
                        
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
    
    public func getTimeTable(stopId: String, completion: @escaping ([Time]?) -> Void) {
           let url = URL(string: "http://data.metromobilite.fr/api/routers/default/index/clusters/SEM\(stopId)/stoptimes")
        
        let session = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                  do {
                      if let dataResult = data {
                          do {// Decode data to object
                              let jsonDecoder = JSONDecoder()
                              let timeTableResult = try jsonDecoder.decode([Time].self, from: dataResult)
                              completion(timeTableResult)
                              
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
//45,14217067   -   5,74115298 //La casa

