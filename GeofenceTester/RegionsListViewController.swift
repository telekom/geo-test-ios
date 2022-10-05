/*
 * telekom / geo-test-ios
 *
 * RegionsDetailControllerViewController.swift
 * Created by Alexander von Below on 13.06.22.
 * Copyright (c) 2022 Deutsche Telekom AG
 *
 * This program is made available under the terms of the 
 * MIT license which is available at
 * https://opensource.org/licenses/MIT
 *
 * SPDX-License-Identifier: MIT 
 */

import UIKit
import MapKit
import os.log
import AppCenterAnalytics

let PausesVisitAutomatically = "PausesVisitAutomatically"

class RegionsListViewController: UIViewController {

    public static let UpdateNotificationName = Notification.Name.init("updateRegions")

    var locationManager: CLLocationManager = CLLocationManager()
    var storage = PersistantStorage<EventRecord>()
    internal var logger = os.Logger()
    var firstUse = true
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var addButton: UIBarButtonItem!
    @IBOutlet var settingsButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        addButton.accessibilityLabel = NSLocalizedString("Add Monitored Region at current location", comment: "Accessibilty label for add button")
        addButton.accessibilityLabel = NSLocalizedString("Settings", comment: "Accessibilty label for settings button")

        locationManager.delegate = self
        
        self.mapView.setCenter(
            self.mapView.userLocation.coordinate,
            animated: false)
        registerMapAnnotationViews()
        
        switch self.locationManager.authorizationStatus {
        case .notDetermined:
            self.locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            self.startLocationServices()
            
        default:
            let alert = UIAlertController(title: NSLocalizedString("No authorization",
                                                                   comment: "Alert: Authorization to Localization denied"),
                                          message: NSLocalizedString("This app requires the location services to be authorised",
                                                                     comment: "Alert: Authorization to Localization denied"),
                                          preferredStyle: .alert)
            self.present(alert, animated: true)
        }
        
        NotificationCenter.default.addObserver(
            forName: RegionsListViewController.UpdateNotificationName,
            object: nil,
            queue: .main) { _ in
                self.updateMap()
            }
    }
    
    internal func startLocationServices() {
        self.mapView.showsUserLocation = true
        mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        locationManager.startMonitoringVisits()
        
        let pauses = UserDefaults.standard.bool(forKey: PausesVisitAutomatically)
        locationManager.pausesLocationUpdatesAutomatically = pauses
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateMap()
    }
    
    let defaultReuseIdentifier = "defaultAnnotationView"
    private func registerMapAnnotationViews() {
        mapView.register(MKMarkerAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: defaultReuseIdentifier)
    }
        
    @IBAction func addRegionAction() {
        let alertController = UIAlertController(title: NSLocalizedString("New Region",
                                                                         comment: "New Region Alert"),
                                                message: NSLocalizedString("Please enter a name",
                                                                           comment: "New Region Alert"),
                                                preferredStyle: .alert)
        alertController.addTextField()
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel",
                                                                         comment: "New Region Alert"),
                                                style: .cancel,
                                                handler: { _ in
            return
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK",
                                                                         comment: "New Region Alert"),
                                                style: .default,
                                                handler: { _ in
            guard let identifier = alertController.textFields?.first?.text else {
                return
            }
            
            let center = self.mapView.userLocation.coordinate
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [self] granted, error in
                
                if let error = error {
                    self.handleError("Error in requestAuthorization: \(error.localizedDescription)")
                    return
                }
                
                self.registerRegion(identifier: identifier, center: center)
                NotificationCenter.default.post(
                    name: RegionsListViewController.UpdateNotificationName,
                    object: nil)
            }
        }))
        
        self.present(alertController, animated: true)
    }
    
    private func registerRegion(identifier: String, center: CLLocationCoordinate2D) {
        guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
            self.handleError("Circular Region Monitoring not available")
            return
        }
        // Register the region.
        let region = CLCircularRegion(center: center,
                                      radius: 100,
                                      identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        self.locationManager.startMonitoring(for: region)
    }
    
    private func updateMap() {
        guard mapView != nil else {
            return
        }
        
        let regions = self.locationManager.monitoredRegions
        
        var mapAnnotations = [MKAnnotation]()
        let existingAnnotations = mapView.annotations
        mapView.removeAnnotations(existingAnnotations)
        mapView.removeOverlays(mapView.overlays)
        
        for region in regions {
            if let region = region as? CLCircularRegion {
                let overlay = MKCircle(center: region.center,
                                       radius: region.radius)
                // We set this to false, otherwise the identifier will be read twice
                overlay.isAccessibilityElement = false
                mapView.addOverlay(overlay)
                let annotation = MKPointAnnotation()
                annotation.title = region.identifier
                annotation.coordinate = region.center
                mapAnnotations.append(annotation)
            }
        }
        mapView.addAnnotations(mapAnnotations)
        mapView.showAnnotations(mapAnnotations, animated: true)
    }
       
    internal func handleError (_ error: Error) {
        handleError(error.localizedDescription)
    }
    
    internal func handleError (_ error: String) {
        Analytics.trackEvent(error, withProperties: [:], flags: .critical)
        logger.error("\(error)")
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if var destination = segue.destination as? LocationUser {
            destination.locationManager = self.locationManager
        }
        
        if var destination = segue.destination as? Loggable {
            destination.logger = logger
        }

        if let destination = segue.destination as? RegionDetailViewController {
            guard let annotation = sender as? MKAnnotation else {
                self.handleError("Sender was not MKAnnotation")
                return
            }
            guard let identifier = annotation.title,
                    let region = locationManager.monitoredRegions.first(where: {
                $0.identifier == identifier
            }) as? CLCircularRegion else {
                return
            }
            
            destination.identifier = region.identifier
            destination.radius = region.radius
        }
        
        if let destination = segue.destination as? EventsTableViewController {
            destination.storage = storage
        }
    }
}

extension RegionsListViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if self.locationManager.monitoredRegions.count == 0 {
            if firstUse {
                mapView.setCenter(
                    userLocation.coordinate,
                    animated: false)
            }
        }
        firstUse = false
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: defaultReuseIdentifier,
                                                                   for: annotation)
        annotationView.canShowCallout = true
        let rightButton = UIButton(type: .detailDisclosure)
        annotationView.rightCalloutAccessoryView = rightButton
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.clear
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 2
        renderer.isAccessibilityElement = false
        return renderer
    }
    
    func mapView(_ mapView: MKMapView,
           annotationView view: MKAnnotationView,
                          calloutAccessoryControlTapped control: UIControl){
        self.performSegue(withIdentifier: "RegionDetail", sender: view.annotation)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let calloutView = view.rightCalloutAccessoryView
        calloutView?.isAccessibilityElement = true
        view.isAccessibilityElement = false
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        let calloutView = view.rightCalloutAccessoryView
        calloutView?.isAccessibilityElement = false
        view.isAccessibilityElement = true
    }
}
