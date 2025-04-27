//
//  MainTabView.swift
//  SnapSolve
//
//  Created by Niloy Meharchandani on 26/04/25.
//


import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationView {
                TicketsListView()
            }
            .tabItem {
                Label("Tickets", systemImage: "list.bullet")
            }

            NavigationView {
                CameraView() // see note below
            }
            .tabItem {
                Label("Report", systemImage: "camera")
            }

            NavigationView {
                IssuesMapView()
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }
        }
        .accentColor(.blue)
    }
}