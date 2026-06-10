//
//  SearchCompleter.swift
//  MapBite_Example
//
//  Created by cano on 2026/06/10.
//

import SwiftUI
import MapKit

@MainActor
@Observable
class SearchCompleter: NSObject {
    var currentRestaurant: Restaurant?
    
    private let completer = MKLocalSearchCompleter()
    
    override init() {
        super.init()
        completer.resultTypes = .pointOfInterest
        
        // Initialize
        currentRestaurant = Restaurant(
            name: "青山",
            address: "港区南青山2丁目",
            coordinate: CLLocationCoordinate2D(latitude: Constants.lat, longitude: Constants.lon)
        )
    }
    
    // 検索
    func search(for coordinate: CLLocationCoordinate2D) {
        Task {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = "カフェ"
            request.region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 1000,
                longitudinalMeters: 1000
            )
            
            let search = MKLocalSearch(request: request)
            
            do {
                let response = try await search.start()
                
                // ランダムにカフェを一件取得
                guard let randomItem = response.mapItems.randomElement() else {
                    return
                }
                
                currentRestaurant = Restaurant(
                    name: randomItem.name ?? "Unknown",
                    address: randomItem.addressRepresentations?
                        .fullAddress(includingRegion: true, singleLine: true)
                        ?? "Unknown address",
                    coordinate: randomItem.location.coordinate,
                )
            } catch {
                print("Search error:", error)
            }
        }
    }
}
