//   RouteView.swift
//   BigPoly
//
//   Created by: Grant Perry on 3/1/24 at 2:01 PM
//     Modified:
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import MapKit

	/// A view that calculates and displays a route between two points on a map, along with the travel time.
struct RouteView: View {
		// MARK: - State Properties
	@State private var route: MKRoute? // The route to be displayed.
	@State private var travelTime: String? // Formatted travel time for the route.

		// Predefined locations to demonstrate routing.
	@State var Home = CLLocationCoordinate2D(latitude: 37.000914, longitude: -76.442160)
	@State var WashingtonDC = CLLocationCoordinate2D(latitude: 38.907192, longitude: -77.036871)
	@State var Williamsburg = CLLocationCoordinate2D(latitude: 37.2707, longitude: -76.7075)
	@State var Noland1 = CLLocationCoordinate2D(latitude: 37.047821, longitude: -76.485286)
	@State var Noland2 = CLLocationCoordinate2D(latitude: 37.051075, longitude: -76.482014)

		// Visual properties for the polyline representing the route.
	private let gradient = LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
	private let stroke = StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round, dash: [8, 8])

		// MARK: - View Body
	var body: some View {
		Map {
				// Conditionally displays the route as a polyline on the map if available.
			if let route {
				MapPolyline(route.polyline)
					.stroke(.blue.gradient, lineWidth: 8)
			}
		}
		.overlay(alignment: .bottom, content: {
				// Displays travel information if available.
			HStack {
				if let travelTime {
					Text("Distance: \(gp.formatNumber(route!.distance / 1609.34, 2)) miles | Time: \(travelTime)")
						.padding()
						.font(.headline)
						.foregroundStyle(.black)
						.background(.ultraThinMaterial)
						.cornerRadius(15)
				}
			}
		})
		.onAppear(perform: {
				// Fetches the route when the view appears.
			fetchRouteFrom(from: Noland2, to: Noland1)
		})
	}
}

	// MARK: - Route Fetching
extension RouteView {

		/// Fetches a route from a source to a destination coordinate.
		/// - Parameters:
		///   - from: The starting point of the route.
		///   - to: The destination point of the route.
	private func fetchRouteFrom(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
		let request = MKDirections.Request()
		request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
		request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
		request.transportType = .walking // Specifies the transport type for the route.

		Task {
				// Attempts to calculate the route asynchronously.
			let result = try? await MKDirections(request: request).calculate()
			route = result?.routes.first // Stores the first route, if available.
			getTravelTime() // Calls to format the travel time for display.
		}
	}

		/// Formats and stores the travel time for the current route.
	private func getTravelTime() {
		guard let route else { return } // Ensures a route is available.
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .abbreviated // Shortens units to a compact form.
		formatter.allowedUnits = [.hour, .minute] // Includes only hours and minutes.
		travelTime = formatter.string(from: route.expectedTravelTime) // Formats the travel time.
	}
}


#Preview {
	RouteView()
}
