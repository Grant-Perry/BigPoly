	//   LookAroundView.swift
	//   BigPoly
	//
	//   Created by: Grant Perry on 3/1/24 at 2:17 PM
	//     Modified:
	//
	//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
	//
import SwiftUI
import MapKit

	/// This SwiftUI view is designed to present an interactive Look Around scene based on the location data associated with a workout.
	/// It initializes with workout data to determine the location for the Look Around scene. When the view appears, it attempts to fetch
	/// the scene asynchronously, updating its state accordingly. The view also overlays text information (city name) on the Look Around
	/// preview, offering a contextual hint about the location being viewed.
	/// This view utilizes the `MKLookAroundScene` to render interactive panoramic views.
struct LocationPreviewLookAroundView: View {
		// State to manage the current Look Around scene.
		// [lookAroundScene:]: Optional, stores the Look Around scene if available.
	@State private var lookAroundScene: MKLookAroundScene?

		// Holds workout data, used to derive coordinates for the Look Around scene.
		// [workoutData:]: Non-optional, contains workout-related data including location.
	@State var workoutData: WorkoutData

		// Temporary storage for coordinates.
		// [holdCoord:]: Optional, temporarily holds coordinates for the Look Around scene.
	@State var holdCoord: CLLocationCoordinate2D?

		// Indicates the retrieval status of the Look Around scene.
		// [retScene:]: Non-optional, indicates if a valid Look Around scene is available.
	@State private var retScene: String = "Valid"

	var body: some View {
			// Constructs a Look Around preview with the initial scene and configurations.
		LookAroundPreview(initialScene: lookAroundScene,
								allowsNavigation: true,
								showsRoadLabels: true,
								pointsOfInterest: .all)
		.overlay(alignment: .bottomTrailing) {
			HStack {
					// Displays the city name from workout data or "Loading..." if not available.
				Text("\(workoutData.workoutAddress?.city ?? "Loading...")")
			}
			.font(.caption)
			.foregroundStyle(.white)
			.padding(18)
		}
		.onAppear {
				// Fetches the Look Around scene when the view appears.
			getLookAroundScene()
		}
	}

		/// Fetches a Look Around scene for the last coordinate in `workoutData`.
	func getLookAroundScene() {
		lookAroundScene = nil // Resets the Look Around scene state.
		Task {
				// Checks if there are coordinates available in `workoutData`.
			if let thisCoords = workoutData.workoutCoords?.last {
					// Updates the state with the current coordinates.
				holdCoord = thisCoords
					// Prepares a request for a Look Around scene using the last coordinate.
				let request = MKLookAroundSceneRequest(coordinate: thisCoords)
				print("[lookAroundScene] thisCoords: \(thisCoords) - \(workoutData.workoutAddress!)")
					// Attempts to fetch the scene asynchronously.
				lookAroundScene = try? await request.scene
			} else { return } // Exits if no coordinates are available.
		}
	}
}

