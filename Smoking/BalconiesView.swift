import SwiftUI

struct BalconiesView: View {
    @EnvironmentObject var manager: SpaceManager
    
    // --- Theme Colors ---
    // (Colors logic...)
    
    @State private var selectedSpace: SpaceMock?
    @State private var selectedSpaceColor: Color = .green
    
    let columns = [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    
    func getBalconyColor(_ id: String) -> Color {
        // (Color logic same as before)
        switch id {
        case "b-l1": return .orange
        case "b-l2-1": return .yellow
        case "b-l2-2": return .blue
        case "b-l3": return .blue
        case "b-s1": return .red
        case "b-s2": return .yellow
        default: return .green
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Balconies").font(.system(size: 34, weight: .bold)).foregroundColor(.white).padding(.top, 20).padding(.horizontal)
                
                VStack(spacing: 12) {
                    BalconySectionHeader(title: "Academy Balconies", accentColor: .white).padding(.horizontal)
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        // READ FROM MANAGER
                        ForEach(manager.balconies) { space in
                            let specificColor = getBalconyColor(space.id)
                            Button(action: {
                                selectedSpace = space
                                selectedSpaceColor = specificColor
                            }) {
                                BalconySpaceCard(space: space, color: specificColor, activeIcons: manager.getIcons(for: space.id))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 20)
        }
        .background(Color.black).navigationBarHidden(true)
        .sheet(item: $selectedSpace) { space in
            BalconyOccupancySheetView(
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

// ... BalconyOccupancySheetView and helpers remain exactly the same ...
// (Omitting repetition, ensure you keep the BalconyOccupancySheetView, BalconySpaceCard, etc.)
// Just make sure BalconiesView_Previews has .environmentObject(SpaceManager())

struct BalconyOccupancySheetView: View {
    let space: SpaceMock
    let themeColor: Color
    let currentIcons: [String]
    let currentNote: String
    var onConfirm: (Bool, [String], String) -> Void
    
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isInSpace = false
    @State private var isSmoking = false
    @State private var isCrowded = false
    @State private var notes: String = ""
    
    var previewSpace: SpaceMock {
        let status: SpaceStatus = isInSpace ? .occupied : space.status
        return SpaceMock(id: space.id, name: space.name, type: space.type, status: status, description: notes, imageName: space.imageName)
    }
    
    var activeIcons: [String] {
        var icons: [String] = []
        if isSmoking { icons.append("cigarette") }
        if isCrowded { icons.append("person.3.fill") }
        return icons
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground).edgesIgnoringSafeArea(.all)
                
                VStack(alignment: .leading, spacing: 20) {
                    
                    Text("Card Preview").font(.caption).foregroundColor(.gray).padding(.bottom, -15).padding(.top, 10)
                    
                    BalconySpaceCard(space: previewSpace, color: themeColor, activeIcons: activeIcons, showArrow: false)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            BalconyToggleRow(title: "Are you in this space?", isOn: $isInSpace, icon: "person.fill")
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Environment").font(.caption).foregroundColor(.secondary).padding(.leading, 8)
                                VStack(spacing: 0) {
                                    BalconyCompactToggleRow(title: "Smoking?", isOn: $isSmoking, icon: "flame.fill", isCigarette: true, showDivider: true)
                                    BalconyCompactToggleRow(title: "Is it crowded?", isOn: $isCrowded, icon: "person.3.fill", isCigarette: false, showDivider: false)
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
                        Text("Confirm").font(.headline).fontWeight(.bold).foregroundColor(.white).frame(maxWidth: .infinity).frame(height: 55).background(.ultraThinMaterial).background(themeColor.opacity(0.8)).cornerRadius(16)
                    }
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 24)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark").symbolRenderingMode(.hierarchical).bold()
                    }
                }
            }
        }
        .onAppear {
            isInSpace = (space.status == .occupied)
            isSmoking = currentIcons.contains("cigarette")
            isCrowded = currentIcons.contains("person.3.fill")
            notes = currentNote
        }
    }
}

// ... Keep existing helpers (BalconySpaceCard, BalconyToggleRow, etc.) ...
// For brevity, assuming they are preserved.

struct BalconyCompactToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let icon: String
    var isCigarette: Bool
    let showDivider: Bool
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                if isCigarette {
                    Image("cigarette_icon").renderingMode(.template).resizable().scaledToFit().frame(width: 24, height: 24).foregroundColor(isOn ? .green : .gray)
                } else {
                    Image(systemName: icon).font(.system(size: 18).weight(.semibold)).foregroundColor(isOn ? .green : .gray).frame(width: 24)
                }
                Text(title).font(.subheadline).fontWeight(.medium)
                Spacer()
                Toggle("", isOn: $isOn).labelsHidden().tint(.green)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            if showDivider { Divider().padding(.leading, 56) }
        }
    }
}

struct BalconyToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let icon: String
    var body: some View {
        HStack {
            Image(systemName: icon).font(.system(size: 20)).foregroundColor(isOn ? .green : .gray).frame(width: 30)
            Text(title).font(.headline)
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden().tint(.green)
        }
        .padding().background(Color(UIColor.secondarySystemBackground)).cornerRadius(12)
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
        .padding(.vertical, 8).background(Color.black)
    }
}

struct BalconySpaceCard: View {
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
                                .foregroundColor(.white).padding(4).background(Color.gray.opacity(0.6)).clipShape(Circle())
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
        .frame(height: 130)
        .background(Color.black.opacity(0.5))
        .cornerRadius(20)
        .overlay(RoundedRectangle(cornerRadius: 20).stroke(isOccupied ? Color.red : color.opacity(0.5), lineWidth: isOccupied ? 2 : 1))
    }
}

struct BalconiesView_Previews: PreviewProvider {
    static var previews: some View {
        BalconiesView()
            .environmentObject(SpaceManager())
            .preferredColorScheme(.dark)
    }
}
