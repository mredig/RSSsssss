//
//  ScrollView.swift
//  RSSsssss
//
//  Created by Michael Redig on 11/1/20.
//

import SwiftUI

struct ScrollView<Content: View>: View {
	let axes: Axis.Set
	let showsIndicators: Bool
	let offsetChanged: (CGPoint) -> Void
	let content: Content

	let coordSpaceName: String

	init(
		_ axes: Axis.Set = .vertical,
		showsIndicators: Bool = true,
		coordSpaceName: String = "scrollView",
		offsetChanged: @escaping (CGPoint) -> Void = { _ in },
		@ViewBuilder content: () -> Content) {

		self.axes = axes
		self.showsIndicators = showsIndicators
		self.offsetChanged = offsetChanged
		self.coordSpaceName = coordSpaceName
		self.content = content()
	}

	var body: some View {
		SwiftUI.ScrollView(axes, showsIndicators: showsIndicators) {
			VStack(spacing: 0) {
				GeometryReader { geo in
					Color.clear.preference(
						key: ScrollOffsetPreferenceKey.self,
						value: geo.frame(in: .named(coordSpaceName)).origin)
				}
				.frame(width: 0, height: 0)
				.onPreferenceChange(ScrollOffsetPreferenceKey.self, perform: offsetChanged)

				content
			}
		}
		.coordinateSpace(name: coordSpaceName)
	}
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
	static var defaultValue: CGPoint = .zero

	static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
		value = nextValue()
	}
}
