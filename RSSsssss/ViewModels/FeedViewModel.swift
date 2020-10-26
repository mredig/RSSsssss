//
//  FeedViewModel.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import Foundation
import Combine

class FeedViewModel: NSObject, ObservableObject {
	let feedURL: URL

	@Published var state: State = .idle

	private var bag: Set<AnyCancellable> = []

	let parsingDelegate = ParsingDelegate()

	init(feedURL: URL) {
		self.feedURL = feedURL
		super.init()
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

					let parser = XMLParser(data: data)
					parser.delegate = self.parsingDelegate
					if parser.parse() {
						print("success parsing")
					} else if let error = parser.parserError {
						print("Error parsing: \(error)")
					} else {
						print("Unspecified error while parsing")
					}

					print(self.parsingDelegate.rootNode)

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
