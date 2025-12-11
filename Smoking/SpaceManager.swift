import SwiftUI
import Combine

class SpaceManager: ObservableObject {
    // --- NAVIGATION STATE ---
    @Published var selectedTab: Int = 0
    
    // --- MASTER LISTS ---
    @Published var collabs: [SpaceMock] = []   // Start empty, load from Cloud
    @Published var balconies: [SpaceMock] = [] // Start empty, load from Cloud
    @Published var spaceIcons: [String: [String]] = [:]
    
    // Auto-refresh timer to sync devices
    private var cancellables = Set<AnyCancellable>()
    
    // Keep your original Mocks as a "Backup / Seed" source
    private let initialCollabs: [SpaceMock] = [
        SpaceMock(id: "1-1", name: "Collab 01-01", type: "collab", status: .free, description: "Sunny Side", imageName: "Collab 01-01"),
        SpaceMock(id: "1-2", name: "Collab 01-02", type: "collab", status: .occupied, description: "Meeting", imageName: "Collab 01-02"),
        SpaceMock(id: "1-3", name: "Collab 01-03", type: "collab", status: .free, description: "Quiet", imageName: "Collab 01-03"),
        SpaceMock(id: "1-4", name: "Collab 01-04", type: "collab", status: .free, description: "Near Entrance", imageName: "Collab 01-04"),
        SpaceMock(id: "2-1", name: "Collab 02-01", type: "collab", status: .free, description: "", imageName: "Collab 02-01"),
        SpaceMock(id: "2-2", name: "Collab 02-02", type: "collab", status: .occupied, description: "Brainstorming", imageName: "Collab 02-02"),
        SpaceMock(id: "2-3", name: "Collab 02-03", type: "collab", status: .free, description: "", imageName: "Collab 02-03"),
        SpaceMock(id: "2-4", name: "Collab 02-04", type: "collab", status: .free, description: "", imageName: "Collab 02-04"),
        SpaceMock(id: "2-5", name: "Collab 02-05", type: "collab", status: .occupied, description: "Zoom Call", imageName: "Collab 02-05"),
        SpaceMock(id: "2-6", name: "Collab 02-06", type: "collab", status: .free, description: "", imageName: "Collab 02-06"),
        SpaceMock(id: "3-1", name: "Collab 03-01", type: "collab", status: .free, description: "", imageName: "Collab 03-01"),
        SpaceMock(id: "3-2", name: "Collab 03-02", type: "collab", status: .occupied, description: "Occupied by John", imageName: "Collab 03-02"),
        SpaceMock(id: "3-3", name: "Collab 03-03", type: "collab", status: .free, description: "", imageName: "Collab 03-03"),
        SpaceMock(id: "3-4", name: "Collab 03-04", type: "collab", status: .free, description: "", imageName: "Collab 03-04"),
        SpaceMock(id: "3-5", name: "Collab 03-05", type: "collab", status: .free, description: "", imageName: "Collab 03-05"),
        SpaceMock(id: "3-6", name: "Collab 03-06", type: "collab", status: .occupied, description: "Design Review", imageName: "Collab 03-06")
    ]
    
    private let initialBalconies: [SpaceMock] = [
        SpaceMock(id: "b-l1", name: "Balcony lab 1", type: "balcony", status: .free, description: "Sunny spot", imageName: "Balcony lab 1"),
        SpaceMock(id: "b-l2-1", name: "First Balcony lab 2", type: "balcony", status: .occupied, description: "Smoking area", imageName: "Balcony lab 2"),
        SpaceMock(id: "b-l2-2", name: "Second Balcony lab 2", type: "balcony", status: .free, description: "Quiet corner", imageName: "2 Balcony lab 2"),
        SpaceMock(id: "b-l3", name: "Balcony lab 3", type: "balcony", status: .free, description: "View of the park", imageName: "Balcony lab 3"),
        SpaceMock(id: "b-s1", name: "Balcony Seminar 1", type: "balcony", status: .free, description: "", imageName: "Balcony Seminar 1"),
        SpaceMock(id: "b-s2", name: "Balcony Seminar 2", type: "balcony", status: .occupied, description: "Phone call", imageName: "Balcony Seminar 2")
    ]
    
    // --- INIT ---
    init() {
        // Initialize with mocks immediately so UI isn't empty
        self.collabs = initialCollabs
        self.balconies = initialBalconies
        
        // Then try to fetch real data
        loadFromCloud()
        
        // Start polling every 5 seconds to sync changes from other devices
        // This ensures Device B sees Device A's updates automatically
        Timer.publish(every: 5.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.loadFromCloud()
            }
            .store(in: &cancellables)
    }
    
    func loadFromCloud() {
        CloudKitManager.shared.fetchSpaces { [weak self] fetchedSpaces in
            guard let self = self else { return }
            
            if fetchedSpaces.isEmpty {
                // FIRST RUN EVER: Cloud is empty. Seed it!
                print("Cloud is empty. Seeding initial data...")
                let allMocks = self.initialCollabs + self.initialBalconies
                CloudKitManager.shared.seedInitialData(mocks: allMocks)
            } else {
                // Cloud has data! Use it.
                DispatchQueue.main.async {
                    self.collabs = fetchedSpaces.filter { $0.type == "collab" }
                    self.balconies = fetchedSpaces.filter { $0.type == "balcony" }
                }
            }
        }
    }
    
    // --- ACTIONS ---
    
    func updateSpace(id: String, isOccupied: Bool, icons: [String], note: String) {
        // 1. Update Local UI immediately (for speed)
        updateLocalState(id: id, isOccupied: isOccupied, icons: icons, note: note)
        
        // 2. Sync to Cloud
        // We create a temporary object to send to the manager
        let tempSpace = SpaceMock(id: id, name: "", type: "", status: isOccupied ? .occupied : .free, description: note, imageName: "")
        CloudKitManager.shared.updateSpaceInCloud(space: tempSpace)
    }
    
    private func updateLocalState(id: String, isOccupied: Bool, icons: [String], note: String) {
        spaceIcons[id] = icons
        
        if let idx = collabs.firstIndex(where: { $0.id == id }) {
            var space = collabs[idx]
            let newSpace = SpaceMock(id: space.id, name: space.name, type: space.type, status: isOccupied ? .occupied : .free, description: note, imageName: space.imageName)
            collabs[idx] = newSpace
            return
        }
        
        if let idx = balconies.firstIndex(where: { $0.id == id }) {
            var space = balconies[idx]
            let newSpace = SpaceMock(id: space.id, name: space.name, type: space.type, status: isOccupied ? .occupied : .free, description: note, imageName: space.imageName)
            balconies[idx] = newSpace
        }
    }
    
    func getIcons(for id: String) -> [String] {
        return spaceIcons[id] ?? []
    }
    
    var suggestions: [SpaceMock] {
        let all = collabs + balconies
        return all.shuffled()
    }
}
