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

	/// Manages the retrieval and processing of weather data using WeatherKit and CoreLocation.
	/// This class encapsulates functionality for fetching both current and forecasted weather information,
	/// converting temperature units, and handling location data for weather queries.
@Observable
class WeatherKitManager: NSObject {
		// Properties to store fetched weather forecasts and related data.
	var dailyForecast: Forecast<DayWeather>?
	var hourlyForecast: Forecast<HourWeather>?

		// WeatherService instances for fetching weather data.
	let weatherService = WeatherService() // Instance for custom use.
	let sharedWeatherService = WeatherService.shared // Shared instance for common requests.

		// Current date and location information for weather queries.
	var date: Date = .now
	var latitude: Double = 0
	var longitude: Double = 0

		// Variables to store specific weather metrics after fetching.
	var windSpeedVar: Double = 0
	var precipForecast: Double = 0
	var precipForecast2: Double = 0
	var precipForecastAmount: Double = 0
	var isErrorAlert: Bool = false // Indicates if an error alert should be shown.
	var symbolVar: String = "xmark" // Default symbol for weather conditions.
	var tempVar: String = "" // Current temperature.
	var tempHour: String = "" // Temperature for a specific hour.
	var windDirectionVar: String = "" // Wind direction.
	var highTempVar: String = "" // High temperature forecast.
	var lowTempVar: String = "" // Low temperature forecast.
	var locationName: String = "" // Name of the location for the weather query.
	var weekForecast: [Forecasts] = [] // Array to store a week's worth of forecast data.
	var symbolHourly: String = "" // Symbol representing hourly weather conditions.

		// Computed property to create a CLLocation object from latitude and longitude.
	var cLocation: CLLocation {
		CLLocation(latitude: latitude, longitude: longitude)
	}

		// Initialization allowing for optional injection of forecast data and other parameters.
	internal init(dailyForecast: Forecast<DayWeather>? = nil, hourlyForecast: Forecast<HourWeather>? = nil, date: Date = .now, latitude: Double = 0, longitude: Double = 0, windSpeedVar: Double = 0, precipForecast: Double = 0, precipForecast2: Double = 0, precipForecastAmount: Double = 0, isErrorAlert: Bool = false, symbolVar: String = "xmark", tempVar: String = "", tempHour: String = "", windDirectionVar: String = "", highTempVar: String = "", lowTempVar: String = "", locationName: String = "", weekForecast: [Forecasts] = [], symbolHourly: String = "") {
		self.dailyForecast = dailyForecast
		self.hourlyForecast = hourlyForecast
			// Additional initialization logic...
	}

		// MARK: Methods

		/// `fetchWeather(for:)`
		/// - Fetches current weather data for a specific location using WeatherKit.
		/// - Parameters:
		///   - coordinate: The geographic coordinates for which to fetch the weather.
		/// - Returns: A `Weather` object containing the current weather data for the specified location.
		/// - Throws: An error if the weather data cannot be fetched.
	private func fetchWeather(for coordinate: CLLocationCoordinate2D) async throws -> Weather {
		let location = convertToCLLocation(coordinate)
		return try await sharedWeatherService.weather(for: location)
	}

		/// `fetchPastCast(forWhere:forWhenStart:forWhenEnd:pastCast:)`
		/// - Fetches historical weather forecast for a specific location and date range.
		/// - Parameters:
		///   - forWhere: The `CLLocation` for which to fetch the historical weather.
		///   - forWhenStart: The start date of the desired historical period.
		///   - forWhenEnd: The end date of the desired historical period.
		///   - pastCast: The `PastForecast` object to be populated with the fetched weather data.
		/// - This function modifies the passed `PastForecast` object with fetched weather data.
	func fetchPastCast(forWhere: CLLocation, forWhenStart: Date, forWhenEnd: Date, pastCast: PastForecast) async {
		do {
			let forecast = try await weatherService.weather(for: forWhere, including: .daily(startDate: forWhenStart, endDate: forWhenEnd.addingTimeInterval(86400)))
			if let firstCast = forecast.first {
				pastCast.symbolName = firstCast.symbolName
				pastCast.condition = firstCast.condition.description
				pastCast.minTemp = firstCast.lowTemperature.value
				pastCast.maxTemp = firstCast.highTemperature.value
				pastCast.windSpeed = firstCast.wind.speed.value
				pastCast.precip = firstCast.precipitation.description
			}
		} catch {
			print("Error fetching weather forecast for the specified date range: \(error)")
		}
	}

		/// `getWeather(for:)`
		/// - Retrieves the current and hourly forecast for a given location.
		/// - Parameters:
		///   - coordinate: The location for which to fetch weather data.
		/// - This function initiates a series of async fetch operations to populate weather data properties.
	func getWeather(for coordinate: CLLocationCoordinate2D) {
		Task {
			do {
				let weather = try await fetchWeather(for: coordinate)
//				let current = weather.currentWeather
				let hourly = weather.hourlyForecast.first
//				if let dailyForecast = await dailyForecast(for: coordinate), let firstHourlyForecast = hourly {
//						// Update properties with fetched data
//				}
			} catch {
				print("\(error.localizedDescription)")
			}
		}
	}

		/// `dailyForecast(for:)`
		/// - Fetches the daily forecast for a specific coordinate.
		/// - Parameters:
		///   - for coordinate: The `CLLocationCoordinate2D` for which to fetch the daily forecast.
		/// - Returns: An optional `Forecast<DayWeather>` containing the daily weather forecast.
		/// - This function performs an asynchronous fetch operation to retrieve daily weather data.
	func dailyForecast(for coordinate: CLLocationCoordinate2D) async -> Forecast<DayWeather>? {
		let currentCoord = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		return await Task.detached(priority: .userInitiated) {
			return try? await self.sharedWeatherService.weather(for: currentCoord, including: .daily)
		}.value
	}

		/// `hourlyForecast(for:)`
		/// - Fetches the hourly forecast for a specific coordinate.
		/// - Parameters:
		///   - for coordinate: The `CLLocationCoordinate2D` for which to fetch the hourly forecast.
		/// - Returns: An optional `Forecast<HourWeather>` containing the hourly weather forecast.
		/// - This function performs an asynchronous fetch operation to retrieve hourly weather data.
	func hourlyForecast(for coordinate: CLLocationCoordinate2D) async -> Forecast<HourWeather>? {
		let currentCoord = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		return await Task.detached(priority: .userInitiated) {
			return try? await self.sharedWeatherService.weather(for: currentCoord, including: .hourly)
		}.value
	}

		/// `convertToCLLocation(_:)`
		/// - Converts `CLLocationCoordinate2D` to `CLLocation`.
		/// - Parameters:
		///   - coordinate: The `CLLocationCoordinate2D` to convert.
		/// - Returns: A `CLLocation` object for the given coordinate.
	func convertToCLLocation(_ coordinate: CLLocationCoordinate2D) -> CLLocation {
		CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
	}

		/// `celToFah(_:)`
		/// - Converts temperature from Celsius to Fahrenheit.
		/// - Parameters:
		///   - celsius: The temperature in Celsius to convert.
		/// - Returns: The temperature in Fahrenheit.
	func cTOf(_ celsius: Double) -> Double {
		(celsius * 9.0 / 5.0) + 32.0
	}
}

