//   gpNumFormat.swift
//   BigPoly
//
//   Created by: Grant Perry on 3/4/24 at 1:20 PM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI

	/// A utility structure for formatting numeric values.
class gp {

		/// Formats a numeric value to a string with a specified number of decimal places.
		/// This method can handle any type that conforms to `BinaryFloatingPoint`, which includes
		/// standard floating-point types such as `Float`, `Double`, and `CGFloat`.
		///
		/// - Parameters:
		///   - [number:]: The number to be formatted. It must conform to `BinaryFloatingPoint`.
		///   - [decimalPlaces:]: The number of decimal places to include in the formatted string.
		///     If `0`, the number is rounded to the nearest whole number.
		/// - Returns: A `String` representation of the number formatted to the specified number of decimal places.
		///
		/// Example usage:
		/// ```
		/// let newFormatNum = gp.formatNum(1234.5678, 1) // returns: "1234.5"
		/// ```
	static func formatNumber<numToFix: BinaryFloatingPoint>(_ number: numToFix, _ decimalPlaces: Int) -> String {
			// If the caller requests no decimal places, format the number as an integer.
		if decimalPlaces == 0 {
			return String(format: "%.0f", Double(number))
		} else {
				// Construct a format string using the specified number of decimal places.
				// This allows for dynamic adjustment of the number of decimals in the output.
			let formatString = "%.\(decimalPlaces)f"
				// Use the format string to format the number, casting it to Double to satisfy the String format method.
			return String(format: formatString, Double(number))
		}
	}
}
