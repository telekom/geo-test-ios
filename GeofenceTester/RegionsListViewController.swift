//
//  RegionsDetailControllerViewController.swift
//  GeofenceTester
//
//  Created by Alexander von Below on 13.06.22.
//

import UIKit
import MapKit
import os.log

class RegionsListViewController: UIViewController, MKMapViewDelegate {

    var locationManager: CLLocationManager!
    private var logger = Logger()
    
    @IBOutlet var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Monitored Regions"
        registerMapAnnotationViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateMap()
    }
    
    let defaultReuseIdentifier = "defaultAnnotationView"
    private func registerMapAnnotationViews() {
        mapView.register(MKMarkerAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: defaultReuseIdentifier)
    }
        
    @IBAction func addRegion() {
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
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
                
                if let error = error {
                    self.logger.log(level: .error, "Error in requestAuthorization: \(error.localizedDescription)")
                    return
                }
                
                guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
                    return
                }
                // Register the region.
                let region = CLCircularRegion(center: center,
                                              radius: 10,
                                              identifier: identifier)
                region.notifyOnEntry = true
                region.notifyOnExit = true
                
                self.locationManager.startMonitoring(for: region)
                self.updateMap()
            }
        }))
        
        self.present(alertController, animated: true)
    }
    
    func updateMap() {
        guard mapView != nil else {
            return
        }
        
        let regions = self.locationManager.monitoredRegions
        
        var mapAnnotations = [MKAnnotation]()
        let existingAnnotations = mapView.annotations
        mapView.removeAnnotations(existingAnnotations)
        
        for region in regions {
            if let region = region as? CLCircularRegion {
                let annotation = MKPointAnnotation()
                annotation.title = region.identifier
                annotation.coordinate = region.center
                mapAnnotations.append(annotation)
            }
        }
        mapView.addAnnotations(mapAnnotations)
        mapView.showAnnotations(mapAnnotations, animated: true)
    }
        
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
    
    func mapView(_ mapView: MKMapView,
           annotationView view: MKAnnotationView,
                          calloutAccessoryControlTapped control: UIControl){
        self.performSegue(withIdentifier: "RegionDetail", sender: view.annotation)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let detailView = segue.destination as? RegionViewController {
            guard let annotation = sender as? MKAnnotation else {
                let logger = Logger()
                logger.log(level: .error, "Sender was not MKAnnotation")
                return
            }
            guard let identifier = annotation.title else {
                return
            }
            detailView.identifier = identifier
            detailView.locationManager = locationManager
        }
    }
    
    @IBAction func unwindAction(unwindSegue: UIStoryboardSegue) {
        self.updateMap()
    }

}
