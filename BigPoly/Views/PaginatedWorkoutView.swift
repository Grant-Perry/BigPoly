////   PaginatedWorkoutView.swift
////
////   Created by: Grant Perry on 2/14/24 at 11:17 AM
////     Modified: Monday February 19, 2024 at 3:07:10 PM
////
////  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
////
//
//import SwiftUI
//import HealthKit
//
//struct PaginatedWorkoutsView: View {
//	@State private var workouts: [HKWorkout] = []
//	var workoutData: [WorkoutData] // = []
//
//	@State private var isLoading = false
//	@State private var startDate = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
//	@State private var endDate = Date()
//	@State private var limit = 20 // Default limit
//	@State private var currentPage = 0
//
//	var body: some View {
//		NavigationView {
//			VStack {
//				NavigationLink("Sort & Filter", destination: SortingFilteringView(
//					startDate: $startDate,
//					endDate: $endDate,
//					limit: $limit,
//					applyFilters: {
//						currentPage = 0 // Reset to the first page
//						loadWorkouts() // Reload workouts with the new filters
//					}
//				))
//
//				List(workouts, id: \.uuid) { thisWorkout in
//					NavigationLink(destination: FullMapView(workoutData: thisWorkout)) {
//						WorkoutRouteView(workoutData: thisWorkout)
//					}
//				}
//				.navigationTitle("Workouts")
//				if isLoading {
//					ProgressView()
//				}
//
//				Button("Load More") {
//					currentPage += 1
//					loadWorkouts()
//				}
//			}
//			.navigationTitle("Workouts")
//		}
//
//// MARK: - async load the workouts
//
//		.onAppear {
//			loadWorkouts()
//		}
//	}
//
//	private func loadWorkouts() {
//		guard !isLoading else { return }
//		isLoading = true
//
//		Task {
//			do {
//				let detectedWorkouts = try await WorkoutCore.shared.fetchPagedWorkouts(startDate: startDate, 
//																										endDate: endDate,
//																										limit: limit,
//																										page: currentPage)
//				if currentPage == 0 {
//					workouts = detectedWorkouts
//				} else {
//					workouts.append(contentsOf: detectedWorkouts)
//				}
//				isLoading = false
//			} catch {
//				print("Failed to load workouts: \(error)")
//				isLoading = false
//			}
//		}
//	}
//}
//
//
////#Preview {
////	PaginatedWorkoutsView()
////}
