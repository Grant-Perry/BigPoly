//   WeatherKitManager.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/24/24 at 9:47 AM
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry

//  Modified: Modified: Tuesday February 27, 2024 at 9:26:35 AM

import SwiftUI
import Observation
import WeatherKit
import CoreLocation

@Observable
class WeatherKitManager: NSObject {
	//	static let wKitShared = WeatherKitManager()

	var dailyForecast : Forecast<DayWeather>?
	var hourlyForecast : Forecast<HourWeather>?
	let weatherService = WeatherService()
	let sharedWeatherService = WeatherService.shared
	var date: Date = .now
	var latitude: Double = 0
	var longitude: Double = 0
	var windSpeedVar: Double = 0
	var precipForecast: Double = 0
	var precipForecast2: Double = 0
	var precipForecastAmount: Double = 0
	var isErrorAlert: Bool = false
	var symbolVar: String = "xmark"
	var tempVar: String = ""
	var tempHour: String = ""
	var windDirectionVar: String	= ""
	var highTempVar: String = ""
	var lowTempVar: String = ""
	var locationName: String = ""
	var weekForecast: [Forecasts]	= []
	var symbolHourly: String = ""
	var cLocation: CLLocation {
		CLLocation(latitude: latitude, longitude: longitude)
	}

	internal init(dailyForecast: Forecast<DayWeather>? = nil, hourlyForecast: Forecast<HourWeather>? = nil, date: Date = .now, latitude: Double = 0, longitude: Double = 0, windSpeedVar: Double = 0, precipForecast: Double = 0, precipForecast2: Double = 0, precipForecastAmount: Double = 0, isErrorAlert: Bool = false, symbolVar: String = "xmark", tempVar: String = "", tempHour: String = "", windDirectionVar: String = "", highTempVar: String = "", lowTempVar: String = "", locationName: String = "", weekForecast: [Forecasts] = [], symbolHourly: String = "") {
		self.dailyForecast = dailyForecast
		self.hourlyForecast = hourlyForecast
		self.date = date
		self.latitude = latitude
		self.longitude = longitude
		self.windSpeedVar = windSpeedVar
		self.precipForecast = precipForecast
		self.precipForecast2 = precipForecast2
		self.precipForecastAmount = precipForecastAmount
		self.isErrorAlert = isErrorAlert
		self.symbolVar = symbolVar
		self.tempVar = tempVar
		self.tempHour = tempHour
		self.windDirectionVar = windDirectionVar
		self.highTempVar = highTempVar
		self.lowTempVar = lowTempVar
		self.locationName = locationName
		self.weekForecast = weekForecast
		self.symbolHourly = symbolHourly
	}

		// Fetches current weather data for a given location.
		// [coordinate:]: CLLocationCoordinate2D, Required for fetching weather data.
		// Returns: Weather object containing current weather data.
	private func fetchWeather(for coordinate: CLLocationCoordinate2D) async throws -> Weather {
		// Convert coordinate to CLLocation within the async context to ensure all parts of the operation can be cancelled together.
		let location = convertToCLLocation(coordinate)

		// Directly await the weather fetching without detaching a new task, assuming sharedService's weather function is already async.
		let weather = try await sharedWeatherService.weather(for: location)

		return weather
	}

	// Fetch historical weather forecast for a specific location and date range
	// [forWhere:], [forWhenStart:], [forWhenEnd:], [pastCast:]: Various parameters for specifying the location and date range.
	// Modifies the passed PastForecast object with fetched weather data.
	func fetchPastCast(forWhere: CLLocation, forWhenStart: Date, forWhenEnd: Date, pastCast: PastForecast) async {
		let weatherService = WeatherService()
		print("[fetchPastCast]: startDate = \(forWhenStart) - endDate = \(forWhenStart.addingTimeInterval(86400)) ")
		do {
			// Fetch the weather forecast for the specified location and date range
			let forecast = try await weatherService.weather(for: forWhere, 
																			including: .daily(startDate: forWhenStart,
																									endDate: forWhenStart.addingTimeInterval(86400)))
			if let firstCast 			= forecast.first {
				pastCast.symbolName 	= firstCast.symbolName
				pastCast.condition 	= firstCast.condition.description
				pastCast.minTemp 		= firstCast.lowTemperature.value
				pastCast.maxTemp 		= firstCast.highTemperature.value
				pastCast.windSpeed 	= firstCast.wind.speed.value
				pastCast.precip		= firstCast.precipitation.description

				print("pastCast = \(pastCast)")
				if let symbolName = pastCast.symbolName {
					print("symbolName = \(symbolName)")
				}
			}
		} catch {
			print("Error fetching weather forecast for the specified date range: \(error)")
		}
	}

	// main method to retrieve the currentForecast and hourlyForecast
	// [coordinate:]: CLLocationCoordinate2D, Location for which to fetch weather data.
	func getWeather(for coordinate: CLLocationCoordinate2D) {
		Task {
			do {
				let weather = try await fetchWeather(for: coordinate)
				//				let forecast = try await weatherService.weather(for: convertToCLLocation(coordinate), on: date)
				let current = weather.currentWeather
				let hourly  = weather.hourlyForecast.first
				guard let dailyForecast = await dailyForecast(for: coordinate) else {
					print("Failed to fetch daily forecast. [getWeather]")
					return
				}
				guard let firstHourlyForecast = hourly else { // } hourlyForecast.first else {
					print("firstHourlyForecast not available.  [getWeather]\n")
					// Show an error message or take appropriate action
					return
				}

				precipForecast2 = firstHourlyForecast.precipitationChance
				precipForecast = firstHourlyForecast.precipitationAmount.value
				symbolHourly = firstHourlyForecast.symbolName
				tempHour = String(format: "%.0f", firstHourlyForecast.temperature.converted(to: .fahrenheit).value )
				tempVar = String(format: "%.0f", current.temperature.converted(to: .fahrenheit).value )
				highTempVar = String(format: "%.0f", dailyForecast.first?.highTemperature.converted(to: .fahrenheit).value ?? 0 )
				lowTempVar = String(format: "%.0f", dailyForecast.first?.lowTemperature.converted(to: .fahrenheit).value ?? 0 )
				windSpeedVar = current.wind.speed.converted(to: .milesPerHour).value
				windDirectionVar = CardinalDirection(course: current.wind.direction.converted(to: .degrees).value).rawValue
				symbolVar = current.symbolName

				// Check to see if the dailyForecast array has anything in it for the 10-day forecast; if not, return
				if dailyForecast.isEmpty {
					return
				}
				let howManyDays = min(dailyForecast.count, 10)

				// iterate and build the daily weather display
				weekForecast = (0..<howManyDays).map { index in
					let dailyWeather	= dailyForecast[index]
					let symbolName		= dailyWeather.symbolName
					let minTemp			= String(format: "%.0f", dailyWeather.lowTemperature.converted(to: .fahrenheit).value)
					let maxTemp			= String(format: "%.0f", dailyWeather.highTemperature.converted(to: .fahrenheit).value)
					return Forecasts(symbolName: symbolName, minTemp: minTemp, maxTemp: maxTemp)
				}
			} catch {
				if let error = error as? URLError, error.code == .notConnectedToInternet {
					print("Network error: The Internet connection appears to be offline.")
					isErrorAlert = true
				} else {
					print("\(error.localizedDescription) - [getWeather]")
					// Handle other error scenarios or log the error
				}
			}
		}
	}

		/// Fetches the daily forecast for a specific coordinate.
		/// Utilizes `WeatherService` to retrieve weather data including daily forecasts.
		/// - Parameters:
		///   - [for coordinate:]: CLLocationCoordinate2D, the geographic coordinates for which to fetch the weather.
		/// - Returns: An optional `Forecast<DayWeather>` containing the daily weather forecast.
		/// - Note: This method executes a detached task with user-initiated priority to ensure it doesn't block the main thread and has a slightly higher priority than default.
	func dailyForecast(for coordinate: CLLocationCoordinate2D) async -> Forecast<DayWeather>? {
			// Convert CLLocationCoordinate2D to CLLocation for compatibility with WeatherService API.
		let currentCoord = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

			// Asynchronously fetch the daily weather forecast using WeatherService.
		let dayWeather = await Task.detached(priority: .userInitiated) {
				// Attempt to fetch the weather for the given coordinates, focusing on daily forecasts.
			return try? await self.sharedWeatherService.weather(for: currentCoord, including: .daily)
		}.value

			// Log the number of days for which weather data was retrieved.
		print("dayWeather = \(dayWeather?.count ?? 0)")

		return dayWeather
	}

		/// Fetches the hourly forecast for a specific coordinate.
		/// Leverages `WeatherService` to obtain weather data including hourly forecasts.
		/// - Parameters:
		///   - [for coordinate:]: CLLocationCoordinate2D, the geographic coordinates for which to fetch the weather.
		/// - Returns: An optional `Forecast<HourWeather>` containing the hourly weather forecast.
		/// - Note: Executes a detached task with user-initiated priority to perform the fetch operation without interfering with UI responsiveness.
	func hourlyForecast(for coordinate: CLLocationCoordinate2D) async -> Forecast<HourWeather>? {
			// Convert CLLocationCoordinate2D to CLLocation to use in the WeatherService API.
		let currentCoord = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

			// Asynchronously retrieve the hourly weather forecast using WeatherService.
		let hourWeather = await Task.detached(priority: .userInitiated) {
				// Attempt to fetch the weather for the given location, specifically requesting hourly forecast data.
			return try? await self.sharedWeatherService.weather(for: currentCoord, including: .hourly)
		}.value

			// Log the number of hours for which weather data was retrieved.
		print("hourWeather = \(hourWeather?.count ?? 0)")

		return hourWeather
	}


		// Helper method to convert CLLocationCoordinate2D to CLLocation.
		// [coordinate:]: CLLocationCoordinate2D, Coordinate to convert.
		// Returns: CLLocation object for the given coordinate.
	func convertToCLLocation(_ coordinate: CLLocationCoordinate2D) -> CLLocation {
		return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
	}

		// Converts temperature from Celsius to Fahrenheit.
		// [celsius:]: Double, Temperature in Celsius to convert.
		// Returns: Temperature in Fahrenheit as Double.
	func celToFah(_ celsius: Double) -> Double {
		let fahrenheit = (celsius * 9.0 / 5.0) + 32.0
		return fahrenheit
	}
}

