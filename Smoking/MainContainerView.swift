//
//  MainContainerView.swift
//  Smoking
//
//  Created by Raffaele Barra on 03/12/25.
//


import SwiftUI

struct MainContainerView: View {
    // Standard Native TabView Implementation
    // No custom init() required to hide things anymore
    
    var body: some View {
        TabView {
            // Tab 1: Collabs
            NavigationView {
                HomeView()
            }
            .tabItem {
                Label("Collabs", systemImage: "sofa.fill")
            }
            
            // Tab 2: Balcony
            NavigationView {
                // Placeholder for Balcony View
                VStack {
                    Text("Balcony View")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            }
            .tabItem {
                Label("Balconies", systemImage: "cloud.sun.fill")
            }
        }
        // Optional: Customize Tab Bar Color for Dark Mode
        .accentColor(.blue)
    }
}

struct MainContainerView_Previews: PreviewProvider {
    static var previews: some View {
        MainContainerView()
            .preferredColorScheme(.dark)
    }
}
