//
//  PostDetailView.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/31/20.
//

import SwiftUI

struct PostDetailView: View {

	@ObservedObject var post: RSSPost

	var body: some View {
		ScrollView {
			VStack {
				Text(post.title ?? "Post")
					.font(.title)

				Text(post.content ?? "Content")
			}
		}
	}
}
