	//   LoadingView.swift
	//   BigMetric
	//
	//   Created by: Grant Perry on 2/7/24 at 10:39 AM
	//     Modified:
	//
	//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
	//

import SwiftUI

/// ``LoadingView``
/// Designed to display a loading indicator with customizable parameters.
/// This view combines a textual description of the current loading operation, an icon representation, and a circular progress indicator.
/// - Parameters:
///     - `calledFrom`: The name of the view or process from which the LoadingView was called, to provide context to the user.
///     - `workType`: A descriptive string of the work being performed, e.g., "Data", "Images", to inform the user about the type of loading occurring.
///     - `icon`: A string representing the SF Symbol name used as an icon next to the `calledFrom` text.
/// - Modifiers:
///     - `progress`, `bg`, `bgTop`: Color variables to customize the appearance of the loading view, including the progress indicator and background gradients.
/// - The body constructs a `VStack` containing a `ZStack` for layering the background, icon, text, and progress indicator components.
struct LoadingView: View {
	var calledFrom: String
	var workType: String
	var icon: String

	var progress = Color(#colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1))
	var bg = Color(#colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1))
	var bgTop = Color(#colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1))

	var body: some View {
		VStack {
			ZStack {
				VStack {
					Rectangle()
						.fill(LinearGradient(gradient: Gradient(colors: [bgTop, bgTop]), startPoint: .top, endPoint: .bottom))
						.frame(height: 45)
					Spacer()
				}
				VStack {
					HStack {
						Text(calledFrom)
							.foregroundStyle(.white)
							.font(.system(size: 22))
							.padding(EdgeInsets(top: 0, leading: 16, bottom: 35, trailing: 16))
						Spacer()
						Image(systemName: icon)
							.resizable()
							.frame(width: 36, height: 36)
							.foregroundColor(.white)
							.padding(EdgeInsets(top: 5, leading: 0, bottom: 40, trailing: 10))
					}
					Spacer()
				}
				VStack {
					Spacer() // Push everything down
					Text("Loading \(workType)...")
						.foregroundColor(.white)
						.font(.title3)
						.padding()
						.multilineTextAlignment(.center)
						.lineLimit(2)
						.minimumScaleFactor(0.5)
						.scaledToFit()

					ProgressView()
						.scaleEffect(2, anchor: .center)
						.progressViewStyle(CircularProgressViewStyle(tint: Color.white))
						.padding(.top, 10)
					Spacer() // Push everything up
				}
			}
		}
		.frame(width: 275, height: 275)
		.background(LinearGradient(gradient: Gradient(colors: [bgTop, bg]), startPoint: .top, endPoint: .bottom).opacity(0.8))
		.cornerRadius(20)
		.preferredColorScheme(.dark)
	}
}



#Preview {
	LoadingView(calledFrom: "Preview", workType: "\nAdditional Workouts", icon: "map.circle")
}

