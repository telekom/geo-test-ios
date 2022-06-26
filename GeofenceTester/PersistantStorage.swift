//
//  PersistantStorage.swift
//  GeofenceTester
//
//  Created by Alexander von Below on 15.06.22.
//

import Foundation



class PersistantStorage<T: Codable> {
    
    private var storage = Array<T>()
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let kFilename = "geolocator.log"
    
    init() throws {
        let url = try fileURL()
        let jsonData: Data
        do {
            jsonData = try Data(contentsOf: url)
        }
        catch {
            // File does not exist
            return
        }
        storage = try decoder.decode([T].self, from: jsonData)
    }
    
    func store(_ object: T) throws {
        storage.append(object)
        try save()
    }
     
    func retrieveAll() -> [T] {
        return storage
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
        let json = try encoder.encode(storage)
        try json.write(to: fileURL())
    }
}
