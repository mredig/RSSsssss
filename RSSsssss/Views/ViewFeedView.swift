//
//  ViewFeedView.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import SwiftUI

struct ViewFeedView: View {

	@StateObject var feedVM: FeedViewModel
	@StateObject var postsController: ObservedRSSPostsController

//	@FetchRequest(
//		entity: RSSPost.entity(),
//		sortDescriptors: [.init(key: "date", ascending: true)]
//	) var items: FetchedResults<RSSPost>

	var body: some View {
		List {
			ForEach(postsController.items) { item in
				NavigationLink(
					destination: PostDetailView(post: item),
					label: {
						Text(item.title ?? "Untitled")
					})
			}
		}

	}
}
