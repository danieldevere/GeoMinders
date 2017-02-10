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
    
    var locations = [Location]()
    
    var searchedLocations = [Location]()
    
    var toggleTaggedAnnotationsButtonSelected = false
    
    enum moveMapCases: Int {
        case currentLocation = 0
        case untaggedLocations = 1
        case taggedLocations = 2
    }
    
    @IBOutlet weak var toggleTaggedAnnotationsButton: UIBarButtonItem!
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var bottomBar: UIView!
    
    @IBOutlet weak var radiusSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
     @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func toggleTaggedAnnotations() {
        toggleTaggedAnnotationsButtonSelected = !toggleTaggedAnnotationsButtonSelected
        stateForToggleButton()
    }
    
    @IBAction func currentLocationButton() {
        
        moveMap(forMapCase: .currentLocation)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .NotDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        bottomBar.hidden = true
        stateForToggleButton()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        } else if let annotation = mapView.dequeueReusableAnnotationViewWithIdentifier("Pin") as? MKPinAnnotationView {
            return annotation
        } else {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView.canShowCallout = true
            annotationView.enabled = true
            annotationView.animatesDrop = true
            let annotationButton = UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton
            annotationButton.addTarget(self, action: Selector("chooseRadiusForTag:"), forControlEvents: .TouchUpInside)
            annotationView.rightCalloutAccessoryView = annotationButton
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            if let index = find(locations, annotation as! Location) {
                button.tag = index
            }
            return annotationView
        }
    }
    
    func chooseRadiusForTag(sender: UIButton) {
        bottomBar.hidden = false
        let button = sender as UIButton
        let location = locations[button.tag]
        searchBar.hidden = true
        
      //  removeSearchedAnnotationsExcept(location)
        moveMap(forMapCase: .untaggedLocations)
    }
    
    func addAnnotations() {
        if searchedLocations.count > 0 {
            removeAnnotationsForLocations(searchedLocations)
        }
        for mapItem in searchResults.mapItems as! [MKMapItem]{
            let location = Location(name: "", placemark: mapItem.placemark, longitude: mapItem.placemark.coordinate.longitude, latitude: mapItem.placemark.coordinate.latitude)
            searchedLocations.append(location)
            map.addAnnotation(location)
        }
        moveMap(forMapCase: .untaggedLocations)
        
    }
    
    func addTaggedLocationAnnotations() {
        map.addAnnotations(locations)
    }
    
    func removeSearchedAnnotationsExcept(chosenLocation: Location) {
        for location in searchedLocations {
            if location != chosenLocation {
                map.removeAnnotation(location)
            }
        }
    }
    
    func removeAnnotationsForLocations(locations: [Location]) {
        for location in locations {
            map.removeAnnotation(location)
        }
    }
    
    func toggleSavedLocationAnnotations() {
        
    }
    
    func stateForToggleButton() {
        if toggleTaggedAnnotationsButtonSelected {
            toggleTaggedAnnotationsButton.title = "Hide Tags"
        } else {
            toggleTaggedAnnotationsButton.title = "Show Tags"
        }

    }
    
    func moveMap(forMapCase mapCase: moveMapCases) {
        var myCount: Int
        var mapLocations = searchedLocations
        switch mapCase {
        case .currentLocation:
            myCount = 0
        case .untaggedLocations:
            myCount = searchedLocations.count
            mapLocations = searchedLocations
        case .taggedLocations:
            myCount = locations.count
            mapLocations = locations
        }
        var region: MKCoordinateRegion
        println("Count of searchedLocations: \(searchedLocations.count)")
        switch myCount {
        case 0:
            region = MKCoordinateRegionMakeWithDistance(map.userLocation.coordinate, 1000, 1000)
            println("User location: \(map.userLocation.coordinate.latitude)")
        case 1:
            println("Ran case 1")
            let location = mapLocations[mapLocations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(location.placemark!.coordinate, 1000, 1000)
        default:
            println("Ran default")
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            for location in mapLocations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, location.placemark!.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, location.placemark!.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, location.placemark!.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, location.placemark!.coordinate.longitude)
            }
            let center = CLLocationCoordinate2D(latitude: topLeftCoord.latitude - (topLeftCoord.latitude  - bottomRightCoord.latitude) / 2, longitude: topLeftCoord.longitude - (topLeftCoord.longitude - bottomRightCoord.longitude) / 2)
            let extraSpace = 1.1
            let span = MKCoordinateSpan(latitudeDelta: abs(topLeftCoord.latitude - bottomRightCoord.latitude) * extraSpace, longitudeDelta: abs(topLeftCoord.longitude - bottomRightCoord.longitude) * extraSpace)
            region = MKCoordinateRegion(center: center, span: span)
        }
        let regionThatFits = map.regionThatFits(region)
        map.setRegion(regionThatFits, animated: true)
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