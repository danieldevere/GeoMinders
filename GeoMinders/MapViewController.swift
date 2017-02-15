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

protocol MapViewControllerDelegate: class {
    func mapViewControllerDidExit(controller: MapViewController)
}

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    

    
    var locations = [Location]()
    
    var searchedLocations = [Location]()
    
    var toggleTaggedAnnotationsButtonSelected = false
    
    var locationToTag = Location()
    
    var overlay: MKOverlay?
    
    enum moveMapCases: Int {
        case currentLocation = 0
        case untaggedLocations = 1
        case taggedLocations = 2
    }
    
    @IBOutlet weak var toggleTaggedAnnotationsButton: UIBarButtonItem!
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var bottomBar: UIView!
    
    @IBOutlet weak var radiusSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var delegate: MapViewControllerDelegate?
    
    
    
    @IBAction func currentLocationButton() {

        

        moveMap(forMapCase: .currentLocation)
    }
    
    @IBAction func segmentChanged() {
        let placemark = MKPlacemark(coordinate: locationToTag.coordinate, addressDictionary: nil)
        let location = Location(name: "", placemark: placemark, longitude: locationToTag.coordinate.longitude, latitude: locationToTag.coordinate.latitude)
        map.removeOverlays(map.overlays)
        addRadiusOverlayForLocation(location, withRadius: (Double(radiusSegmentedControl.selectedSegmentIndex) + 1) * 100.0)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .NotDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        map.delegate = self
        regularView()
    }
    
    override func viewDidAppear(animated: Bool) {
        stateForToggleButton()
     //   println("Locations array: \(locations)")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "TagLocation" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.topViewController as! TagLocationViewController
            controller.taggedLocation = locationToTag
            controller.delegate = self
        }
    }
    
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if annotation.isKindOfClass(MKUserLocation) {
            return nil
        } else if let annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier("Pin") as? MKPinAnnotationView {
            let annotationButton = UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton
            annotationButton.addTarget(self, action: Selector("chooseRadiusForTag:"), forControlEvents: .TouchUpInside)
            annotationView.rightCalloutAccessoryView = annotationButton
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            var index = 0

            for i in 0...searchedLocations.count-1 {
                //  println("Annotation is: \(annotation.title) Location is: \(searchedLocations[i].title) Index is: \(i)")
                if (annotation.coordinate.latitude == searchedLocations[i].coordinate.latitude) && (annotation.coordinate.longitude == searchedLocations[i].coordinate.longitude) && (annotation.title == searchedLocations[i].title) {
                    index = i
                    //  annotationView.tag = i
                    button.tag = i
               //     println("***Picked Annotation is: \(annotation.title) Location is: \(searchedLocations[i].title) Index is: \(i)")
                    break
                }
            }

        //    println("Dequed Annotation is: \(annotation.title) Location is: \(searchedLocations[annotationView.rightCalloutAccessoryView.tag].title) Index is: \(annotationView.rightCalloutAccessoryView.tag)")
            return annotationView
        } else {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView.canShowCallout = true
            annotationView.enabled = true
            annotationView.animatesDrop = true
            let annotationButton = UIButton.buttonWithType(UIButtonType.ContactAdd) as! UIButton
            annotationButton.addTarget(self, action: Selector("chooseRadiusForTag:"), forControlEvents: .TouchUpInside)
            annotationView.rightCalloutAccessoryView = annotationButton
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            var index = 0
            for i in 0...searchedLocations.count-1 {
              //  println("Annotation is: \(annotation.title) Location is: \(searchedLocations[i].title) Index is: \(i)")
                if (annotation.coordinate.latitude == searchedLocations[i].coordinate.latitude) && (annotation.coordinate.longitude == searchedLocations[i].coordinate.longitude) && (annotation.title == searchedLocations[i].title) {
                    index = i
                  //  annotationView.tag = i
                    button.tag = i
            //        println("***Picked Annotation is: \(annotation.title) Location is: \(searchedLocations[i].title) Index is: \(i)")
                    break
                }
            }
          //  button.tag = index
            return annotationView
        }
    }
    
    func regularView() {
        bottomBar.hidden = true
        searchBar.hidden = false
        cancelButton.title = "Back"
        cancelButton.action = Selector("cancel")
        cancelButton.target = self
        stateForToggleButton()
        toggleTaggedAnnotationsButton.action = Selector("toggleTaggedAnnotations")
        toggleTaggedAnnotationsButton.target = self
    }
    
    func taggingLocationView() {
        bottomBar.hidden = false
        searchBar.hidden = false
        cancelButton.action = Selector("tagCancelButtonPressed")
        cancelButton.target = self
        toggleTaggedAnnotationsButton.title = "Tag"
        toggleTaggedAnnotationsButton.action = Selector("tagButtonPressed")
        toggleTaggedAnnotationsButton.target = self
        
    }
    
    func cancel() {
        delegate?.mapViewControllerDidExit(self)
    }
    
    func toggleTaggedAnnotations() {
        if toggleTaggedAnnotationsButtonSelected {
            removeAnnotationsForLocations(locations)
        } else {
            addAnnotations(locations)
            moveMap(forMapCase: .taggedLocations)
        }
        toggleTaggedAnnotationsButtonSelected = !toggleTaggedAnnotationsButtonSelected
        stateForToggleButton()
    }

    
    
    func tagButtonPressed() {
        locationToTag.radius = (Double(radiusSegmentedControl.selectedSegmentIndex) + 1) * 100
        performSegueWithIdentifier("TagLocation", sender: nil)
    }
    
    func tagCancelButtonPressed() {
        regularView()
        locationToTag = Location()
        moveMap(forMapCase: .untaggedLocations)
        map.removeOverlay(overlay)
        for annotation in map.annotations {
         //   let annotationView = map.viewForAnnotation(annotation as! MKAnnotation)
         //   println("Annotation is: \(annotation.title) Tag is: \(annotationView.rightCalloutAccessoryView.tag)")
        }
        
    //    println("Annotations: \(map.annotations)")
    }
    
    func stateForToggleButton() {
        if toggleTaggedAnnotationsButtonSelected {
            toggleTaggedAnnotationsButton.title = "Hide Tags"
        } else {
            toggleTaggedAnnotationsButton.title = "Show Tags"
        }
        
    }


    
    func chooseRadiusForTag(sender: UIButton) {
        taggingLocationView()
        let button = sender
        let location = searchedLocations[button.tag]
   //     println("Plus symbol press. Location is: \(location.name) Index is: \(button.tag)")
        locationToTag = location
        radiusSegmentedControl.selectedSegmentIndex = 0
        addRadiusOverlayForLocation(location, withRadius: (Double(radiusSegmentedControl.selectedSegmentIndex) + 1) * 100.0)
        moveMapToLocation(locationToTag)
    }
    
    func addAnnotations(theseLocations: [Location]) {
        if theseLocations.count > 0 {
            removeAnnotationsForLocations(theseLocations)
        }
        map.addAnnotations(theseLocations)
    }
    
    func removeAnnotationsForLocations(locations: [Location]) {
        if locations.count > 0 {
            map.removeAnnotations(locations)
        }
    }
    
    
    func moveMapToLocation(location: Location) {
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
        let regionThatFits = map.regionThatFits(region)
        map.setRegion(regionThatFits, animated: true)
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
        switch myCount {
        case 0:
            region = MKCoordinateRegionMakeWithDistance(map.userLocation.coordinate, 1000, 1000)
        case 1:
            let location = mapLocations[mapLocations.count - 1]
            region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
        default:
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            for location in mapLocations {
                topLeftCoord.latitude = max(topLeftCoord.latitude, location.coordinate.latitude)
                topLeftCoord.longitude = min(topLeftCoord.longitude, location.coordinate.longitude)
                bottomRightCoord.latitude = min(bottomRightCoord.latitude, location.coordinate.latitude)
                bottomRightCoord.longitude = max(bottomRightCoord.longitude, location.coordinate.longitude)
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
            circleRenderer.fillColor = UIColor.purpleColor().colorWithAlphaComponent(0.4)
            return circleRenderer
        }
        return nil
    }
    
    func addRadiusOverlayForLocation(location: Location, withRadius radius: CLLocationDistance) {
        overlay = MKCircle(centerCoordinate: location.coordinate, radius: radius)
        map.addOverlay(overlay)
    }

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
                for mapItem in response.mapItems as! [MKMapItem] {
                    let location = Location(name: mapItem.placemark.name, placemark: mapItem.placemark, longitude: mapItem.placemark.coordinate.longitude, latitude: mapItem.placemark.coordinate.latitude)
                    self.searchedLocations.append(location)
                }
                self.addAnnotations(self.searchedLocations)
                self.moveMap(forMapCase: .untaggedLocations)
                searchBar.resignFirstResponder()
            }
        })
    }
}

extension MapViewController: TagLocationViewControllerDelegate {
    func tagLocationViewControllerDidGoBack(controller: TagLocationViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tagLocationViewController(controller: TagLocationViewController, didSaveTag tag: Location) {
        locations.append(tag)

        dismissViewControllerAnimated(true, completion: nil)
        delegate?.mapViewControllerDidExit(self)
    }
}
