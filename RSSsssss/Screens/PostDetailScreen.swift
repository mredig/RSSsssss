//
//  PostDetailView.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/31/20.
//

import SwiftUI

struct PostDetailScreen: View {

	@ObservedObject var post: RSSPost
	@EnvironmentObject var rssController: RSSController

	var body: some View {
		GeometryReader { geo in
			WebView(htmlString: post.content ?? "")
				.frame(geo.size)
		}
		.ignoresSafeArea(.container, edges: .bottom)
		.navigationTitle(post.title ?? "Unknown Post Title")
		.navigationBarItems(trailing: linkButton())
		.onAppear {
			rssController.markPostAsRead(post)
		}
	}

	@ViewBuilder private func linkButton() -> some View {
		if let link = post.link {
			Link(
				destination: link,
				label: {
					Image(systemName: "safari")
				})
		}
	}
}
