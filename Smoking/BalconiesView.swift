import SwiftUI

struct BalconiesView: View {
    // --- Theme Colors ---
    let balconyColor1 = Color.green
    let balconyColor2 = Color.teal
    let balconyColor3 = Color.mint // Added a 3rd color for Space 3
    
    // --- States ---
    @State private var isSection1Expanded: Bool = true
    @State private var isSection2Expanded: Bool = true
    @State private var isSection3Expanded: Bool = true
    
    @State private var selectedSpace: SpaceMock?
    @State private var selectedSpaceColor: Color = .green
    
    // --- Data Storage ---
    // Store icons separately by ID: [SpaceID: [IconNames]]
    @State private var spaceIcons: [String: [String]] = [:]
    // Store notes separately by ID
    @State private var spaceNotes: [String: String] = [:]
    
    // --- Mock Data for Balconies ---
    // Space 1: Balconies 01-01 to 01-03
    @State private var balconySpace1: [SpaceMock] = [
        SpaceMock(id: "b-1-1", name: "Balcony 01-01", type: "balcony", status: .free, description: "Sunny spot", imageName: "balcony1"),
        SpaceMock(id: "b-1-2", name: "Balcony 01-02", type: "balcony", status: .occupied, description: "Smoking area", imageName: "balcony2"),
        SpaceMock(id: "b-1-3", name: "Balcony 01-03", type: "balcony", status: .free, description: "Quiet corner", imageName: "balcony3"),
    ]
    
    // Space 2: Balconies 02-01 to 02-03
    @State private var balconySpace2: [SpaceMock] = [
        SpaceMock(id: "b-2-1", name: "Balcony 02-01", type: "balcony", status: .free, description: "View of the park", imageName: "balcony1"),
        SpaceMock(id: "b-2-2", name: "Balcony 02-02", type: "balcony", status: .free, description: "", imageName: "balcony2"),
        SpaceMock(id: "b-2-3", name: "Balcony 02-03", type: "balcony", status: .occupied, description: "Phone call", imageName: "balcony3"),
    ]
    
    // Space 3: Balconies 03-01 to 03-03
    @State private var balconySpace3: [SpaceMock] = [
        SpaceMock(id: "b-3-1", name: "Balcony 03-01", type: "balcony", status: .free, description: "", imageName: "balcony4"),
        SpaceMock(id: "b-3-2", name: "Balcony 03-02", type: "balcony", status: .free, description: "", imageName: "balcony1"),
        SpaceMock(id: "b-3-3", name: "Balcony 03-03", type: "balcony", status: .free, description: "", imageName: "balcony2"),
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("Balconies")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 20)
                    .padding(.horizontal)
                
                // Group 1: Space 1
                DisclosureGroup(isExpanded: $isSection1Expanded) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(balconySpace1) { space in
                            Button(action: {
                                selectedSpace = space
                                selectedSpaceColor = balconyColor1
                            }) {
                                BalconySpaceCard(space: space, color: balconyColor1, activeIcons: spaceIcons[space.id] ?? [])
                            }
                        }
                    }
                    .padding(.top, 10)
                } label: {
                    BalconySectionHeader(title: "Balconies Space 1", accentColor: balconyColor1)
                }
                .accentColor(balconyColor1)
                .padding(.horizontal)
                
                // Group 2: Space 2
                DisclosureGroup(isExpanded: $isSection2Expanded) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(balconySpace2) { space in
                            Button(action: {
                                selectedSpace = space
                                selectedSpaceColor = balconyColor2
                            }) {
                                BalconySpaceCard(space: space, color: balconyColor2, activeIcons: spaceIcons[space.id] ?? [])
                            }
                        }
                    }
                    .padding(.top, 10)
                } label: {
                    BalconySectionHeader(title: "Balconies Space 2", accentColor: balconyColor2)
                }
                .accentColor(balconyColor2)
                .padding(.horizontal)
                
                // Group 3: Space 3
                DisclosureGroup(isExpanded: $isSection3Expanded) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(balconySpace3) { space in
                            Button(action: {
                                selectedSpace = space
                                selectedSpaceColor = balconyColor3
                            }) {
                                BalconySpaceCard(space: space, color: balconyColor3, activeIcons: spaceIcons[space.id] ?? [])
                            }
                        }
                    }
                    .padding(.top, 10)
                } label: {
                    BalconySectionHeader(title: "Balconies Space 3", accentColor: balconyColor3)
                }
                .accentColor(balconyColor3)
                .padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .background(Color.black)
        .navigationBarHidden(true)
        // --- THE POP-OVER SHEET ---
        .sheet(item: $selectedSpace) { space in
            BalconyOccupancySheetView(
                space: space,
                themeColor: selectedSpaceColor,
                currentIcons: spaceIcons[space.id] ?? [],
                currentNote: spaceNotes[space.id] ?? "",
                onConfirm: { isOccupied, icons, note in
                    updateSpace(id: space.id, isOccupied: isOccupied, icons: icons, note: note)
                }
            )
        }
    }
    
    // Logic to update space
    func updateSpace(id: String, isOccupied: Bool, icons: [String], note: String) {
        spaceIcons[id] = icons
        spaceNotes[id] = note
        
        func updateArray(_ arr: inout [SpaceMock]) {
            if let index = arr.firstIndex(where: { $0.id == id }) {
                let old = arr[index]
                let newSpace = SpaceMock(
                    id: old.id,
                    name: old.name,
                    type: old.type,
                    status: isOccupied ? .occupied : .free,
                    description: note,
                    imageName: old.imageName
                )
                arr[index] = newSpace
            }
        }
        
        updateArray(&balconySpace1)
        updateArray(&balconySpace2)
        updateArray(&balconySpace3)
    }
}

// --- BALCONY SHEET VIEW ---
struct BalconyOccupancySheetView: View {
    let space: SpaceMock
    let themeColor: Color
    let currentIcons: [String]
    let currentNote: String
    var onConfirm: (Bool, [String], String) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isInSpace = false
    @State private var isSmoking = false
    @State private var notes: String = ""
    
    // Computed property for preview
    var previewSpace: SpaceMock {
        let status: SpaceStatus = isInSpace ? .occupied : space.status
        return SpaceMock(id: space.id, name: space.name, type: space.type, status: status, description: notes, imageName: space.imageName)
    }
    
    var activeIcons: [String] {
        var icons: [String] = []
        if isSmoking { icons.append("cigarette") } // Use special key for cigarette
        return icons
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading, spacing: 24) {
                
                // Close Button
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
                
                // Card Preview
                Text("Card Preview")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.bottom, -15)
                
                BalconySpaceCard(
                    space: previewSpace,
                    color: themeColor,
                    activeIcons: activeIcons
                )
                
                Divider()
                
                // Controls
                ScrollView {
                    VStack(spacing: 20) {
                        // 1. Occupancy
                        BalconyToggleRow(title: "Are you in this space?", isOn: $isInSpace, icon: "person.fill")
                        
                        // 2. Smoking Toggle
                        BalconyToggleRow(title: "Smoking?", isOn: $isSmoking, icon: "flame.fill", isCigarette: true)
                        
                        // 3. Notes TextField
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Short Notes", systemImage: "note.text")
                                .font(.headline)
                            
                            TextField("e.g. Taking a break...", text: $notes)
                                .padding()
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(12)
                        }
                        .padding(.top, 4)
                    }
                }
                
                Spacer()
                
                // Confirm Button
                Button(action: {
                    onConfirm(isInSpace, activeIcons, notes)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Confirm")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(Color.green) // Green for balconies usually looks good
                        .cornerRadius(16)
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 24)
        }
        .onAppear {
            isInSpace = (space.status == .occupied)
            isSmoking = currentIcons.contains("cigarette")
            notes = currentNote
        }
    }
}

// --- HELPER COMPONENTS ---

struct BalconyToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let icon: String
    var isCigarette: Bool = false
    
    var body: some View {
        HStack {
            if isCigarette {
                Text("🚬")
                    .font(.system(size: 20))
                    .frame(width: 30)
            } else {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isOn ? .green : .gray)
                    .frame(width: 30)
            }
            
            Text(title)
                .font(.headline)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.green)
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct BalconySectionHeader: View {
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

struct BalconySpaceCard: View {
    let space: SpaceMock
    let color: Color
    var activeIcons: [String] = []
    
    var isOccupied: Bool { space.status == .occupied }
    
    var body: some View {
        ZStack {
            // Background Image
            Image(space.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 130)
                .clipped()
                .opacity(0.4)
            
            // Tint Overlay
            Color.black.opacity(0.4)
            color.opacity(0.1)
            
            // Content
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
                
                VStack(alignment: .leading, spacing: 4) {
                    // Display Icons on top
                    if !activeIcons.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(activeIcons, id: \.self) { icon in
                                Group {
                                    if icon == "cigarette" {
                                        Text("🚬")
                                            .font(.system(size: 10))
                                    } else {
                                        Image(systemName: icon)
                                            .font(.system(size: 12))
                                    }
                                }
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.red.opacity(0.6)) // Red background for warning style
                                .clipShape(Circle())
                            }
                        }
                        .padding(.bottom, 4)
                    }
                    
                    // Name
                    Text(space.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    // Description/Notes (Shown if available)
                    if !space.description.isEmpty {
                        Text(space.description)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                }
            }
            .padding(16)
        }
        .frame(height: 130)
        .background(Color.black)
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(isOccupied ? Color.red : color.opacity(0.5), lineWidth: isOccupied ? 2 : 1))
    }
}

struct BalconiesView_Previews: PreviewProvider {
    static var previews: some View {
        BalconiesView()
            .preferredColorScheme(.dark)
    }
}
