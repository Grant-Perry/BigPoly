//   Forecasts.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/24/24 at 11:10 AM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI

// utilized in WeatherKitManager
struct Forecasts: Identifiable {
	let id = UUID()
	let symbolName: String
	let minTemp: String
	let maxTemp: String

}
