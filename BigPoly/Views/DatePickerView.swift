//   DatePickerView.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/20/24 at 2:53 PM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//
// this is the datePicker view called in a .sheet from polyView

import SwiftUI

struct DatePickerView: View {
	@Binding var startDate: Date
	@Binding var endDate: Date
	@Binding var workoutLimit: Int
	@Binding var isLoading: Bool
	let onSubmit: () -> Void
	@Environment(\.presentationMode) var presentationMode

	var body: some View {
		NavigationView {
			Form {
				DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
				DatePicker("End Date", selection: $endDate, displayedComponents: .date)
				Picker("Workout Limit", selection: $workoutLimit) {
					ForEach(Array(stride(from: 50, through: 500, by: 50)), id: \.self) {
						Text("\($0) Workouts").tag($0)
					}
				}
				Button("Done") {
					onSubmit()
					// turn the isLoading screen back on
					isLoading = true
					presentationMode.wrappedValue.dismiss() // Dismiss the sheet
				}
				.padding()
				.background(.yellow.gradient)
				.foregroundColor(Color.white)
				.cornerRadius(10)
				.padding(.top, 10)
				rightJustify()
			}
			}
			.navigationTitle("Modify Date")
		}
	}

