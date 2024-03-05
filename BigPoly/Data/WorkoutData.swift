//   WorkoutData.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/17/24 at 2:42 PM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import HealthKit
import CoreLocation
import MapKit
import Observation

@Observable
class WorkoutData: Equatable {

	let id = UUID()
	let workout: HKWorkout
	let workoutDate: Date
	let workoutEndDate: Date
	var workoutDistance: Double
	var workoutAddress: Address?
	var workoutCoords: [CLLocationCoordinate2D]?
	var workoutPoly: MKPolyline?
	
	internal init(workout: HKWorkout, workoutDate: Date, workoutEndDate: Date, workoutDistance: Double, workoutAddress: Address? = nil, workoutCoords: [CLLocationCoordinate2D]? = nil, workoutPoly: MKPolyline? = nil) {
		self.workout = workout
		self.workoutDate = workoutDate
		self.workoutEndDate = workoutEndDate
		self.workoutDistance = workoutDistance
		self.workoutAddress = workoutAddress
		self.workoutCoords = workoutCoords
		self.workoutPoly = workoutPoly
	}

	static func == (lhs: WorkoutData, rhs: WorkoutData) -> Bool {
		return lhs.id == rhs.id
	}


}

