
/// ``fullMapmetricsView.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/14/24 at 12:51 PM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//


import SwiftUI

/// ``fullMapMetricsView``
/// A view component displaying the city name, workout date, and distance metrics related to a workout session.
/// This view uses a horizontal stack (`HStack`) to organize its content, with a vertical stack (`VStack`) for 
/// the city name and workout date, and distance information aligned to the trailing edge.
/// - Parameters:
///     - `cityName`: A `String` representing the name of the city where the workout took place.
///     - `workoutDate`: A `Date` indicating when the workout session occurred.
///
/// The body of the view is designed to present the workout details in a clear and visually appealing manner, 
/// featuring a background gradient, rounded corners, and a shadow for depth.
/// The `onAppear` modifier is available for any initialization tasks, though it's empty in this template.
///
/// - Note: The distance is fetched from a shared instance of `WorkoutCore` and formatted to two decimal places.
struct fullMapMetricsView: View {

	var cityName: String
	var workoutDate: Date

	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Text("\(cityName)")
					.font(.title)
					.bold()
				Text("  \(workoutDate, formatter: dateFormatter)")
			}
			Spacer()
			Text("Distance: \(String(format: "%.2f", WorkoutCore.shared.distance)) km") // Assuming distance is in kilometers
		}
		.padding()
		.frame(maxWidth: .infinity)
		.background(.blue.gradient)
		.foregroundColor(.white)
		.cornerRadius(8)
		.shadow(color: .gray, radius: 5, x: 0, y: 2)
	}

	private var dateFormatter: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		return formatter
	}
}



#Preview {
	fullMapMetricsView(cityName: "Las Vegas", workoutDate: Date())
}
