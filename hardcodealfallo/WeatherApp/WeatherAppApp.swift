//
//  WeatherAppApp.swift
//  WeatherApp
//
import SwiftUI

@main
struct WeatherAppApp: App {
    var body: some Scene {
        WindowGroup {
            TestView(latitude: 25.6866, longitude: -100.3161)
        }
    }
}
