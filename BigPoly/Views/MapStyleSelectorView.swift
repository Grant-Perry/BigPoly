//   MapStyleSelectorView.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/20/24 at 4:24 PM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import MapKit

struct MapStyleSelectorView: View {
	@State private var selectedMapStyle = MKMapType.standard // Default style

	var body: some View {
		VStack {
			Picker("Select Map Style", selection: $selectedMapStyle) {
				Text("Standard").tag(MKMapType.standard)
				Text("Satellite").tag(MKMapType.satellite)
				Text("Hybrid").tag(MKMapType.hybrid)
				// Add more styles as needed
			}
			.pickerStyle(SegmentedPickerStyle()) // Style the picker as desired

//			FullMapView(mapStyle: selectedMapStyle)
//				.edgesIgnoringSafeArea(.all) // Make the map full screen or adjust as needed
		}
	}
}


#Preview {
    MapStyleSelectorView()
}
