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

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var hoursLabel: UILabel!
    
    let locationManager = CLLocationManager()
    let sourcePoint = CLLocationCoordinate2D(latitude: 45.19193413, longitude: 5.72666532) //pour tester l'itinéraire
    let regionInMeters: Double = 500
    

    let api = Api()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        
        mapView.delegate = self

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
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    
    //zoom automatically on the user's position
    //rayon : 500 m
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
    
    var myLocation: CLLocation?
    var isFirstLaunch: Bool = true
//update the position of the user when he move and show buses points with itineraire
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{return}
        self.myLocation = location
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        if isFirstLaunch {
            let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
            mapView.setRegion(region, animated:true)
            isFirstLaunch = false
        }
      
        var stopPoints: [Stop]?
        api.getStopPoint(longitude: center.longitude, latitude: center.latitude) { (stops) in
            stopPoints = stops
            
            stops?.forEach({ (stop) in
                let coordinates2D = CLLocationCoordinate2D(latitude: stop.lat!, longitude: stop.lon!)

                let stopName = stop.name
                let busName = stop.lines?.joined(separator: ", ")
                let annotation = StopAnnotation()
                annotation.id = stop.id
                annotation.coordinate = coordinates2D
                annotation.title = stopName
                annotation.subtitle = busName
                

                DispatchQueue.main.async {
//                    self.mapView.setRegion(coordinateRegion, animated: true)
                    self.mapView.addAnnotation(annotation)
                  
                }
                  
            })
        }
    }
    
    //verify differents permissions
    func locationManager(_ manager:CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus){
        checkLocationAuthorization()
    }
    
    
    //create itineraire
    func directionsRequest(source: CLLocationCoordinate2D, destination: CLLocationCoordinate2D) {
        let request = MKDirections.Request()
        
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: source, addressDictionary: nil))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination, addressDictionary: nil))
            request.requestsAlternateRoutes = true
        request.transportType = .walking

            let directions = MKDirections(request: request)

            directions.calculate { [unowned self] response, error in
                guard let unwrappedResponse = response else { return }

                for route in unwrappedResponse.routes {
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                    }
            }
        self.mapView.removeOverlays(mapView.overlays)//clear line
    }
    
    func displayTimes(_ times: [Time]) {
         bottomViewHeight.constant = 200
        var depart = ""
        var stopName = ""
        times.forEach { (time) in
            stopName = time.name!
            depart += String(describing: time.realtimeDepart)
            depart += " - "
        }
        
        hoursLabel.text = stopName + depart
          
        
      
        
    }
   
    //show and custom the line
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }

    
    //onclick on pine show itineraire and schedule bus
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let location = myLocation else{return}
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        if let annotation = view.annotation as? StopAnnotation {
            let destinationPoint = annotation.coordinate
            self.directionsRequest(source: self.sourcePoint, destination: destinationPoint)
             //schedule
             api.getTimeTable(stopId: annotation.id!) { (times) in
                self.displayTimes(times!)
            }
        }
    }
    
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        self.mapView.removeOverlays(mapView.overlays)
        bottomViewHeight.constant = 0
    }

}

