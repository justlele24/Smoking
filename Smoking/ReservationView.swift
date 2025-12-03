//
//  ReservationView.swift
//  Smoking
//
//  Created by Raffaele Barra on 03/12/25.
//


import SwiftUI

struct ReservationView: View {
    @Environment(\.presentationMode) var presentationMode
    let spaceName: String
    let spaceImage: String // Placeholder for your photo asset name
    
    @State private var description: String = ""
    @State private var isConfirmed: Bool = false

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                // Custom Nav Bar
                HStack {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Color(white: 0.15))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // Space Image (Where you will put your photos)
                // Use Image(spaceImage) when you have assets. Using System for now.
                Image(systemName: spaceImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                    .foregroundColor(.gray)
                    .background(Color(white: 0.1))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal)
                
                // Title
                VStack(spacing: 8) {
                    Text(spaceName)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Available for 2 hours")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
                
                // Input Form
                VStack(alignment: .leading, spacing: 12) {
                    Text("What are you doing?")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    TextField("e.g. Brainstorming, Lunch...", text: $description)
                        .padding()
                        .background(Color(white: 0.15))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Confirm Button
                Button(action: {
                    // Action: Call backend function here
                    isConfirmed = true
                    // In real app: dismiss after delay
                }) {
                    HStack {
                        if isConfirmed {
                            Image(systemName: "checkmark")
                            Text("Reserved!")
                        } else {
                            Text("Confirm Reservation")
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(isConfirmed ? Color.green : Color.blue)
                    .cornerRadius(28)
                    .shadow(color: (isConfirmed ? Color.green : Color.blue).opacity(0.5), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .disabled(isConfirmed)
            }
        }
        .navigationBarHidden(true)
    }
}

struct ReservationView_Previews: PreviewProvider {
    static var previews: some View {
        ReservationView(spaceName: "Collab 3-02", spaceImage: "table.furniture")
            .preferredColorScheme(.dark)
    }
}