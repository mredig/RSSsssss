//
//  RSSController.swift
//  RSSsssss
//
//  Created by Michael Redig on 11/1/20.
//

import Foundation
import CoreData
import Combine

class RSSController: ObservableObject {
	static private let refreshQueue = DispatchQueue(label: "Feed refresh queue")

	private(set) var feedObservedResultsController: ObservedFetchedResultsController<RSSFeed>
	private(set) var postsObservedResultsControllers: [URL: ObservedFetchedResultsController<RSSPost>] = [:]

	let stack: CoreDataStack

	private var bag: Set<AnyCancellable> = []

	init(coreDataStack: CoreDataStack) {
		self.stack = coreDataStack

		let fetchRequest: NSFetchRequest<RSSFeed> = RSSFeed.fetchRequest()
		fetchRequest.sortDescriptors = [
			.init(keyPath: \RSSFeed.title, ascending: true)
		]

		self.feedObservedResultsController = .init(context: coreDataStack.mainContext, fetchRequest: fetchRequest)
	}

	// MARK: - Collection Controls
	func refreshAllFeeds() {
		let backgroundContext = stack.container.newBackgroundContext()
		let feeds = fetchFeeds(on: backgroundContext)

		feeds.forEach(refresh)
	}

	func refresh(_ feed: RSSFeed) {
		feed.managedObjectContext?.performAndWait {
			guard let feedURL = feed.feedURL else { return }
			remoteLoadXML(from: feedURL)
				.sink { [weak self] rootDocumentNode in
					guard
						let rssNode = rootDocumentNode.firstChild(named: "rss"),
						let channelNode = rssNode.firstChild(named: "channel")
					else { return }

					let itemNodes = channelNode.childrenNamed("item")
					self?.addPosts(from: itemNodes, sourceFeed: feedURL)
				}
				.store(in: &bag)
		}
	}

	// MARK: - CRUD
	// MARK: CU
	func addFeed(from source: URL, site: URL) {
		remoteLoadXML(from: source)
			.sink { [weak self] rootDocNode in
				guard let feed = self?.addFeed(from: rootDocNode, sourceFeed: source, site: site) else { return }
				self?.refresh(feed)
			}
			.store(in: &bag)
	}

	@discardableResult func addFeed(from parsedXMLDocumentNode: ParsedNode, sourceFeed: URL, site: URL) -> RSSFeed? {
		let context = stack.container.newBackgroundContext()

		var feed: RSSFeed?
		context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		context.performAndWait {
			feed = RSSFeed(context: context, parsedXMLDocumentNode: parsedXMLDocumentNode, sourceFeed: sourceFeed, site: site)
		}

		do {
			try stack.save(context: context)
		} catch {
			NSLog("Error saving context: \(error)")
		}
		return feed
	}

	func addPosts(from parsedXMLItems: [ParsedNode], sourceFeed: URL, save: Bool = false) {
		let context = stack.container.newBackgroundContext()

		guard let feed = fetchFeed(with: sourceFeed, on: context) else { return }

		context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		context.performAndWait {
			parsedXMLItems.forEach {
				_ = RSSPost(context: context, parsedItemNode: $0, parent: feed)
			}
		}
	}

	// MARK: R
	/// If context is unspecified, uses main context
	func fetchFeeds(on context: NSManagedObjectContext? = nil) -> [RSSFeed] {
		let context = context ?? stack.mainContext

		let fetchRequest: NSFetchRequest<RSSFeed> = RSSFeed.fetchRequest()

		var feeds: [RSSFeed] = []

		context.performAndWait {
			do {
				feeds = try context.fetch(fetchRequest)
			} catch {
				NSLog("Error fetching feeds: \(error)")
			}
		}
		return feeds
	}

	/// If context is unspecified, uses main context
	func fetchFeed(with sourceURL: URL, on context: NSManagedObjectContext? = nil) -> RSSFeed? {
		let context = context ?? stack.mainContext

		let fetchRequest: NSFetchRequest<RSSFeed> = RSSFeed.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "feedURL == %@", sourceURL as NSURL)

		var feed: RSSFeed?
		context.performAndWait {
			do {
				feed = try context.fetch(fetchRequest).first
			} catch {
				NSLog("Error fetching feed: \(error)")
			}
		}
		return feed
	}


	// MARK: - Utility
	private func remoteLoadXML(from url: URL) -> AnyPublisher<ParsedNode, Never> {
		URLSession.shared.dataTaskPublisher(for: url)
			.receive(on: Self.refreshQueue)
			.map(\.data)
			.tryMap { data -> ParsedNode? in
				let parseDelegate = ParsingDelegate()
				let parser = XMLParser(data: data)
				parser.delegate = parseDelegate

				if parser.parse() {
					return parseDelegate.rootNode
				} else if let error = parser.parserError {
					throw error
				} else {
					throw NSError(domain: "unknown", code: -1, userInfo: ["info": "Unspecified error while parsing"])
				}
			}
			.replaceNil(with: ParsedNode(elementName: "empty"))
			.replaceError(with: ParsedNode(elementName: "empty"))
			.eraseToAnyPublisher()
	}
}
