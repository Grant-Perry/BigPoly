//   MyFavoriteLocation.swift
//   BigPoly
//
//   Created by: Grant Perry on 3/1/24 at 2:41 PM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import MapKit

struct MyFavoriteLocation: Identifiable, Equatable {
	var id = UUID()
	var name: String
	var coordinate: CLLocationCoordinate2D
	// stupid thing to conform to Equatable
	static func == (lhs: MyFavoriteLocation, rhs: MyFavoriteLocation) -> Bool {
		return lhs.id == rhs.id
	}
}
