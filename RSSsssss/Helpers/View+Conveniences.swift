//
//  View+Conveniences.swift
//  RSSsssss
//
//  Created by Michael Redig on 11/1/20.
//

import SwiftUI

extension View {
	func frame(_ size: CGSize, alignment: Alignment = .center) -> some View {
		frame(width: size.width, height: size.height, alignment: alignment)
	}

	func cornerRadius(_ radius: CGFloat, style: RoundedCornerStyle) -> some View {
		clipShape(RoundedRectangle(cornerRadius: radius, style: style))
	}
}
