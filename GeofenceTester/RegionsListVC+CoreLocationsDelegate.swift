/*
 * telekom / geo-test-ios
 *
 * RegionsListVC+CoreLocationsDelegate.swift
 * Created by Alexander von Below on 30.06.22.
 * Copyright (c) 2022 Deutsche Telekom AG
 *
 * This program is made available under the terms of the 
 * MIT license which is available at
 * https://opensource.org/licenses/MIT
 *
 * SPDX-License-Identifier: MIT 
 */

import UIKit
import CoreLocation

extension RegionsListViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        process(event: .ENTER, info: region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        process(event: .EXIT, info: region.identifier)
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        let visitLocation = CLLocation(latitude: visit.coordinate.latitude,
                                       longitude: visit.coordinate.longitude)
        let info: String
        if let matchingRegion = locationManager.monitoredRegions.first(where:{ region in
            guard let region = region as? CLCircularRegion else {
                return false
            }
            let regionLocation = CLLocation(latitude: region.center.latitude,
                                            longitude: region.center.longitude)
            let distance = visitLocation.distance(from: regionLocation)
            return abs(distance) <= region.radius
        }) {
            let infoFormat = NSLocalizedString("Found: %@", comment: "Found visit in region info")
            info = String(format: infoFormat, matchingRegion.identifier)
        } else {
            let infoFormat = NSLocalizedString("Coordinate %.4f, %.4f",
                                               comment: "Visit with Coordinate Info")
            info = String(format: infoFormat, visit.coordinate.latitude, visit.coordinate.longitude)
        }
        process(event: .VISIT, info: info)
    }
    
    private func process (event: EventRecord.EventType,
                          info: String) {
        let content = UNMutableNotificationContent()
        let title: String
        switch event {
        case .ENTER:
            title = NSLocalizedString("Region Entered",
                                      comment: "Push Notificaton Title")
        case .EXIT:
            title = NSLocalizedString("Region Exited",
                                      comment: "Push Notificaton Title")
        case .VISIT:
            title = NSLocalizedString("Visit",
                                      comment: "Push Notificaton Title")
        }
        content.title = title
        
        let eventRecord = EventRecord(event: event,
                                      identifier: info,
                                      date: Date())
        content.body = eventRecord.debugDescription

        do {
            try storage.store(eventRecord)
        }
        catch let error {
            self.handleError(error)
        }
        let request = UNNotificationRequest(identifier: UUID().uuidString,
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
            self.startLocationServices()
            
        case .notDetermined:
            self.handleError("Warning: Location Not Determined")
        default:
            self.handleError("Warning: Switch fell through")
        }
    }
}
