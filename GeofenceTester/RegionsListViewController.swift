//
//  RegionsDetailControllerViewController.swift
//  GeofenceTester
//
//  Created by Alexander von Below on 13.06.22.
//

import UIKit
import MapKit
import os.log

class RegionsListViewController: UIViewController {

    var locationManager: CLLocationManager = CLLocationManager()
    var storage = PersistantStorage<EventRecord>()
    private var logger = Logger()
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        locationManager.delegate = self
        
        registerMapAnnotationViews()
        
        switch self.locationManager.authorizationStatus {
        case .notDetermined:
            self.locationManager.requestAlwaysAuthorization()
        case .authorizedAlways:
            self.mapView.showsUserLocation = true
            mapView.setCenter(mapView.userLocation.coordinate, animated: true)
        default:
            let alert = UIAlertController(title: "No authorization", message: "This app requires the location services to be authorised", preferredStyle: .alert)
            self.present(alert, animated: true)
        }
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
        let alertController = UIAlertController(title: "New Region", message: "Please enter a name", preferredStyle: .alert)
        alertController.addTextField()
        alertController.addAction(UIAlertAction(title: "Cancel",
                                                style: .cancel,
                                                handler: { _ in
            return
        }))
        alertController.addAction(UIAlertAction(title: "OK",
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
                DispatchQueue.main.async {
                    self.updateMap()
                }
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
                                      radius: 10,
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
                let overlay = MKCircle(center: region.center, radius: region.radius)
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
       
    private func handleError (_ error: Error) {
        handleError(error.localizedDescription)
    }
    
    private func handleError (_ error: String) {
        logger.error("\(error)")
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? RegionViewController {
            guard let annotation = sender as? MKAnnotation else {
                let logger = Logger()
                logger.log(level: .error, "Sender was not MKAnnotation")
                return
            }
            guard let identifier = annotation.title else {
                return
            }
            destination.identifier = identifier
            destination.locationManager = locationManager
        }
        
        if let destination = segue.destination as? EventsTableViewController {
            destination.storage = storage
        }
    }
    
    @IBAction func unwindAction(unwindSegue: UIStoryboardSegue) {
        self.updateMap()
    }
}

extension RegionsListViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            // Make a fast exit if the annotation is the `MKUserLocation`, as it's not an annotation view we wish to customize.
            return nil
        }
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: defaultReuseIdentifier,
                                                                   for: annotation)
        annotationView.canShowCallout = true
        let rightButton = UIButton(type: .infoLight)
        annotationView.rightCalloutAccessoryView = rightButton
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.clear
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 2
        return renderer
    }
    
    func mapView(_ mapView: MKMapView,
           annotationView view: MKAnnotationView,
                          calloutAccessoryControlTapped control: UIControl){
        self.performSegue(withIdentifier: "RegionDetail", sender: view.annotation)
    }
}

// MARK: - CLLocationManagerDelegate

extension RegionsListViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let date = Date()
        let content = UNMutableNotificationContent()
        content.title = "Region Entered"
        content.body = "\(region.identifier) \(date)"
        
        let eventRecord = EventRecord(event: .ENTER,
                                      identifier: region.identifier,
                                      date: date)
        do {
            try storage.store(eventRecord)
        }
        catch let error {
            self.handleError(error)
        }
        let request = UNNotificationRequest(identifier: region.identifier,
                                            content: content,
                                            trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let content = UNMutableNotificationContent()
        content.title = "Region Exited"
        content.body = "\(region.identifier) \(Date())"
        
        let eventRecord = EventRecord(event: .EXIT,
                                      identifier: region.identifier,
                                      date: Date())
        do {
            try storage.store(eventRecord)
        }
        catch let error {
            self.handleError(error)
        }
        let request = UNNotificationRequest(identifier: region.identifier,
                                            content: content,
                                            trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    func locationManager( _ manager: CLLocationManager,
                          monitoringDidFailFor region: CLRegion?,
                          withError error: Error
    ) {
        self.handleError(error)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            // Disable your app's location features
            self.handleError("Warning: Location restricted or denied")
            
        case .authorizedWhenInUse:
            // Enable your app's location features.
            self.handleError("Warning: Location InUse Only")
            
        case .authorizedAlways:
            self.mapView.showsUserLocation = true
            // Enable or prepare your app's location features that can run any time.
            
        case .notDetermined:
            self.handleError("Warning: Location Not Determined")
        default:
            self.handleError("Warning: Switch fell through")
        }
    }
}
