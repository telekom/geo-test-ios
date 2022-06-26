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
    }
    var event: EventType
    var identifier: String
    var date: Date
}

extension EventRecord: CustomDebugStringConvertible {
    var debugDescription: String {
        get {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            formatter.dateStyle = .short
            return "\(event.rawValue): \(identifier) \(formatter.string(from: date))"
        }
    }
}
