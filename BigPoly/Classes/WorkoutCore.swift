//   WorkoutCore.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/8/24 at 9:58 AM
//     Modified: Monday February 19, 2024 at 3:14:07 PM
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import HealthKit
import CoreLocation
import Observation
import MapKit

@Observable
class WorkoutCore {
	static let shared = WorkoutCore()
	var fullMapLoading = false // state to track navigation when NavigationLink pressed

	var distance: Double = 0
	private let healthStore = HKHealthStore()
	var cityNames: [UUID: String] = [:] // Maps workout UUID to city names

	private init() {}

	// Requests permission to access HealthKit data.
	func requestHealthKitPermission() async throws {
		let typesToRead: Set<HKObjectType> = [
			HKObjectType.workoutType(),
			HKSeriesType.workoutRoute()
		]
		try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
	}

	/* GENESIS: This should be the beginning.

	 Build the initial workoutData model with all the workouts.
	 */
	func buildWorkoutData(startDate: Date,
								 endDate: Date,
								 limit: Int) async throws -> [WorkoutData] {

		let workouts = try await fetchLastWorkouts(startDate: startDate,
																 endDate: endDate,
																 limit: limit)
		var workoutDataList: [WorkoutData] = []

		for thisWorkout in workouts {
			let routeCoordinates = try await getWorkoutCoords(thisWorkout: thisWorkout)
			let distance = routeCoordinates.calcDistance

			// get the first coords
			let thisCoords = routeCoordinates.first

			if let latitude = thisCoords?.coordinate.latitude,
				let longitude = thisCoords?.coordinate.longitude {
				// Fetch address based on routeCoordinates.first
				let fetchedAddress = await WorkoutCore.shared.fetchAndUpdateAddress(latitude: latitude, longitude: longitude)

				// initialize the WorkoutData model
				let returnWorkoutData = WorkoutData(workout: thisWorkout,
																workoutDate: thisWorkout.startDate,
																workoutEndDate: thisWorkout.endDate,
																workoutDistance: distance,
																workoutAddress: fetchedAddress,
																workoutCoords: routeCoordinates.map {$0.coordinate}) // the .map is to convert CLLocation->CLLocation2D
				workoutDataList.append(returnWorkoutData)
			}
		}
		return workoutDataList
	}

	func fetchLastWorkouts(startDate: Date, endDate: Date, limit: Int) async throws -> [HKWorkout] {
		// Predicate for date range
		print("fetchLastWorkouts: startDate: \(startDate) - endDate: \(endDate)\n")
		let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

		// Predicates for workout types
		let walkPredicate = HKQuery.predicateForWorkouts(with: .walking)
		let runPredicate = HKQuery.predicateForWorkouts(with: .running)
		let bikePredicate = HKQuery.predicateForWorkouts(with: .cycling)

		// Combine predicates: workouts within the date range and of specified types
		let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, NSCompoundPredicate(orPredicateWithSubpredicates: [walkPredicate, runPredicate, bikePredicate])])

		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

		// Fetch all workouts first
		let allWorkouts: [HKWorkout] = try await withCheckedThrowingContinuation { continuation in
			let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
											  predicate: combinedPredicate,
											  limit: limit,
											  sortDescriptors: [sortDescriptor]) { _, result, error in
				if let error = error {
					continuation.resume(throwing: error)
				} else if let workouts = result as? [HKWorkout] {
					continuation.resume(returning: workouts)
				} else {
					continuation.resume(returning: [])
				}
			}
			self.healthStore.execute(query)
		}

		// Filter workouts that have route data with valid coordinates
		var workoutsWithValidCoordinates: [HKWorkout] = []
		for workout in allWorkouts {
			// Fetch routes for each workout
			if let routes = await getWorkoutRoute(workout: workout), !routes.isEmpty {
				// Check for valid coordinates in each route
				for route in routes {
					let locations = await getCLocationDataForRoute(routeToExtract: route)
					if locations.contains(where: { $0.coordinate.latitude != 0 && $0.coordinate.longitude != 0 }) {
						workoutsWithValidCoordinates.append(workout)
						break // Found valid coordinates, no need to check further routes
					}
				}
			}
		}

		return workoutsWithValidCoordinates
	}



	// good method to sum distance for a particular workout
	public func getWorkoutDistance(_ thisWorkout: HKWorkout) async throws -> Double {
		guard let route = await getWorkoutRoute(workout: thisWorkout)?.first else {
			return 0
		}
		// get the coordinates of the last workout
		let coords = await getCLocationDataForRoute(routeToExtract: route)
		return coords.calcDistance
		//		return await getCLocationDataForRoute(routeToExtract: route).calcDistance
	}

	func formatDuration(duration: TimeInterval) -> String {
		let formatter = DateComponentsFormatter()
		formatter.unitsStyle = .positional
		formatter.allowedUnits = [.minute, .second]
		formatter.zeroFormattingBehavior = .pad

		if duration >= 3600 { // if duration is 1 hour or longer
			formatter.allowedUnits.insert(.hour)
		}
		return formatter.string(from: duration) ?? "0:00"
	}

	func formatDateName(_ date: Date) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMMM d, yyyy"
		return dateFormatter.string(from: date)
	}


	/// <#Description#>
	/// - Parameter workout: extract coordinates/routes from this workout
	/// - Returns: workouts as [HKWorkoutRoute]
	func getWorkoutRoute(workout: HKWorkout) async -> [HKWorkoutRoute]? {
		let byWorkout 	= HKQuery.predicateForObjects(from: workout)
		let samples 	= try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
			healthStore.execute(HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(),
																	predicate: byWorkout, anchor: nil,
																	limit: HKObjectQueryNoLimit,
																	resultsHandler: { (query, samples, deletedObjects, anchor, error) in
				if let hasError = error {
					continuation.resume(throwing: hasError)
					return
				}
				guard let samples = samples else { return }
				continuation.resume(returning: samples)
			}))
		}
		guard let workouts = samples as? [HKWorkoutRoute] else { return nil }
		return workouts
	}

	func getCLocationDataForRoute(routeToExtract: HKWorkoutRoute) async -> [CLLocation] {
		do {
			let locations: [CLLocation] = try await withCheckedThrowingContinuation { continuation in
				var allLocations: [CLLocation] = []
				let query = HKWorkoutRouteQuery(route: routeToExtract) { query, locationsOrNil, done, errorOrNil in
					if let error = errorOrNil {
						continuation.resume(throwing: error)
						return
					}
					if let locationsOrNil = locationsOrNil {
						allLocations.append(contentsOf: locationsOrNil)
						if done {
							continuation.resume(returning: allLocations)
						}
					} else {
						continuation.resume(returning: []) // Resume with an empty array if no locations are found
					}
				}
				healthStore.execute(query)
			}
			return locations
		} catch {
			print("Error fetching location data: \(error.localizedDescription)")
			return []
		}
	}

	func calcNumCoords(_ work: HKWorkout) async -> Int {
		guard let route = await getWorkoutRoute(workout: work)?.first else {
			return 0
		}
		let locations = await getCLocationDataForRoute(routeToExtract: route)
		let filteredLocations = locations.filter { $0.coordinate.latitude != 0 || $0.coordinate.longitude != 0 }
		return filteredLocations.count
	}

	func filterWorkoutsWithCoords(_ workouts: [HKWorkout]) async -> [HKWorkout] {
		var filteredWorkouts: [HKWorkout] = []
		for workout in workouts {
			if await calcNumCoords(workout) > 0 {
				filteredWorkouts.append(workout)
			}
		}
		return filteredWorkouts
	}

	// MARK: - Address geocode lookup
	func fetchAndUpdateAddress(latitude: Double, longitude: Double) async -> Address? {

		let geocoder = CLGeocoder()
		let location = CLLocation(latitude: latitude, longitude: longitude)
		var address: Address?
		//		var workoutData: WorkoutData

		do {
			let placemarks = try await geocoder.reverseGeocodeLocation(location)
			if let placemark = placemarks.first {
				// Update the address state
				address = Address(
					address: placemark.thoroughfare ?? "",
					city: placemark.locality ?? "",
					zipCode: placemark.postalCode ?? "",
					state: placemark.administrativeArea ?? "",
					latitude: latitude,
					longitude: longitude,
					name: placemark.name
				)

			}
		} catch let error {
			print("Address not found: \(error.localizedDescription)")
		}
		return address
	}

	// fetch directions - return and MKRoute with directions
	func fetchRouteFrom(from source: CLLocationCoordinate2D,
							  to destination: CLLocationCoordinate2D) async -> MKRoute {

		var thisRoute: MKRoute?
		//  var travelTime: String?
		let request = MKDirections.Request()
		request.transportType = .automobile //.walking

		request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
		request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
		request.transportType = .automobile

		let result = try? await MKDirections(request: request).calculate()
		thisRoute = result?.routes.first
		return thisRoute!

	}







	// fetches the last limit workouts - used in GENESIS process
	//	func fetchLastWorkouts(limit: Int) async throws -> [HKWorkout] {
	//		let predicate = HKQuery.predicateForWorkouts(with: .walking)
	//		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
	//
	//		// Fetch all workouts first
	//		let allWorkouts: [HKWorkout] = try await withCheckedThrowingContinuation { continuation in
	//			let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
	//											  predicate: predicate,
	//											  limit: limit,
	//											  sortDescriptors: [sortDescriptor]) { _, result, error in
	//				if let error = error {
	//					continuation.resume(throwing: error)
	//				} else if let workouts = result as? [HKWorkout] {
	//					continuation.resume(returning: workouts)
	//				} else {
	//					continuation.resume(returning: [])
	//				}
	//			}
	//			self.healthStore.execute(query)
	//		}
	//
	//		// Filter workouts that have route data with valid coordinates
	//		var workoutsWithValidCoordinates: [HKWorkout] = []
	//		for workout in allWorkouts {
	//			// Fetch routes for each workout
	//			if let routes = await getWorkoutRoute(workout: workout), !routes.isEmpty {
	//				// Check for valid coordinates in each route
	//				for route in routes {
	//					let locations = await getCLocationDataForRoute(routeToExtract: route)
	//					if locations.contains(where: { $0.coordinate.latitude != 0 && $0.coordinate.longitude != 0 }) {
	//						workoutsWithValidCoordinates.append(workout)
	//						break // Found valid coordinates, no need to check further routes
	//					}
	//				}
	//			}
	//		}
	//
	//		return workoutsWithValidCoordinates
	//	}

	/// returns the [CLLocationCoordinate2D] - coordinates from the passed HKWorkout

	func getWorkoutCoords(thisWorkout: HKWorkout) async throws -> [CLLocation] {

		var thisCoords: [HKWorkout] = []
		var retCoords: [CLLocation] = []
		// get all coords/routes for thisWorkout
		if let routes = await getWorkoutRoute(workout: thisWorkout), !routes.isEmpty {
			for route in routes {
				let coords = await getCLocationDataForRoute(routeToExtract: route)
				if !coords.isEmpty && coords.contains(where: { $0.coordinate.latitude != 0 && $0.coordinate.longitude != 0 }) {
					thisCoords.append(thisWorkout)
					retCoords = coords
					//					retCoords.append(coords)
					//					retCoords = locations.map { $0.coordinate }
					break // Found valid coordinates, no need to check further routes
				}
			}
		}
		return retCoords

	}



	func updateCityName(for workoutID: UUID, with cityName: String) {
		DispatchQueue.main.async {
			self.cityNames[workoutID] = cityName
		}
	}

	func cityName(for workoutID: UUID) -> String {
		self.cityNames[workoutID] ?? "Unknown City"
	}

	// Helper function to fetch coordinates for a route.
	private func fetchCoordinates(for route: HKWorkoutRoute) async throws -> [CLLocationCoordinate2D] {
		try await withCheckedThrowingContinuation { continuation in
			var coordinates: [CLLocationCoordinate2D] = []

			let query = HKWorkoutRouteQuery(route: route) { _, returnedLocations, done, errorOrNil in
				if let error = errorOrNil {
					continuation.resume(throwing: error)
					return
				}

				if let locations = returnedLocations {
					coordinates.append(contentsOf: locations.map { $0.coordinate })
				}

				if done {
					continuation.resume(returning: coordinates)
				}
			}
			healthStore.execute(query)
		}
	}
	// Fetches route data for a given workout and returns the coordinates.
	func fetchRouteData(for workout: HKWorkout) async throws -> [CLLocationCoordinate2D] {
		// Directly use HKSeriesType.workoutRoute() since it's non-optional
		let routeType = HKSeriesType.workoutRoute()

		// Fetch routes
		let routes: [HKWorkoutRoute] = try await withCheckedThrowingContinuation { continuation in
			let predicate = HKQuery.predicateForObjects(from: workout)
			let query = HKSampleQuery(sampleType: routeType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
				if let error = error {
					continuation.resume(throwing: error)
				} else if let routes = samples as? [HKWorkoutRoute] {
					continuation.resume(returning: routes)
				} else {
					// It's crucial to resume the continuation even if no routes are found to avoid hanging.
					continuation.resume(returning: [])
				}
			}
			self.healthStore.execute(query)
		}

		// Ensure there's at least one route to process
		guard let firstRoute = routes.first else {
			return []
		}

		// Proceed to fetch and process coordinates from the first route
		return try await fetchCoordinates(for: firstRoute)
	}

	func calcTime(from: Date, to: Date) -> String {
		// Calculate the difference between the two dates
		let calendar = Calendar.current
		let components = calendar.dateComponents([.hour, .minute, .second], from: from, to: to)

		// Extract hour, minute, and second components
		let hours = components.hour ?? 0
		let minutes = components.minute ?? 0
		let seconds = components.second ?? 0

		// Format the time difference into a string
		var timeDifference: String = ""
		if hours > 0 {
			timeDifference = String(format: "%d:%02d:%02d", hours, minutes, seconds)
		} else {
			timeDifference = String(format: "%d:%02d", minutes, seconds)
		}
		return timeDifference
	}



}

