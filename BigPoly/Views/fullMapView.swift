	//   fullMapView.swift
	//
	//   Created by: Grant Perry on 2/8/24 at 9:56 AM
	//     Modified: Monday March 4, 2024 at 4:49:26 PM
	//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry

import SwiftUI
import MapKit
import HealthKit
import UIKit

	/// This is the full map view called from NavigationLink on the list view from WorkoutRouteView is selected

struct FullMapView: View {
	@State var thisWorkoutData: WorkoutData
	@State var showLoading: Bool // force open/close the LoadingView()
	@State var isAvail = false // for lookAround scene
	@State var workoutCore = WorkoutCore.shared
	let gradient = LinearGradient(colors: [.gpPink, .gpYellow, .gpGreen], startPoint: .leading, endPoint: .trailing)
	let stroke = StrokeStyle(lineWidth: 6, lineCap: .round, lineJoin: .round) //, dash: [10, 10])

	var body: some View {

			//	MARK: - Full Map View with polyLine overlay of workout

			// unwrap the first and last coords
		if	let firstCoords = thisWorkoutData.workoutCoords?.first!, let lastCoords = thisWorkoutData.workoutCoords?.last! {
			Map {
				MapPolyline(coordinates: thisWorkoutData.workoutCoords!)
					.stroke(gradient, style: stroke)

				Annotation(
					"Start", coordinate: firstCoords, anchor: .bottom) {

						Image(systemName: "figure.walk.departure")
							.imageScale(.small)
							.padding(4)
							.foregroundStyle(.white)
							.background(Color.gpGreen)
							.cornerRadius(4)
					}

				Annotation(
					"End", coordinate: lastCoords, anchor: .bottom) {

						Image(systemName: "figure.walk.arrival")
							.imageScale(.small)
							.padding(4)
							.foregroundStyle(.white)
							.background(Color.gpRed)
							.cornerRadius(4)
					}

					//			Marker("Start", coordinate: startWorkout)
			}
			.onAppear {
				print("onAppear showLoading = \(showLoading)")
					// determine if there is a valid lookAround scene available
					// use it to set the .frame height to 0 if false
				Task {
						//				showLoading = workoutCore.fullMapLoading // turn on the loading screen
					if let thisCoord = thisWorkoutData.workoutCoords?.first {
						isAvail = await isLookAroundAvailable(for: thisCoord)
						print("lookAround Status: \(isAvail)")
					}
					print("[fullMapView-onAppear] showLoading NOW = \(showLoading)")
				}
				workoutCore.fullMapLoading = false // close the loading window
				showLoading = false
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

 // MARK: Top blue card .safeArea for the metrics display

			.safeAreaInset(edge: .top) {
				let thisTitle = String("\(thisWorkoutData.workoutAddress?.address ?? "Details for") Walk")
				WorkoutMetricsView(thisWorkoutData: thisWorkoutData,
										 cityName: thisWorkoutData.workoutAddress?.city ?? "Loading",
										 workoutDate: thisWorkoutData.workoutDate,
										 thisDistance: thisWorkoutData.workoutDistance,
										 thisCoords: thisWorkoutData.workoutCoords?.first ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))

				.navigationTitle(thisTitle)
				.navigationBarTitleDisplayMode(.inline)
				.mapStyle(.imagery(elevation: .realistic))
				.background(.clear)
			}
 // MARK: -> LookAround view .safeArea
			.safeAreaInset(edge: .bottom) {
				HStack {
					Spacer()
					VStack(spacing: 0) {
						LocationPreviewLookAroundView(workoutData: thisWorkoutData)
							// the MAGIC of isAvail! pre-checked if lookaround has a valid scene. set the .frame to 0 if it is not available
							.frame(height: isAvail ? 128 : 0)
							.clipShape(RoundedRectangle(cornerRadius: 10))
							.padding([.top, .horizontal])
					}
					Spacer()
				}
				.sheet(isPresented: $showLoading) {
					LoadingView(calledFrom: "Full Map", workType:  "This Workout", icon: "mappin.and.ellipse")
				}
				.background(.thinMaterial)
			}
		}
	}
}

	// determine if a valid lookAround is available for the coordinate
func isLookAroundAvailable(for thisCoords: CLLocationCoordinate2D) async -> Bool {
	do {
		let thisScene = try await MKLookAroundSceneRequest(coordinate: thisCoords).scene
		return thisScene != nil
	} catch {
			//			retScene = "NOT VALID"
		return false
	}
}




