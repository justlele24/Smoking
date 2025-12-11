import SwiftUI

@main
struct AcademySpacesApp: App {
    // Create the shared manager once here
    @StateObject private var spaceManager = SpaceManager()
    
    var body: some Scene {
        WindowGroup {
            MainContainerView()
                .preferredColorScheme(.dark)
                .environmentObject(spaceManager) // Inject it into the environment
        }
    }
}
