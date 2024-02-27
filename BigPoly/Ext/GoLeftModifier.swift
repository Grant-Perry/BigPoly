//   GoLeftModifier.swift
//   BigPoly
//
//   Created by: Grant Perry on 2/25/24 at 1:42 PM
//     Modified: 
//
//  Copyright © 2024 Delicious Studios, LLC. - Grant Perry
//

import SwiftUI

// Top justification
struct GoTopModifier: ViewModifier {
	func body(content: Content) -> some View {
		VStack {
			content
			Spacer()
		}
	}
}

// Bottom justification
struct GoBottomModifier: ViewModifier {
	func body(content: Content) -> some View {
		VStack {
			Spacer()
			content
		}
	}
}

// left justification
struct GoLeftModifier: ViewModifier {
	func body(content: Content) -> some View {
		HStack {
			content
			Spacer()
		}
	}
}

struct GoRightModifier: ViewModifier {
	func body(content: Content) -> some View {
		HStack {
			Spacer()
			content
		}
	}
}

// Extension to apply the .goLeft modifier
extension View {
	func goLeft() -> some View {
		self.modifier(GoLeftModifier())
	}
}

// Extension to apply the .goRight modifier
extension View {
	func goRight() -> some View {
		self.modifier(GoRightModifier())
	}
}

// Extension to apply the .goTop modifier
extension View {
	func goTop() -> some View {
		self.modifier(GoTopModifier())
	}
}

// Extension to apply the .goBottom modifier
extension View {
	func goBottom() -> some View {
		self.modifier(GoBottomModifier())
	}
}



