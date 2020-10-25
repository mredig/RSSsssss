//
//  RSSPostDTO.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import Foundation

// spec: https://validator.w3.org/feed/docs/rss2.html

// everything is optional, but it DOES require EITHER a title or description.
struct RSSPostDTO {
	let guid: String?
	let title: String?
	let description: String?
	let author: String?
	let category: String?
	let date: Date?
	let link: URL?
	let source: URL?
}


// some of these MIGHT need to be optional
struct RSSFeedDTO {
	let title: String
	let site: URL
	let description: String
	let id: UUID
	let feedURL: URL
	let image: URL?
}
