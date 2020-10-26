//
//  ViewFeedView.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import SwiftUI

struct ViewFeedView: View {

	@StateObject var feedVM: FeedViewModel

	@FetchRequest(
		entity: RSSPost.entity(),
		sortDescriptors: [.init(key: "date", ascending: true)]
	) var items: FetchedResults<RSSPost>

	var body: some View {
		switch feedVM.state {
		case .idle, .loading:
			Text("Loading \(feedVM.feedURL)")
		case .loaded(let string):
//			ScrollView {
//				Text(string)
//			}
			List {
				ForEach(items) { item in
					Text(item.title ?? "who knows")
				}
			}
		case .error(let error):
			Text("\(error as NSError)")
		}
	}
}
