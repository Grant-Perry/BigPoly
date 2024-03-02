//   LocationPreviewLookAroundViewStudy.swift
//   BigPoly
//
//   Created by: Grant Perry on 3/2/24 at 12:21 PM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import MapKit

struct LocationPreviewView_Orig: View {
	@State private var selection: UUID?

	let myFavoriteLocations = [
		MyFavoriteLocation(name: "Today", coordinate: .todayRun),
		MyFavoriteLocation(name: "Empire state building", coordinate: .empireStateBuilding),
		MyFavoriteLocation(name: "Columbia University", coordinate: .columbiaUniversity),
		MyFavoriteLocation(name: "Weequahic Park", coordinate: .weequahicPark)]

	var body: some View {
		Map(selection: $selection) {
			ForEach(myFavoriteLocations) { location in
				Marker(location.name, coordinate: location.coordinate)
					.tint(.orange)
			}
		}
		.safeAreaInset(edge: .bottom) {
			HStack {
				Spacer()
				VStack(spacing: 0) {
					if let selection {
						if let item = myFavoriteLocations.first(where: { $0.id == selection }) {
							
							LocationPreviewLookAroundView_Orig(selectedResult: item)
								.frame(height: 128)
								.clipShape(RoundedRectangle(cornerRadius: 10))
								.padding([.top, .horizontal])
						}
					}
				}
				Spacer()
			}
			.background(.thinMaterial)
		}
		.onChange(of: selection) {
			guard let selection else { return }
			guard let item = myFavoriteLocations.first(where: { $0.id == selection }) else { return }
			print(item.coordinate)
		}
	}
}
