//   DatePickerView.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/20/24 at 2:53 PM
//     Modified: Wednesday March 6, 2024 at 10:21:41 AM
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//
// this is the datePicker view called in a .sheet from polyView


import SwiftUI

/// ``DatePickerView``
/// A custom view for selecting a date range and workout limit for filtering workouts.
/// This view utilizes `@Binding` properties to allow for two-way data binding with parent views, enabling real-time updates.
/// - Parameters:
///     - `startDate`: A binding to a `Date` value representing the start date of the filter range.
///     - `endDate`: A binding to a `Date` value for the end date of the filter range.
///     - `workoutLimit`: A binding to an `Int` representing the maximum number of workouts to display.
///     - `isLoading`: A binding to a `Bool` that controls the loading state of the view.
///     - `onSubmit`: A closure that is called when the submit button is tapped.
/// - `presentationMode`: Utilizes the `@Environment` property to handle the view's presentation state.
///
/// The body constructs a form within a `NavigationStack`, including date pickers for start and end dates, a picker for the workout limit, and a submit button.
/// Upon submission, the view triggers `onSubmit`, toggles `isLoading` to true, and dismisses itself.
struct DatePickerView: View {
	@Binding var startDate: Date
	@Binding var endDate: Date
	@Binding var workoutLimit: Int
	@Binding var isLoading: Bool
	let onSubmit: () -> Void
	@Environment(\.presentationMode) var presentationMode

	var body: some View {
		NavigationStack {
			Form {
				DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
				DatePicker("End Date", selection: $endDate, displayedComponents: .date)
				Picker("Workouts", selection: $workoutLimit) {
					ForEach(Array(stride(from: 10, through: 500, by: 50)), id: \.self) {
						Text("\($0) Workouts").tag($0)
					}
				}
				Button("Submit") {
					onSubmit()
					// Re-activate loading screen
					isLoading = true
					presentationMode.wrappedValue.dismiss() // Dismiss the view
				}
				.padding()
				.background(.yellow.gradient)
				.foregroundColor(Color.white)
				.cornerRadius(10)
				.padding(.top, 10)
				// Extensions for visual adjustments
			}
			.background(.blue.gradient)
			.cornerRadius(10)
			.navigationTitle("Modify Date")
			// Optional dark mode preference
			// .preferredColorScheme(.dark)
		}
	}
}


