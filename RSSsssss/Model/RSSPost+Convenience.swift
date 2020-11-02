//
//  RSSPost+Convenience.swift
//  RSSsssss
//
//  Created by Michael Redig on 11/1/20.
//

import Foundation
import CoreData

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
		self.guid = Self.guidFixer(guid: guid, link: link, title: title, description: itemDescription, content: content, feed: sourceFeed)
		self.link = link
		self.source = source
		self.sourceFeed = sourceFeed
	}

	private static func guidFixer(guid: String?, link: URL?, title: String?, description: String?, content: String?, feed: RSSFeed) -> String {
		guard let feedURL = feed.feedURL else { fatalError("Feed without a feedURL! \(feed)") }
		if let guid = guid {
			return "\(feedURL.absoluteString)-\(guid)"
		}
		let guid = link?.absoluteString ?? title ?? description ?? content ?? "lastResort"
		return "\(feedURL.absoluteString)-\(guid)"
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

// MARK: - ViewModel like stuff
extension RSSPost {
	static let relativeDateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.doesRelativeDateFormatting = true
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		return formatter
	}()

	var prettyDate: String {
		guard let date = date else { return "??" }
		return Self.relativeDateFormatter.string(from: date)
	}
}
