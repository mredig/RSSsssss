//
//  RSSController.swift
//  RSSsssss
//
//  Created by Michael Redig on 11/1/20.
//

import Foundation
import CoreData

class RSSController: ObservableObject {

	private(set) var feedFetchedResultsController: ObservedFetchedResultsController<RSSFeed>
	private(set) var postsFetchedResultsControllers: [URL: ObservedFetchedResultsController<RSSPost>] = [:]

	let stack: CoreDataStack

	init(coreDataStack: CoreDataStack) {
		self.stack = coreDataStack

		let fetchRequest: NSFetchRequest<RSSFeed> = RSSFeed.fetchRequest()
		fetchRequest.sortDescriptors = [
			.init(keyPath: \RSSFeed.title, ascending: true)
		]
//		self.feedFetchedResultsController = NSFetchedResultsController<RSSFeed>(
//			fetchRequest: fetchRequest,
//			managedObjectContext: stack.mainContext,
//			sectionNameKeyPath: nil,
//			cacheName: nil)
		self.feedFetchedResultsController = .init(context: coreDataStack.mainContext, fetchRequest: fetchRequest)


	}

	// MARK: - CRUD
	// MARK: CU
	func addFeed(from parsedXMLDocumentNode: ParsedNode, sourceFeed: URL, site: URL) {
		let context = stack.container.newBackgroundContext()

		context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		context.performAndWait {
			_ = RSSFeed(context: context, parsedXMLDocumentNode: parsedXMLDocumentNode, sourceFeed: sourceFeed, site: site)
		}

		do {
			try stack.save(context: context)
		} catch {
			NSLog("Error saving context: \(error)")
		}
	}

//	func addPosts(from parsedXMLItems: [ParsedNode], sourceFeed: RSSFeed, save: Bool = false) {
//		let context = stack.container.newBackgroundContext()
//
//		context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//		context.performAndWait {
//			parsedXMLItems.forEach {
//				_ = RSSPost(context: context, parsedItemNode: $0, parent: sourceFeed)
//			}
//		}
//
//		guard save else { return }
//		do {
//			try stack.save(context: context)
//		} catch {
//			NSLog("Error saving context: \(error)")
//		}
//	}

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

	func observableRSSFeedFRC() -> ObservedFetchedResultsController<RSSFeed> {
		let fetchReqeust: NSFetchRequest<RSSFeed> = RSSFeed.fetchRequest()

		fetchReqeust.sortDescriptors = [
			.init(keyPath: \RSSFeed.title, ascending: true)
		]

		return .init(context: stack.mainContext, fetchRequest: fetchReqeust)
	}

//	func fetchPost(with guid: String, on context: NSManagedObjectContext? = nil) -> RSSPost? {
//		let context = context ?? stack.mainContext
//	}
}
