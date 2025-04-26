//
//  Ticket.swift
//  SnapSolve
//
//  Created by Niloy Meharchandani on 25/04/25.
//


// Ticket.swift
import Foundation
import CoreLocation

struct Ticket: Identifiable {
    let id: String
    let imageData: Data
    let location: CLLocationCoordinate2D?
    let analysis: AnalysisResult
}

