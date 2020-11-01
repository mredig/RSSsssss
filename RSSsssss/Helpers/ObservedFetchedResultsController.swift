//
//  ObservedFetchedResultsController.swift
//  RSSsssss
//
//  Created by Michael Redig on 11/1/20.
//

import Foundation
import CoreData

class ObservedFetchedResultsController<Element: NSManagedObject>: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
	@Published private(set) var items: [Element] = []
	private let fetchedResultsController: NSFetchedResultsController<Element>

	init(context: NSManagedObjectContext, fetchRequest: NSFetchRequest<Element>) {
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

	// MARK: - NSFetchedResultsControllerDelegate
	func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
		guard let items = controller.fetchedObjects as? [Element] else { return }
		self.items = items
	}
}
