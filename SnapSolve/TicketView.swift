//
//  TicketView.swift
//  SnapSolve
//
//  Created by Niloy Meharchandani on 25/04/25.
//


// TicketView.swift
import SwiftUI
import CoreLocation

struct TicketView: View {
    let ticket: Ticket

    var body: some View {
        VStack(spacing: 20) {
            Text("Ticket ID: \(ticket.id)")
                .font(.headline)

            if let coord = ticket.location {
                Text("Location: \(coord.latitude), \(coord.longitude)")
            } else {
                Text("Location: unknown")
            }

            Text("Issue: \(ticket.analysis.description)")
            Text("Action: \(ticket.analysis.recommendedAction)")

            Spacer()
        }
        .padding()
    }
}

#Preview {
    
}
