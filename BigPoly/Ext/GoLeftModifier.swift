//   GoLeftModifier.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/25/24 at 1:42 PM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI

/// ``GoTopModifier``
/// A view modifier to align content at the top of a container.
/// This modifier wraps the content within a `VStack` and pushes it to the top, leaving flexible space below.
struct GoTopModifier: ViewModifier {
	func body(content: Content) -> some View {
		VStack {
			content
			Spacer()
		}
	}
}

/// ``GoBottomModifier``
/// A view modifier for aligning content at the bottom of a container.
/// This wraps the content within a `VStack`, positioning it at the bottom with flexible space above.
struct GoBottomModifier: ViewModifier {
	func body(content: Content) -> some View {
		VStack {
			Spacer()
			content
		}
	}
}

/// ``GoLeftModifier``
/// A view modifier to align content to the left side of a container.
/// It employs an `HStack` to position the content on the left, with a `Spacer` pushing it against the container's edge.
struct GoLeftModifier: ViewModifier {
	func body(content: Content) -> some View {
		HStack {
			content
			Spacer()
		}
	}
}

/// ``GoRightModifier``
/// A modifier for positioning content to the right within a container.
/// This utilizes an `HStack` with a `Spacer` on the left, moving the content to the right edge.
struct GoRightModifier: ViewModifier {
	func body(content: Content) -> some View {
		HStack {
			Spacer()
			content
		}
	}
}

/// Extension for `View` to apply ``goLeft`` modifier.
/// Enables left alignment of content within a view by applying `GoLeftModifier`.
extension View {
	func goLeft() -> some View {
		self.modifier(GoLeftModifier())
	}
}

/// Extension for `View` to use ``goRight`` modifier.
/// Allows for right-justifying content within a view through `GoRightModifier`.
extension View {
	func goRight() -> some View {
		self.modifier(GoRightModifier())
	}
}

/// Extension to apply ``goTop`` modifier on a view.
/// This facilitates top alignment of content by leveraging `GoTopModifier`.
extension View {
	func goTop() -> some View {
		self.modifier(GoTopModifier())
	}
}

/// Extension for applying ``goBottom`` modifier to a view.
/// It aids in bottom-aligning content by utilizing `GoBottomModifier`.
extension View {
	func goBottom() -> some View {
		self.modifier(GoBottomModifier())
	}
}




