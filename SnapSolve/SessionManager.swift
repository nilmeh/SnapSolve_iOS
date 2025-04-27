//
//  SessionManager.swift
//  SnapSolve
//
//  Created by Niloy Meharchandani on 26/04/25.
//


// SessionManager.swift
import SwiftUI
import FirebaseAuth

class SessionManager: ObservableObject {
    @Published var isLoggedIn: Bool = false

    init() {
        listen()
    }

    func listen() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.isLoggedIn = user != nil
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
        self.isLoggedIn = false
    }
}
