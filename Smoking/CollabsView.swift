import SwiftUI

struct CollabsView: View {
    @EnvironmentObject var manager: SpaceManager
    
    // --- Theme Colors ---
    let space1Color = Color(red: 0.25, green: 0.88, blue: 0.82)
    let space2Color = Color.yellow
    let space3Color = Color.orange
    
    @State private var isSpace1Expanded: Bool = true
    @State private var isSpace2Expanded: Bool = true
    @State private var isSpace3Expanded: Bool = true
    
    @State private var selectedSpace: SpaceMock?
    @State private var selectedSpaceColor: Color = .blue
    
    // Filtered lists from Manager
    var space1: [SpaceMock] { manager.collabs.filter { $0.id.hasPrefix("1-") } }
    var space2: [SpaceMock] { manager.collabs.filter { $0.id.hasPrefix("2-") } }
    var space3: [SpaceMock] { manager.collabs.filter { $0.id.hasPrefix("3-") } }
    
    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Collabs").font(.system(size: 34, weight: .bold)).foregroundColor(.white).padding(.top, 20).padding(.horizontal)
                
                // Group 1
                DisclosureGroup(isExpanded: $isSpace1Expanded) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(space1) { space in
                            Button(action: { selectedSpace = space; selectedSpaceColor = space1Color }) {
                                ColoredSpaceCard(space: space, color: space1Color, activeIcons: manager.getIcons(for: space.id))
                            }
                        }
                    }
                    .padding(.top, 10)
                } label: { SectionHeader(title: "Collaborative Space 1", accentColor: space1Color) }
                .accentColor(space1Color).padding(.horizontal)
                
                // Group 2
                DisclosureGroup(isExpanded: $isSpace2Expanded) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(space2) { space in
                            Button(action: { selectedSpace = space; selectedSpaceColor = space2Color }) {
                                ColoredSpaceCard(space: space, color: space2Color, activeIcons: manager.getIcons(for: space.id))
                            }
                        }
                    }
                    .padding(.top, 10)
                } label: { SectionHeader(title: "Collaborative Space 2", accentColor: space2Color) }
                .accentColor(space2Color).padding(.horizontal)
                
                // Group 3
                DisclosureGroup(isExpanded: $isSpace3Expanded) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(space3) { space in
                            Button(action: { selectedSpace = space; selectedSpaceColor = space3Color }) {
                                ColoredSpaceCard(space: space, color: space3Color, activeIcons: manager.getIcons(for: space.id))
                            }
                        }
                    }
                    .padding(.top, 10)
                } label: { SectionHeader(title: "Collaborative Space 3", accentColor: space3Color) }
                .accentColor(space3Color).padding(.horizontal)
            }
            .padding(.bottom, 20)
        }
        .background(Color.black).navigationBarHidden(true)
        .sheet(item: $selectedSpace) { space in
            OccupancySheetView(
                space: space,
                themeColor: selectedSpaceColor,
                currentIcons: manager.getIcons(for: space.id),
                currentNote: space.description,
                onConfirm: { isOccupied, icons, note in
                    manager.updateSpace(id: space.id, isOccupied: isOccupied, icons: icons, note: note)
                }
            )
        }
    }
}

// ... OccupancySheetView and other helpers remain exactly the same as previous version ...
// (I am omitting the long helper code here to save space, but you should keep the exact same Sheet, ToggleRows, Cards, etc. from the previous successful iteration, just ensure the sheet connects to manager actions as shown above)

// (Include rest of the file content from previous CollabsView.swift, ensuring ColoredSpaceCard etc are present)
// For completeness of the file block, I will include the critical components:

struct OccupancySheetView: View {
    let space: SpaceMock
    let themeColor: Color
    let currentIcons: [String]
    let currentNote: String
    var onConfirm: (Bool, [String], String) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isInSpace = false
    @State private var isListeningToMusic = false
    @State private var isWatchingMovie = false
    @State private var isPlayingInstrument = false
    @State private var notes: String = ""
    
    var previewSpace: SpaceMock {
        let status: SpaceStatus = isInSpace ? .occupied : space.status
        return SpaceMock(id: space.id, name: space.name, type: space.type, status: status, description: notes, imageName: space.imageName)
    }
    
    var activeIcons: [String] {
        var icons: [String] = []
        if isListeningToMusic { icons.append("music.note") }
        if isWatchingMovie { icons.append("film") }
        if isPlayingInstrument { icons.append("guitars") }
        return icons
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Card Preview").font(.caption).foregroundColor(.gray).padding(.bottom, -15).padding(.top, 10)
                    
                    ColoredSpaceCard(space: previewSpace, color: themeColor, activeIcons: activeIcons, showArrow: false)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            ToggleRow(title: "Are you in this space?", isOn: $isInSpace, icon: "person.fill")
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Activity").font(.caption).foregroundColor(.secondary).padding(.leading, 8)
                                VStack(spacing: 0) {
                                    CompactToggleRow(title: "Listening to music?", isOn: $isListeningToMusic, icon: "music.note", showDivider: true)
                                    CompactToggleRow(title: "Watching a movie?", isOn: $isWatchingMovie, icon: "film", showDivider: true)
                                    CompactToggleRow(title: "Playing an instrument?", isOn: $isPlayingInstrument, icon: "guitars", showDivider: false)
                                }
                                .background(Color(UIColor.secondarySystemBackground)).cornerRadius(12)
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Notes").font(.caption).foregroundColor(.secondary).padding(.leading, 8)
                                TextField("e.g. Taking a break...", text: $notes).padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(12)
                            }
                        }
                        .padding(.top, 20)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        onConfirm(isInSpace, activeIcons, notes)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("Confirm Occupation").font(.headline).fontWeight(.bold).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 55).background(.ultraThinMaterial).background(themeColor.opacity(0.8)).cornerRadius(16)
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark").symbolRenderingMode(.hierarchical)
                            .bold()
                    }
                }
            }
        }
        .onAppear {
            isInSpace = (space.status == .occupied)
            isListeningToMusic = currentIcons.contains("music.note")
            isWatchingMovie = currentIcons.contains("film")
            isPlayingInstrument = currentIcons.contains("guitars")
            notes = currentNote
        }
    }
}

// (Include CompactToggleRow, ToggleRow, SectionHeader, ColoredSpaceCard from previous context here)
struct CompactToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let icon: String
    let showDivider: Bool
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: icon).font(.system(size: 18)).foregroundColor(.blue).frame(width: 24)
                Text(title).font(.subheadline).fontWeight(.medium)
                Spacer()
                Toggle("", isOn: $isOn).labelsHidden()
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            if showDivider { Divider().padding(.leading, 56) }
        }
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let icon: String
    var body: some View {
        HStack {
            Image(systemName: icon).font(.system(size: 20)).foregroundColor(.blue).frame(width: 30)
            Text(title).font(.headline)
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden()
        }
        .padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(12)
    }
}

struct SectionHeader: View {
    let title: String
    let accentColor: Color
    var body: some View {
        HStack(spacing: 12) {
            Capsule().fill(accentColor).frame(width: 4, height: 24)
            Text(title).font(.title3).fontWeight(.bold).foregroundColor(accentColor).textCase(.uppercase)
            Spacer()
        }
        .padding(.vertical, 8).background(Color.black)
    }
}

struct ColoredSpaceCard: View {
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
                VStack(alignment: .leading, spacing: 8) {
                    if !activeIcons.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(activeIcons, id: \.self) { icon in
                                Image(systemName: icon).font(.system(size: 10)).foregroundColor(.white).padding(4).background(Color.white.opacity(0.2)).clipShape(Circle())
                            }
                        }
                    }
                    Text(space.name).font(.system(size: 16, weight: .bold)).foregroundColor(.white).lineLimit(1)
                    if !space.description.isEmpty {
                        Text(space.description).font(.caption).foregroundColor(.white.opacity(0.8)).lineLimit(1)
                    }
                }
            }
            .padding(16)
        }
        .frame(height: 130)
        .background(Color.black.opacity(0.5)).cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(isOccupied ? Color.red : color.opacity(0.5), lineWidth: isOccupied ? 2 : 1))
    }
}

struct CollabsView_Previews: PreviewProvider {
    static var previews: some View {
        CollabsView().environmentObject(SpaceManager()).preferredColorScheme(.dark)
    }
}
