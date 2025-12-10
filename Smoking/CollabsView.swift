import SwiftUI

struct CollabsView: View {
    // --- Theme Colors ---
    let space1Color = Color(red: 0.25, green: 0.88, blue: 0.82) // Turquoise
    let space2Color = Color.yellow
    let space3Color = Color.orange
    
    // --- States ---
    @State private var isSpace1Expanded: Bool = true
    @State private var isSpace2Expanded: Bool = true
    @State private var isSpace3Expanded: Bool = true
    
    @State private var selectedSpace: SpaceMock?
    @State private var selectedSpaceColor: Color = .blue
    
    // --- Data Storage ---
    // Store icons separately by ID: [SpaceID: [IconNames]]
    @State private var spaceIcons: [String: [String]] = [:]
    
    // Arrays must be @State to be modified
    @State private var space1: [SpaceMock] = [
        SpaceMock(id: "1-1", name: "Collab 01-01", type: "collab", status: .free, description: "Sunny Side", imageName: "Collab 01-01"),
        SpaceMock(id: "1-2", name: "Collab 01-02", type: "collab", status: .occupied, description: "Meeting", imageName: "Collab 01-02"),
        SpaceMock(id: "1-3", name: "Collab 01-03", type: "collab", status: .free, description: "Quiet", imageName: "Collab 01-03"),
        SpaceMock(id: "1-4", name: "Collab 01-04", type: "collab", status: .free, description: "Near Entrance", imageName: "Collab 01-04"),
    ]
    
    @State private var space2: [SpaceMock] = [
        SpaceMock(id: "2-1", name: "Collab 02-01", type: "collab", status: .free, description: "", imageName: "room1"),
        SpaceMock(id: "2-2", name: "Collab 02-02", type: "collab", status: .occupied, description: "Brainstorming", imageName: "room2"),
        SpaceMock(id: "2-3", name: "Collab 02-03", type: "collab", status: .free, description: "", imageName: "room3"),
        SpaceMock(id: "2-4", name: "Collab 02-04", type: "collab", status: .free, description: "", imageName: "room4"),
        SpaceMock(id: "2-5", name: "Collab 02-05", type: "collab", status: .occupied, description: "Zoom Call", imageName: "room1"),
        SpaceMock(id: "2-6", name: "Collab 02-06", type: "collab", status: .free, description: "", imageName: "room2"),
    ]
    
    @State private var space3: [SpaceMock] = [
        SpaceMock(id: "3-1", name: "Collab 03-01", type: "collab", status: .free, description: "", imageName: "room3"),
        SpaceMock(id: "3-2", name: "Collab 03-02", type: "collab", status: .occupied, description: "Occupied by John", imageName: "room4"),
        SpaceMock(id: "3-3", name: "Collab 03-03", type: "collab", status: .free, description: "", imageName: "room1"),
        SpaceMock(id: "3-4", name: "Collab 03-04", type: "collab", status: .free, description: "", imageName: "room2"),
        SpaceMock(id: "3-5", name: "Collab 03-05", type: "collab", status: .free, description: "", imageName: "room3"),
        SpaceMock(id: "3-6", name: "Collab 03-06", type: "collab", status: .occupied, description: "Design Review", imageName: "room4"),
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("Collabs")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .padding(.horizontal)
                
                // Group 1
                DisclosureGroup(isExpanded: $isSpace1Expanded) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(space1) { space in
                            Button(action: {
                                selectedSpace = space
                                selectedSpaceColor = space1Color
                            }) {
                                ColoredSpaceCard(space: space, color: space1Color, activeIcons: spaceIcons[space.id] ?? [])
                            }
                        }
                    }
                    .padding(.top, 10)
                } label: {
                    SectionHeader(title: "Collaborative Space 1", accentColor: space1Color)
                }
                .accentColor(space1Color)
                .padding(.horizontal)
                
                // Group 2
                DisclosureGroup(isExpanded: $isSpace2Expanded) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(space2) { space in
                            Button(action: {
                                selectedSpace = space
                                selectedSpaceColor = space2Color
                            }) {
                                ColoredSpaceCard(space: space, color: space2Color, activeIcons: spaceIcons[space.id] ?? [])
                            }
                        }
                    }
                    .padding(.top, 10)
                } label: {
                    SectionHeader(title: "Collaborative Space 2", accentColor: space2Color)
                }
                .accentColor(space2Color)
                .padding(.horizontal)
                
                // Group 3
                DisclosureGroup(isExpanded: $isSpace3Expanded) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(space3) { space in
                            Button(action: {
                                selectedSpace = space
                                selectedSpaceColor = space3Color
                            }) {
                                ColoredSpaceCard(space: space, color: space3Color, activeIcons: spaceIcons[space.id] ?? [])
                            }
                        }
                    }
                    .padding(.top, 10)
                } label: {
                    SectionHeader(title: "Collaborative Space 3", accentColor: space3Color)
                }
                .accentColor(space3Color)
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .background(Color.black)
        .navigationBarHidden(true)
        // --- THE POP-OVER SHEET ---
        .sheet(item: $selectedSpace) { space in
            OccupancySheetView(
                space: space,
                themeColor: selectedSpaceColor,
                // Pass current icons so sheet knows its state
                currentIcons: spaceIcons[space.id] ?? [],
                onConfirm: { isOccupied, icons in
                    updateSpace(id: space.id, isOccupied: isOccupied, icons: icons)
                }
            )
        }
    }
    
    // Logic to find and update the space in the correct array
    func updateSpace(id: String, isOccupied: Bool, icons: [String]) {
        // Update Icons Map
        spaceIcons[id] = icons
        
        // Helper to update array
        func updateArray(_ arr: inout [SpaceMock]) {
            if let index = arr.firstIndex(where: { $0.id == id }) {
                let old = arr[index]
                let newStatus: SpaceStatus = isOccupied ? .occupied : .free
                // Create new copy with updated status
                let newSpace = SpaceMock(id: old.id, name: old.name, type: old.type, status: newStatus, description: old.description, imageName: old.imageName)
                arr[index] = newSpace
            }
        }
        
        updateArray(&space1)
        updateArray(&space2)
        updateArray(&space3)
    }
}

// --- NEW VIEW: THE POP-OVER FORM ---
struct OccupancySheetView: View {
    let space: SpaceMock
    let themeColor: Color
    let currentIcons: [String] // Receive previously saved icons
    var onConfirm: (Bool, [String]) -> Void // Callback to save changes
    
    @Environment(\.presentationMode) var presentationMode
    
    // Toggles State
    @State private var isInSpace = false
    @State private var isListeningToMusic = false
    @State private var isWatchingMovie = false
    @State private var isPlayingInstrument = false
    
    // Computed property to create a temporary "Preview" space object
    var previewSpace: SpaceMock {
        let status: SpaceStatus = isInSpace ? .occupied : space.status
        return SpaceMock(id: space.id, name: space.name, type: space.type, status: status, description: space.description, imageName: space.imageName)
    }
    
    var activeIcons: [String] {
        var icons: [String] = []
        if isListeningToMusic { icons.append("music.note") }
        if isWatchingMovie { icons.append("film") }
        if isPlayingInstrument { icons.append("guitars") }
        return icons
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 24) {
                
                // --- CLOSE BUTTON ---
                HStack {
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.secondary)
                            .padding(8)
                            .background(Color.secondary.opacity(0.2))
                            .clipShape(Circle())
                    }
                }
                .padding(.top, 20)
                
                // --- PREVIEW OF THE CARD ---
                Text("Card Preview")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, -15)
                
                ColoredSpaceCard(
                    space: previewSpace,
                    color: themeColor,
                    activeIcons: activeIcons
                )
                
                Divider()
                
                // Questions / Toggles
                ScrollView {
                    VStack(spacing: 20) {
                        ToggleRow(title: "Are you in this space?", isOn: $isInSpace, icon: "person.fill")
                        ToggleRow(title: "Listening to music?", isOn: $isListeningToMusic, icon: "music.note")
                        ToggleRow(title: "Watching a movie?", isOn: $isWatchingMovie, icon: "film")
                        ToggleRow(title: "Playing an instrument?", isOn: $isPlayingInstrument, icon: "guitars")
                    }
                }
                
                Spacer()
                
                // Confirm Button
                Button(action: {
                    // Send data back to main view
                    onConfirm(isInSpace, activeIcons)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Confirm Occupation")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color.blue)
                        .cornerRadius(16)
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            // SYNC TOGGLES WITH SAVED STATE
            isInSpace = (space.status == .occupied)
            isListeningToMusic = currentIcons.contains("music.note")
            isWatchingMovie = currentIcons.contains("film")
            isPlayingInstrument = currentIcons.contains("guitars")
        }
    }
}

// Helper for the Toggle Rows
struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden() // Hides the default text label since we made our own
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

// ... SectionHeader remains same ...
struct SectionHeader: View {
    let title: String
    let accentColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Capsule().fill(accentColor).frame(width: 4, height: 24)
            Text(title).font(.title3).fontWeight(.bold).foregroundColor(accentColor).textCase(.uppercase)
            Spacer()
        }
        .padding(.vertical, 8)
        .background(Color.black)
    }
}

// --- UPDATED CARD TO SUPPORT ICONS ON TOP ---
struct ColoredSpaceCard: View {
    let space: SpaceMock
    let color: Color
    // New Optional Parameter for icons
    var activeIcons: [String] = []
    
    var isOccupied: Bool { space.status == .occupied }
    
    var body: some View {
        ZStack {
            // --- BACKGROUND IMAGE ---
            Image(space.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 130)
                .clipped()
                .opacity(0.4) // Soft image background
            
            // --- CARD CONTENT ---
            VStack(alignment: .leading) {
                HStack {
                    // Status Dot
                    Circle()
                        .fill(isOccupied ? Color.red : Color.green)
                        .frame(width: 12, height: 12)
                        .shadow(color: isOccupied ? Color.red.opacity(0.6) : Color.green.opacity(0.6), radius: 4)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(6)
                        .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 1))
                }
                
                Spacer()
                
                // Name + Icons (Now vertically stacked)
                VStack(alignment: .leading, spacing: 8) {
                    // Display Icons on top
                    if !activeIcons.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(activeIcons, id: \.self) { icon in
                                Image(systemName: icon)
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                                    .padding(4)
                                    .background(Color.white.opacity(0.2))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    
                    // Name below icons
                    Text(space.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
            }
            .padding(16)
        }
        .frame(height: 130) // Increased height slightly for new layout
        // Remove the solid color background
        // .background(color.opacity(0.15))
        .background(Color.black.opacity(0.5)) // Add a dark overlay for readability
        .cornerRadius(20)
        // BORDER changes to RED if occupied
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(isOccupied ? Color.red : color.opacity(0.5), lineWidth: isOccupied ? 2 : 1))
    }
}

struct CollabsView_Previews: PreviewProvider {
    static var previews: some View {
        CollabsView()
            .preferredColorScheme(.dark)
    }
}
