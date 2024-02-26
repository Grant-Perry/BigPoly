//   CustomMapView.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/10/24 at 10:09 AM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI
import MapKit

struct CustomMapView: UIViewRepresentable {
	var coordinates: [CLLocationCoordinate2D]

	func makeUIView(context: Context) -> MKMapView {
		let mapView = MKMapView()
		mapView.isZoomEnabled = true
		mapView.isScrollEnabled = true
		mapView.isRotateEnabled = true
		return mapView
	}

	func updateUIView(_ mapView: MKMapView, context: Context) {
		updateAnnotations(for: mapView)
	}

	private func updateAnnotations(for mapView: MKMapView) {
		mapView.removeAnnotations(mapView.annotations) // Remove existing annotations

		let annotations = coordinates.map { location -> MKPointAnnotation in
			let annotation = MKPointAnnotation()
			annotation.coordinate = location
			return annotation
		}

		mapView.showAnnotations(annotations, animated: true)

		if annotations.count > 1 {
			let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
			mapView.addOverlay(polyline)
			mapView.setVisibleMapRect(polyline.boundingMapRect, animated: true)
		}
	}

	// Delegate for rendering overlays
	class Coordinator: NSObject, MKMapViewDelegate {
		func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
			if let polyline = overlay as? MKPolyline {
				let renderer = MKPolylineRenderer(polyline: polyline)
				renderer.strokeColor = .blue
				renderer.lineWidth = 3
				return renderer
			}
			return MKOverlayRenderer()
		}
	}

	func makeCoordinator() -> Coordinator {
		Coordinator()
	}
}
