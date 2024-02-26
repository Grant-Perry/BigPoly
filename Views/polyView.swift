//   polyView.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/8/24 at 9:26 AM
//     Modified:
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import HealthKit

struct PolyView: View {
	@State private var workouts: [HKWorkout] = []
	@State private var isLoading = true
	@State private var workoutLimit = 150

	var body: some View {
		NavigationView {
			if isLoading {
				LoadingView()
			} else {
				List(workouts, id: \.uuid) { workout in
					NavigationLink(destination: FullMapView(workout: workout)) {
						WorkoutRouteView(workout: workout)
					}
				}
				.navigationTitle("Workouts")
			}
		}
		.onAppear {
			Task {
				await loadWorkouts()
			}
		}
	}

	private func loadWorkouts() async {
		do {
			try await WorkoutCore.shared.requestHealthKitPermission()
			workouts = try await WorkoutCore.shared.fetchLastWorkouts(limit: workoutLimit)
//			print("WORKOUT: \(workouts)\n------------------------------\n\n")
			isLoading = false
		} catch {
			print("Error loading workouts: \(error)")
			isLoading = false
		}
	}
}

#Preview {
	PolyView()
}





