//   ShowHistoryWeather.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/25/24 at 10:21 AM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import CoreLocation

//import Observation
// This is a test to see if weather is loading correctly. HINT: it is.

struct HistoryCastView: View {
	@State var pastCast = PastForecast()
	var home = CLLocationCoordinate2D(latitude: 37.000914, longitude: -76.442160)
	@State private var startDate = Date()
	@State private var endDate = Date().addingTimeInterval(3600)
	@State var weatherKit = WeatherKitManager()


	var body: some View {
		VStack {
			Text("Weather for Home on...")
				.font(.title)
				.foregroundColor(.white)
			DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
				.padding()
//			DatePicker("End Date", selection: $endDate, displayedComponents: .date)
//				.padding()
			Button("GO") {

				Task {
					await weatherKit.fetchPastCast(forWhere: CLLocation(latitude: home.latitude, longitude: home.longitude),
															 forWhenStart: startDate,
															 forWhenEnd: startDate.addingTimeInterval(86400),
															 pastCast: pastCast)
				}
			}
//			.disabled(startDate >= endDate) // Disable the button if startDate is not strictly before endDate
			.padding()

			// Display PastForecast properties
			if let symbolName = pastCast.symbolName {
				Image(systemName: symbolName)
//				Text("Symbol: \(symbolName)")
			}
			if let condition = pastCast.condition {
				Text("Condition: \(condition)")
			}
			if let minTemp = pastCast.minTemp {
				Text("Min Temp: \(weatherKit.cTOf(minTemp))")
			}
			if let maxTemp = pastCast.maxTemp {
				Text("Max Temp: \(weatherKit.cTOf(maxTemp))")
			}
			if let windSpeed = pastCast.windSpeed {
				Text("Wind Speed: \(windSpeed)")
			}
			if let precip = pastCast.precip {
				Text("Precipitation: \(precip)")
			}
		}
		.background(.blue.gradient)
		.foregroundColor(.gpGreen)
		.frame(maxWidth: .infinity, maxHeight: .infinity) // Expand to fill the available space
		.background(.blue.gradient)
		.edgesIgnoringSafeArea(.all) // Extend the background color to the edges of the screen
//		.padding()

		}
	}

#Preview {
	HistoryCastView()
}
