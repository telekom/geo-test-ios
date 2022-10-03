/*
 * telekom / geo-test-ios
 *
 * PersistantStorage.swift
 * Created by Alexander von Below on 15.06.22.
 * Copyright (c) 2022 Deutsche Telekom AG
 *
 * This program is made available under the terms of the 
 * MIT license which is available at
 * https://opensource.org/licenses/MIT
 *
 * SPDX-License-Identifier: MIT 
 */

import Foundation

protocol Storage {
    associatedtype Object: Codable
    var objects: Array<Object> { get }
    func store(_ object: Object) throws
}

class PersistantStorage<T: Codable>: Storage {
    typealias Object = T

    public private(set) var objects = Array<T>()
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let kFilename = "geolocator.log"
    
    init() {
        do {
            let url = try fileURL()
            let jsonData = try Data(contentsOf: url)
            // Well, it really should throw, but …
            objects = try decoder.decode([T].self, from: jsonData)
        }
        catch {
            // File does not exist
            return
        }
    }
    
    func store(_ object: T) throws {
        objects.append(object)
        try save()
    }
     
    func deleteAll() throws {
        objects.removeAll()
        let url = try fileURL()
        try FileManager.default.removeItem(at: url)
    }
    
    private func fileURL() throws -> URL {
        let fm = FileManager.default
        var path: URL!
        do {
            path = try fm.url(for: .documentDirectory,
                              in: .userDomainMask,
                              appropriateFor: nil,
                              create: false)
        }
        catch {
            throw (error)
        }
        path.appendPathComponent(kFilename)
        return path
    }
    
    private func save() throws {
        let json = try encoder.encode(objects)
        try json.write(to: fileURL())
    }
}
