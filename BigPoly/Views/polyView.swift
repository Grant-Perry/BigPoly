
//   polyView.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/8/24 at 9:26 AM
//     Modified: Tuesday March 5, 2024 at 5:05:29 PM
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry

import SwiftUI
import HealthKit
import MapKit

struct PolyView: View {
	@State private var workoutData: [WorkoutData] = []
	@State var isLoading = true
	@State private var isLoadingMore = false // For pagination loading state
	@State private var hasMoreData = true // To control if more data is available
	@State var workoutCore = WorkoutCore.shared
	@State private var workoutLimit = 50 // DO NOT make this < 50
	@State private var showDatePicker = false
	@State private var startDate = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date().addingTimeInterval(-3600 * 30)
	@State private var endDate = Date()
	@State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), 
										   span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))

	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				Group {
					List(workoutData.indices, id: \.self) { index in
						let workout = workoutData[index]
						NavigationLink(destination: FullMapView(thisWorkoutData: workout, showLoading: true)) {
							WorkoutRouteView(workoutData: workout)
								.onAppear {
									if index == workoutData.count - 1 && hasMoreData {
										loadMoreWorkouts()
									}
								}
						}
					}
				}
				Button("Change Dates") {
					showDatePicker.toggle()
				}
				.padding()
				.background(
					LinearGradient(gradient: Gradient(colors: [.gpOrange, .gpWhite]), startPoint: .leading, endPoint: .topLeading)
				)
				.foregroundColor(Color.white)
				.cornerRadius(10)
				.padding(.top, 10)
			}
			.navigationTitle("Gp. Workouts")
		}
			// put up the Loading modal if necessary
		.overlay(
			isLoading ?
			Color.black.opacity(0.75) // Semi-transparent background
				.edgesIgnoringSafeArea(.all) // Cover the entire screen area
				.overlay(
					LoadingView(calledFrom: "WorkoutData", workType: "\nAdditional Workouts", icon: "map.circle")
						.frame(width: 265) // Set the LoadingView size
						.lineLimit(2)
						.minimumScaleFactor(0.5)
						.scaledToFit()
						.background(Color.white) // Background color of LoadingView
						.cornerRadius(20)
						.shadow(radius: 10), // Optional: add shadow for better contrast
					alignment: .center
				)
			: nil,
			alignment: .center
		)
		.onAppear {
			Task {
				if workoutData.isEmpty {
					try await workoutCore.requestHealthKitPermission()
					await loadWorkouts(resetData: true)
				}

			}
		}
		.sheet(isPresented: $showDatePicker) {
			DatePickerView(startDate: $startDate,
								endDate: $endDate,
								workoutLimit: $workoutLimit,
								isLoading: $isLoading,
								onSubmit: {
				Task { await loadWorkouts(resetData: true) }
			})
		}
		.background(.blue.gradient)
	}

	/// ``loadWorkouts(resetData:)``
	/// Invoked within WorkoutRouteView to asynchronously fetch and load workout data, possibly resetting existing data.
	/// - Parameters:
	///     - resetData: Boolean value indicating whether existing workout data should be cleared before loading new data. Defaults to `false`.
	/// - This function performs an asynchronous operation to fetch workout data for a specified time range. It supports pagination by updating
	/// the start date with the date of the last workout fetched, preparing it for subsequent fetch operations. It also handles potential errors
	/// by setting the ``hasMoreData``flag to false and logging the error.
	private func loadWorkouts(resetData: Bool = false) async {
		if resetData {
			workoutData.removeAll() // Clears existing data if resetData is true
			hasMoreData = true // Reset pagination flag
		}
		isLoading = true // Indicates the start of loading process
		do {
			// Calculate start and end dates based on the last workout date, if available
			if let lastWorkoutDate = workoutData.last?.workoutDate  {
				endDate = lastWorkoutDate // Set endDate to last workout date
										  // Set startDate to 90 days before endDate or today if no workouts
				startDate = Calendar.current.date(byAdding: .day, value: -90, to: endDate) ?? Calendar.current.date(byAdding: .day, value: -90, to: Date())!
				print("\n-----------------\n\n[loadWorkouts - isLoadingMore] oldestWorkout = \(lastWorkoutDate) - startDate: \(startDate) - endDate = \(endDate)")
			}
			// Fetch new workouts for the calculated date range
			let newWorkouts = try await workoutCore.buildWorkoutData(startDate: startDate, endDate: endDate, limit: workoutLimit)

			if newWorkouts.isEmpty {
				hasMoreData = false // If no new workouts, end pagination
			} else {
				workoutData.append(contentsOf: newWorkouts) // Append new workouts to data
															// Prepare startDate for the next load
				startDate = workoutData.last!.workoutDate
			}
		} catch {
			print("Error loading workouts: \(error)")
			hasMoreData = false // End pagination on error
		}
		isLoading = false // End loading process
	}

	/// ``loadMoreWorkouts()`
	/// Triggers the asynchronous loading of additional workouts, if not currently loading and more data is available.
	/// - This function checks if more workouts are available and if it's not currently in the process of loading more. It then proceeds to asynchronously fetch more workout data, updating the UI upon completion. This allows for incremental data loading, enhancing user experience in data-rich applications.
	private func loadMoreWorkouts() {
		guard !isLoadingMore && hasMoreData else { return } // Check if able to load more
		isLoadingMore = true // Mark the beginning of loading more data

		// Asynchronously load more workouts without resetting existing data
		Task {
			await loadWorkouts()
			isLoadingMore = false // Mark the end of loading more data
		}
	}

}











