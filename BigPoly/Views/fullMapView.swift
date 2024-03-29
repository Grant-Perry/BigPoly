//   fullMapView.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/8/24 at 9:56 AM
//     Modified: Monday February 19, 2024 at 9:43:53 AM
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import MapKit
import HealthKit
import UIKit

/// This is the full map view when the NavigationLink on the list view from WorkoutRouteView is selected

struct FullMapView: View {
	//	let workout: HKWorkout
	@State var thisWorkoutData: WorkoutData
//	@State private var selectedMapStyle: String = ".hybrid"
	@State  var regionx = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
														 span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
	@State var isLoading = true
	var position: MapCameraPosition = .automatic
	let gradient = LinearGradient(colors: [.gpPink, .gpYellow, .gpGreen], startPoint: .leading, endPoint: .trailing)
	let stroke = StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round) //,
//		dash: [5, 5])
	
	var body: some View {
//		region.center = thisWorkoutData.workoutCoords?.first

		Map {

			MapPolyline(coordinates: thisWorkoutData.workoutCoords!)
				.stroke(gradient, style: stroke)
//				.stroke(lineWidth: 6)
			
			Annotation(
				"Start", coordinate: CLLocationCoordinate2D(latitude: Double((thisWorkoutData.workoutCoords?.first!.latitude)!), 
																		  longitude: Double((thisWorkoutData.workoutCoords?.first!.longitude)!)), anchor: .bottom) {
																			  Image(systemName: "figure.walk.departure")
																				  .imageScale(.small)
																				  .padding(4)
																				  .foregroundStyle(.white)
																				  .background(Color.gpGreen)
																				  .cornerRadius(4)
																		  }
			
			Annotation(
				"End", coordinate: CLLocationCoordinate2D(latitude: Double((thisWorkoutData.workoutCoords?.last!.latitude)!),
																		longitude: Double((thisWorkoutData.workoutCoords?.last!.longitude)!)), anchor: .bottom) {
																			Image(systemName: "figure.walk.arrival")
																				.imageScale(.small)
																				.padding(4)
																				.foregroundStyle(.white)
																				.background(Color.gpRed)
																				.cornerRadius(4)
																		}

			//			Marker("Start", coordinate: startWorkout)
			//			Marker("End", coordinate: endWorkout)
		}
		.font(.footnote)
		.mapControlVisibility(.visible)
		.controlSize(.small)
		.mapControls() {
			MapPitchToggle()
			MapCompass()
			MapUserLocationButton()
			MapScaleView()

		}
		
		// MARK: Top Blue safeArea for the metrics display
		.safeAreaInset(edge: .top) {
			WorkoutMetricsView(thisWorkoutData: thisWorkoutData,
									 cityName: thisWorkoutData.workoutAddress?.city ?? "Loading",
									 workoutDate: thisWorkoutData.workoutDate,
									 thisDistance: thisWorkoutData.workoutDistance,
									 thisCoords: thisWorkoutData.workoutCoords?.first ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))

			.navigationTitle("Workout Map")
			.navigationBarTitleDisplayMode(.inline)
			.mapStyle(.imagery(elevation: .realistic))
			.background(.clear)
		}
	}
}


