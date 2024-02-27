
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
import MapKit

struct PolyView: View {
	@State private var workoutData: [WorkoutData] = []
	@State var isLoading = true
	@State private var workoutLimit = 50
	@State private var showDatePicker = false
	// startDate is set to 3 months prior to Date()
	@State private var startDate = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date().addingTimeInterval(-3600 * 30) // subtract 30 days from Date()
	@State private var endDate = Date()
	@State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))

//	@State var histForecast:HistForecast = HistForecast()

	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				if isLoading {
					LoadingView()

				} else {
					List(workoutData, id: \.workout.uuid) { listWorkoutData in
						NavigationLink(destination: FullMapView(thisWorkoutData: listWorkoutData)) {
							WorkoutRouteView(workoutData: listWorkoutData)
						}
					}
				}
 // MARK: --- Sorting Button
				Button("Change Dates") {
					showDatePicker.toggle()
				}
				.padding()
				.background(
					LinearGradient(gradient: Gradient(colors: [.gpOrange, .gpWhite]), startPoint: .leading, endPoint: .topLeading)
				)
				.foregroundColor(Color.white)
				.cornerRadius(10)
				.padding(.top, 10) // Add some space between the list/loading view and the button
			}
			.navigationTitle("Gp. Workouts")
		}
		.onAppear {
			Task {

				// The initial call to build the data
				await loadWorkouts()
			}
		}
		.sheet(isPresented: $showDatePicker) {
			DatePickerView(startDate: $startDate,
								endDate: $endDate,
								workoutLimit: $workoutLimit,
								isLoading: $isLoading,
								onSubmit: {
				Task { await loadWorkouts() }
			})
		}
		.background(.blue.gradient)
	}

		// GENESIS: ...it starts EVERYTHING.
		private func loadWorkouts() async {
			do {
				// get user authorization
				try await WorkoutCore.shared.requestHealthKitPermission()
				print("inside loadWorkouts: startDate: \(startDate) - endDate: \(endDate)")

				workoutData = try await WorkoutCore.shared.buildWorkoutData(startDate: startDate,
																								endDate: endDate,
																								limit: workoutLimit)
			} catch {
				print("Error loading workouts: \(error)")
				isLoading = false
			}
			//			turn off the loading screen
			isLoading = false
		}
	}

	#Preview {
		PolyView()
	}











