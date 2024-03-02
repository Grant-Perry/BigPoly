//   NewYorkView.swift
//   BigPoly
//
//   Created by: Grant Perry on 3/1/24 at 2:12 PM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import MapKit

struct NewYorkView: View {
	var body: some View {
		Map {
			Marker("Empire state building", coordinate: .empireStateBuilding)
				.tint(.orange)
			Annotation("Columbia University", coordinate: .columbiaUniversity) {
				ZStack {
					RoundedRectangle(cornerRadius: 5)
						.fill(Color.teal)
					Text("🎓")
						.padding(5)
				}
			}
		}
		.mapControls {
			MapUserLocationButton()
			MapCompass()
			MapScaleView()
		}
	}
}

#Preview {
	NewYorkView()
}

extension CLLocationCoordinate2D {
	static let weequahicPark = CLLocationCoordinate2D(latitude: 40.7063, longitude: -74.1973)
	static let empireStateBuilding = CLLocationCoordinate2D(latitude: 40.7484, longitude: -73.9857)
	static let columbiaUniversity = CLLocationCoordinate2D(latitude: 40.8075, longitude: -73.9626)
	static let todayRun = CLLocationCoordinate2D(latitude: 37.0519, longitude: -76.4785)

}
