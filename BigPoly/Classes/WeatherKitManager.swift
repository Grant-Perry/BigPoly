//   WeatherKitManager.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/24/24 at 9:47 AM
//     Modified: Saturday February 24, 2024 at 10:07:28 AM

// 	brought over from BigMetric-Monkey -
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//  Modified: Monday February 26, 2024 at 10:09:52 AM

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
	let sharedService = WeatherService.shared
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

	private func fetchWeather(for coordinate: CLLocationCoordinate2D) async throws -> Weather {
		let weather = try await Task.detached(priority: .userInitiated) { [self] in
			return try await self.sharedService.weather(for: self.convertToCLLocation(coordinate))
		}.value
		return weather
	}

	// Function to fetch historical weather forecast for a specific location and date range
	//  Modified: Saturday February 24, 2024 at 10:01:36 AM
	func fetchPastCast(forWhere: CLLocation, 
							 forWhenStart: Date,
							 forWhenEnd: Date,
							 pastCast: PastForecast) async {
		
		let weatherService = WeatherService()

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

				precipForecast2	= firstHourlyForecast.precipitationChance
				precipForecast	= firstHourlyForecast.precipitationAmount.value
				symbolHourly		= firstHourlyForecast.symbolName
				tempHour			= String(format: "%.0f", firstHourlyForecast.temperature.converted(to: .fahrenheit).value )
				tempVar				= String(format: "%.0f", current.temperature.converted(to: .fahrenheit).value )
				highTempVar		= String(format: "%.0f", dailyForecast.first?.highTemperature.converted(to: .fahrenheit).value ?? 0 )
				lowTempVar			= String(format: "%.0f", dailyForecast.first?.lowTemperature.converted(to: .fahrenheit).value ?? 0 )
				windSpeedVar		= current.wind.speed.converted(to: .milesPerHour).value
				windDirectionVar	= CardinalDirection(course: current.wind.direction.converted(to: .degrees).value).rawValue
				symbolVar			= current.symbolName
				//					locationName		= distanceTracker.locationName

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


	@discardableResult
	func dailyForecast(for coordinate: CLLocationCoordinate2D) async -> Forecast<DayWeather>? {
		let currentCoord     	= CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		let dayWeather       	= await Task.detached(priority: .userInitiated) {
			/// let (current, minute, hourly) = try await service.weather(for: newYork, including: .current, .minute, .hourly)
			let dayForecast	= try? await self.sharedService.weather(
				for: currentCoord,
				including: .daily)
			return dayForecast
		}.value
		print("dayWeather = \(dayWeather?.count ?? 0)")
		return dayWeather
	}

	@discardableResult
	func hourlyForecast(for coordinate: CLLocationCoordinate2D) async -> Forecast<HourWeather>? {
		let currentCoord		=  CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
		let hourWeather			= await Task.detached(priority: .userInitiated) {
			let hourForecast	= try? await self.sharedService.weather(
				for: currentCoord,
				including: .hourly)
			return hourForecast
		}.value
		print("hourWeather = \(hourWeather?.count ?? 0)")
		return hourWeather
	}

	// convert a CLLocationCoordinate2D to CLLocation
	func convertToCLLocation(_ coordinate: CLLocationCoordinate2D) -> CLLocation {
		return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
	}

	//convert celsius to fahrenheit
	func celToFah(_ celsius: Double) -> Double {
		let fahrenheit = (celsius * 9.0 / 5.0) + 32.0
		return fahrenheit

	}
}
