import SwiftUI
import UIKit // Required for the native iOS 17 Page Control

// Local model for the Carousel
struct FeaturedCollab: Identifiable {
    let id = UUID()
    let name: String
    let location: String
    let imageName: String
}

struct HomeView: View {
    let featuredSpaces: [FeaturedCollab] = [
        FeaturedCollab(name: "Collab 3-05", location: "3rd Floor • Near Lab", imageName: "Collab 03-05"),
        FeaturedCollab(name: "Collab 2-04", location: "2nd Floor • Quiet Zone", imageName: "Collab 03-06"),
        FeaturedCollab(name: "Balcony Lab 3", location: "Main Hall • Sunny", imageName: "Balcony lab 3"),
        FeaturedCollab(name: "Collab 4-05", location: "4th Floor • Roof Access", imageName: "room4")
    ]
    
    @State private var currentIndex: Int = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                // --- HERO SECTION (Carousel + Header) ---
                ZStack(alignment: .top) {
                    
                    // 1. The Native ScrollView (Carousel)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(featuredSpaces.indices, id: \.self) { index in
                                let space = featuredSpaces[index]
                                
                                GeometryReader { geometry in
                                    ZStack(alignment: .bottom) {
                                        Rectangle()
                                            .fill(LinearGradient(
                                                gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.black]),
                                                startPoint: .top,
                                                endPoint: .bottom
                                            ))
                                            .overlay(
                                                Image(space.imageName)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: geometry.size.width, height: geometry.size.height)
                                                    .clipped()
                                                    .opacity(0.8)
                                            )
                                            .cornerRadius(0)
                                        
                                        // Gradient for text readability
                                        LinearGradient(
                                            colors: [.clear, .black.opacity(0.8)],
                                            startPoint: .center,
                                            endPoint: .bottom
                                        )
                                        
                                        VStack(spacing: 8) {
                                            Text(space.name)
                                                .font(.system(size: 32, weight: .bold))
                                                .foregroundColor(.white)
                                            
                                            Text(space.location)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            
                                            // NATIVE RESERVE BUTTON
                                            NavigationLink(destination: ReservationView(spaceName: space.name, spaceImage: space.imageName)) {
                                                Text("Reserve")
                                                    .fontWeight(.semibold)
                                                    .frame(minWidth: 140) // Give it a good tap area
                                            }
                                            .buttonStyle(.borderedProminent) // Native iOS Button Style
                                            .buttonBorderShape(.capsule)     // Native Capsule Shape
                                            .controlSize(.large)             // Nice and big
                                            .tint(.white)                    // White background (Hero style)
                                            .foregroundColor(.black)         // Black text for contrast
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
                    .scrollPosition(id: Binding(
                        get: { currentIndex },
                        set: { if let val = $0 { currentIndex = val } }
                    ))
                    .frame(height: 600)
                    
                    // 2. THE HEADER
                    VStack {
                        LinearGradient(
                            colors: [.black.opacity(0.7), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 120)
                        .allowsHitTesting(false)
                    }
                    
                    HStack {
                        Text("Collabs")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(.white)
                        Spacer()
                        
                        // NATIVE QR BUTTON (Glass Effect)
                        Button(action: {}) {
                            Image(systemName: "qrcode.viewfinder")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(10)
                                .background(.ultraThinMaterial) // Native Frosted Glass
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 60)
                    
                    // 3. THE NATIVE IOS 17 TIMER PAGE CONTROL
                    VStack {
                        Spacer()
                        NativeTimerPageControl(
                            numberOfPages: featuredSpaces.count,
                            currentPage: $currentIndex
                        )
                        .frame(height: 50)
                        .padding(.bottom, 20)
                    }
                    .frame(height: 600)
                }
                
                // Recent Activities...
                VStack(alignment: .leading, spacing: 20) {
                    Text("Recent Activities")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ActivityCard(icon: "film.fill", title: "Movie", color: .blue)
                            ActivityCard(icon: "mic.fill", title: "Karaoke", color: .blue)
                            ActivityCard(icon: "gamecontroller.fill", title: "Gaming", color: .purple)
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
    }
}

// --- NATIVE IOS 17+ PAGE CONTROL WRAPPER ---
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
        uiView.currentPage = currentPage
        
        if let progress = uiView.progress as? UIPageControlTimerProgress {
            if !progress.isRunning {
                progress.resumeTimer()
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIPageControlTimerProgressDelegate {
        var parent: NativeTimerPageControl
        
        init(_ parent: NativeTimerPageControl) {
            self.parent = parent
        }
        
        @objc func valueChanged(_ sender: UIPageControl) {
            parent.currentPage = sender.currentPage
        }
        
        func pageControlProgress(_ progress: UIPageControlProgress, didFinishWithPage page: Int) {
            let nextPage = (page + 1) % parent.numberOfPages
            DispatchQueue.main.async {
                withAnimation {
                    self.parent.currentPage = nextPage
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
        .preferredColorScheme(.dark)
    }
}
