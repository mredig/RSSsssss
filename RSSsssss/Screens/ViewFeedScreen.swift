//
//  ViewFeedView.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import SwiftUI

struct ViewFeedScreen: View {

	let title: String
	@StateObject var postsController: ObservedFetchedResultsController<RSSPost>

	@EnvironmentObject var rssController: RSSController

	var body: some View {
		List {
			ForEach(postsController.items) { post in
				NavigationLink(
					destination: PostDetailScreen(post: post),
					label: {
						HStack {
							Image(systemName: "circle.fill")
								.foregroundColor(post.isRead ? .gray : .blue)

							Text(post.title ?? "Untitled")
						}
					})
					.background(GeometryReader { geo -> Color in
						markReadIfOffscreen(post: post, geoProxy: geo)
						return Color.clear
					})
			}
		}
		.navigationTitle(title)

	}

	private func markReadIfOffscreen(post: RSSPost, geoProxy: GeometryProxy) {
		if geoProxy.frame(in: .global).origin.y < 0 {
			rssController.markPostAsRead(post)
		}
	}
}
