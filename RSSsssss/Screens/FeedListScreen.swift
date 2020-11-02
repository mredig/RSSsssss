//
//  FeedListScreen.swift
//  RSSsssss
//
//  Created by Michael Redig on 11/1/20.
//

import SwiftUI

struct FeedListScreen: View {

	@EnvironmentObject var rssController: RSSController

    var body: some View {
		ObserveView(obj: rssController.feedFetchedResultsController) { feedFRC in
			List {
				ForEach(feedFRC.items) { item in
					Text(item.title ?? "No title")
				}
			}
			.listStyle(GroupedListStyle())
		}
		.navigationTitle("Your Feeds")
		.navigationBarItems(
			leading:
				Button(
					action: {
						rssController.refreshAllFeeds()
					},
					label: {
						Image(systemName: "arrow.clockwise.circle")
					}),
			trailing:
				NavigationLink(
					destination: AddFeedScreen(),
					label: {
						Image(systemName: "plus")
					})
		)
    }
}

struct FeedListView_Previews: PreviewProvider {
    static var previews: some View {
        FeedListScreen()
    }
}
