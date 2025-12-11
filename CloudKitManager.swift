//
//  CloudKitManager.swift
//  Smoking
//
//  Created by Raffaele Barra on 11/12/25.
//


import Foundation
import CloudKit
import SwiftUI
import Combine

class CloudKitManager: ObservableObject {
    static let shared = CloudKitManager()
    
    // The public database is accessible by all users (Anonymous usage)
    private let database = CKContainer.default().publicCloudDatabase
    private let recordType = "AcademySpace"
    
    @Published var spaces: [SpaceMock] = []
    
    // --- 1. FETCH DATA ---
    func fetchSpaces(completion: @escaping ([SpaceMock]) -> Void) {
        let predicate = NSPredicate(value: true) // Fetch ALL
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        var fetchedItems: [SpaceMock] = []
        
        operation.recordMatchedBlock = { recordId, result in
            switch result {
            case .success(let record):
                if let space = self.convertRecordToSpace(record) {
                    fetchedItems.append(space)
                }
            case .failure(let error):
                print("Error fetching record: \(error)")
            }
        }
        
        operation.queryResultBlock = { result in
            DispatchQueue.main.async {
                print("Fetched \(fetchedItems.count) spaces from CloudKit")
                // Sort by ID to keep order consistent
                let sorted = fetchedItems.sorted { $0.id < $1.id }
                completion(sorted)
            }
        }
        
        database.add(operation)
    }
    
    // --- 2. UPDATE STATUS ---
    func updateSpaceInCloud(space: SpaceMock) {
        // We need to fetch the specific record ID first or query it by our custom ID string
        // For simplicity, we query by the 'id' field we created
        let predicate = NSPredicate(format: "id == %@", space.id)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        let operation = CKQueryOperation(query: query)
        
        operation.recordMatchedBlock = { recordId, result in
            if case .success(let record) = result {
                // Update the fields
                record["status"] = (space.status == .occupied ? "occupied" : "free")
                record["descriptionText"] = space.description
                // Save specific icons as a comma-separated string (easier than List for simple sync)
                // Note: You need to pass the current active icons to this function really, 
                // but for now let's just sync status/desc to be fast.
                
                self.database.save(record) { savedRecord, error in
                    if let error = error {
                        print("Cloud save failed: \(error)")
                    } else {
                        print("Cloud save success for \(space.name)")
                    }
                }
            }
        }
        
        database.add(operation)
    }
    
    // --- 3. SEEDING (THE TIME SAVER) ---
    // Only call this if Cloud is empty
    func seedInitialData(mocks: [SpaceMock]) {
        print("Seeding CloudKit with \(mocks.count) spaces...")
        
        for space in mocks {
            let record = CKRecord(recordType: recordType)
            record["id"] = space.id
            record["name"] = space.name
            record["type"] = space.type
            record["status"] = (space.status == .occupied ? "occupied" : "free")
            record["descriptionText"] = space.description
            record["imageName"] = space.imageName
            
            database.save(record) { _, error in
                if let error = error {
                    print("Error seeding \(space.name): \(error.localizedDescription)")
                }
            }
        }
    }
    
    // --- HELPER: Convert CKRecord -> SpaceMock ---
    private func convertRecordToSpace(_ record: CKRecord) -> SpaceMock? {
        guard let id = record["id"] as? String,
              let name = record["name"] as? String,
              let type = record["type"] as? String,
              let statusString = record["status"] as? String,
              let imageName = record["imageName"] as? String
        else { return nil }
        
        let desc = record["descriptionText"] as? String ?? ""
        let status: SpaceStatus = (statusString == "occupied") ? .occupied : .free
        
        return SpaceMock(id: id, name: name, type: type, status: status, description: desc, imageName: imageName)
    }
}
