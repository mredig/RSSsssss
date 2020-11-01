//
//  RSSModels+Convenience.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import Foundation
import CoreData

extension RSSFeed {
	convenience init(
		context: NSManagedObjectContext,
		title: String,
		feedDescription: String,
		feedURL: URL,
		site: URL,
		image: URL?) {
		self.init(context: context)
		self.title = title
		self.feedDescription = feedDescription
		self.feedURL = feedURL
		self.site = site
		self.image = image
		self.id = UUID()
	}

	convenience init?(
		context: NSManagedObjectContext,
		parsedXMLDocumentNode: ParsedNode,
		sourceFeed: URL,
		site: URL) {

		guard let channelNode = parsedXMLDocumentNode.firstChild(named: "rss") else { return nil }
		self.init(context: context, parsedRSSNode: channelNode, sourceFeed: sourceFeed, site: site)
	}

	convenience init?(
		context: NSManagedObjectContext,
		parsedRSSNode: ParsedNode,
		sourceFeed: URL,
		site: URL) {

		guard let channelNode = parsedRSSNode.firstChild(named: "channel") else { return nil }
		self.init(context: context, parsedChannelNode: channelNode, sourceFeed: sourceFeed, site: site)
	}

	convenience init?(
		context: NSManagedObjectContext,
		parsedChannelNode: ParsedNode,
		sourceFeed: URL,
		site: URL) {

		guard parsedChannelNode.elementName == "channel" else { return nil }

		guard
			let titleNode = parsedChannelNode.firstChild(named: "title"),
			let title = titleNode.stringContent,
			let descriptionNode = parsedChannelNode.firstChild(named: "description"),
			let description = descriptionNode.stringContent
//			let feedURLNode = parsedChannelNode.firstChild(named: "link"),
//			let feedURL = feedURLNode.urlContent
		else { return nil }

		let imageNode = parsedChannelNode.firstChild(named: "image")?.firstChild(named: "url")

		self.init(
			context: context,
			title: title,
			feedDescription: description,
			feedURL: sourceFeed,
			site: site,
			image: imageNode?.urlContent)
	}
}
