//
//  ProfileView.swift
//  SnapSolve
//
//  Created by Niloy Meharchandani on 04/28/25.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var sessionManager: SessionManager
    
    private var user: User? {
        Auth.auth().currentUser
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Subtle gradient background
                LinearGradient(
                    colors: [.white, Color(.systemGroupedBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    // Profile Header
                    VStack(spacing: 20) {
                        // Profile Icon with modern shadow
                        ZStack {
                            Circle()
                                .fill(.white)
                                .frame(width: 140, height: 140)
                                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 4)
                            
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 130, height: 130)
                            
                            if let photoURL = user?.photoURL {
                                AsyncImage(url: photoURL) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                } placeholder: {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 70, height: 70)
                                        .foregroundStyle(.blue)
                                }
                            } else {
                                Image(systemName: "person.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                    .foregroundStyle(.blue)
                            }
                        }
                        
                        // User Details
                        if let user = user {
                            VStack(spacing: 12) {
                                Text(user.displayName ?? "SnapSolve User")
                                    .font(.system(.title, design: .rounded, weight: .bold))
                                    .foregroundStyle(.primary)
                                
                                Text(user.email ?? "No email available")
                                    .font(.system(.title3, design: .rounded))
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 40)
                    
                    // Sign Out Button
                    Button(action: {
                        sessionManager.signOut()
                    }) {
                        Text("Sign Out")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .foregroundStyle(.white)
                            .background(
                                LinearGradient(
                                    colors: [.red, .red.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 3)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.secondary)
                            .background(Circle().fill(.white))
                    }
                }
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(SessionManager())
            .preferredColorScheme(.light)
        
        ProfileView()
            .environmentObject(SessionManager())
            .preferredColorScheme(.dark)
    }
}
