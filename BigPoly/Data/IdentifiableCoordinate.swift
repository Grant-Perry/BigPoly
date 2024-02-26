//   IdentifiableCoordinate.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/10/24 at 9:47 AM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import CoreLocation

// model utilized by the fullMapView to create identifiable coordinats 
struct IdentifiableCoordinate: Identifiable {
	let id = UUID() // Unique identifier required by Identifiable
	let coordinate: CLLocationCoordinate2D
}
