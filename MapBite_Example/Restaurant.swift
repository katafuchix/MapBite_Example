//
//  Restaurant.swift
//  MapBite_Example
//
//  Created by cano on 2026/06/10.
//

import SwiftUI
import MapKit

// 飲食店情報
struct Restaurant: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CLLocationCoordinate2D
    
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
        lhs.id == rhs.id
    }
}
