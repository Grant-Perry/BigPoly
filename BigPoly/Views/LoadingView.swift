//   LoadingView.swift
//   BigMetric
//
//   Created by: Grant Perry on 2/7/24 at 10:39 AM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI

struct LoadingView: View {
	var progress = Color(#colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1))
	var bg = Color(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
	var bgTop = Color(#colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1))

	var body: some View {
		VStack {
			ZStack {
				VStack {
					Rectangle()
						.fill(.blue.gradient)
						.frame(height: 45)
					Spacer()
				}
				VStack {
					HStack {
						Text("PolyView")
							.foregroundStyle(.white)
							.font(.system(size: 22))
							.padding(EdgeInsets(top: 5, leading: 16, bottom: 16, trailing: 16))
						Spacer()
						Image(systemName: "map.circle")
							.resizable()
							.frame(width: 36, height: 36)
							.foregroundColor(.white)
							.padding(EdgeInsets(top: 3, leading: 16, bottom: 16, trailing: 16))
					}
					Spacer()
				}
				VStack {
					Spacer(minLength: 75)
					VStack {
						Text("Loading Workouts...")
							.foregroundColor(.white)
							.font(.title2)
							.padding(.bottom, 15)
						ProgressView()
							.scaleEffect(2, anchor: .center)
							.progressViewStyle(CircularProgressViewStyle(tint: Color.white))
					}
					Spacer()

				}
			}
			.frame(width: 300, height: 300)
			.background(.blue.gradient.opacity(0.8))
			.cornerRadius(20)
			.horizontallyCentered()

		}
		.preferredColorScheme(.dark)
		.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
//		.background(.black)
//		.background(.blue.gradient)
	}
}

#Preview {
    LoadingView()
}
