//
//  RegionsListVC+CoreLocationsDelegate.swift
//  GeofenceTester
//
//  Created by Alexander von Below on 30.06.22.
//

import UIKit
import CoreLocation

extension RegionsListViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        process(event: .ENTER, region: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        process(event: .EXIT, region: region)
    }
    
    private func process (event: EventRecord.EventType, region: CLRegion) {
        let content = UNMutableNotificationContent()
        let title: String
        switch event {
        case .ENTER:
            title = NSLocalizedString("Region Entered",
                                      comment: "Push Notificaton Title")
        case .EXIT:
            title = NSLocalizedString("Region Exited",
                                      comment: "Push Notificaton Title")
        }
        content.title = title
        content.body = "\(region.identifier) \(Date())"
        
        let eventRecord = EventRecord(event: event,
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
