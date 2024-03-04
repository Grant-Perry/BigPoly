//   WorkoutMetricsView.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/14/24 at 12:20 PM
//     Modified: Sunday February 25, 2024 at 7:19:57 PM
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//
import SwiftUI
import CoreLocation

	/// Called from WorkoutRouteView 
	/// Displays workout metrics including location, date, distance, and weather conditions.
	/// - Property List:
	///   - [thisWorkoutData]: WorkoutData, State, Stores workout data including routes and distance.
	///   - [cityName]: String, State, Name of the city where the workout took place.
	///   - [workoutDate]: Date, State, Date when the workout occurred.
	///   - [thisDistance]: Double, State, Total distance covered in the workout.
	///   - [thisCoords]: CLLocationCoordinate2D, State, Coordinates for the workout location.
	///   - [pastCast]: PastForecast, State, Weather conditions during the workout.
	///   - [weatherKit]: WeatherKitManager, State, Manages weather data fetching.
	///   - [isLoading]: Bool, State, Indicates if data is currently loading.
struct WorkoutMetricsView: View {
	@State var thisWorkoutData: WorkoutData
	@State var cityName: String
	@State var workoutDate: Date
	@State var thisDistance: Double
	@State var thisCoords: CLLocationCoordinate2D
	@State var pastCast = PastForecast()
	@State var weatherKit = WeatherKitManager()
	@State private var isLoading = false

	var body: some View {
		VStack {
			if isLoading {
					// Displays a loading view when data is being fetched.
				LoadingView(calledFrom: "Metrics", workType: "Workouts", icon: "map.fill")
			} else {
				HStack {
						// Left side of the view displaying city name and workout date.
					VStack {
						Text("\(cityName)")
							.font(.title).bold()
							.lineLimit(1)
							.minimumScaleFactor(0.5)
							.scaledToFit()

						Text("\(workoutDate, formatter: dateFormatter)")
							.font(.footnote)
							.padding(.leading)
					}
					.frame(width: UIScreen.main.bounds.width * 0.45, alignment: .center)
					.padding(.trailing)

					Spacer() // Separates the left and right sides of the HStack.

						// Right side of the view displaying weather conditions and distance.
					VStack(alignment: .trailing) {
						HStack(alignment: .top, spacing: 4) {
							if let symbolName = pastCast.symbolName {
								Image(systemName: symbolName)
									.font(.footnote)

								Spacer()

								Text(pastCast.condition ?? "")
									.font(.footnote)
									.lineLimit(2)
									.minimumScaleFactor(0.5)
									.scaledToFit()
							}
						}

						HStack(alignment: .center, spacing: 4) {
							if let maxT = pastCast.maxTemp, let minT = pastCast.minTemp {
								Image(systemName: "thermometer.variable.and.figure")
									.font(.footnote)

								Spacer()

								Text(String(Int((weatherKit.celToFah(minT)))))
									.font(.footnote) +

								Text(" L")
									.font(.system(size: 8))
								Text(String(Int((weatherKit.celToFah(maxT)))))
									.font(.footnote) +
								Text(" H")
									.font(.system(size: 8))

							} else {
								Text("loading")
									.font(.system(size: 9))
							}
						}
						.font(.footnote)

						HStack(alignment: .bottom, spacing: 0) {
							Image(systemName: "figure.run.square.stack")
								.font(.footnote)

							Spacer()

							Text("\(String(format: "%.2f", thisDistance))")
								.font(.callout) +
							Text(" Miles")
								.font(.system(size: 9))
						}
					}
					.onAppear {
						Task {
								// Fetches past weather conditions for the workout asynchronously.
							await weatherKit.fetchPastCast(forWhere: weatherKit.convertToCLLocation(thisCoords),
																	 forWhenStart: thisWorkoutData.workoutDate,
																	 forWhenEnd: thisWorkoutData.workoutEndDate,
																	 pastCast: pastCast)

							isLoading = false // Disables the loading view once data has been fetched.
						}
					}
					.frame(width: UIScreen.main.bounds.width * 0.3, alignment: .trailing)
				}
				.padding()
				.frame(maxWidth: .infinity)
				.background(Color.blue.gradient.opacity(0.9))
				.foregroundColor(.white)
				.cornerRadius(8)
				.shadow(color: .gray, radius: 5, x: 0, y: 2)
					// Styling applied to the entire metrics display, including background, foreground colors, corner radius, and shadow.
			}
		}
	}

		/// DateFormatter to format the workoutDate for display.
		/// - Returns: A configured DateFormatter for medium date style.
	private var dateFormatter: DateFormatter {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		return formatter
	}
}

//
//#Preview {
//	//	var home = CLLocationCoordinate2D(latitude: 37.000914, longitude: -76.442160)
//	WorkoutMetricsView(cityName: "Los Angles", workoutDate: Date(), thisWorkoutData = WorkoutData(),
//							 thisDistance: 2.47, thisCoords: CLLocationCoordinate2DMake(37.000914, -76.442160))
//}
