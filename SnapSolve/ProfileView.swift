//
//  ProfileView.swift
//  SnapSolve
//
//  Created by Niloy Meharchandani on 04/28/25.
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var user: User? = Auth.auth().currentUser

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Profile Icon
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                    .padding(.top, 40)

                // User details
                VStack(spacing: 8) {
                    if let user = user {
                        Text(user.displayName ?? "No Name")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text(user.email ?? "No Email")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Log Out Button
                Button(action: {
                    sessionManager.signOut()
                }) {
                    Text("Log Out")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .environmentObject(SessionManager())
    }
}