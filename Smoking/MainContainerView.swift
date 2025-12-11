import SwiftUI

struct MainContainerView: View {
    // Access the shared manager
    @EnvironmentObject var spaceManager: SpaceManager
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        // BINDING: The TabView now reads/writes to the Manager's selectedTab
        TabView(selection: $spaceManager.selectedTab) {
            // Tab 0: HOME
            NavigationView {
                HomeView()
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(0)
            
            // Tab 1: COLLABS
            NavigationView {
                CollabsView()
            }
            .tabItem {
                Label("Collabs", systemImage: "sofa.fill")
            }
            .tag(1)
            
            // Tab 2: BALCONIES
            NavigationView {
                BalconiesView()
            }
            .tabItem {
                Label("Balconies", systemImage: "cloud.sun.fill")
            }
            .tag(2)
        }
        .accentColor(.blue)
    }
}

struct MainContainerView_Previews: PreviewProvider {
    static var previews: some View {
        MainContainerView()
            .environmentObject(SpaceManager())
            .preferredColorScheme(.dark)
    }
}
