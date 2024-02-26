//   HistForecast.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/24/24 at 11:09 AM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import Observation

@Observable
class PastForecast {
	var symbolName: String?
	var condition: String?
	var minTemp: Double?
	var maxTemp: Double?
	var windSpeed: Double?
	var precip: String?
}

