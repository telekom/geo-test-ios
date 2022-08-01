/*
 * telekom / geo-test-ios
 *
 * EventRecord.swift
 * Created by Alexander von Below on 27.06.22.
 * Copyright (c) 2022 Deutsche Telekom AG
 *
 * This program is made available under the terms of the 
 * MIT license which is available at
 * https://opensource.org/licenses/MIT
 *
 * SPDX-License-Identifier: MIT 
 */

import Foundation


struct EventRecord: Codable {
    enum EventType: String, Codable {
        case ENTER
        case EXIT
        case VISIT
    }
    var event: EventType
    var identifier: String
    var date: Date
}

extension EventRecord: CustomDebugStringConvertible {
    var debugDescription: String {
        get {
            return "\(event.rawValue): \(identifier) \(date.formatted(date: .abbreviated, time: .shortened))"
        }
    }
}
