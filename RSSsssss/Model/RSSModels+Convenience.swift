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

		let itemNodes = parsedChannelNode.childrenNamed("item")
		addPosts(from: itemNodes, on: context)
	}

	func addPosts(from itemNodes: [ParsedNode], on context: NSManagedObjectContext) {
		context.performAndWait {
			for itemNode in itemNodes {
				guard itemNode.elementName == "item" else { continue }

				_ = RSSPost(context: context, parsedItemNode: itemNode, parent: self)
			}
		}
	}
}

extension RSSPost {
	static let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
		return formatter
	}()

	convenience init(
		context: NSManagedObjectContext,
		title: String?,
		author: String?,
		itemDescription: String?,
		content: String?,
		category: String?,
		date: Date?,
		guid: String?,
		link: URL?,
		source: URL?,
		sourceFeed: RSSFeed) {
		self.init(context: context)
		self.title = title
		self.author = author
		self.itemDescription = itemDescription
		self.content = content
		self.category = category
		self.date = date
		self.guid = guid
		self.link = link
		self.source = source
		self.sourceFeed = sourceFeed
	}

	convenience init?(
		context: NSManagedObjectContext,
		parsedItemNode: ParsedNode,
		parent: RSSFeed) {

		guard parsedItemNode.elementName == "item" else { return nil }

		let titleNode = parsedItemNode.firstChild(named: "title")
		let authorNode = parsedItemNode.firstChild(namedInPriority: ["author", "dc:creator"])
		let descriptionNode = parsedItemNode.firstChild(namedInPriority: ["description", "content:encoded"])
		let contentNode = parsedItemNode.firstChild(namedInPriority: ["content:encoded", "description"])
		let categoryNode = parsedItemNode.firstChild(named: "category")
		let dateNode = parsedItemNode.firstChild(named: "pubDate")
		let guidNode = parsedItemNode.firstChild(named: "guid")
		let linkNode = parsedItemNode.firstChild(named: "link")
		let sourceNode = parsedItemNode.firstChild(named: "source")

		// confirm at LEAST one of these fields is populated
		guard ![titleNode, descriptionNode, contentNode].compactMap({ $0 }).isEmpty else { return nil }

		var date: Date?
		if let dateStr = dateNode?.stringContent {
			date = Self.dateFormatter.date(from: dateStr)
		}

		self.init(
			context: context,
			title: titleNode?.stringContent,
			author: authorNode?.stringContent,
			itemDescription: descriptionNode?.stringContent,
			content: contentNode?.stringContent,
			category: categoryNode?.stringContent,
			date: date,
			guid: guidNode?.stringContent,
			link: linkNode?.urlContent,
			source: sourceNode?.urlContent,
			sourceFeed: parent)
	}
}
