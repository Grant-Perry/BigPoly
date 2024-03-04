	//   WorkoutCore.swift
	//   BigPoly
	//
	//   Created by: Grant Perry on 2/8/24 at 9:58 AM
	//     Modified: Monday March 4, 2024 at 3:10:30 PM
	//
	//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry

import SwiftUI
import HealthKit
import CoreLocation
import MapKit
import Observation

@Observable
class WorkoutCore {
	static let shared = WorkoutCore()
	var fullMapLoading = false // state to track navigation when NavigationLink pressed
	var distance: Double = 0
	private let healthStore = HKHealthStore()
	var cityNames: [UUID: String] = [:] // Maps workout UUID to city names
	private init() {}

		/// `buildWorkoutData
		/// GENESIS: This is where it all begins.
		/// buildWorkoutData asynchronously constructs an array of `WorkoutData` objects for workouts occurring within a specified
		/// date range. This function fetches workouts, their routes, and calculates distances to build comprehensive workout data.

		/// - Parameters:
		///   - [startDate:]: `Date`, The beginning date of the range for which to fetch workouts.
		///   - [endDate:]: `Date`, The end date of the range.
		///   - [limit:]: `Int`, The maximum number of workouts to fetch.

		/// - Returns: An array of `WorkoutData` objects, each representing a fetched workout with additional data like distance and address.
		/// - Throws: An error if any part of the data fetching or processing fails.
	func buildWorkoutData(startDate: Date, endDate: Date, limit: Int) async throws -> [WorkoutData] {
			// Fetches workouts within the specified date range and limit using an asynchronous call.
		let workouts = try await fetchLastWorkouts(startDate: startDate, endDate: endDate, limit: limit)
			// Prepares an empty array to hold the constructed `WorkoutData` objects.
		var workoutDataList: [WorkoutData] = []

			// Iterates over each fetched workout to process and build `WorkoutData`.
		for thisWorkout in workouts {
				// Fetches the coordinates for the workout's route asynchronously.
			let routeCoordinates = try await getWorkoutCoords(thisWorkout: thisWorkout)
				// Calculates the distance covered in the workout based on its route coordinates.
			let distance = routeCoordinates.calcDistance

				// Attempts to fetch the first set of coordinates from the route, if available.
			let thisCoords = routeCoordinates.first

				// Checks if valid latitude and longitude values are present.
			if let latitude = thisCoords?.coordinate.latitude, let longitude = thisCoords?.coordinate.longitude {
					// Fetches a human-readable address for the first coordinate of the route.
				let fetchedAddress = await WorkoutCore.shared.fetchAndUpdateAddress(latitude: latitude, longitude: longitude)

					// Initializes a `WorkoutData` object with the fetched and calculated data.
				let returnWorkoutData = WorkoutData(
					workout: thisWorkout,
					workoutDate: thisWorkout.startDate,
					workoutEndDate: thisWorkout.endDate,
					workoutDistance: distance,
					workoutAddress: fetchedAddress,
					workoutCoords: routeCoordinates.map {$0.coordinate} // Converts CLLocation objects to CLLocationCoordinate2D for storage.
				)
					// Appends the constructed `WorkoutData` object to the list.
				workoutDataList.append(returnWorkoutData)
			}
		}
			// Returns the complete list of `WorkoutData` objects.
		return workoutDataList
	}

		/// `fetchLastWorkouts
		/// Fetches workouts from HealthKit that fall within a specified date range and meet certain activity type criteria ensuring they have valid route data.
		/// This function leverages HealthKit to query for workouts that fall within a specified date range and are of certain types (walking, running, cycling). It first
		/// fetches all matching workouts and then further filters them to include only those with associated route data containing valid geographic coordinates. The function
		/// uses asynchronous operations (async/await) to perform the potentially long-running HealthKit query without blocking the execution of the app, and it incorporates
		/// error handling to manage failed queries gracefully.

		/// - Parameters:
		///   - [startDate:]: Date, The beginning of the date range for which to fetch workouts.
		///   - [endDate:]: Date, The end of the date range.
		///   - [limit:]: Int, The maximum number of workouts to return.
		/// - Returns: An array of `HKWorkout` objects that meet the criteria.
		/// - Throws: An error if unable to complete the fetch request.
	func fetchLastWorkouts(startDate: Date, endDate: Date, limit: Int) async throws -> [HKWorkout] {
			// Log the function call with date range for debugging.
		print("fetchLastWorkouts: startDate: \(startDate) - endDate: \(endDate)\n")

			// Create a predicate to filter workouts by the specified date range.
		let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)

			// Create predicates to filter workouts by activity type (walking, running, cycling).
		let walkPredicate = HKQuery.predicateForWorkouts(with: .walking)
		let runPredicate = HKQuery.predicateForWorkouts(with: .running)
		let cyclePredicate = HKQuery.predicateForWorkouts(with: .cycling)

			// Combine the date range predicate with the activity type predicates.
		let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, NSCompoundPredicate(orPredicateWithSubpredicates: [walkPredicate, runPredicate, cyclePredicate])])

			// Define a sort descriptor to order the results by start date in descending order.
		let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

			// Perform the query to fetch workouts that match the combined predicate and within the specified limit.
		let allWorkouts: [HKWorkout] = try await withCheckedThrowingContinuation { continuation in
			let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
											  predicate: combinedPredicate,
											  limit: limit,
											  sortDescriptors: [sortDescriptor]) { _, result, error in
				if let error = error {
					continuation.resume(throwing: error) // Resume with error if the query fails.
				} else if let workouts = result as? [HKWorkout] {
					continuation.resume(returning: workouts) // Resume with the fetched workouts.
				} else {
					continuation.resume(returning: []) // Resume with an empty array if no workouts are found.
				}
			}
			self.healthStore.execute(query)
		}
			// Now filter the fetched workouts to include only those with valid route data.
		var workoutsWithValidCoordinates: [HKWorkout] = []
		for thisWorkout in allWorkouts {
			if let routes = await getWorkoutRoute(workout: thisWorkout), !routes.isEmpty {
				for route in routes {
					let locations = await getCLocationDataForRoute(routeToExtract: route)
						// Include the workout if at least one route has valid coordinates (latitude and longitude not equal to 0).
					if locations.contains(where: { $0.coordinate.latitude != 0 && $0.coordinate.longitude != 0 }) {
						workoutsWithValidCoordinates.append(thisWorkout)
						break // Stop checking further routes for this workout.
					}
				}
			}
		}

			// Return the filtered list of workouts.
		return workoutsWithValidCoordinates
	}

		///  `func getWorkoutRoute
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

		/// `func getCLocationDataForRoute
		/// asynchronously fetch geographic location data for a specific HKWorkoutRoute. Utilizes a HealthKit query
		/// (HKWorkoutRouteQuery) to retrieve CLLocation objects associated with the route. The function employs Swift's
		/// concurrency features (async/await along with withCheckedThrowingContinuation) to handle the asynchronous nature
		/// of the data fetching and error handling gracefully. If successful, returns an array of [CLLocation] objects representing
		/// the geographic path of the workout route. If no locations are found or an error occurs, it returns an empty array and logs the error.

		/// Asynchronously retrieves location data (as `CLLocation` objects) for a given workout route.
		/// - Parameter [routeToExtract:]: `HKWorkoutRoute`, The workout route from which to extract location data.
		/// - Returns: An array of `CLLocation` objects representing the route. Returns an empty array if no locations are found or an error occurs.
	func getCLocationDataForRoute(routeToExtract: HKWorkoutRoute) async -> [CLLocation] {
		do {
				// Attempt to fetch locations using a `withCheckedThrowingContinuation` to handle asynchronous fetching.
			let locations: [CLLocation] = try await withCheckedThrowingContinuation { continuation in
					// Initialize an empty array to hold the fetched locations.
				var allLocations: [CLLocation] = []

					// Create a query to fetch the workout route's locations.
				let query = HKWorkoutRouteQuery(route: routeToExtract) { query, locationsOrNil, done, errorOrNil in
						// Handle possible error by resuming the continuation with a throw.
					if let error = errorOrNil {
						continuation.resume(throwing: error)
						return
					}

						// If location data is available, append it to the `allLocations` array.
					if let locationsOrNil = locationsOrNil {
						allLocations.append(contentsOf: locationsOrNil)

							// Once all location data has been fetched (indicated by `done`), resume the continuation with the locations array.
						if done {
							continuation.resume(returning: allLocations)
						}
					} else {
							// If no locations are found, resume with an empty array to indicate no data.
						continuation.resume(returning: [])
					}
				}
					// Execute the query on the HealthStore instance.
				healthStore.execute(query)
			}
				// Return the fetched locations.
			return locations
		} catch {
				// Log any errors encountered during the fetch operation.
			print("Error fetching location data: \(error.localizedDescription)")
				// Return an empty array in case of error to indicate failure to fetch locations.
			return []
		}
	}

		/// `func calcNumCoords
		/// Calculates the number of valid coordinates for a given workout's route.
		/// This method filters out coordinates that are exactly at (0, 0), which are likely to be invalid or placeholders.
		/// - Parameter [work:]: `HKWorkout`, the workout for which to calculate valid coordinate count.
		/// - Returns: The count of valid coordinates (latitude or longitude not equal to 0) within the workout's route.
		/// - Note: This function assumes that a workout has at least one route and fetches only the first one.
	func calcNumCoords(_ work: HKWorkout) async -> Int {
			// Attempts to fetch the first route associated with the workout. If no routes are found, returns 0.
		guard let route = await getWorkoutRoute(workout: work)?.first else {
			return 0
		}
			// Fetches location data for the extracted route.
		let locations = await getCLocationDataForRoute(routeToExtract: route)
			// Filters the locations to exclude coordinates at (0, 0), considering them as invalid.
		let filteredLocations = locations.filter { $0.coordinate.latitude != 0 || $0.coordinate.longitude != 0 }
			// Returns the count of filtered, presumably valid, locations.
		return filteredLocations.count
	}

		// MARK: - Address geocode lookup

		/// `func fetchAndUpdateAddress
		/// Asynchronously fetches and updates an address using reverse geocoding for given latitude and longitude coordinates.
		/// - Parameters:
		///   - [latitude:]: Double, The latitude of the location to reverse geocode.
		///   - [longitude:]: Double, The longitude of the location to reverse geocode.
		/// - Returns: An optional `Address` object containing detailed address information if successful; `nil` if not found or an error occurs.
	func fetchAndUpdateAddress(latitude: Double, longitude: Double) async -> Address? {
			// Initializes a CLGeocoder to perform reverse geocoding.
		let geocoder = CLGeocoder()
			// Creates a CLLocation object with the provided coordinates.
		let location = CLLocation(latitude: latitude, longitude: longitude)
			// Prepares a variable to store the result.
		var address: Address?

		do {
				// Performs the reverse geocoding operation.
			let placemarks = try await geocoder.reverseGeocodeLocation(location)
				// Checks if at least one placemark is found.
			if let placemark = placemarks.first {
					// Constructs an Address object with the placemark details.
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
				// Logs the error if the reverse geocoding fails.
			print("Address not found: \(error.localizedDescription)")
		}
			// Returns the constructed Address object, or nil if the operation failed.
		return address
	}

		/// `getWorkoutCoords
		/// Asynchronously fetches the geographical coordinates from the routes of a specified workout.
		/// - Parameter [thisWorkout:]: `HKWorkout`, The workout from which to extract geographical coordinates.
		/// - Returns: An array of `CLLocation` objects representing the coordinates of the workout's route.
		/// - Throws: An error if unable to fetch workout routes or coordinates.
	func getWorkoutCoords(thisWorkout: HKWorkout) async throws -> [CLLocation] {
			// Temporary storage for workout routes (though not directly used for the final result).
		var thisCoords: [HKWorkout] = []
			// Prepare a variable to store the returned coordinates.
		var retCoords: [CLLocation] = []

			// Checks if there are routes associated with the workout and they are not empty.
		if let routes = await getWorkoutRoute(workout: thisWorkout), !routes.isEmpty {
			for route in routes {
					// Fetches location data for each route.
				let coords = await getCLocationDataForRoute(routeToExtract: route)
					// Checks if coordinates are valid (latitude and longitude are not 0).
				if !coords.isEmpty && coords.contains(where: { $0.coordinate.latitude != 0 && $0.coordinate.longitude != 0 }) {
						// Appends the workout to thisCoords (though this step seems unnecessary for the final result).
					thisCoords.append(thisWorkout)
						// Updates retCoords with the fetched coordinates and breaks the loop since valid coordinates are found.
					retCoords = coords
					break // Stops checking further routes as valid coordinates are found.
				}
			}
		}
			// Returns the retrieved coordinates.
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

		/// `func fetchCoordinates`
		/// Asynchronously retrieves the geographical coordinates for a specified workout route.
		/// This function uses HealthKit's `HKWorkoutRouteQuery` to fetch location data related to a workout route,
		/// then extracts and returns the coordinates.
		///
		/// - Parameter [for route:]: `HKWorkoutRoute`, the workout route from which to fetch the coordinates.
		/// - Returns: An array of `CLLocationCoordinate2D` representing the route's geographical coordinates.
		/// - Throws: An error if the route data cannot be fetched or if an error occurs during the query.
	private func fetchCoordinates(for route: HKWorkoutRoute) async throws -> [CLLocationCoordinate2D] {
			// Performs an asynchronous operation awaiting a continuation to handle the result of the HealthKit query.
		try await withCheckedThrowingContinuation { continuation in
				// Initialize an empty array to store the coordinates.
			var coordinates: [CLLocationCoordinate2D] = []

				// Create a query to fetch locations associated with the provided `HKWorkoutRoute`.
			let query = HKWorkoutRouteQuery(route: route) { _, returnedLocations, done, errorOrNil in
					// Check for and handle any errors encountered during the query.
				if let error = errorOrNil {
						// If an error occurs, resume the continuation by throwing the error, terminating the operation.
					continuation.resume(throwing: error)
					return
				}

					// If location data is successfully returned, append the coordinates to the `coordinates` array.
				if let locations = returnedLocations {
					coordinates.append(contentsOf: locations.map { $0.coordinate })
				}

					// Once all data has been fetched (indicated by `done`), resume the continuation, returning the coordinates.
				if done {
					continuation.resume(returning: coordinates)
				}
			}
				// Execute the query on the HealthKit store.
			healthStore.execute(query)
		}
	}

		/// `fetchRouteData`
		/// Asynchronously fetches route data for a specified workout and returns the geographic coordinates.
		/// Utilizes HealthKit to query for `HKWorkoutRoute` objects associated with the given `HKWorkout`.
		/// - Parameter [for workout:]: `HKWorkout`, The workout from which to fetch route data.
		/// - Returns: An array of `CLLocationCoordinate2D` representing the route's geographic coordinates.
		/// - Throws: An error if the route data cannot be fetched or if no routes are associated with the workout.
	func fetchRouteData(for workout: HKWorkout) async throws -> [CLLocationCoordinate2D] {
			// Utilizes HKSeriesType.workoutRoute() to define the type of data to query, which is specifically workout routes.
		let routeType = HKSeriesType.workoutRoute()

			// Attempts to fetch routes associated with the workout using an asynchronous continuation to handle the response.
		let routes: [HKWorkoutRoute] = try await withCheckedThrowingContinuation { continuation in
				// Defines a predicate to filter objects that originate from the specified workout.
			let predicate = HKQuery.predicateForObjects(from: workout)
				// Creates a query for workout routes with the specified predicate and no limit on the number of results.
			let query = HKSampleQuery(sampleType: routeType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, error in
					// Handles potential errors by resuming the continuation with a throw.
				if let error = error {
					continuation.resume(throwing: error)
						// If routes are found, resumes the continuation with the fetched routes.
				} else if let routes = samples as? [HKWorkoutRoute] {
					continuation.resume(returning: routes)
						// Ensures the continuation is always resumed to avoid hanging, even if no routes are found.
				} else {
					continuation.resume(returning: [])
				}
			}
				// Executes the query on the HealthKit store.
			self.healthStore.execute(query)
		}

			// Checks to ensure at least one route is available to process.
		guard let firstRoute = routes.first else {
				// If no routes are found, returns an empty array of coordinates.
			return []
		}

			// If a route is found, proceeds to fetch and process the geographic coordinates from the first route.
			// This involves another asynchronous operation, potentially fetching detailed location data for the route.
		return try await fetchCoordinates(for: firstRoute)
	}

		/// `func calcTime`
		/// Calculates the time difference between two dates and formats it as a string.
		/// - Parameters:
		///   - from: The start date of the time interval.
		///   - to: The end date of the time interval.
		/// - Returns: A string representing the time difference in the format of "HH:mm:ss" or "mm:ss" depending on the duration.
	func calcTime(from: Date, to: Date) -> String {
			// Utilize the Calendar API to calculate the difference between two dates.
		let calendar = Calendar.current
			// Request the components of hours, minutes, and seconds from the calculated difference.
		let components = calendar.dateComponents([.hour, .minute, .second], from: from, to: to)

			// Extract the hour, minute, and second components from the dateComponents result.
			// If any component is nil (which shouldn't happen in this context), it defaults to 0.
		let hours = components.hour ?? 0
		let minutes = components.minute ?? 0
		let seconds = components.second ?? 0

			// Initialize a variable to hold the formatted time difference as a string.
		var timeDifference: String = ""

			// Check if the total duration includes full hours.
		if hours > 0 {
				// If there are hours, format the string to include hours, minutes, and seconds.
			timeDifference = String(format: "%d:%02d:%02d", hours, minutes, seconds)
		} else {
				// If the duration is less than an hour, format the string to include just minutes and seconds.
			timeDifference = String(format: "%d:%02d", minutes, seconds)
		}

			// Return the formatted string representing the time difference.
		return timeDifference
	}


		// Requests permission to access HealthKit data.
	func requestHealthKitPermission() async throws {
		let typesToRead: Set<HKObjectType> = [
			HKObjectType.workoutType(),
			HKSeriesType.workoutRoute()
		]
		try await healthStore.requestAuthorization(toShare: [], read: typesToRead)
	}



}

