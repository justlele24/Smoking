//
//  DetailGridView.swift
//  Smoking
//
//  Created by Raffaele Barra on 03/12/25.
//


import SwiftUI

struct DetailGridView: View {
    @Environment(\.presentationMode) var presentationMode
    
    // Mock Data representing sub-spaces
    let spaces: [SpaceMock] = [
        SpaceMock(id: "1", name: "Collab 03 - 01", type: "collab", status: .free, description: ""),
        SpaceMock(id: "2", name: "Collab 03 - 02", type: "collab", status: .occupied, description: ""),
        SpaceMock(id: "3", name: "Collab 03 - 03", type: "collab", status: .free, description: ""),
        SpaceMock(id: "4", name: "Collab 03 - 04", type: "collab", status: .free, description: ""),
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            
            // Custom Header
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    HStack(spacing: 5) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                    .cornerRadius(20)
                }
                Spacer()
                
                Image(systemName: "qrcode.viewfinder")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                    .padding(10)
                    .background(Color(red: 0.15, green: 0.15, blue: 0.15))
                    .clipShape(Circle())
            }
            .padding(.top, 10)
            
            Text("Collab 03")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 10)
            
            Text("Choose your Collab")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            
            // Grid
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(spaces) { space in
                    SpaceGridCard(space: space)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .navigationBarHidden(true)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct DetailGridView_Previews: PreviewProvider {
    static var previews: some View {
        DetailGridView()
            .preferredColorScheme(.dark)
    }
}