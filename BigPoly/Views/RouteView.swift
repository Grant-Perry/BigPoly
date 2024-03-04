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
// get/display directions from one CLLocaiton to another and display it on map with a polyLine overlay

struct RouteView: View {
	@State private var route: MKRoute?
	@State private var travelTime: String?
	@State var Home = CLLocationCoordinate2D(latitude: 37.000914, longitude: -76.442160)
	@State var WashingtonDC = CLLocationCoordinate2D(latitude: 38.907192, longitude: -77.036871)
	@State var Williamsburg = CLLocationCoordinate2D(latitude: 37.2707, longitude: -76.7075)

	private let gradient = LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
	private let stroke = StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round, dash: [8, 8])

	var body: some View {
		Map {
			if let route {
				MapPolyline(route.polyline)
					.stroke(.blue, lineWidth: 8)
				// .stroke(gradient, style: stroke)
			}
		}
		.overlay(alignment: .bottom, content: {
			HStack {
				if let travelTime {
					Text("Travel time: \(travelTime)")
						.padding()
						.font(.headline)
						.foregroundStyle(.black)
						.background(.ultraThinMaterial)
						.cornerRadius(15)
				}
			}
		})
		.onAppear(perform: {
			fetchRouteFrom(from: Home, to: WashingtonDC)
		})
	}
}

extension RouteView {

	private func fetchRouteFrom(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
		let request = MKDirections.Request()
		request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
		request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
		request.transportType = .automobile

		Task {
			let result = try? await MKDirections(request: request).calculate()
			route = result?.routes.first
			getTravelTime()
		}
	}

	private func getTravelTime() {
		guard let route else { return }
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .abbreviated
		formatter.allowedUnits = [.hour, .minute]
		travelTime = formatter.string(from: route.expectedTravelTime)
	}
}

#Preview {
	RouteView()
}
