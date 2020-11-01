//
//  ObservedView.swift
//  RSSsssss
//
//  Created by Michael Redig on 11/1/20.
//

import SwiftUI

struct ObserveView<Observable: ObservableObject, Content: View>: View {
	@ObservedObject var obj: Observable
	let content: (Observable) -> Content

	init(obj: Observable, @ViewBuilder content: @escaping (Observable) -> Content) {
		self.obj = obj
		self.content = content
	}

	var body: some View {
		content(obj)
	}
}
