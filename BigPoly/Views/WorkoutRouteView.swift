//   WorkoutRouteView.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/10/24 at 2:42 PM
//     Modified:
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//


import SwiftUI
import CoreLocation
import MapKit
import HealthKit

struct WorkoutRouteView: View {
	//	@State var workout: HKWorkout
	@State var workoutData: WorkoutData
	@State private var workoutCore = WorkoutCore.shared
	@State var address: Address? = nil
	@State var thisWorkoutDistance: Double = 0
	@State var date: Date = Date()
	@State var latitude: Double = 37.000914
	@State var longitude: Double = -76.442160
	@State var isLoading = true
	@State var locations: [CLLocation]? = nil
	@State private var position: MapCameraPosition = .automatic
	@State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), span: MKCoordinateSpan(latitudeDelta: 1.25, longitudeDelta: 1.25))
	var boxHeight = 125.0

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			HStack(spacing: 0) {
				if isLoading {
					ProgressView()
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.background(Color.blue.gradient)
						.cornerRadius(10)
				} else {
					// MARK: - Address Container
					VStack {
						Text(workoutData.workoutDate.formatted(as: "MMM d, yy"))
							.font(.system(size: 15))
							.foregroundColor(.white)
							.rightJustify()
							.padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 33))

						//						Spacer()
						Text(workoutData.workoutAddress?.city ?? "Loading...")
							.font(.system(size: 22)).bold()
							.foregroundColor(.white)
						//							.padding(EdgeInsets(top: 1, leading: 15, bottom: 0, trailing: 0))
							.padding(.leading)
							.leftJustify()

						VStack(alignment: .leading, spacing: 1) {
							Text(workoutData.workoutAddress?.name  ?? "Loading...")
								.font(.system(size: 17))
								.frame(width: 120, height: 16)
							Spacer()
							HStack {
								Spacer() // Pushes the content to the right

								Text("Distance:")
									.font(.system(size: 8))

								Text(String(format: "%.2f", workoutData.workoutDistance))
									.font(.system(size: 17).bold())
							}
							.padding(.trailing, 30)

							HStack {
								Spacer()
								HStack {
									Spacer() // Pushes the content to the right

									Text("Time:")
										.font(.system(size: 8))
									// calculate the time between first waypoint and last
									Text(String(workoutCore.calcTime(from: workoutData.workoutDate, to: workoutData.workoutEndDate)))
										.font(.system(size: 11))
								}
								.padding(.trailing, 30)
							}
						}
						.foregroundColor(.white)
						.padding(.leading, 20) // indent the text
						.leftJustify()
						Spacer()
					}
					.frame(width: UIScreen.main.bounds.width * 0.5, height: boxHeight)
					.background(.blue.gradient)
					.cornerRadius(10, corners: [.topLeft, .bottomLeft])
					.leftJustify()
				}

				// MARK: -> Map container
				if let coordinate = locations?.first?.coordinate {
					Map(position: $position) {
						Annotation(
							"❤️",
							coordinate: coordinate,
							anchor: .bottom
						) {
						}
					}
					.onAppear {
						// adjust the camera position for these coordinates
						updateCameraPosition()
					}
					.mapControlVisibility(.hidden)
					.mapStyle(.hybrid(elevation: .realistic))
					.disabled(true)
					.frame(width: UIScreen.main.bounds.width * 0.35, height: boxHeight)
					.cornerRadius(10, corners: [.topRight, .bottomRight])
					.padding(.leading, -20)
				} else {
					Text("No Map Data")
						.frame(width: UIScreen.main.bounds.width * 0.5, height: boxHeight)
						.background(.blue.gradient)
						.cornerRadius(10)
				}
			}
		}
		// MARK: - Full Container
		.frame(width: UIScreen.main.bounds.width * 0.65, height: boxHeight)
		//			.frame(width: UIScreen.main.bounds.width * 0.9, height: heights)
		.padding([.top, .horizontal])



		.onAppear() {
			Task {
				isLoading = true // turn on the loading screen
				print("TASK # 2: Get the routes")
				guard let routes = await workoutCore.getWorkoutRoute(workout: workoutData.workout),
						let firstRoute = routes.first else { return }

				print("TASK # 3: Get the CLLocations for the routes\n")
				locations = await workoutCore.getCLocationDataForRoute(routeToExtract: firstRoute)
				guard let firstLocation = locations?.first else {
					print("No locations available in the route.")
					return
				}
				print("finished locations\n")
				self.latitude = firstLocation.coordinate.latitude
				self.longitude = firstLocation.coordinate.longitude

				// change loading window state to close it
				self.isLoading = false
			}
		}
		.preferredColorScheme(.light)
	}
	

	private func updateCameraPosition() {
		// set the center, distance, heading and pitch for the MapCamera for this map view

		if let thisCoords = locations?.first?.coordinate {
			position = .camera(
				MapCamera (
					centerCoordinate: thisCoords,
					distance: 1.5,
					heading: 242,
					pitch: 60))
		}
	}
}


