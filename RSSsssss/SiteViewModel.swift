//
//  SiteViewModel.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import Foundation
import Combine
import SwiftSoup

class SiteViewModel: ObservableObject {
	@Published var document: Document?

	@Published var state: State = .idle

	let site: URL

	var rssLinks: [URL] { getRSSLinks() }

	private var bag: Set<AnyCancellable> = []

	init(site: URL) {
		self.site = site

		FeedGrabber.getSite(site)
			.receive(on: RunLoop.main)
			.sink(
				receiveCompletion: { completion in
					if case .failure(let error) = completion {
						self.state = .error(error)
					}
				},
				receiveValue: { document in
					self.state = .loaded(document)
				})
			.store(in: &bag)

		state = .loading
	}

	private func getRSSLinks() -> [URL] {
		guard case .loaded(let document) = state else { return [] }
		let linkElements = try? document.getElementsByTag("link")
		let rssLinkElements = linkElements?.filter { (try? $0.attr("type").contains("rss")) == true }
		let linkStrings = rssLinkElements?.compactMap { try? $0.attr("href") }
		return linkStrings?.compactMap { URL(string: $0) } ?? []
	}

	enum State {
		case idle
		case loading
		case loaded(Document)
		case error(Error)
	}
}
