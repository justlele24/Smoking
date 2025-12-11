import SwiftUI
import UIKit

struct HomeView: View {
    // Connect to shared data
    @EnvironmentObject var manager: SpaceManager
    
    @State private var currentIndex: Int = 0
    @State private var displaySpaces: [SpaceMock] = []
    
    // --- ACTIVITY CATEGORIES ---
    enum ActivityCategory: String, CaseIterable {
        case quiet = "Quiet"
        case crowded = "Crowded"
        case smoking = "Smoking"
        case movies = "Movies"
        case instrument = "Instrument"
        case music = "Music"
        
        var icon: String {
            switch self {
            case .quiet: return "moon.zzz.fill"
            case .crowded: return "person.3.fill"
            case .smoking: return "flame.fill" // Or cigarette custom icon logic
            case .movies: return "film.fill"
            case .instrument: return "guitars.fill"
            case .music: return "music.note"
            }
        }
        
        var color: Color {
            switch self {
            case .quiet: return .indigo
            case .crowded: return .orange
            case .smoking: return .gray
            case .movies: return .purple
            case .instrument: return .yellow
            case .music: return .pink
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                // --- HERO SECTION ---
                ZStack(alignment: .top) {
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(displaySpaces.indices, id: \.self) { index in
                                let space = displaySpaces[index]
                                let icons = manager.getIcons(for: space.id)
                                let isOccupied = space.status == .occupied
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .bottom) {
                                        // Background
                                        Rectangle()
                                            .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.black]), startPoint: .top, endPoint: .bottom))
                                            .overlay(
                                                Image(space.imageName)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                                    .clipped()
                                                    .opacity(0.8)
                                            )
                                            .cornerRadius(0)
                                        
                                        LinearGradient(colors: [.clear, .black.opacity(0.9)], startPoint: .center, endPoint: .bottom)
                                        
                                        // Content
                                        VStack(spacing: 8) {
                                            HStack(spacing: 8) {
                                                Circle().fill(isOccupied ? Color.red : Color.green).frame(width: 8, height: 8)
                                                Text(isOccupied ? "OCCUPIED" : "AVAILABLE")
                                                    .font(.caption2).fontWeight(.bold).foregroundColor(isOccupied ? .red : .green)
                                                
                                                if !icons.isEmpty {
                                                    Color.white.opacity(0.3).frame(width: 1, height: 12)
                                                    HStack(spacing: 6) {
                                                        ForEach(icons, id: \.self) { icon in
                                                            if icon == "cigarette" {
                                                                Image("cigarette_icon").renderingMode(.template).resizable().scaledToFit().frame(width: 14, height: 14).foregroundColor(.white)
                                                            } else {
                                                                Image(systemName: icon).font(.system(size: 12)).foregroundColor(.white)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                            .padding(.horizontal, 12).padding(.vertical, 6)
                                            .background(.ultraThinMaterial).clipShape(Capsule())
                                            
                                            Text(space.name).font(.system(size: 32, weight: .bold)).foregroundColor(.white)
                                            
                                            if !space.description.isEmpty {
                                                Text(space.description).font(.subheadline).foregroundColor(.gray).multilineTextAlignment(.center).padding(.horizontal)
                                            }
                                            
                                            Button(action: {
                                                let targetTab = (space.type == "collab") ? 1 : 2
                                                NotificationCenter.default.post(name: NSNotification.Name("SwitchTab"), object: targetTab)
                                            }) {
                                                Text("Explore")
                                                    .font(.headline).fontWeight(.semibold).foregroundColor(.white)
                                                    .frame(minWidth: 160, minHeight: 50)
                                                    .background(.ultraThinMaterial).clipShape(Capsule())
                                            }
                                            .padding(.top, 10)
                                        }
                                        .padding(.bottom, 80)
                                    }
                                    .rotation3DEffect(
                                        Angle(degrees: Double(geometry.frame(in: .global).minX) / -20),
                                        axis: (x: 0, y: 1, z: 0)
                                    )
                                }
                                .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                                .id(index)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .scrollPosition(id: Binding(get: { currentIndex }, set: { if let val = $0 { currentIndex = val } }))
                    .frame(height: 600)
                    
                    // Header
                    VStack {
                        LinearGradient(colors: [.black.opacity(0.7), .clear], startPoint: .top, endPoint: .bottom)
                            .frame(height: 120).allowsHitTesting(false)
                    }
                    HStack {
                        Text("Suggested").font(.system(size: 34, weight: .bold)).foregroundColor(.white) .padding(.top)
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "qrcode.viewfinder").font(.system(size: 20, weight: .semibold)).foregroundColor(.white).padding(12).background(.ultraThinMaterial).clipShape(Circle())
                        }
                    }
                    .padding(.horizontal).padding(.top, 60)
                    
                    // Page Control
                    VStack {
                        Spacer()
                        if !displaySpaces.isEmpty {
                            NativeTimerPageControl(numberOfPages: displaySpaces.count, currentPage: $currentIndex)
                                .frame(height: 50).padding(.bottom, 20)
                        }
                    }
                    .frame(height: 600)
                }
                
                // --- RECENT ACTIVITIES (FILTERS) ---
                VStack(alignment: .leading, spacing: 20) {
                    Text("Recent Activities")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(ActivityCategory.allCases, id: \.self) { category in
                                NavigationLink(destination: ActivityDetailView(category: category)) {
                                    LiveActivityCard(category: category, manager: manager)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 100)
                }
                .padding(.top, 20)
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarHidden(true)
        .background(Color.black)
        .onAppear {
            refreshCarousel()
        }
    }
    
    func refreshCarousel() {
        if displaySpaces.isEmpty {
            var items = manager.suggestions
            if let freeIndex = items.firstIndex(where: { $0.status == .free }) {
                let freeSpace = items.remove(at: freeIndex)
                items.insert(freeSpace, at: 0)
            }
            displaySpaces = items
        } else {
            displaySpaces = displaySpaces.map { localSpace in
                let updated = manager.collabs.first(where: { $0.id == localSpace.id })
                           ?? manager.balconies.first(where: { $0.id == localSpace.id })
                return updated ?? localSpace
            }
        }
    }
}

// --- NEW COMPONENT: LIVE ACTIVITY CARD ---
struct LiveActivityCard: View {
    let category: HomeView.ActivityCategory
    @ObservedObject var manager: SpaceManager
    
    var count: Int {
        let allSpaces = manager.collabs + manager.balconies
        return allSpaces.filter { space in
            switch category {
            case .quiet:
                return space.status == .free
            case .smoking:
                return manager.getIcons(for: space.id).contains("cigarette")
            case .crowded:
                return manager.getIcons(for: space.id).contains("person.3.fill")
            case .movies:
                return manager.getIcons(for: space.id).contains("film")
            case .instrument:
                return manager.getIcons(for: space.id).contains("guitars")
            case .music:
                return manager.getIcons(for: space.id).contains("music.note")
            }
        }.count
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                if category == .smoking {
                    Image("cigarette_icon")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(.white)
                } else {
                    Image(systemName: category.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                Spacer()
                Text("\(count)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(6)
                    .background(Color.black.opacity(0.2))
                    .clipShape(Circle())
            }
            .padding(.bottom, 20)
            
            Text(category.rawValue)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(20)
        .frame(width: 150, height: 120, alignment: .leading)
        .background(category.color)
        .cornerRadius(20)
    }
}

// --- NEW VIEW: ACTIVITY DETAIL LIST ---
struct ActivityDetailView: View {
    let category: HomeView.ActivityCategory
    @EnvironmentObject var manager: SpaceManager
    @Environment(\.presentationMode) var presentationMode
    
    var filteredSpaces: [SpaceMock] {
        let allSpaces = manager.collabs + manager.balconies
        return allSpaces.filter { space in
            switch category {
            case .quiet:
                return space.status == .free
            case .smoking:
                return manager.getIcons(for: space.id).contains("cigarette")
            case .crowded:
                return manager.getIcons(for: space.id).contains("person.3.fill")
            case .movies:
                return manager.getIcons(for: space.id).contains("film")
            case .instrument:
                return manager.getIcons(for: space.id).contains("guitars")
            case .music:
                return manager.getIcons(for: space.id).contains("music.note")
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .padding(10)
                            .background(Color(UIColor.systemGray6).opacity(0.2))
                            .clipShape(Circle())
                    }
                    Text(category.rawValue)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.top, 20)
                
                if filteredSpaces.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No spaces found matching '\(category.rawValue)' right now.")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 50)
                } else {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(filteredSpaces) { space in
                            // Navigate to the tab when clicked
                            Button(action: {
                                let targetTab = (space.type == "collab") ? 1 : 2
                                NotificationCenter.default.post(name: NSNotification.Name("SwitchTab"), object: targetTab)
                            }) {
                                // Re-using the HomeSpaceCard style for consistency
                                HomeSpaceCard(
                                    space: space,
                                    color: category.color,
                                    activeIcons: manager.getIcons(for: space.id)
                                )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

// ... NativeTimerPageControl, HomeSpaceCard, etc. from previous versions ...
// (Omitting standard helpers like NativeTimerPageControl, HomeSpaceCard for brevity as they are unchanged,
// ensuring they are present in the final file)

struct NativeTimerPageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int
    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.backgroundStyle = .prominent
        control.allowsContinuousInteraction = true
        control.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        control.currentPageIndicatorTintColor = UIColor.white
        let progress = UIPageControlTimerProgress(preferredDuration: 3.0)
        progress.resetsToInitialPageAfterEnd = true
        progress.delegate = context.coordinator
        control.progress = progress
        control.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        return control
    }
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.numberOfPages = numberOfPages
        uiView.currentPage = currentPage
        if let progress = uiView.progress as? UIPageControlTimerProgress { if !progress.isRunning { progress.resumeTimer() } }
    }
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    class Coordinator: NSObject, UIPageControlTimerProgressDelegate {
        var parent: NativeTimerPageControl
        init(_ parent: NativeTimerPageControl) { self.parent = parent }
        @objc func valueChanged(_ sender: UIPageControl) { parent.currentPage = sender.currentPage }
        func pageControlProgress(_ progress: UIPageControlProgress, didFinishWithPage page: Int) {
            guard parent.numberOfPages > 0 else { return }
            let nextPage = (page + 1) % parent.numberOfPages
            DispatchQueue.main.async { withAnimation { self.parent.currentPage = nextPage } }
        }
    }
}

struct HomeSpaceCard: View {
    let space: SpaceMock
    let color: Color
    var activeIcons: [String] = []
    var showArrow: Bool = true
    var isOccupied: Bool { space.status == .occupied }
    var body: some View {
        ZStack {
            Image(space.imageName).resizable().scaledToFill().frame(height: 130).clipped().opacity(0.4)
            Color.black.opacity(0.4)
            color.opacity(0.1)
            VStack(alignment: .leading) {
                HStack {
                    Circle().fill(isOccupied ? Color.red : Color.green).frame(width: 12, height: 12).shadow(color: isOccupied ? Color.red.opacity(0.6) : Color.green.opacity(0.6), radius: 4)
                    Spacer()
                    if showArrow {
                        Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold)).foregroundColor(.white).padding(6).overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                    }
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    if !activeIcons.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(activeIcons, id: \.self) { icon in
                                Group {
                                    if icon == "cigarette" {
                                        Image("cigarette_icon").renderingMode(.template).resizable().scaledToFit().frame(width: 14, height: 14)
                                    } else {
                                        Image(systemName: icon).font(.system(size: 12))
                                    }
                                }
                                .foregroundColor(.white).padding(4).background(Color.red.opacity(0.6)).clipShape(Circle())
                            }
                        }
                        .padding(.bottom, 4)
                    }
                    Text(space.name).font(.system(size: 16, weight: .bold)).foregroundColor(.white).lineLimit(1)
                    if !space.description.isEmpty {
                        Text(space.description).font(.caption).foregroundColor(.white.opacity(0.7)).lineLimit(1)
                    }
                }
            }
            .padding(16)
        }
        .frame(height: 130).background(Color.black.opacity(0.5)).cornerRadius(20).overlay(RoundedRectangle(cornerRadius: 20).stroke(isOccupied ? Color.red : color.opacity(0.5), lineWidth: isOccupied ? 2 : 1))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView { HomeView() }
            .environmentObject(SpaceManager())
            .preferredColorScheme(.dark)
    }
}
