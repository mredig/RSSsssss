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
	var title: String = "Untitled"
	var site: URL?
	var description: String = ""
	var feedURL: URL?
	var image: URL?

	internal init(title: String = "Untitled", site: URL? = nil, description: String = "", feedURL: URL? = nil, image: URL? = nil) {
		self.title = title
		self.site = site
		self.description = description
		self.feedURL = feedURL
		self.image = image
	}

	init() {}
}
