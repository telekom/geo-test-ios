/*
 * telekom / geo-test-ios
 *
 * File.swift
 * Created by Alexander von Below on 03.07.22.
 * Copyright (c) 2022 Deutsche Telekom AG
 *
 * This program is made available under the terms of the 
 * MIT license which is available at
 * https://opensource.org/licenses/MIT
 *
 * SPDX-License-Identifier: MIT 
 */

import Foundation
import os.log
import CoreLocation

protocol Loggable {
    var logger: Logger! { get set }
}

protocol LocationUser {
    var locationManager: CLLocationManager! { get set }
}
