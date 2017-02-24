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
    func mapViewController(_ controller: MapViewController, didTagLocation location: Location)
}

class MapViewController: UIViewController, MKMapViewDelegate {
    
    let locationManager = CLLocationManager()
    
    var editingLocation = false
    
    var taggingLocation = false

    
    var locations = [Location]()
    
    var searchedLocations: [Location]?
    
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
    
    @IBOutlet weak var currentLocation: UIButton!
    
    @IBOutlet weak var searchSpinner: UIActivityIndicatorView!
    
    var delegate: MapViewControllerDelegate?
    
    
    
    @IBAction func currentLocationButton() {

        

        moveMap(forMapCase: .currentLocation)
    }
    
    @IBAction func segmentChanged() {
        map.removeOverlays(map.overlays)
        addRadiusOverlayForLocation(locationToTag, withRadius: (Double(radiusSegmentedControl.selectedSegmentIndex) + 1) * 100.0 * 0.3048)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        searchSpinner.isHidden = true
        if locations.count >= 20 {
            let alertController = UIAlertController(title: "Too Many Locations", message: "Apple only allows us to track up to 20 locations.  You will need to delete a location before adding a new one.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: {
                _ in
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        }
        currentLocation.isEnabled = false
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        map.delegate = self
        regularView()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.dismissKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        if editingLocation{
            currentLocation.isHidden = true
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            cancelButton.title = "< Back"
            cancelButton.action = #selector(MapViewController.cancel)
            self.title = locations[0].name
            addRadiusOverlayForLocation(locations[0], withRadius: locations[0].radius)
            toggleTaggedAnnotations()
            self.title = "This Location"
            

        }
        let pinGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addAnnotationOnTap))
        pinGestureRecognizer.cancelsTouchesInView = false
        pinGestureRecognizer.delegate = self
        view.addGestureRecognizer(pinGestureRecognizer)
        map.isRotateEnabled = false
        if !editingLocation {
            toggleTaggedAnnotationsButton.isEnabled = true
        }
        
    }
    
    func stringFromCLPlacemark(placemark: CLPlacemark) -> String {
        var string = ""
        if let subthoroughfare = placemark.subThoroughfare {
            string.append("\(subthoroughfare) ")
        }
        if let thoroughfare = placemark.thoroughfare {
            string.append("\(thoroughfare)\n")
        }
        if let locality = placemark.locality {
            string.append("\(locality), ")
        }
        if let administrativeArea = placemark.administrativeArea {
            string.append("\(administrativeArea) ")
        }
        if let postalCode = placemark.postalCode {
            string.append("\(postalCode)")
        }
        if string.isEmpty {
            return "(No address found)"
        } else {
            return string
        }
    }
    
    func addAnnotationOnTap(gesture: UIGestureRecognizer) {
        if toggleTaggedAnnotationsButtonSelected {
            let alertController = UIAlertController(title: "Cannot add pin", message: "You cannot tap to add a pin while showing your saved locations.  Press Hide Saved to add a pin", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        } else {
            if gesture.state == UIGestureRecognizerState.began {
                let touchPoint = gesture.location(in: map)
                let locationCoordinate = map.convert(touchPoint, toCoordinateFrom: map)
                var locationName = ""
                var locationPlacemark = CLPlacemark()
                var location = Location()
                let geocodeLocation = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
                CLGeocoder().reverseGeocodeLocation(geocodeLocation, completionHandler: {
                    placemarks, error in
                    if error != nil {
                        print("Reverse Geocode failed. Error: \(error)")
                    } else {
                        if let placemark = placemarks {
                            if placemark.count > 0 {
                                let pm = placemark[0]
                                if let pmName = pm.name {
                                    locationName = pmName
                                }
                                locationPlacemark = pm
                                location = Location(name: locationName, address: self.stringFromCLPlacemark(placemark: locationPlacemark), addressName: locationName, longitude: locationCoordinate.longitude, latitude: locationCoordinate.latitude)
                            }
                        }
                        if (self.currentLocation.isEnabled && self.map.annotations.count > 1) || (!self.currentLocation.isEnabled && self.map.annotations.count > 0) {
                            self.map.removeAnnotations(self.map.annotations)
                        }
                        self.searchedLocations = [location]
                        self.addAnnotations(self.searchedLocations!)
                        self.map.selectAnnotation(self.searchedLocations![0], animated: true)
                    }
                })
            }

        }
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
            print("viewforannotation elseif")
            if !toggleTaggedAnnotationsButtonSelected && !editingLocation {
                let annotationButton = UIButton(type: UIButtonType.contactAdd)
                annotationButton.addTarget(self, action: #selector(MapViewController.chooseRadiusForTag(_:)), for: .touchUpInside)
                annotationView.rightCalloutAccessoryView = annotationButton
                let button = annotationView.rightCalloutAccessoryView as! UIButton
                
                
                for (arrayIndex, _) in (searchedLocations?.enumerated())! {
                    if (annotation.coordinate.latitude == searchedLocations?[arrayIndex].latitude) && (annotation.coordinate.longitude == searchedLocations?[arrayIndex].longitude) {
                        button.tag = arrayIndex
                        break
                    }
                }

            }
            return annotationView
        } else {
            print("Viewforannotation else")
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView.canShowCallout = true
            annotationView.isEnabled = true
            annotationView.animatesDrop = true
            print("three lines down")
            if !toggleTaggedAnnotationsButtonSelected && !editingLocation {
                print("this shouldn't run")
                let annotationButton = UIButton(type: UIButtonType.contactAdd)
                annotationButton.addTarget(self, action: #selector(MapViewController.chooseRadiusForTag(_:)), for: .touchUpInside)
                annotationView.rightCalloutAccessoryView = annotationButton
                let button = annotationView.rightCalloutAccessoryView as! UIButton
                print("just before for loop")
                for (index, _) in (searchedLocations?.enumerated())! {
                    print("for loop")
                    if (annotation.coordinate.latitude == searchedLocations?[index].latitude) && (annotation.coordinate.longitude == searchedLocations?[index].longitude) {
                        button.tag = index
                        break
                    }
                }

            }
            print("before return")
                      //  button.tag = index
            return annotationView
        }
    }
    
    func regularView() {
        taggingLocation = false
        bottomBar.isHidden = true
        searchBar.isHidden = false
        cancelButton.title = "< Back"
        cancelButton.action = #selector(MapViewController.cancel)
        cancelButton.target = self
        stateForToggleButton()
        toggleTaggedAnnotationsButton.action = #selector(MapViewController.toggleTaggedAnnotations)
        toggleTaggedAnnotationsButton.target = self
        toggleTaggedAnnotationsButton.style = .plain
        if currentLocation.isEnabled {
            toggleTaggedAnnotationsButton.isEnabled = true
        } else {
            toggleTaggedAnnotationsButton.isEnabled = false
        }
    }
    
    func taggingLocationView() {
        taggingLocation = true
        self.title = "Choose Size"
        bottomBar.isHidden = false
        searchBar.isHidden = true
        cancelButton.action = #selector(MapViewController.tagCancelButtonPressed)
        cancelButton.target = self
        cancelButton.title = "< Search"
        toggleTaggedAnnotationsButton.title = "Save"
        toggleTaggedAnnotationsButton.style = .done
        toggleTaggedAnnotationsButton.action = #selector(MapViewController.tagButtonPressed)
        toggleTaggedAnnotationsButton.target = self
        toggleTaggedAnnotationsButton.isEnabled = true
        
    }
    
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func toggleTaggedAnnotations() {
        if toggleTaggedAnnotationsButtonSelected {
            toggleTaggedAnnotationsButtonSelected = false
            removeAnnotationsForLocations(locations)
            if let theseLocations = searchedLocations {
                addAnnotations(theseLocations)
            }
            searchBar.isHidden = false
            if currentLocation.isEnabled {
                moveMapToDefaultView()
            }
            
            
            
        } else {
            toggleTaggedAnnotationsButtonSelected = true
            if let theseLocations = searchedLocations {
                removeAnnotationsForLocations(theseLocations)
            }
            searchBar.isHidden = true
            addAnnotations(locations)
            moveMap(forMapCase: .taggedLocations)
            
        }
        stateForToggleButton()
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !currentLocation.isEnabled {
            if editingLocation {
                currentLocation.isEnabled = true
            //    toggleTaggedAnnotationsButton.isEnabled = false
                print("Editing Location")
                
            } else {
                currentLocation.isEnabled = true
                moveMapToDefaultView()
            }
            
        }
        
    }
    

    
    
    func tagButtonPressed() {
        locationToTag.radius = ((Double(radiusSegmentedControl.selectedSegmentIndex) + 1) * 100) * 0.3048
        performSegue(withIdentifier: "TagLocation", sender: nil)
    }
    
    func tagCancelButtonPressed() {
        regularView()
        addAnnotationsExcept(locationToTag)
        let annotationView = map.view(for: locationToTag)
        annotationView?.rightCalloutAccessoryView?.isHidden = false
        locationToTag = Location()
        moveMap(forMapCase: .untaggedLocations)
        title = "Tap a Pin"
        map.remove(overlay!)
    }
    
    func stateForToggleButton() {
        if !editingLocation {
            if toggleTaggedAnnotationsButtonSelected {
                toggleTaggedAnnotationsButton.title = "Hide Saved"
            } else {
                toggleTaggedAnnotationsButton.title = "Show Saved"
            }
        }
    }


    
    func chooseRadiusForTag(_ sender: UIButton) {
        taggingLocationView()
        let button = sender
        let location = searchedLocations?[button.tag]
        button.isHidden = true
        removeAnnotationsExcept(location!)
        locationToTag = location!
        radiusSegmentedControl.selectedSegmentIndex = 0
        addRadiusOverlayForLocation(location!, withRadius: (Double(radiusSegmentedControl.selectedSegmentIndex) + 1) * 100 * 0.3048)
        moveMapToLocation(locationToTag)
        
    }
    
    func addAnnotationsExcept(_ location: Location) {
        for thisLocation in searchedLocations! {
            if (location.coordinate.latitude != thisLocation.coordinate.latitude) || (location.coordinate.longitude != thisLocation.coordinate.longitude) {
                map.addAnnotation(thisLocation)
            }
        }
    }
    
    func removeAnnotationsExcept(_ location: Location) {
        for thisLocation in searchedLocations! {
            if (location.coordinate.latitude != thisLocation.coordinate.latitude) || (location.coordinate.longitude != thisLocation.coordinate.longitude) {
                map.removeAnnotation(thisLocation)
            }
        }
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
        let region = MKCoordinateRegionMakeWithDistance(location.coordinate, 500, 500)
        let regionThatFits = map.regionThatFits(region)
        map.setRegion(regionThatFits, animated: true)
    }
    
    func moveMapToDefaultView() {
        let region = MKCoordinateRegionMakeWithDistance(map.userLocation.coordinate, 30000, 30000)
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
            myCount = (searchedLocations?.count)!
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
            let location = mapLocations?[(mapLocations?.count)! - 1]
            region = MKCoordinateRegionMakeWithDistance((location?.coordinate)!, 500, 500)
        default:
            var topLeftCoord = CLLocationCoordinate2D(latitude: -90, longitude: 180)
            var bottomRightCoord = CLLocationCoordinate2D(latitude: 90, longitude: -180)
            for location in mapLocations! {
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
    
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    func stringFromPlacemark(_ placemark: MKPlacemark) -> String {
        var string = ""
        if let subThoroughFare = placemark.subThoroughfare {
            string.append("\(subThoroughFare) ")
        }
        if let thoroughfare = placemark.thoroughfare {
            string.append("\(thoroughfare)\n")
        }
        if let locality = placemark.locality {
            string.append("\(locality), ")
        }
        if let administrativeArea = placemark.administrativeArea {
            string.append("\(administrativeArea) ")
        }
        if let postalCode = placemark.postalCode {
            string.append(postalCode)
        }
        return string
    }

    

}

extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setImage(UIImage(), for: .clear, state: UIControlState.normal)
        searchSpinner.isHidden = false
        searchSpinner.startAnimating()
        searchBar.resignFirstResponder()
        let query = MKLocalSearchRequest()
        query.region = map.region
        query.naturalLanguageQuery = searchBar.text
        let search = MKLocalSearch(request: query)
        search.start(completionHandler: {
            response, error in
            if let error = error {
                print("Error: \(error)")
            } else {
                if let locations = self.searchedLocations {
                    self.removeAnnotationsForLocations(locations)
                }
                self.searchedLocations = [Location]()
                for mapItem in (response?.mapItems)! as [MKMapItem] {
                    let location = Location(name: mapItem.placemark.name!, address: self.stringFromPlacemark(mapItem.placemark), addressName: mapItem.placemark.name!, longitude: mapItem.placemark.coordinate.longitude, latitude: mapItem.placemark.coordinate.latitude)
                    self.searchedLocations?.append(location)
                }
                if let theseLocations = self.searchedLocations {
                    self.addAnnotations(theseLocations)
                }
                self.moveMap(forMapCase: .untaggedLocations)
                searchBar.resignFirstResponder()
                self.title = "Tap a Pin"
                self.searchSpinner.stopAnimating()
                self.searchSpinner.isHidden = true
                let icon = UISearchBar().image(for: .clear, state: .normal)
                self.searchBar.setImage(icon, for: .clear, state: .normal)
            }
        })
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            if let theseLocations = searchedLocations {
                removeAnnotationsForLocations(theseLocations)
                searchedLocations = [Location]()
                title = "Search or Press"
            }
        }
    }
}

extension MapViewController: TagLocationViewControllerDelegate {
    func tagLocationViewControllerDidGoBack(_ controller: TagLocationViewController) {
        dismiss(animated: true, completion: nil)
        tagCancelButtonPressed()
    }
    
    func tagLocationViewController(_ controller: TagLocationViewController, didSaveTag tag: Location) {
        locations.append(tag)

        dismiss(animated: true, completion: nil)
        delegate?.mapViewController(self, didTagLocation: tag)
    }
}

extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if taggingLocation || editingLocation {
            return false
        } else {
            return true
        }
    }
}
