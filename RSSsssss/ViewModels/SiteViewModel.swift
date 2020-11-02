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

	var site: URL? {
		URL(string: siteInput)
	}
	var siteInput: String = "https://" {
		didSet {
			updateSite()
		}
	}
	var siteTitle: String {
		(try? document?.title()) ?? site?.absoluteString ?? ""
	}
	var rssLinks: [(title: String, link: URL)] { getRSSLinks() }

	private var bag: Set<AnyCancellable> = []

	init(siteInput: String? = nil) {
		if let input = siteInput {
			self.siteInput = input
			updateSite()
		}
	}

	private func updateSite() {
		guard let site = site else { return }
		bag.forEach { $0.cancel() }

		URLSession.shared.dataTaskPublisher(for: site)
			.map { $0.data }
			.map { String(data: $0, encoding: .utf8) ?? "" }
			.tryMap { try SwiftSoup.parse($0) }
			.receive(on: RunLoop.main)
			.sink(
				receiveCompletion: { completion in
					if case .failure(let error as NSError) = completion {
						if error.code == -1003 {
							self.state = .error(SimpleError(message: "\(site) is invalid"))
						} else {
							self.state = .error(error)
						}
					}
				},
				receiveValue: { document in
					self.state = .loaded(document)
				})
			.store(in: &bag)

		state = .loading(site)
	}

	private func getRSSLinks() -> [(String, URL)] {
		guard case .loaded(let document) = state else { return [] }
		let linkElements = try? document.getElementsByTag("link")
		let rssLinkElements = linkElements?.filter { (try? $0.attr("type").contains("rss")) == true }
		let linkStrings = rssLinkElements?.compactMap { element -> (String, String)? in
			guard let link = try? element.attr("href") else { return nil }
			let title = try? element.attr("title")
			return (title ?? link, link)
		}
		return (linkStrings ?? []).compactMap {
			guard let url = URL(string: $0.1, relativeTo: site) else { return nil }
			return ($0.0, url)
		}
	}

	enum State {
		case idle
		case loading(URL)
		case loaded(Document)
		case error(Error)
	}
}
