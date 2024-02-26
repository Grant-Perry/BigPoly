//   DELETETHIS.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/12/24 at 12:31 PM
//     Modified:
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import MapKit

struct DeleteThis: View {
	@State var home = CLLocationCoordinate2D(latitude: 37.000914, longitude: -76.442160)
	@State private var position: MapCameraPosition = .automatic
	@State var isLoading = false
	var heights = 125.0

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {

			if isLoading {
				ProgressView()
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.background(Color.blue.gradient)
					.cornerRadius(10)
			} else {
				HStack(spacing: 0) {
					HStack {
						// MARK: - Address Container
						HStack {
							VStack {
								Text(Date().formatted(as: "MMM d, yy"))
									.font(.system(size: 15))
									.foregroundColor(.white)
									.rightJustify()
									.padding(EdgeInsets(top: 3, leading: 0, bottom: 0, trailing: 26))
								Text("Newport News")
									.font(.system(size: 22)).bold()
									.foregroundColor(.white)
									.padding(.leading)
									.leftJustify()

								VStack(alignment: .leading, spacing: 1) {
									Text("5912 Huntington Ave")
										.font(.system(size: 17))
										.frame(width: 120, height: 16)
									Spacer()
									Text("Distance: \(String(format: "%.2f", 2.34))")
										.rightJustify()
										.padding(.trailing, 30)
										.font(.system(size: 18).bold())


									// the date was here
								}

								HStack {
									Text("miles")
										.rightJustify()
										.padding(.trailing, 30)
										.font(.system(size: 8))
								}
								.foregroundColor(.white)
								.padding(.leading, 20) // indent the text
								.leftJustify()
							}
						}

						Spacer()
							.frame(width: UIScreen.main.bounds.width * 0.5, height: heights)
							.background(.blue.gradient)
							.cornerRadius(10, corners: [.topLeft, .bottomLeft])
							.leftJustify()


						// MARK: -> Map View
						HStack {
							if  !isLoading {
								Map(position: $position) {
									Annotation(
										"❤️",
										coordinate: home,
										anchor: .bottom
									) {
										//								Image(systemName: "")
										//									.imageScale(.medium)
									}
									//							Marker("Start", systemImage: "figure-wave", coordinate: coordinate)
								}
								.mapControlVisibility(.hidden)
								.mapStyle(.hybrid(elevation: .realistic ))
								.disabled(true)
								.frame(width: UIScreen.main.bounds.width * 0.35, height: heights)
								.cornerRadius(10, corners: [.topRight, .bottomRight])

								.padding(.leading, -20)
							}
							else {
								Text("No Map Data")
									.frame(width: UIScreen.main.bounds.width * 0.5, height: heights)
									.background(Color.gray)
									.cornerRadius(10)
							}
						}


					}
				}
			}
		}
	}
}

#Preview {
	DeleteThis()
}
