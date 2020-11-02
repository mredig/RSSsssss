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
					self?.addPosts(from: itemNodes, sourceFeed: feedURL, save: true)
				}
				.store(in: &bag)
		}
	}

	// MARK: - CRUD
	// MARK: C
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

		save(context: context, errorMessage: "Error saving feed")
		return feed
	}

	func addPosts(from parsedXMLItems: [ParsedNode], sourceFeed: URL, save shouldSave: Bool = false) {
		let context = stack.container.newBackgroundContext()

		guard let feed = fetchFeed(with: sourceFeed, on: context) else { return }

		context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
		context.performAndWait {
			parsedXMLItems.forEach {
				_ = RSSPost(context: context, parsedItemNode: $0, parent: feed)
			}
		}

		guard shouldSave else { return }
		save(context: context, errorMessage: "Error saving posts")
	}

	// MARK: U
	func markPostAsRead(_ post: RSSPost) {
		guard
			let context = post.managedObjectContext,
			!post.isRead
		else { return }

		context.performAndWait {
			post.isRead = true
		}

		save(context: context, errorMessage: "Error marking post as read")
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

	func observableRSSPostFRC(for feed: RSSFeed) -> ObservedFetchedResultsController<RSSPost> {
		guard let feedURL = feed.feedURL else { fatalError("Somehow a feed was created without a url! \(feed)") }
		if let ofrc = postsObservedResultsControllers[feedURL] {
			return ofrc
		}

		let fetchRequest: NSFetchRequest<RSSPost> = RSSPost.fetchRequest()

		fetchRequest.predicate = NSPredicate(format: "sourceFeed == %@", feed)

		fetchRequest.sortDescriptors = [
			.init(keyPath: \RSSPost.date, ascending: false)
		]

		let ofrc = ObservedFetchedResultsController(context: stack.mainContext, fetchRequest: fetchRequest)
		postsObservedResultsControllers[feedURL] = ofrc
		return ofrc
	}

	// MARK: D
	func delete(feed: RSSFeed) {
		guard let context = feed.managedObjectContext else { return }
		context.performAndWait {
			context.delete(feed)
		}

		save(context: context, errorMessage: "Error deleting feed")
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
					throw SimpleError(message: "Unspecified error while parsing")
				}
			}
			.replaceNil(with: ParsedNode(elementName: "empty"))
			.replaceError(with: ParsedNode(elementName: "empty"))
			.eraseToAnyPublisher()
	}

	private func save(context: NSManagedObjectContext, errorMessage: String? = nil) {
		do {
			try stack.save(context: context)
		} catch {
			NSLog("\(errorMessage ?? "Error saving context"): \(error)")
		}
	}
}
