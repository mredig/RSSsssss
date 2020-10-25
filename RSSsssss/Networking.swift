//
//  Networking.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import Foundation
import Combine
import SwiftSoup

class FeedGrabber: ObservableObject {

	@Published var data = ""
	@Published var document: Document?

	var bag: Set<AnyCancellable> = []

	func getSite() {
		let temp = URL(string: "https://mikespsyche.com")!
		URLSession.shared.dataTaskPublisher(for: temp)
			.map { $0.data }
			.map { String(data: $0, encoding: .utf8) ?? "" }
			.tryMap { try SwiftSoup.parse($0) }
			.tryMap {
				let elements = try $0.getElementsByTag("link")
//				let types = elements.filter { $0.hasAttr("type") }
//				types.forEach { print($0) }
				let rsses = elements.filter { (try? $0.attr("type").contains("rss")) == true }
				rsses.forEach { print($0) }
				return $0
			}
			.mapError { error -> Error in
				print("Error parsing html: \(error)")
				return error
			}
			.receive(on: RunLoop.main)
			.replaceError(with: nil)
			.assign(to: \.document, on: self)
			.store(in: &bag)
	}
}
