//
//  ViewController.swift
//  GeofenceTester
//
//  Created by Alexander von Below on 10.06.22.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var monitoringButton: UIButton!
    @IBOutlet var errorView: UITextView!
    @IBOutlet var locationField: UITextField!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation? {
        didSet {
            monitoringButton.isEnabled = true
            let longitude = currentLocation?.coordinate.longitude ?? 0
            let latitude = currentLocation?.coordinate.latitude ?? 0
            locationField.text = "\(longitude), \(latitude)"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self;
    }

    @IBAction func getLocation (_ sender: UIButton) {
        if self.locationManager.authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            self.locationManager.requestAlwaysAuthorization()
        }
    }
    
    @IBAction func setMonitoring (_ sender: UIButton) {
        
        guard let center = self.currentLocation?.coordinate else {
            self.appendError("No center coordinate found")
            return
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            
            if let error = error {
                self.appendError(error)
                return
            }
            
            guard CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) else {
                self.appendError("Monitoring not available")
                return
            }
            // Register the region.
            let region = CLCircularRegion(center: center,
                                          radius: 10,
                                          identifier: "Test Region")
            region.notifyOnEntry = true
            region.notifyOnExit = true
            
            self.locationManager.startMonitoring(for: region)
        }
    }
    
    @IBAction func testPushNotification() {
        
        print ("Push Test pressed")
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            
            if let error = error {
                self.appendError(error)
                return
            }
            
            let content = UNMutableNotificationContent()
            content.title = "Test"
            content.body = "This is not music, this is a test"
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10,
                                                            repeats: false)
            let request = UNNotificationRequest(identifier: "Test",
                                                content: content,
                                                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    self.appendError(error)
                    return
                }
                else {
                    self.appendError("Note: Added Request successfully")
                }
            }
        }
    }
    
    // Core Location Delegate
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let content = UNMutableNotificationContent()
        content.title = "Region Entered"
        content.body = "\(region.identifier) \(Date())"
        
        let request = UNNotificationRequest(identifier: region.identifier,
                                            content: content,
                                            trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let content = UNMutableNotificationContent()
        content.title = "Region Exited"
        content.body = "\(region.identifier) \(Date())"
        
        let request = UNNotificationRequest(identifier: region.identifier,
                                            content: content,
                                            trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
    
    func locationManager( _ manager: CLLocationManager,
                          monitoringDidFailFor region: CLRegion?,
                          withError error: Error
    ) {
        self.appendError(error)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.appendError(error)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            // Disable your app's location features
            self.appendError("Warning: Location restricted or denied")
            
        case .authorizedWhenInUse:
            // Enable your app's location features.
            self.appendError("Warning: Location InUse Only")
            
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            // Enable or prepare your app's location features that can run any time.
            
        case .notDetermined:
            self.appendError("Warning: Location Not Determined")
        default:
            self.appendError("Warning: Switch fell through")
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let myLocation = locations.first else {
            self.appendError("No location was reported")
            return;
        }
        self.currentLocation = myLocation
    }
    
    // Error Handling
    
    func appendError(_ error: String) {
        DispatchQueue.main.async {
            self.errorView.text?.append(contentsOf: error + "\n")
        }
    }
    
    func appendError(_ error: Error) {
        let errorString = error.localizedDescription
        appendError(errorString)
    }
    
    // Navigation Handling
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let regionsController = segue.destination as? RegionsDetailControllerViewController {
            regionsController.regions = locationManager.monitoredRegions
        }
    }
}

