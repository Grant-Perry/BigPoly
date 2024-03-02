//   LocationPreviewLookAroundView_Orig.swift
//   BigPoly
//
//   Created by: Grant Perry on 3/2/24 at 12:24 PM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import MapKit

struct LocationPreviewLookAroundView_Orig: View {
	@State private var lookAroundScene: MKLookAroundScene?
	var selectedResult: MyFavoriteLocation
	@State private var retScene: String = "nothing"

	var body: some View {
		LookAroundPreview(initialScene: lookAroundScene)
			.overlay(alignment: .bottomTrailing) {
				HStack {
					Text("\(selectedResult.name) - \(retScene)")

				}
				.font(.caption)
				.foregroundStyle(.white)
				.padding(18)
			}
			.onAppear {
				getLookAroundScene()
			}
			.onChange(of: selectedResult) {
				getLookAroundScene()
			}
	}

	func getLookAroundScene() {
		lookAroundScene = nil
		Task {
			// determine if there is a valid lookAround
			if await isLookaroundAvailable(for: selectedResult.coordinate) {
				let thisRequest = MKLookAroundSceneRequest(coordinate: selectedResult.coordinate)
				guard let lookAroundScene = try? await thisRequest.scene else {
					throw LookaroundError.unableToCreateScene
				}
			} else {
				// there is no valid lookaround
				retScene = "No valid lookaround"
			}
		}
	}

	func isLookaroundAvailable(for coordinate: CLLocationCoordinate2D) async -> Bool {
		do {
			let thisScene = try await MKLookAroundSceneRequest(coordinate: coordinate).scene
			retScene = thisScene != nil ? "valid" : "not valid"
			return thisScene != nil
		} catch {
			retScene = "NOT VALID"
			return false
		}
	}
}

enum LookaroundError: Error {
	case unableToCreateScene
	
}