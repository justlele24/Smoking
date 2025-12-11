import SwiftUI
import Combine

class SpaceManager: ObservableObject {
    // --- NAVIGATION STATE ---
    // 0 = Home, 1 = Collabs, 2 = Balconies
    @Published var selectedTab: Int = 0
    
    // --- MASTER LISTS ---
    @Published var collabs: [SpaceMock] = [
        // Space 1
        SpaceMock(id: "1-1", name: "Collab 01-01", type: "collab", status: .free, description: "Sunny Side", imageName: "Collab 01-01"),
        SpaceMock(id: "1-2", name: "Collab 01-02", type: "collab", status: .occupied, description: "Meeting", imageName: "Collab 01-02"),
        SpaceMock(id: "1-3", name: "Collab 01-03", type: "collab", status: .free, description: "Quiet", imageName: "Collab 01-03"),
        SpaceMock(id: "1-4", name: "Collab 01-04", type: "collab", status: .free, description: "Near Entrance", imageName: "Collab 01-04"),
        
        // Space 2
        SpaceMock(id: "2-1", name: "Collab 02-01", type: "collab", status: .free, description: "", imageName: "Collab 02-01"),
        SpaceMock(id: "2-2", name: "Collab 02-02", type: "collab", status: .occupied, description: "Brainstorming", imageName: "Collab 02-02"),
        SpaceMock(id: "2-3", name: "Collab 02-03", type: "collab", status: .free, description: "", imageName: "Collab 02-03"),
        SpaceMock(id: "2-4", name: "Collab 02-04", type: "collab", status: .free, description: "", imageName: "Collab 02-04"),
        SpaceMock(id: "2-5", name: "Collab 02-05", type: "collab", status: .occupied, description: "Zoom Call", imageName: "Collab 02-05"),
        SpaceMock(id: "2-6", name: "Collab 02-06", type: "collab", status: .free, description: "", imageName: "Collab 02-06"),
        
        // Space 3
        SpaceMock(id: "3-1", name: "Collab 03-01", type: "collab", status: .free, description: "", imageName: "Collab 03-01"),
        SpaceMock(id: "3-2", name: "Collab 03-02", type: "collab", status: .occupied, description: "Occupied by John", imageName: "Collab 03-02"),
        SpaceMock(id: "3-3", name: "Collab 03-03", type: "collab", status: .free, description: "", imageName: "Collab 03-03"),
        SpaceMock(id: "3-4", name: "Collab 03-04", type: "collab", status: .free, description: "", imageName: "Collab 03-04"),
        SpaceMock(id: "3-5", name: "Collab 03-05", type: "collab", status: .free, description: "", imageName: "Collab 03-05"),
        SpaceMock(id: "3-6", name: "Collab 03-06", type: "collab", status: .occupied, description: "Design Review", imageName: "Collab 03-06"),
    ]
    
    @Published var balconies: [SpaceMock] = [
        SpaceMock(id: "b-l1", name: "Balcony lab 1", type: "balcony", status: .free, description: "Sunny spot", imageName: "Balcony lab 1"),
        SpaceMock(id: "b-l2-1", name: "First Balcony lab 2", type: "balcony", status: .occupied, description: "Smoking area", imageName: "Balcony lab 2"),
        SpaceMock(id: "b-l2-2", name: "Second Balcony lab 2", type: "balcony", status: .free, description: "Quiet corner", imageName: "2 Balcony lab 2"),
        SpaceMock(id: "b-l3", name: "Balcony lab 3", type: "balcony", status: .free, description: "View of the park", imageName: "Balcony lab 3"),
        SpaceMock(id: "b-s1", name: "Balcony Seminar 1", type: "balcony", status: .free, description: "", imageName: "Balcony Seminar 1"),
        SpaceMock(id: "b-s2", name: "Balcony Seminar 2", type: "balcony", status: .occupied, description: "Phone call", imageName: "Balcony Seminar 2")
    ]
    
    @Published var spaceIcons: [String: [String]] = [
        "1-2": ["music.note", "mic.fill"],
        "2-2": ["laptopcomputer"],
        "2-5": ["video.fill"],
        "3-6": ["pencil.and.outline"],
        "b-l2-1": ["cigarette"],
        "b-s2": ["phone.fill"]
    ]
    
    // --- ACTIONS ---
    
    func updateSpace(id: String, isOccupied: Bool, icons: [String], note: String) {
        spaceIcons[id] = icons
        
        if let idx = collabs.firstIndex(where: { $0.id == id }) {
            var space = collabs[idx]
            let newSpace = SpaceMock(
                id: space.id,
                name: space.name,
                type: space.type,
                status: isOccupied ? .occupied : .free,
                description: note,
                imageName: space.imageName
            )
            collabs[idx] = newSpace
            return
        }
        
        if let idx = balconies.firstIndex(where: { $0.id == id }) {
            var space = balconies[idx]
            let newSpace = SpaceMock(
                id: space.id,
                name: space.name,
                type: space.type,
                status: isOccupied ? .occupied : .free,
                description: note,
                imageName: space.imageName
            )
            balconies[idx] = newSpace
        }
    }
    
    func getIcons(for id: String) -> [String] {
        return spaceIcons[id] ?? []
    }
    
    // Returns randomized suggestions for HomeView
    var suggestions: [SpaceMock] {
        let all = collabs + balconies
        return all.shuffled()
    }
}
