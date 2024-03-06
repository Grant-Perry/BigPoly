//   LookAroundView.swift
//   BigPoly
//
//   Created by: Grant Perry on 3/1/24 at 2:17 PM
//     Modified: Tuesday March 5, 2024 at 5:05:05 PM
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry

import SwiftUI
import MapKit

/// ``LocationPreviewLookAroundView``
/// A SwiftUI view for displaying a `MKLookAroundScene` scene based on the location data from a workout.
/// It utilizes `@State` properties to manage the LookAround scene, workout data, and coordinate handling.
/// The view integrates a `LookAroundPreview` with dynamic content based on the provided workout data and coordinates.
/// - Parameters:
///     - `lookAroundScene`: An optional `MKLookAroundScene` to store the LookAround scene if available.
///     - `workoutData`: Contains workout-related data, including location, used to derive coordinates for the LookAround scene.
///     - `holdCoord`: An optional `CLLocationCoordinate2D` for temporarily holding coordinates for the LookAround scene.
///
/// The body constructs a LookAround preview configured with the initial scene, navigation options, road labels, and points of interest.
/// An overlay displays the city name from workout data. The `onAppear` modifier fetches the LookAround scene based on the last coordinate
/// in `workoutData`to track/maintain pagination.
struct LocationPreviewLookAroundView: View {
	@State private var lookAroundScene: MKLookAroundScene?
	@State var workoutData: WorkoutData
	@State var holdCoord: CLLocationCoordinate2D?

	var body: some View {
		LookAroundPreview(initialScene: lookAroundScene,
						  allowsNavigation: true,
						  showsRoadLabels: true,
						  pointsOfInterest: .all)
		.overlay(alignment: .bottomTrailing) {
			HStack {
				Text("\(workoutData.workoutAddress?.city ?? "Loading...")")
			}
			.font(.caption)
			.foregroundStyle(.white)
			.padding(18)
		}
		.onAppear {
			getLookAroundScene()
		}
	}
}

// MARK: - Helpers

extension LocationPreviewLookAroundView {
	/// Fetches a LookAround scene for the last coordinate in `workoutData`.
	func getLookAroundScene() {
		lookAroundScene = nil // Resets the Look Around scene state.
		Task {
			if let thisCoords = workoutData.workoutCoords?.last {
				holdCoord = thisCoords
				let request = MKLookAroundSceneRequest(coordinate: thisCoords)
				print("[lookAroundScene] thisCoords: \(thisCoords) - \(workoutData.workoutAddress!)")
				lookAroundScene = try? await request.scene
			} else { return }
		}
	}
}
