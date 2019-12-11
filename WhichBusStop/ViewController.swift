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
    let locationManager = CLLocationManager()
    let sourcePoint = CLLocationCoordinate2D(latitude: 45.191302, longitude: 5.715173) //pour tester l'itinéraire
    let regionInMeters: Double = 500

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocationServices()
        
        mapView.delegate = self
        //let sourcePoint = CLLocationCoordinate2D(latitude: 45.191302, longitude: 5.715173)
        //let destinationPoint = CLLocationCoordinate2D(latitude: 45.191587, longitude: 5.714554)
        //directionsRequest(source: sourcePoint, destination: destinationPoint)

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
    
//update the position of the user when he move and show buses points with itineraire
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
                //let place = MKPlacemark(coordinate: coordinates2D)
                //self.mapView.addAnnotation(place)
                let annotation = MKPointAnnotation()
                let stopName = stop.name
                annotation.coordinate = coordinates2D
                annotation.title = stopName
                annotation.subtitle = stop.lines?.joined(separator: ", ")
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
    

   
    //show and custom the line
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }

    
    //onclick on pine show itineraire
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKPointAnnotation {
            let destinationPoint = annotation.coordinate
            self.directionsRequest(source: self.sourcePoint, destination: destinationPoint)
            
        }
        
    }

}

