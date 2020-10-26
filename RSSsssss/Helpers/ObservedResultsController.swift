//
//  ObservedResultsController.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/26/20.
//

import Foundation
import CoreData

class ObservedRSSPostsController: NSObject, ObservableObject {
	@Published private(set) var items: [RSSPost] = []
	private let fetchedResultsController: NSFetchedResultsController<RSSPost>

//	convenience init?(context: NSManagedObjectContext, feed: URL) {
//		let fetReq: NSFetchRequest<RSSFeed> = RSSFeed.fetchRequest()
//		fetReq.predicate = NSPredicate(format: "feedURL == %@", feed as NSURL)
//
//		var rssFeed: RSSFeed?
//		context.performAndWait {
//			let result = try? context.fetch(fetReq)
//			rssFeed = result?.first
//		}
//		guard let unwrapped = rssFeed else { return nil }
//		self.init(context: context, feed: unwrapped)
//	}

	init(context: NSManagedObjectContext, feed: URL) {

		let fetchRequest: NSFetchRequest<RSSPost> = RSSPost.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "sourceFeed.feedURL == %@", feed as NSURL)

		fetchRequest.sortDescriptors = [
			.init(keyPath: \RSSPost.date, ascending: false)
		]

		fetchedResultsController = NSFetchedResultsController(
			fetchRequest: fetchRequest,
			managedObjectContext: context,
			sectionNameKeyPath: nil,
			cacheName: nil)

		super.init()

		fetchedResultsController.delegate = self

		do {
			try fetchedResultsController.performFetch()
			items = fetchedResultsController.fetchedObjects ?? []
		} catch {
			NSLog("FRC Fetch failed: \(error)")
		}
	}
}

extension ObservedRSSPostsController: NSFetchedResultsControllerDelegate {
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		guard let items = controller.fetchedObjects as? [RSSPost] else { return }
		self.items = items
	}
}
