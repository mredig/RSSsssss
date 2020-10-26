//
//  Networking.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import Foundation
import Combine
import SwiftSoup

enum FeedGrabber {

	static func getSite(_ url: URL) -> AnyPublisher<Document, Error> {
		URLSession.shared.dataTaskPublisher(for: url)
			.map { $0.data }
			.map { String(data: $0, encoding: .utf8) ?? "" }
			.tryMap { try SwiftSoup.parse($0) }
			.eraseToAnyPublisher()
	}

	static func getFeed(_ url: URL) -> AnyPublisher<Data, Error> {
		URLSession.shared.dataTaskPublisher(for: url)
			.map(\.data)
			.mapError { $0 }
			.eraseToAnyPublisher()
	}
}
