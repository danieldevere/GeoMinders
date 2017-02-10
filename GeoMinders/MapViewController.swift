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
    
    var isTaggingLocation = false
    
    var locationToTag = Location()
    
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
        let placemark = MKPlacemark(coordinate: map.userLocation.coordinate, addressDictionary: nil)
        let location = Location(name: "", placemark: placemark, longitude: map.userLocation.coordinate.longitude, latitude: map.userLocation.coordinate.latitude)
        addRadiusOverlayForLocation(location, withRadius: 100)
        

        moveMap(forMapCase: .currentLocation)
    }
    
    @IBAction func segmentChanged() {
        let placemark = MKPlacemark(coordinate: locationToTag.coordinate, addressDictionary: nil)
        let location = Location(name: "", placemark: placemark, longitude: locationToTag.coordinate.longitude, latitude: locationToTag.coordinate.latitude)
        map.removeOverlays(map.overlays)
 //       removeRadiusOverlayForGeotification(location, withRadius: (Double(radiusSegmentedControl.selectedSegmentIndex) + 1) * 100.0)
        addRadiusOverlayForLocation(location, withRadius: (Double(radiusSegmentedControl.selectedSegmentIndex) + 1) * 100.0)
    //    moveMap(forMapCase: .untaggedLocations)
        println("User Location: \(map.userLocation.location.coordinate.latitude)")
        println("Tag Location: \(locationToTag.coordinate.latitude)")
        println("Tag Latitude: \(locationToTag.latitude)")
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .NotDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        map.delegate = self
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
            if let index = find(searchedLocations, annotation as! Location) {
                button.tag = index
                
            }
            return annotationView
        }
    }
    
    func chooseRadiusForTag(sender: UIButton) {
        bottomBar.hidden = false
        let button = sender as UIButton
        let location = searchedLocations[button.tag]
        searchBar.hidden = true
        locationToTag = location
        removeSearchedAnnotationsExcept(locationToTag)
     //   println("LocationToTag: \(locationToTag)")
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
        var thisLocation = Location()
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
    //    println("Count of searchedLocations: \(searchedLocations.count)")
        switch myCount {
        case 0:
            region = MKCoordinateRegionMakeWithDistance(map.userLocation.coordinate, 1000, 1000)
     //       println("User location: \(map.userLocation.coordinate.latitude)")
        case 1:
      //      println("Ran case 1")
            let location = mapLocations[mapLocations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(location.placemark!.coordinate, 1000, 1000)
        default:
      //      println("Ran default")
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
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            var circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor.purpleColor()
            circleRenderer.fillColor = UIColor.purpleColor().colorWithAlphaComponent(1.0)
            return circleRenderer
        }
        return nil
    }
    
    func addRadiusOverlayForLocation(location: Location, withRadius radius: CLLocationDistance) {
        map.removeAnnotation(location)
        map.addOverlay(MKCircle(centerCoordinate: location.coordinate, radius: radius), level: MKOverlayLevel.AboveLabels)
    }

    func removeRadiusOverlayForGeotification(location: Location, withRadius radius: CLLocationDistance) {
        // Find exactly one overlay which has the same coordinates & radius to remove
        if let overlays = map.overlays {
            for overlay in overlays {
                if let circleOverlay = overlay as? MKCircle {
                    var coord = circleOverlay.coordinate
                    if coord.latitude == location.placemark!.coordinate.latitude && coord.longitude == location.placemark!.coordinate.longitude && circleOverlay.radius == radius {
                        map.removeOverlay(circleOverlay)
                        break
                    }
                }
            }
        }
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
          //      println("Response: \(response)")
                self.searchResults = response
                self.addAnnotations()
            }
        })
    }
}
