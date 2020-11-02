//
//  PostDetailView.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/31/20.
//

import SwiftUI

struct PostDetailScreen: View {

	@ObservedObject var post: RSSPost

	@State private var textViewHeight: CGFloat = 300

	var body: some View {
		ScrollView {
			VStack {
				Text(post.title ?? "Post")
					.font(.title)
					.debugBorder(.yellow)

				WebView(htmlString: post.content ?? "") { height in
					textViewHeight = height
				}
				.frame(height: textViewHeight)
				.debugBorder(.red)
			}
		}
	}
}
