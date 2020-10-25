//
//  FeedViewModel.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import Foundation
import Combine

class FeedViewModel: ObservableObject {
	let feedURL: URL

	@Published var state: State = .idle

	private var bag: Set<AnyCancellable> = []


	init(feedURL: URL) {
		self.feedURL = feedURL

		loadFeed()
	}

	private func loadFeed() {
		state = .loading
		FeedGrabber.getFeed(feedURL)
			.receive(on: RunLoop.main)
			.sink(
				receiveCompletion: { _ in },
				receiveValue: { data in
					self.state = .loaded(String(data: data, encoding: .utf8) ?? "")
				})
			.store(in: &bag)
	}

	enum State {
		case idle
		case loading
		case loaded(String)
		case error(Error)
	}
}
