//
//  CoreDataStack.swift
//  RSSsssss
//
//  Created by Michael Redig on 10/25/20.
//

import Foundation
import CoreData

class CoreDataStack: ObservableObject {
	init() {}

	/// A generic function to save any context we want (main or background)
	func save(context: NSManagedObjectContext) throws {
		//Placeholder in case something doesn't work
		var closureError: Error?

		context.performAndWait {
			do {
				try context.save()
			} catch {
				NSLog("error saving moc: \(error)")
				closureError = error
			}
		}
		if let error = closureError {
			throw error
		}
	}

	/// Access to the Persistent Container
	lazy var container: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "RSSModels")
		container.loadPersistentStores(completionHandler: { _, error in
			if let error = error {
				fatalError("Failed to load persistent store: \(error)")
			}
		})
		// May need to be disabled if dataset is too large for performance reasons
		container.viewContext.automaticallyMergesChangesFromParent = true
		container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		return container
	}()

	var mainContext: NSManagedObjectContext {
		return container.viewContext
	}
}
