import Foundation

struct SpaceMock: Identifiable {
    let id: String
    let name: String
    let type: String // "collab" or "balcony"
    let status: SpaceStatus
    let description: String
    let imageName: String // NEW: Added image property
}

enum SpaceStatus {
    case free
    case occupied
}
