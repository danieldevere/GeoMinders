//
//  MapViewController.swift
//  GeoMinders
//
//  Created by DANIEL DEVERE on 2/8/17.
//  Copyright (c) 2017 DANIEL DEVERE. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate: class {
    func mapViewController(_ controller: MapViewController, didTagLocation location: Location)
}

class MapViewController: UIViewController {
    
    // MARK: - Variables
    
    let locationManager = CLLocationManager()
    var editingLocation = false
    var taggingLocation = false
    var locations = [Location]()
    var searchedLocations: [Location]?
    var isShowingSavedLocations = false
    var locationToTag = Location()
    var overlay: MKOverlay?
    var delegate: MapViewControllerDelegate?
    
    enum moveMapCases: Int {
        case currentLocation = 0
        case untaggedLocations = 1
        case taggedLocations = 2
    }
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var radiusSegmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var currentLocation: UIButton!
    @IBOutlet weak var searchSpinner: UIActivityIndicatorView!
    
    // MARK: - Action Functions
    // User taps the blue current location button
    @IBAction func currentLocationButton() {
        moveMap(forMapCase: .currentLocation)
    }
    // User changes the size of the geofence
    @IBAction func segmentChanged() {
        map.removeOverlays(map.overlays)
        addRadiusOverlayForLocation(locationToTag, withRadius: (Double(radiusSegmentedControl.selectedSegmentIndex) + 1) * 100.0 * 0.3048)
    }
    
    // MARK: - Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set up the view
        searchSpinner.isHidden = true
        currentLocation.isEnabled = false
        map.delegate = self
        map.isRotateEnabled = false
        if editingLocation {
            editingLocationView()
        } else {
            regularView()
        }
        // Check for too many saved locations
        if locations.count >= 20 {
            let alertController = UIAlertController(title: "Too Many Locations", message: "Apple only allows us to track up to 20 locations.  You will need to delete a location before adding a new one.", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: {
                _ in
                self.dismiss(animated: true, completion: nil)
            })
            alertController.addAction(alertAction)
            present(alertController, animated: true, completion: nil)
        }
        // Authorization to use location
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        // Gesture recognizer to dismiss keyboard on tap of map
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MapViewController.dismissKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
        
        // Gesture recognizer to add pin with long press
        let pinGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.addAnnotationOnTap))
        pinGestureRecognizer.cancelsTouchesInView = false
        pinGestureRecognizer.delegate = self
        view.addGestureRecognizer(pinGestureRecognizer)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // User taps save after choosing a radius
        if segue.identifier == "TagLocation" {
            let navigationController = segue.destination as! UINavigationController
            let controller = navigationController.topViewController as! TagLocationViewController
            controller.taggedLocation = locationToTag
            controller.delegate = self
        }
    }
    
    // MARK: - Button functions
    
    // User is adding new location and cancels
    func cancel() {
        dismiss(animated: true, completion: nil)
    }
    // User taps the save button after choosing radius
    func tagButtonPressed() {
        locationToTag.radius = ((Double(radiusSegmentedControl.selectedSegmentIndex) + 1) * 100) * 0.3048
        performSegue(withIdentifier: "TagLocation", sender: nil)
    }
    // User taps the + button on callout but cancels instead of saving
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
    // User presses the + button on callout
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
    
    // MARK: - View update functions
    
    func showSavedLocations() {
        // User presses hide saved
        if isShowingSavedLocations {
            isShowingSavedLocations = false
            searchBar.isHidden = false
            removeAnnotationsForLocations(locations)
            if let theseLocations = searchedLocations {
                addAnnotations(theseLocations)
            }
            if searchedLocations!.count > 0 {
                moveMap(forMapCase: .untaggedLocations)
            } else {
                if currentLocation.isEnabled {
                    moveMapToDefaultView()
                }
            }
        // User presses show saved
        } else {
            isShowingSavedLocations = true
            if let theseLocations = searchedLocations {
                removeAnnotationsForLocations(theseLocations)
            }
            searchBar.isHidden = true
            addAnnotations(locations)
            moveMap(forMapCase: .taggedLocations)
        }
        if !editingLocation {
            stateForToggleButton()
        }
    }
    // Sets up the view coming from the location detail screen
    func editingLocationView() {
        currentLocation.isHidden = true
        bottomBar.isHidden = true
        searchBar.isHidden = true
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = nil
        title = "\(locations[0].name)"
        showSavedLocations()
        addRadiusOverlayForLocation(locations[0], withRadius: locations[0].radius)
        map.selectAnnotation(locations[0], animated: true)
    }
    // Sets up the regular view for searching
    func regularView() {
        taggingLocation = false
        bottomBar.isHidden = true
        searchBar.isHidden = false
        if map.annotations.count <= 1 {
            if currentLocation.isEnabled || map.annotations.count == 0 {
                title = "Search or Press"
            } else {
                title = "Tap a Pin"
            }
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.stop, target: self, action: #selector(MapViewController.cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show Saved", style: .plain, target: self, action: #selector(MapViewController.showSavedLocations))
        if locations.count == 0 {
            navigationItem.rightBarButtonItem?.isEnabled = false
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
    }
    // Sets up the view after user has pressed + on callout
    func taggingLocationView() {
        taggingLocation = true
        bottomBar.isHidden = false
        searchBar.isHidden = true
        title = "Choose Size"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(MapViewController.tagCancelButtonPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(MapViewController.tagButtonPressed))
    }
    // Toggles title of right navigation button
    func stateForToggleButton() {
        if isShowingSavedLocations {
            navigationItem.rightBarButtonItem?.title = "Hide Saved"
        } else {
            navigationItem.rightBarButtonItem?.title = "Show Saved"
        }
    }
    
    // MARK: - Annotations
    
    // Add an annotation on press
    func addAnnotationOnTap(gesture: UIGestureRecognizer) {
        // Alerts the user that they can't add while looking at saved
        if isShowingSavedLocations {
            let alertController = UIAlertController(title: "Cannot add pin", message: "You cannot tap to add a pin while showing your saved locations.  Press Hide Saved to add a pin", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        // Sets up the new locations after press
        } else {
            if gesture.state == UIGestureRecognizerState.began {
                let touchPoint = gesture.location(in: map)
                let locationCoordinate = map.convert(touchPoint, toCoordinateFrom: map)
                var locationName = ""
                var location = Location()
                // Geocode location
                let geocodeLocation = CLLocation(latitude: locationCoordinate.latitude, longitude: locationCoordinate.longitude)
                CLGeocoder().reverseGeocodeLocation(geocodeLocation, completionHandler: {
                    placemarks, error in
                    if error != nil {
                        print("Reverse Geocode failed. Error: \(error)")
                    } else {
                        if let placemark = placemarks {
                            if placemark.count > 0 {
                                let locationPlacemark = placemark[0]
                                if let pmName = locationPlacemark.name {
                                    locationName = pmName
                                }
                                location = Location(name: locationName, address: self.stringFromCLPlacemark(placemark: locationPlacemark), addressName: locationName, longitude: locationCoordinate.longitude, latitude: locationCoordinate.latitude)
                            }
                        }
                        // Add annotation
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
    // To add annotations back after cancel tag
    func addAnnotationsExcept(_ location: Location) {
        for thisLocation in searchedLocations! {
            if (location.coordinate.latitude != thisLocation.coordinate.latitude) || (location.coordinate.longitude != thisLocation.coordinate.longitude) {
                map.addAnnotation(thisLocation)
            }
        }
    }
    // To remove annotations when user presses + on callout
    func removeAnnotationsExcept(_ location: Location) {
        for thisLocation in searchedLocations! {
            if (location.coordinate.latitude != thisLocation.coordinate.latitude) || (location.coordinate.longitude != thisLocation.coordinate.longitude) {
                map.removeAnnotation(thisLocation)
            }
        }
    }
    // Adds annotations and checks for already existing
    func addAnnotations(_ theseLocations: [Location]) {
        if theseLocations.count > 0 {
            removeAnnotationsForLocations(theseLocations)
        }
        map.addAnnotations(theseLocations)
    }
    // Removes annotations
    func removeAnnotationsForLocations(_ locations: [Location]) {
        if locations.count > 0 {
            map.removeAnnotations(locations)
        }
    }
    
    func addRadiusOverlayForLocation(_ location: Location, withRadius radius: CLLocationDistance) {
        overlay = MKCircle(center: location.coordinate, radius: radius)
        map.add(overlay!)
    }

    // MARK: - Move map
    
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
    
    // MARK: - Functions
    
    // Convert CLPlacemark into a formatted address
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
    // Convert MKPlacemark into formatted address
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
    // Dismiss keyboard on tap
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
}

// MARK: - Search Bar Delegate

extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // Remove clear button from search bar and add spinner
        searchBar.setImage(UIImage(), for: .clear, state: UIControlState.normal)
        searchSpinner.isHidden = false
        searchSpinner.startAnimating()
        searchBar.resignFirstResponder()
        // Search
        let query = MKLocalSearchRequest()
        query.region = map.region
        query.naturalLanguageQuery = searchBar.text
        let search = MKLocalSearch(request: query)
        search.start(completionHandler: {
            response, error in
            if let error = error {
                print("Error: \(error)")
                // Alert user to search error and stop spinner add clear button back
                let alertController = UIAlertController(title: "Search Failed", message: "Something went wrong with the search \(error)", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "Dismiss", style: .default, handler: {
                    _ in
                    self.searchSpinner.stopAnimating()
                    self.searchSpinner.isHidden = true
                    let icon = UISearchBar().image(for: .clear, state: .normal)
                    self.searchBar.setImage(icon, for: .clear, state: .normal)
                })
                alertController.addAction(alertAction)
                self.present(alertController, animated: true, completion: nil)
            // Search succeeded add annotations
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
                self.title = "Tap a Pin"
                self.searchSpinner.stopAnimating()
                self.searchSpinner.isHidden = true
                let icon = UISearchBar().image(for: .clear, state: .normal)
                self.searchBar.setImage(icon, for: .clear, state: .normal)
            }
        })
    }
    // Remove pins when user clears search text
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

// MARK: - Tag Location delegate

extension MapViewController: TagLocationViewControllerDelegate {
    func tagLocationViewControllerDidGoBack(_ controller: TagLocationViewController) {
        dismiss(animated: true, completion: nil)
        tagCancelButtonPressed()
    }
    // Saves location and dismisses self
    func tagLocationViewController(_ controller: TagLocationViewController, didSaveTag tag: Location) {
        locations.append(tag)
        dismiss(animated: true, completion: nil)
        delegate?.mapViewController(self, didTagLocation: tag)
    }
}

// MARK: - Gesture recognizer delegate

extension MapViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if taggingLocation || editingLocation {
            return false
        } else {
            return true
        }
    }
}

// MARK: - Map delegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Don't override user location blue pin
        if annotation.isKind(of: MKUserLocation.self) {
            return nil

        }
        // Dequeue annotation view or create new one
        var annotationView: MKPinAnnotationView
        if let view = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin") as? MKPinAnnotationView {
            annotationView = view
        } else {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
            annotationView.canShowCallout = true
            annotationView.isEnabled = true
            annotationView.animatesDrop = true
        }
        // Adds callout button
        if !isShowingSavedLocations && !editingLocation {
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
    }
    // Moves map to default view after map opens and you get user location
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if !currentLocation.isEnabled {
            if editingLocation {
                currentLocation.isEnabled = true
            } else {
                currentLocation.isEnabled = true
                moveMapToDefaultView()
            }
        }
    }
    // Creates the radius overlay
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
}
