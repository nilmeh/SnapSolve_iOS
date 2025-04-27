//
//  ContentView.swift
//  SnapSolve
//
import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 1 // Center tab (Camera) by default
    
    init() {
        // Create a consistent translucent tab bar appearance
        let appearance = UITabBarAppearance()
        
        // Set up a clean translucent background with reduced opacity
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterial) // More consistent blur
        appearance.backgroundColor = UIColor.clear // No additional color tint
        
        // Remove shadow and separator
        appearance.shadowColor = UIColor.clear
        appearance.shadowImage = UIImage()
        
        // Remove the line between icons and labels
        appearance.stackedLayoutAppearance.normal.badgeBackgroundColor = UIColor.clear
        
        // Enhance tab item appearance
        let itemAppearance = appearance.stackedLayoutAppearance
        
        // Improved typography with consistent vertical spacing
        itemAppearance.normal.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 10, weight: .medium),
            .foregroundColor: UIColor.secondaryLabel.withAlphaComponent(0.7)
        ]
        itemAppearance.selected.titleTextAttributes = [
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
            .foregroundColor: UIColor.systemBlue.withAlphaComponent(0.9)
        ]
        
        // Enhanced tab icon appearance with reduced opacity
        itemAppearance.normal.iconColor = UIColor.secondaryLabel.withAlphaComponent(0.7)
        itemAppearance.selected.iconColor = UIColor.systemBlue.withAlphaComponent(0.9)
        
        // Apply appearance consistently
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        
        // Ensure tab bar is translucent
        UITabBar.appearance().isTranslucent = true
        
        // Additional fix to ensure no divider line appears
        UITabBar.appearance().clipsToBounds = true
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TicketsListView()
            }
            .tabItem {
                Label("Tickets", systemImage: "ticket.fill")
            }
            .tag(0)
            
            NavigationStack {
                CameraView()
                    .ignoresSafeArea()
            }
            .tabItem {
                Label("Snap", systemImage: "camera.fill")
            }
            .tag(1)
            
            NavigationStack {
                IssuesMapView()
            }
            .tabItem {
                Label("Map", systemImage: "map.fill")
            }
            .tag(2)
        }
        .accentColor(Color.blue)
        .tint(Color.blue)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.light)
                .previewDisplayName("Light Mode")
            
            ContentView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark Mode")
        }
    }
}
