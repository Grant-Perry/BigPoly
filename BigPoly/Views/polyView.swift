
//   polyView.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/8/24 at 9:26 AM
//     Modified: Saturday March 2, 2024 at 4:01:25 PM - M2
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import HealthKit
import MapKit

struct PolyView: View {
	@State private var workoutData: [WorkoutData] = []
	@State var isLoading = true
	@State var workoutCore = WorkoutCore.shared
	@State private var workoutLimit = 50
	@State private var showDatePicker = false
	// startDate is set to 3 months prior to Date()
	@State private var startDate = Calendar.current.date(byAdding: .day, value: -90, to: Date()) ?? Date().addingTimeInterval(-3600 * 30) // subtract 30 days from Date()
	@State private var endDate = Date()
	@State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0))


	var body: some View {
		NavigationStack {
			VStack(spacing: 0) {
				if isLoading {
					LoadingView(calledFrom: "polyView", workType: "Workouts", icon: "mappin.circle.fill")
				} else {
					List(workoutData, id: \.workout.uuid) { listWorkoutData in
						NavigationLink(destination: FullMapView(thisWorkoutData: listWorkoutData, showLoading: true)
							.onAppear {
								workoutCore.fullMapLoading = false
							}) {
								WorkoutRouteView(workoutData: listWorkoutData)
							}
//							.simultaneousGesture(TapGesture().onEnded {
//								workoutCore.fullMapLoading = true
//							} )
					}

					//					List(workoutData, id: \.workout.uuid) { listWorkoutData in
					//											NavigationLink(destination: FullMapView(thisWorkoutData: listWorkoutData)) {
					//					//							WorkoutRouteView(workoutData: listWorkoutData)
					//						}
					//					}
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
		//		.preferredColorScheme(/*@START_MENU_TOKEN@*/.dark/*@END_MENU_TOKEN@*/)
		.background(.blue.gradient)
	}

	// MARK: Helpers

	// GENESIS: ...it starts EVERYTHING.
	private func loadWorkouts() async {
		do {
			// get user authorization
			try await WorkoutCore.shared.requestHealthKitPermission()
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











