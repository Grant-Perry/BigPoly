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

struct LocationPreviewLookAroundView: View {
	@State private var lookAroundScene: MKLookAroundScene?
	@State var workoutData: WorkoutData
	@State private var retScene: String = "Valid"

	var body: some View {
		LookAroundPreview(initialScene: lookAroundScene,
								allowsNavigation: true,
								showsRoadLabels: true,
								pointsOfInterest: .all)
		
		.overlay(alignment: .bottomTrailing) {
			HStack {
				Text("\(workoutData.workoutAddress?.city ?? "Loading...")")
				//				Text("\(holdCoord)")
				//					.font(.system(size: 12))
			}
			.font(.caption)
			.foregroundStyle(.white)
			.padding(18)
		}

		.onAppear {
			getLookAroundScene()
		}
		//		.onChange(of: selectedResult) {
		//			getLookAroundScene()
		//		}
	}

	func getLookAroundScene() {
		lookAroundScene = nil
		Task {
			// unwrap into thisCoords
			if let thisCoords = workoutData.workoutCoords?.last {
				// put thisCoords into State
				let request = MKLookAroundSceneRequest(coordinate: thisCoords)
				//			let request = MKLookAroundSceneRequest(coordinate: selectedResult.coordinate)
//				print("[getLookAroundScene] thisCoords: \(thisCoords) -\n\(workoutData.workoutAddress!)")
				lookAroundScene = try? await request.scene
//				print("[getLookAroundScene] lookAroundScene = \(lookAroundScene) ")
			} else { return }
		}
	}

}
