////   HistoricalWeather.swift
////   BigPoly
////
////   Created by: Grant Perry on 2/23/24 at 5:31 PM
////     Modified: 
////
////  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
////
//
//typealias DailyForecast = Forecast.DailyForecast // Add this line at the top of your file
//import Foundation
//import CoreLocation
//import WeatherKit
//
//struct HistoricalWeather {
//	let date: Date
//	let location: CLLocationCoordinate2D
//	let city: String
//	let highTemperatureFahrenheit: Double
//	let lowTemperatureFahrenheit: Double
//	let overallConditions: String
//
//
//
//	init(date: Date, location: CLLocationCoordinate2D, city: String, highTemp: Double, lowTemp: Double, conditions: String) {
//		self.date = date
//		self.location = location
//		self.city = city
//		self.highTemperatureFahrenheit = highTemp
//		self.lowTemperatureFahrenheit = lowTemp
//		self.overallConditions = conditions
//	}
//}
//
//func getHistoricalWeather(for location: CLLocationCoordinate2D, on date: Date, completion: @escaping (HistoricalWeather?) -> Void) {
//	let weatherService = WeatherService()
//
//	// Create a CLLocation object from the CLLocationCoordinate2D
//	let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
//
//	// Fetch historical weather data
//	// Add a type annotation for the forecast parameter
////	weatherService.weather(for: clLocation, including: .daily(startDate: date, endDate: date) as DailyForecast) { result in
////	weatherService.weather(for: clLocation, including: .daily(startDate: date, endDate: date) as Forecast.DailyForecast) { result in
//	weatherService.weather(for: clLocation, including: .daily(startDate: date, endDate: date) as WeatherKit.Forecast<DailyForecast>.DailyForecast) { result in
//		// ...
//		switch result {
//			case .success(let forecast):
//				if let dailyForecast = forecast.daily.first {
//					let highTempFahrenheit = dailyForecast.temperature.high.toFahrenheit()
//					let lowTempFahrenheit = dailyForecast.temperature.low.toFahrenheit()
//					let conditions = dailyForecast.conditions
//
//					let historicalData = HistoricalWeather(date: date, location: location, city: "Your City", highTemp: highTempFahrenheit, lowTemp: lowTempFahrenheit, conditions: conditions)
//					completion(historicalData)
//				} else {
//					completion(nil)
//				}
//			case .failure:
//				completion(nil)
//		}
//	}
//}
//
//// Extension to convert Celsius to Fahrenheit
//extension Double {
//	func toFahrenheit() -> Double {
//		return (self * 9/5) + 32
//	}
//}
//
////// Example usage:
////let currentDate = Date() // Replace with your desired date
////let currentLocation = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // Example coordinates for San Francisco
////
////getHistoricalWeather(for: currentLocation, on: currentDate) { historicalWeather in
////	if let historicalData = historicalWeather {
////		print("Historical weather for \(historicalData.city) on \(historicalData.date):")
////		print("High temperature: \(historicalData.highTemperatureFahrenheit)°F")
////		print("Low temperature: \(historicalData.lowTemperatureFahrenheit)°F")
////		print("Overall conditions: \(historicalData.overallConditions)")
////	} else {
////		print("Unable to retrieve historical weather data.")
////	}
////}
