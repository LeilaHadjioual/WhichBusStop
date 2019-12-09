//
//  ViewController.swift
//  WhichBusStop
//
//  Created by Leila Hadjioual on 03/12/2019.
//  Copyright © 2019 Leila Hadjioual. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Contacts

class ViewController: UIViewController, CLLocationManagerDelegate{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    let locationManager = CLLocationManager()
    let regionInMeters: Double = 500
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        
        // Agrandir zone blanche en bas
        bottomViewHeight.constant = 0
       
    }
    
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message,preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func setUpLocationManager(){
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    
    //zoom automatically on the user's position
    //rayon : 10000 m
    func centerViewOnUserLocation(){
        if let location = locationManager.location?.coordinate{
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region,animated: true)
        }
    }
    
    //check if the authorization services is ok
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled(){
            setUpLocationManager()
            checkLocationAuthorization()
        }else{
            showAlert(title: "Alerte", message: "Vous devez autoriser la localisation GPS pour utiliser l'application")
        }
    }
    
    //authorize the app launch
    func checkLocationAuthorization(){
        switch CLLocationManager.authorizationStatus(){
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            locationManager.startUpdatingLocation()
        case .denied:
            showAlert(title: "Alerte", message: "Vous devez autoriser la localisation GPS pour utiliser l'application")
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .restricted:
            showAlert(title: "Alerte", message: "Vous devez autoriser la localisation GPS pour utiliser l'application")
            break
        case .authorizedAlways:
            break
            
        }
    }
    
//update the position of the user when he move
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        mapView.setRegion(region, animated:true)
        let api = Api()
        var stopPoints: [Stop]?
        api.getStopPoint(longitude: center.longitude, latitude: center.latitude) { (stops) in
            stopPoints = stops
            
            stops?.forEach({ (stop) in
                let coordinates2D = CLLocationCoordinate2D(latitude: stop.lat!, longitude: stop.lon!)
                let stopName = stop.name
                let busName = stop.lines?.joined(separator: ", ")
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = coordinates2D
                annotation.title = stopName
                annotation.subtitle = busName
                let coordinateRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)

                DispatchQueue.main.async {
                    self.mapView.setRegion(coordinateRegion, animated: true)
                    self.mapView.addAnnotation(annotation)
                }
            })
        }
    }
    
    //verify differents permissions
    func locationManager(_ manager:CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        checkLocationAuthorization()
    }
}

