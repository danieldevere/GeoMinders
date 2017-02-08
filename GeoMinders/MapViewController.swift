//
//  MapViewController.swift
//  GeoMinders
//
//  Created by DANIEL DE VERE on 2/8/17.
//  Copyright (c) 2017 DANIEL DE VERE. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    
    var searchResults = MKLocalSearchResponse()
    
    @IBOutlet weak var map: MKMapView!
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .NotDetermined {
            locationManager.requestAlwaysAuthorization()
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if let annotation = mapView.dequeueReusableAnnotationViewWithIdentifier("Pin") as? MKPinAnnotationView {
            return annotation
        } else {
            let annotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            return annotation
        }
    }
    
    func addAnnotations() {
        let point = MKPointAnnotation()
        let mapItem = searchResults.mapItems[0] as! MKMapItem
        let placemark = mapItem.placemark
        point.coordinate.latitude = placemark.coordinate.latitude
        point.coordinate.longitude = placemark.coordinate.longitude
        
        let pin = MKPinAnnotationView(annotation: point, reuseIdentifier: "Pin")
        map.addAnnotation(point)
        
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        let query = MKLocalSearchRequest()
        query.naturalLanguageQuery = searchBar.text
        let search = MKLocalSearch(request: query)
        search.startWithCompletionHandler({
            response, error in
            if let error = error {
                println("Error: \(error)")
            } else {
                println("Response: \(response)")
                self.searchResults = response
                self.addAnnotations()
            }
        })
    }
}