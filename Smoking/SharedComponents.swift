//
//  SharedComponents.swift
//  Smoking
//
//  Created by Raffaele Barra on 03/12/25.
//

import SwiftUI

// --- Component 1: Space Grid Card (The Red/Green box) ---
struct SpaceGridCard: View {
    let space: SpaceMock
    
    var isOccupied: Bool { space.status == .occupied }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Circle()
                    .fill(isOccupied ? Color.red : Color.green)
                    .frame(width: 12, height: 12)
                    .shadow(color: isOccupied ? Color.red.opacity(0.6) : Color.green.opacity(0.6), radius: 4)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .padding(6)
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
            
            Spacer()
            
            Text(space.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(16)
        .frame(height: 120)
        .background(Color(red: 0.08, green: 0.08, blue: 0.1))
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(isOccupied ? Color.red : Color.clear, lineWidth: isOccupied ? 2 : 0)
        )
    }
}

// --- Component 2: Activity Card (The blue square at bottom of Home) ---
struct ActivityCard: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .padding(.bottom, 20)
            
            Text(title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(20)
        .frame(width: 150, height: 120, alignment: .leading)
        .background(color)
        .cornerRadius(20)
    }
}

// --- Component 3: Tab Button (The pill shape button) ---
struct TabButton: View {
    let icon: String
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(text)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(width: 80, height: 50)
            .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
            .foregroundColor(isSelected ? .blue : .gray)
            .cornerRadius(25)
            .overlay(
                isSelected ?
                RoundedRectangle(cornerRadius: 25)
                    .stroke(LinearGradient(colors: [.blue.opacity(0.5), .clear], startPoint: .top, endPoint: .bottom), lineWidth: 1)
                : nil
            )
        }
    }
}

// --- Preview for Components ---
struct SharedComponents_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            VStack(spacing: 20) {
                SpaceGridCard(space: SpaceMock(id: "1", name: "Test Room", type: "collab", status: .occupied, description: ""))
                    .frame(width: 160)
                
                ActivityCard(icon: "star.fill", title: "Test", color: .blue)
                
                HStack {
                    TabButton(icon: "house", text: "Home", isSelected: true, action: {})
                    TabButton(icon: "house", text: "Home", isSelected: false, action: {})
                }
            }
        }
    }
}
