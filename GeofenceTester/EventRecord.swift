//
//  EventRecord.swift
//  GeofenceTester
//
//  Created by Alexander von Below on 27.06.22.
//

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
