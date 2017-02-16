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
    func mapViewControllerDidExit(_ controller: MapViewController)
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
        if authStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        map.delegate = self
        regularView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        stateForToggleButton()
     //   println("Locations array: \(locations)")

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! TagLocationViewController
            controller.taggedLocation = locationToTag
            controller.delegate = self
        }
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        } else if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin") as? MKPinAnnotationView {
            let annotationButton = UIButton(type: UIButtonType.contactAdd)
            annotationButton.addTarget(self, action: #selector(MapViewController.chooseRadiusForTag(_:)), for: .touchUpInside)
            annotationView.rightCalloutAccessoryView = annotationButton
            let button = annotationView.rightCalloutAccessoryView as! UIButton


            for (arrayIndex, _) in searchedLocations.enumerated() {
                //  println("Annotation is: \(annotation.title) Location is: \(searchedLocations[i].title) Index is: \(i)")
                if (annotation.coordinate.latitude == searchedLocations[arrayIndex].coordinate.latitude) && (annotation.coordinate.longitude == searchedLocations[arrayIndex].coordinate.longitude) {
                    //  annotationView.tag = i
                    button.tag = arrayIndex
               //     println("***Picked Annotation is: \(annotation.title) Location is: \(searchedLocations[i].title) Index is: \(i)")
                    break
                }
            }

        //    println("Dequed Annotation is: \(annotation.title) Location is: \(searchedLocations[annotationView.rightCalloutAccessoryView.tag].title) Index is: \(annotationView.rightCalloutAccessoryView.tag)")
            return annotationView
        } else {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView.canShowCallout = true
            annotationView.isEnabled = true
            annotationView.animatesDrop = true
            let annotationButton = UIButton(type: UIButtonType.contactAdd)
            annotationButton.addTarget(self, action: #selector(MapViewController.chooseRadiusForTag(_:)), for: .touchUpInside)
            annotationView.rightCalloutAccessoryView = annotationButton
            let button = annotationView.rightCalloutAccessoryView as! UIButton
            for i in 0...searchedLocations.count-1 {
              //  println("Annotation is: \(annotation.title) Location is: \(searchedLocations[i].title) Index is: \(i)")
                if (annotation.coordinate.latitude == searchedLocations[i].coordinate.latitude) && (annotation.coordinate.longitude == searchedLocations[i].coordinate.longitude) {
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
        bottomBar.isHidden = true
        searchBar.isHidden = false
        cancelButton.title = "Back"
        cancelButton.action = #selector(MapViewController.cancel)
        cancelButton.target = self
        stateForToggleButton()
        toggleTaggedAnnotationsButton.action = #selector(MapViewController.toggleTaggedAnnotations)
        toggleTaggedAnnotationsButton.target = self
    }
    
    func taggingLocationView() {
        bottomBar.isHidden = false
        searchBar.isHidden = false
        cancelButton.action = #selector(MapViewController.tagCancelButtonPressed)
        cancelButton.target = self
        toggleTaggedAnnotationsButton.title = "Tag"
        toggleTaggedAnnotationsButton.action = #selector(MapViewController.tagButtonPressed)
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
        performSegue(withIdentifier: "TagLocation", sender: nil)
    }
    
    func tagCancelButtonPressed() {
        regularView()
        locationToTag = Location()
        moveMap(forMapCase: .untaggedLocations)
        map.remove(overlay!)
     //   for annotation in map.annotations {
         //   let annotationView = map.viewForAnnotation(annotation as! MKAnnotation)
         //   println("Annotation is: \(annotation.title) Tag is: \(annotationView.rightCalloutAccessoryView.tag)")
    //    }
        
    //    println("Annotations: \(map.annotations)")
    }
    
    func stateForToggleButton() {
        if toggleTaggedAnnotationsButtonSelected {
            toggleTaggedAnnotationsButton.title = "Hide Tags"
        } else {
            toggleTaggedAnnotationsButton.title = "Show Tags"
        }
        
    }


    
    func chooseRadiusForTag(_ sender: UIButton) {
        taggingLocationView()
        let button = sender
        let location = searchedLocations[button.tag]
   //     println("Plus symbol press. Location is: \(location.name) Index is: \(button.tag)")
        locationToTag = location
        radiusSegmentedControl.selectedSegmentIndex = 0
        addRadiusOverlayForLocation(location, withRadius: (Double(radiusSegmentedControl.selectedSegmentIndex) + 1) * 100.0)
        moveMapToLocation(locationToTag)
    }
    
    func addAnnotations(_ theseLocations: [Location]) {
        if theseLocations.count > 0 {
            removeAnnotationsForLocations(theseLocations)
        }
        map.addAnnotations(theseLocations)
    }
    
    func removeAnnotationsForLocations(_ locations: [Location]) {
        if locations.count > 0 {
            map.removeAnnotations(locations)
        }
    }
    
    
    func moveMapToLocation(_ location: Location) {
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)
        let regionThatFits = map.regionThatFits(region)
        map.setRegion(regionThatFits, animated: true)
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.lineWidth = 1.0
            circleRenderer.strokeColor = UIColor.purple
            circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
            return circleRenderer
        }
        return MKOverlayRenderer()
    }
    
    func addRadiusOverlayForLocation(_ location: Location, withRadius radius: CLLocationDistance) {
        overlay = MKCircle(center: location.coordinate, radius: radius)
        map.add(overlay!)
    }

}

extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let query = MKLocalSearchRequest()
        query.naturalLanguageQuery = searchBar.text
        let search = MKLocalSearch(request: query)
        search.start(completionHandler: {
            response, error in
            if let error = error {
                print("Error: \(error)")
            } else {
                for mapItem in (response?.mapItems)! as [MKMapItem] {
                    let location = Location(name: mapItem.placemark.name!, placemark: mapItem.placemark, longitude: mapItem.placemark.coordinate.longitude, latitude: mapItem.placemark.coordinate.latitude)
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
    func tagLocationViewControllerDidGoBack(_ controller: TagLocationViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    func tagLocationViewController(_ controller: TagLocationViewController, didSaveTag tag: Location) {
        locations.append(tag)

        dismiss(animated: true, completion: nil)
        delegate?.mapViewControllerDidExit(self)
    }
}
