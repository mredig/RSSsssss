//
//  Debugging.swift
//  RSSsssss
//
//  Created by Michael Redig on 11/1/20.
//

import SwiftUI

extension View {
	@ViewBuilder func debugBorder(_ color: Color) -> some View {
		#if DEBUG
		self.border(color)
		#else
		self
		#endif
	}

	func debugAction(_ action: () -> Void) -> Self {
		#if DEBUG
		action()
		#endif
		return self
	}

	func debugAction(_ action: (Self) -> Void) -> Self {
		#if DEBUG
		action(self)
		#endif
		return self
	}
}
