//
//  ViewFeedView.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import SwiftUI

struct ViewFeedView: View {

	@StateObject var feedVM: FeedViewModel

	var body: some View {
		switch feedVM.state {
		case .idle, .loading:
			Text("Loading \(feedVM.feedURL)")
		case .loaded(let string):
			ScrollView {
				Text(string)
			}
		case .error(let error):
			Text("\(error as NSError)")
		}
	}
}
