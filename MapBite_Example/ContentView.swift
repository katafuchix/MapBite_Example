//
//  ContentView.swift
//  MapBite_Example
//
//  Created by cano on 2026/06/10.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var searchCompleter = SearchCompleter()
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: Constants.lat, longitude: Constants.lon),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    @State private var hasPerformedInitialSearch = false
    @State private var lookAroundScene: MKLookAroundScene?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                // 画面上半分はカフェ画像
                ZStack {
                    if let scene = lookAroundScene {
                        LookAroundPreview(initialScene: scene)
                            .frame(height: geometry.size.height / 2)
                    } else {
                        Color.black
                            .overlay(Text("Loading...").foregroundColor(.white))
                            .frame(height: geometry.size.height / 2)
                    }
                    
                    // カフェ店名・住所オーバーレイ
                    if let restaurant = searchCompleter.currentRestaurant {
                        VStack(alignment: .leading, spacing: 10) {
                            Spacer()
                            Text(restaurant.name)
                                .font(.title).fontWeight(.bold)
                            Text(restaurant.address)
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .foregroundColor(.white)
                    }
                }
                .frame(height: geometry.size.height / 2)
                .background(Color.black)
                .padding(.top, geometry.safeAreaInsets.top)
                
                // 画面下半分はマップ
                Map(position: $position) {
                    if let restaurant = searchCompleter.currentRestaurant {
                        Marker(restaurant.name, coordinate: restaurant.coordinate)
                            .tint(.red)
                    }
                }
                .frame(height: geometry.size.height / 2)
                .onMapCameraChange(frequency: .onEnd) { context in
                    if hasPerformedInitialSearch {
                        searchCompleter.search(for: context.region.center)
                    } else {
                        hasPerformedInitialSearch = true
                    }
                }
                // レストランが変わったらLookAroundを取得
                .onChange(of: searchCompleter.currentRestaurant) { _, newRestaurant in
                    guard let restaurant = newRestaurant else { return }
                    Task {
                        let request = MKLookAroundSceneRequest(coordinate: restaurant.coordinate)
                        lookAroundScene = try? await request.scene
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
