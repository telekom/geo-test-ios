//
//  File.swift
//  GeofenceTester
//
//  Created by Alexander von Below on 03.07.22.
//

import Foundation
import os.log
import CoreLocation

protocol Loggable {
    var logger: Logger! { get set }
}

protocol LocationUser {
    var locationManager: CLLocationManager! { get set }
}
